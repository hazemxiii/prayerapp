import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:prayerapp/color_notifier.dart';
import 'package:prayerapp/global.dart';
import 'package:prayerapp/location_class/location_class.dart';
import 'package:prayerapp/prayer_page/custom_widgets.dart';
import 'package:prayerapp/sqlite.dart';
import 'package:provider/provider.dart';

class PrayerTimePage extends StatefulWidget {
  const PrayerTimePage({super.key});

  @override
  State<PrayerTimePage> createState() => PrayerTimePageState();
}

class PrayerTimePageState extends State<PrayerTimePage> {
  late PageController pageViewCont;
  late ValueNotifier nextPrayerRemainingTimeNotifier;
  Timer? timer;

  @override
  void initState() {
    super.initState();
    pageViewCont = PageController(initialPage: 1);
    nextPrayerRemainingTimeNotifier = initNextPrayerNotifier();
  }

  @override
  void dispose() {
    super.dispose();
    pageViewCont.dispose();
    if (timer != null) {
      timer!.cancel();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ColorNotifier>(builder: (context, palette, child) {
      return FutureBuilder(
          future: loadPrayerTime(context),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done &&
                snapshot.hasData) {
              if (snapshot.data!.length > 0) {
                startNextPrayerTimer(snapshot.data);

                return Column(
                  children: [
                    NextPrayerWidget(
                      nextPrayerRemainingTimeNotifier:
                          nextPrayerRemainingTimeNotifier,
                    ),
                    PrayersScrollWidget(
                      color: palette.getBackC,
                      prayersData: snapshot.data!,
                    ),
                  ],
                );
              } else {
                return NoInternetWidget(
                  color: palette.getMainC,
                );
              }
            } else {
              return Center(
                child: CircularProgressIndicator(
                  color: palette.getSecC,
                ),
              );
            }
          });
    });
  }

  Future<dynamic> loadPrayerTime(BuildContext context) async {
    List daysTime = [];
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
      if (prayersOfDay.isNotEmpty) {
        List day = [];
        for (int i = 0; i < prayersOfDay.length; i++) {
          day.add(prayersOfDay[i]['time']);
        }
        day.add("");
        day.add(prayersOfDay[0]["displayDate"]);
        daysTime.add(day);
      } else {
        daysTime += (await _fetchPrayerTimesFromApi(date));
      }
    }
    return daysTime;
  }

  Uri _getApiUri(String normalDateAsString) {
    return Uri.https(
        "api.aladhan.com", "/v1/timingsByCity/$normalDateAsString", {
      "city": Prefs.prefs.getString(PrefsKeys.city),
      "country": Prefs.prefs.getString(PrefsKeys.country)
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
      // var hijri = data['date']['hijri'];
      // var hirjiDay = hijri['day'];
      // var hijriMonth = hijri['month']['en'];
      // var hijriYear = hijri['year'];
      // var hijriDate = "$hirjiDay - $hijriMonth - $hijriYear";

      List dayWrap = [
        timings['Fajr'],
        timings['Sunrise'],
        timings['Dhuhr'],
        timings['Asr'],
        timings['Maghrib'],
        timings['Isha'],
        "",
        americanDateAsString
      ];
      return dayWrap;
    } else {
      throw "Failed To Send Request";
    }
  }

  void startNextPrayerTimer(dynamic data) {
    updateNextPrayerTime(data);
    timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      updateNextPrayerTime(data);
    });
  }

  void updateNextPrayerTime(data) async {
    Map nextPrayerData = await Db().getNextPrayer();
    String nextPrayerName = nextPrayerData["name"] ?? "";
    String timeLeft = nextPrayerData["timeLeft"] ?? "";
    String nextPrayerTime = nextPrayerData["time"] ?? "";
    double remianingTimePercentage = nextPrayerData["percentageLeft"] ?? 0;
    nextPrayerRemainingTimeNotifier.value = {
      "timeLeft": timeLeft,
      "prayerName": nextPrayerName,
      "time": nextPrayerTime,
      "remainPercentage": remianingTimePercentage
    };
  }

  ValueNotifier initNextPrayerNotifier() {
    return ValueNotifier({
      "timeLeft": DateTime.now().toString(),
      "prayerName": "",
      "time": "",
      "remainPercentage": 0
    });
  }
}
