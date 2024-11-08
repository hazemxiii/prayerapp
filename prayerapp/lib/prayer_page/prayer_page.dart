import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:prayerapp/color_notifier.dart';
import 'package:prayerapp/global.dart';
import 'package:prayerapp/location_class/location_class.dart';
import 'package:prayerapp/prayer_page/custom_widgets.dart';
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
          future: getPrayerTime(context),
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

  Future<dynamic> getPrayerTime(BuildContext context) async {
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

      String normalDateAsString = getShortDate(date, false);
      String americanDateAsString = getShortDate(date, true);

      Map allPrayers = getAllPrayersFromPrefs();

      if (allPrayers.containsKey(americanDateAsString)) {
        daysTime.add(allPrayers[americanDateAsString]);
      } else {
        daysTime += (await fetchPrayerTimesFromApi(
            allPrayers, americanDateAsString, normalDateAsString));
      }
    }
    return daysTime;
  }

  Uri getApiUri(String normalDateAsString) {
    return Uri.https(
        "api.aladhan.com", "/v1/timingsByCity/$normalDateAsString", {
      "city": Prefs.prefs.getString(PrefsKeys.city),
      "country": Prefs.prefs.getString(PrefsKeys.country)
    });
  }

  Future<List> fetchPrayerTimesFromApi(Map allPrayers,
      String americanDateAsString, String normalDateAsString) async {
    List daysTime = [];
    Uri url = getApiUri(normalDateAsString);

    try {
      List dayWrap = await sendApiRequest(url, americanDateAsString);

      allPrayers[americanDateAsString] = dayWrap;
      allPrayers = removePrayerDayFromPrefs(allPrayers, americanDateAsString);

      Prefs.prefs.setString(PrefsKeys.prayers, jsonEncode(allPrayers));
      daysTime.add(dayWrap);
    } catch (e) {
      debugPrint("Error: ${e.toString()}");
    }
    return daysTime;
  }

  Future<List> sendApiRequest(Uri url, String americanDateAsString) async {
    var r = await http.get(url);
    if (r.statusCode == 200) {
      var data = jsonDecode(r.body)['data'];
      var timings = data['timings'];
      var hijri = data['date']['hijri'];
      var hirjiDay = hijri['day'];
      var hijriMonth = hijri['month']['en'];
      var hijriYear = hijri['year'];
      var hijriDate = "$hirjiDay - $hijriMonth - $hijriYear";

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

  Map removePrayerDayFromPrefs(Map allPrayers, String americanDateAsString) {
    String dateToRemove = getShortDate(
        DateTime.parse(americanDateAsString).subtract(const Duration(days: 30)),
        true);

    if (allPrayers.containsKey(dateToRemove)) {
      allPrayers.remove(dateToRemove);
    }

    return allPrayers;
  }

  Map getAllPrayersFromPrefs() {
    return jsonDecode(Prefs.prefs.getString(PrefsKeys.prayers)!);
  }

  void startNextPrayerTimer(dynamic data) {
    updateNextPrayerTime(data);
    timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      updateNextPrayerTime(data);
    });
  }

  void updateNextPrayerTime(data) async {
    Map nextPrayerData = getNextPrayer(false);

    String nextPrayerName = nextPrayerData["name"];
    String timeLeft = nextPrayerData["timeLeft"];
    String nextPrayerTime = nextPrayerData["time"];
    double remianingTimePercentage = nextPrayerData["percentageLeft"];
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

Map getNextPrayer(bool onlyDateAndName) {
  Map prayers = jsonDecode(Prefs.prefs.getString(PrefsKeys.prayers)!);

  if (prayers.isEmpty) {
    return {};
  }

  String todayDate = getShortDate(DateTime.now(), true);
  String yesterdayDate =
      getShortDate(DateTime.now().subtract(const Duration(days: 1)), true);
  String tomorrowDate =
      getShortDate(DateTime.now().add(const Duration(days: 1)), true);

  List yesterdayPrayers = prayers[yesterdayDate];
  List todayPrayers = prayers[todayDate];
  List tomorrowPrayers = prayers[tomorrowDate];

// initialise the next prayer as tomorrow's fajr and the last prayer as today's Isha'a
  DateTime nextPrayer = DateTime.parse("$tomorrowDate ${tomorrowPrayers[0]}");

  String nextPrayerName = Constants.prayerNames[0];

  DateTime lastPrayer = DateTime.parse("$todayDate ${todayPrayers[5]}");

  DateTime now = DateTime.now();
  for (int i = 0; i < todayPrayers.length - 2; i++) {
    DateTime prayer = DateTime.parse("$todayDate ${todayPrayers[i]}");
    if (!prayer.difference(now).isNegative) {
      nextPrayer = prayer;
      nextPrayerName =
          Constants.prayerNames[i] == "Dhuhr" && nextPrayer.weekday == 5
              ? "Jumu'a"
              : Constants.prayerNames[i];
      if (i != 0) {
        lastPrayer = DateTime.parse("$todayDate ${todayPrayers[i - 1]}");
      } else {
        lastPrayer = DateTime.parse("$yesterdayDate ${yesterdayPrayers[5]}");
      }
      break;
    }
  }
  if (onlyDateAndName) {
    Prefs.prefs.setString(PrefsKeys.nextPrayerTime, nextPrayer.toString());
    Prefs.prefs.setString(PrefsKeys.nextPrayerName, nextPrayerName);
    return {"name": nextPrayerName, "time": nextPrayer};
  }
  Duration diff = nextPrayer.difference(now);
  int dHour = diff.inHours;
  int dMinute = diff.inMinutes - dHour * 60;
  int dSecond = diff.inSeconds - dHour * 60 * 60 - dMinute * 60;

  String timeLeft =
      "${'$dHour'.padLeft(2, "0")}:${'$dMinute'.padLeft(2, "0")}:${'$dSecond'.padLeft(2, "0")}";

  int totalTimeBetweenPrayers = nextPrayer.difference(lastPrayer).inSeconds;

  double percentageTimeRemain = diff.inSeconds / totalTimeBetweenPrayers;

  TimeOfDay time = TimeOfDay.fromDateTime(nextPrayer);
  String hour = "${time.hourOfPeriod}".padLeft(2, "0");
  String minute = "${time.minute}".padLeft(2, "0");
  String period = time.period == DayPeriod.pm ? "PM" : "AM";

  return {
    "timeLeft": timeLeft,
    "name": nextPrayerName,
    "percentageLeft": percentageTimeRemain,
    "time": "$hour:$minute $period"
  };
}

String getShortDate(DateTime date, bool toAmerican) {
  // returns the normal or american date as a string
  int day = date.day;
  int month = date.month;
  int year = date.year;

  if (toAmerican) {
    String monthPad = "$month".padLeft(2, "0");
    String dayPad = "$day".padLeft(2, "0");
    return "$year-$monthPad-$dayPad";
  } else {
    return "$day-$month-$year";
  }
}
