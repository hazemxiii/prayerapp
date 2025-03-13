import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:prayerapp/color_notifier.dart';
import 'package:prayerapp/global.dart';
import 'package:prayerapp/location_class/location_class.dart';
import 'package:prayerapp/main.dart';
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
  final _loadedDaysNotifier = ValueNotifier<int>(0);
  final _todayBtnNotifier = ValueNotifier<bool>(false);
  DateTime startDate = DateTime.now();
  late DateTime oldStartDate;

  @override
  void initState() {
    super.initState();
    pageViewCont = PageController(initialPage: 1);
    pageViewCont.addListener(() {
      double page = pageViewCont.page ?? 0;
      // print(page);
      // print(page.round());
      DateTime now = DateTime.now();
      DateTime today =
          startDate.copyWith(year: now.year, month: now.month, day: now.day);
      if ((page >= 2.5 && !_todayBtnNotifier.value) ||
          (!today.isAtSameMomentAs(startDate))) {
        _todayBtnNotifier.value = true;
      } else if (page < 2.5 && _todayBtnNotifier.value) {
        _todayBtnNotifier.value = false;
      }
    });
    oldStartDate = startDate;
  }

  @override
  void dispose() {
    super.dispose();
    _loadedDaysNotifier.dispose();
    pageViewCont.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        FutureBuilder(
            future: loadPrayerTime(startDate),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.done &&
                  snapshot.data.isNotEmpty) {
                List prayerTimes = snapshot.data!['times'];
                if (prayerTimes.isNotEmpty) {
                  return Column(
                    children: [
                      PrayersScrollWidget(
                        changeDate: _pickDate,
                        displayDates: snapshot.data!['dateStrings'],
                        hijriDates: snapshot.data!['hijriDates'],
                        realDates: snapshot.data!['realDates'],
                        prayerTimes: prayerTimes,
                        pageViewCont: pageViewCont,
                      ),
                    ],
                  );
                } else {
                  return const NoInternetWidget();
                }
              } else {
                return Center(
                  child: SizedBox(
                    width: 300,
                    child: ValueListenableBuilder(
                        valueListenable: _loadedDaysNotifier,
                        builder: (context, v, _) {
                          return Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                "Loaded: $v of 31 days",
                                style: TextStyle(
                                    color: Palette.of(context).secColor,
                                    fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(
                                height: 10,
                              ),
                              LinearProgressIndicator(
                                value: v / 31,
                                color: Palette.of(context).secColor,
                              ),
                            ],
                          );
                        }),
                  ),
                );
              }
            }),
        _todayBtn()
      ],
    );
  }

  Widget _todayBtn() {
    return ValueListenableBuilder(
        valueListenable: _todayBtnNotifier,
        builder: (context, v, _) {
          return Positioned(
              bottom: v ? 10 : -100,
              right: v ? 10 : -100,
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 200),
                opacity: v ? 1 : 0,
                child: MaterialButton(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 15),
                    textColor: context.watch<ColorNotifier>().getMainC,
                    color: context.watch<ColorNotifier>().getSecC,
                    shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(50))),
                    child: const Text("Today"),
                    onPressed: () {
                      _onDateChanged(DateTime.now());
                    }),
              ));
        });
  }

  Future<dynamic> loadPrayerTime(DateTime startDate) async {
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
    for (int daysToAdd = 0; daysToAdd <= 31; daysToAdd++) {
      DateTime date = startDate.add(Duration(days: daysToAdd - 1));
      _loadedDaysNotifier.value = daysToAdd;
      Map data = await Db().getPrayersOfDay(date);
      List<Map> prayersOfDay = data['data'];
      String hijri = data['hijri'];
      if (prayersOfDay.isEmpty) {
        Map data = await _fetchPrayerTimesFromApi(date);
        prayersOfDay = data['data'] ?? [];
        hijri = data['hijri'] ?? "";
        DateTime now = DateTime.now();
        DateTime today =
            startDate.copyWith(year: now.year, month: now.month, day: now.day);
        if (prayersOfDay.isNotEmpty && today.isAtSameMomentAs(startDate)) {
          await Db().insertPrayerDay(prayersOfDay, data['lastDate']);
          await Db().insertHijriDate(date, hijri);
        }
        if (prayersOfDay.isEmpty) {
          continue;
        }
      }
      List dayTime = [];
      List oneDayRealDates = [];
      for (int i = 0; i < prayersOfDay.length; i++) {
        dayTime.add(prayersOfDay[i]['time']);
        oneDayRealDates.add(prayersOfDay[i]['date']);
      }
      realDates.add(oneDayRealDates);
      hijriDates.add(hijri);
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
    return Uri.https("api.aladhan.com", "/v1/timings/$normalDateAsString", {
      "latitude": Prefs.prefs.getDouble(PrefsKeys.la).toString(),
      "longitude": Prefs.prefs.getDouble(PrefsKeys.lo).toString(),
      "adjustment": Prefs.prefs.getInt(PrefsKeys.adjustment).toString()
    });
  }

  Future<Map> _fetchPrayerTimesFromApi(DateTime date) async {
    String americanDateAsString = CustomDateFormat.getShortDate(date, true);
    String normalDateAsString = CustomDateFormat.getShortDate(date, false);
    Uri url = _getApiUri(normalDateAsString);

    try {
      List dayWrap = await _sendApiRequest(url, americanDateAsString);
      return _preparePrayerDayRows(dayWrap);
      // if (date.difference(DateTime.now()).inDays <= 30) {
      //   Db().insertPrayerDay(dayWrap);
      //   return null;
      // } else {
      //   // return null;
      // }
    } catch (e) {
      debugPrint("Error: ${e.toString()}");
      return {};
    }
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

  Map _preparePrayerDayRows(List prayerDay) {
    int americanDateIndex = 7;
    List<Map> rows = [];
    DateTime lastPrayerOfDayDate =
        DateTime.parse("${prayerDay[americanDateIndex]} ${prayerDay[0]}");
    for (int i = 0; i < Constants.prayerNames.length; i++) {
      String prayerName = Constants.prayerNames[i];
      DateTime prayerDate =
          DateTime.parse("${prayerDay[americanDateIndex]} ${prayerDay[i]}");

      DateTime displayDate = prayerDate;

      if (prayerDate.isBefore(lastPrayerOfDayDate)) {
        prayerDate = prayerDate.add(const Duration(days: 1));
      }
      lastPrayerOfDayDate = prayerDate;
      rows.add({
        "prayerName": prayerName,
        "date": CustomDateFormat.getShortDate(prayerDate, true),
        "time":
            CustomDateFormat.timeToString(TimeOfDay.fromDateTime(prayerDate)),
        "displayDate": CustomDateFormat.getShortDate(displayDate, true),
      });
    }
    return {
      "data": rows,
      "hijri": prayerDay[6],
      "lastDate": lastPrayerOfDayDate
    };
  }

  void _pickDate() async {
    DateTime now = DateTime.now();
    DateTime? d = (await showDatePicker(
        context: context,
        firstDate: now.subtract(const Duration(days: 365)),
        lastDate: now.add(const Duration(days: 365))));
    if (d != null && context.mounted) {
      d = DateTime.utc(d.year, d.month, d.day);
      _onDateChanged(d);
    }
  }

  void _onDateChanged(DateTime newDate) {
    DateTime date =
        DateTime.utc(oldStartDate.year, oldStartDate.month, oldStartDate.day);
    newDate = DateTime.utc(newDate.year, newDate.month, newDate.day);
    int diffInDays = newDate.difference(date).inDays;
    if (diffInDays > 30 || diffInDays < -1) {
      setState(() {
        startDate = newDate;
        oldStartDate = startDate.copyWith();
        _todayBtnNotifier.value = true;
      });
    } else {
      pageViewCont.animateToPage(diffInDays >= 0 ? diffInDays + 1 : 0,
          duration: const Duration(milliseconds: 300), curve: Curves.linear);
    }
  }
}
