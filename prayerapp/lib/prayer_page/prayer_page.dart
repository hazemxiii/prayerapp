import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:prayerapp/global.dart';
import 'package:prayerapp/location_class/location_class.dart';
import 'package:prayerapp/prayer_page/prayers_widgets.dart';
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
    return Consumer<ColorPalette>(builder: (context, palette, child) {
      return FutureBuilder(
          future: getPrayerTime(context),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done &&
                snapshot.hasData) {
              if (snapshot.data!.length > 0) {
                updateNextPrayerTime(snapshot.data);
                timer = Timer.periodic(const Duration(seconds: 1), (timer) {
                  updateNextPrayerTime(snapshot.data);
                });

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
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Icon(Icons.warning, size: 40, color: palette.getMainC),
                      Text(
                        "No Internet Connection",
                        style: TextStyle(color: palette.getMainC),
                      )
                    ],
                  ),
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

class PrayersScrollWidget extends StatelessWidget {
  final Color color;
  final List prayersData;
  const PrayersScrollWidget(
      {super.key, required this.color, required this.prayersData});

  @override
  Widget build(BuildContext context) {
    PageController pageViewCont = PageController(initialPage: 1);
    return Expanded(
      child: Container(
        color: color,
        width: double.infinity,
        child: PageView.builder(
            controller: pageViewCont,
            itemCount: prayersData.length,
            itemBuilder: (context, i) {
              int americanDateIndex = 7;
              return PrayerDayWidget(
                  dateString: prayersData[i][americanDateIndex],
                  times: prayersData[i]);
            }),
      ),
    );
  }
}

class NextPrayerWidget extends StatefulWidget {
  final ValueNotifier nextPrayerRemainingTimeNotifier;
  const NextPrayerWidget({
    super.key,
    required this.nextPrayerRemainingTimeNotifier,
  });

  @override
  State<NextPrayerWidget> createState() => _NextPrayerWidgetState();
}

// TODO: clean this file
class _NextPrayerWidgetState extends State<NextPrayerWidget> {
  @override
  Widget build(BuildContext context) {
    return Consumer<ColorPalette>(builder: (context, palette, snapshot) {
      return ValueListenableBuilder(
          valueListenable: widget.nextPrayerRemainingTimeNotifier,
          builder: (context, value, child) {
            return Container(
              padding: const EdgeInsets.all(10),
              margin: const EdgeInsets.all(10),
              width: double.infinity,
              decoration: BoxDecoration(
                  color: palette.getSecC,
                  borderRadius: const BorderRadius.all(Radius.circular(10))),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Column(
                        children: [
                          Text(
                            value['prayerName'],
                            style: TextStyle(
                                color: palette.getMainC, fontSize: 20),
                          ),
                          Text(
                            value['time'],
                            style: TextStyle(
                                color: palette.getMainC, fontSize: 18),
                          )
                        ],
                      ),
                      Column(
                        children: [
                          CircularProgressIndicator(
                            value: value['remainPercentage'].toDouble(),
                            color: palette.getMainC,
                          ),
                          Text(value["timeLeft"],
                              style: TextStyle(
                                  color: palette.getMainC, fontSize: 18))
                        ],
                      )
                    ],
                  ),
                ],
              ),
            );
          });
    });
  }
}

// functions
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

    // get the american and normal dates
    String normalDateAsString = getShortDate(date, false);
    String americanDateAsString = getShortDate(date, true);

    // ignore: use_build_context_synchronously

    Map allPrayers = getAllPrayersFromPrefs();

    // if the date is saved on the device, add it to be returned later, else, get it from the API
    if (allPrayers.containsKey(americanDateAsString)) {
      daysTime.add(allPrayers[americanDateAsString]);
    } else {
      daysTime = await fetchPrayerTimesFromApi(
          allPrayers, americanDateAsString, normalDateAsString);
    }
  }
  return daysTime;
}

Map getAllPrayersFromPrefs() {
  if (!Prefs.prefs.containsKey("prayers")) {
    Prefs.prefs.setString("prayers", jsonEncode({}));
  }
  return jsonDecode(Prefs.prefs.getString("prayers")!);
}

Future<List> fetchPrayerTimesFromApi(Map allPrayers,
    String americanDateAsString, String normalDateAsString) async {
  List daysTime = [];
  var url =
      Uri.https("api.aladhan.com", "/v1/timingsByCity/$normalDateAsString", {
    "city": Prefs.prefs.getString("city"),
    "country": Prefs.prefs.getString("country")
  });

  try {
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

      allPrayers[americanDateAsString] = dayWrap;
      allPrayers = removePrayerDayFromPrefs(allPrayers, americanDateAsString);

      Prefs.prefs.setString("prayers", jsonEncode(allPrayers));
      daysTime.add(dayWrap);
    }
  } catch (e) {
    // print(e);
  }
  return daysTime;
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

void setAddressInPrefs(String country, String city) {
  Prefs.prefs.setString("city", city);
  Prefs.prefs.setString("country", country);
}

Map getNextPrayer(bool onlyDateAndName) {
  if (!Prefs.prefs.containsKey("prayers")) {
    return {};
  }
  Map prayers = jsonDecode(Prefs.prefs.getString("prayers")!);

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
    Prefs.prefs.setString("nextPrayerTime", nextPrayer.toString());
    Prefs.prefs.setString("nextPrayerName", nextPrayerName);
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
