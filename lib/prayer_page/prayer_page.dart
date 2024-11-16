import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:prayerapp/global.dart';
import 'package:prayerapp/location_class/location_class.dart';
import 'package:prayerapp/main.dart';
import 'package:prayerapp/prayer_page/custom_widgets.dart';
import 'package:prayerapp/sqlite.dart';

// TODO: new icons

class PrayerTimePage extends StatefulWidget {
  const PrayerTimePage({super.key});

  @override
  State<PrayerTimePage> createState() => PrayerTimePageState();
}

class PrayerTimePageState extends State<PrayerTimePage> {
  late PageController pageViewCont;

  @override
  void initState() {
    super.initState();
    pageViewCont = PageController(initialPage: 1);
  }

  @override
  void dispose() {
    super.dispose();
    pageViewCont.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: loadPrayerTime(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done &&
              snapshot.hasData) {
            List prayerTimes = snapshot.data!['times'];

            if (prayerTimes.isNotEmpty) {
              return Column(
                children: [
                  PrayersScrollWidget(
                    displayDates: snapshot.data!['dateStrings'],
                    hijriDates: snapshot.data!['hijriDates'],
                    realDates: snapshot.data!['realDates'],
                    prayerTimes: prayerTimes,
                  ),
                ],
              );
            } else {
              return const NoInternetWidget();
            }
          } else {
            return Center(
              child: CircularProgressIndicator(
                color: Palette.of(context).secColor,
              ),
            );
          }
        });
  }

  Future<dynamic> loadPrayerTime() async {
    List timesForAllDays = [];
    List realDates = [];
    List displayDates = [];
    List hijriDates = [];
    if (LocationHandler.location.isLocationEmpty()) {
      await LocationHandler.location.getFromGps(context);
    }
    if (LocationHandler.location.isLocationEmpty()) {
      // ignore: use_build_context_synchronously
      LocationHandler.location.askForManualInput(context);
      return [];
    }
    for (int daysToAdd = 0; daysToAdd < 30; daysToAdd++) {
      DateTime date = DateTime.now().add(Duration(days: daysToAdd - 1));
      List<Map> prayersOfDay = await Db().getPrayersOfDay(date);
      if (prayersOfDay.isEmpty) {
        await _fetchPrayerTimesFromApi(date);
        prayersOfDay = await Db().getPrayersOfDay(date);
      }
      List dayTime = [];
      List oneDayRealDates = [];
      for (int i = 0; i < prayersOfDay.length; i++) {
        dayTime.add(prayersOfDay[i]['time']);
        oneDayRealDates.add(prayersOfDay[i]['date']);
      }
      realDates.add(oneDayRealDates);
      hijriDates.add(await Db().getHijriDate(date));
      displayDates.add(prayersOfDay[0]["displayDate"]);
      timesForAllDays.add(dayTime);
    }

    final r = {
      "times": timesForAllDays,
      "dateStrings": displayDates,
      "hijriDates": hijriDates,
      "realDates": realDates
    };
    return r;
  }

  Uri _getApiUri(String normalDateAsString) {
    return Uri.https(
        "api.aladhan.com", "/v1/timingsByCity/$normalDateAsString", {
      "city": Prefs.prefs.getString(PrefsKeys.city),
      "country": Prefs.prefs.getString(PrefsKeys.country),
      "adjustment": Prefs.prefs.getInt(PrefsKeys.adjustment).toString()
    });
  }

  Future<List> _fetchPrayerTimesFromApi(DateTime date) async {
    String americanDateAsString = CustomDateFormat.getShortDate(date, true);
    String normalDateAsString = CustomDateFormat.getShortDate(date, false);
    List daysTime = [];
    Uri url = _getApiUri(normalDateAsString);

    try {
      List dayWrap = await _sendApiRequest(url, americanDateAsString);
      Db().insertPrayerDay(dayWrap);

      daysTime.add(dayWrap);
    } catch (e) {
      debugPrint("Error: ${e.toString()}");
    }
    return daysTime;
  }

  Future<List> _sendApiRequest(Uri url, String americanDateAsString) async {
    var r = await http.get(url);
    if (r.statusCode == 200) {
      var data = jsonDecode(r.body)['data'];
      var timings = data['timings'];
      String hijriDate = _constructHijriDate(data['date']['hijri']);

      List dayWrap = [
        timings['Fajr'],
        timings['Sunrise'],
        timings['Dhuhr'],
        timings['Asr'],
        timings['Maghrib'],
        timings['Isha'],
        hijriDate,
        americanDateAsString
      ];
      return dayWrap;
    } else {
      throw "Failed To Send Request";
    }
  }

  String _constructHijriDate(Map hijriDate) {
    String day = hijriDate['day'];
    String month = hijriDate['month']['en'];
    String year = hijriDate['year'];
    return "$day - $month - $year";
  }
}
