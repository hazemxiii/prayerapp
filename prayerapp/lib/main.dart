import "dart:async";
import "dart:convert";
import "dart:io";
import "package:flutter/material.dart";
import 'package:http/http.dart' as http;
import "package:prayerapp/notification.dart";
import "package:prayerapp/tasbih_notifier.dart";
import "qiblah.dart";
import "package:shared_preferences/shared_preferences.dart";
import "tasbih.dart";
import "settings.dart";
import 'package:provider/provider.dart';
import "global.dart";
import "service.dart";

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (Platform.isAndroid) {
    await initializeService();
  }
  await setPrefs();
  await Constants.initPrefs();
  runApp(MultiProvider(
    providers: [
      ChangeNotifierProvider(create: (context) => ColorPalette()),
      ChangeNotifierProvider(create: (context) => TasbihNotifier())
    ],
    child: const App(),
  ));
}

class App extends StatelessWidget {
  const App({super.key});
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(home: MainPage());
  }
}

class MainPage extends StatefulWidget {
  const MainPage({super.key});
  @override
  State<MainPage> createState() => _MainPage();
}

class _MainPage extends State<MainPage> {
  int activePage = 0;
  // the pages controlled by the bottom nav bar
  late List<Widget> pages;
  late List pagesAppBars;
  @override
  void initState() {
    super.initState();

    // the pages controlled by the bottom navbar
    pages = [
      const PrayerTimeWidget(),
      const TasbihPage(),
      // const QiblahPage(),
      const Placeholder(),
      const SettingsPage(),
    ];

    pagesAppBars = [
      null,
      null,
      null,
      {"title": "Settings"},
    ];

    // get the colors from the database and update them
    getColors().then((data) {
      Provider.of<ColorPalette>(context, listen: false)
          .setMainC(hexToColor(data[0]));

      Provider.of<ColorPalette>(context, listen: false)
          .setSecC(hexToColor(data[1]));

      Provider.of<ColorPalette>(context, listen: false)
          .setBackC(hexToColor(data[2]));
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ColorPalette>(builder: (context, palette, child) {
      return Scaffold(
          appBar: pagesAppBars[activePage] != null
              ? AppBar(
                  backgroundColor: palette.getBackC,
                  foregroundColor: palette.getSecC,
                  title: Text(pagesAppBars[activePage]["title"]),
                  centerTitle: true,
                )
              : null,
          bottomNavigationBar: SizedBox(
            height: 40,
            child: BottomNavigationBar(
              currentIndex: activePage,
              backgroundColor: palette.getSecC,
              selectedItemColor: palette.getMainC,
              unselectedItemColor: palette.getBackC,
              iconSize: 14,
              selectedFontSize: 10,
              unselectedFontSize: 10,
              onTap: (v) {
                setState(() {
                  activePage = v;
                });
              },
              items: [
                BottomNavigationBarItem(
                    icon: const Icon(Icons.alarm),
                    label: "Prayer Times",
                    backgroundColor: palette.getSecC),
                BottomNavigationBarItem(
                    icon: const Icon(Icons.circle),
                    label: "Tasbih",
                    backgroundColor: palette.getSecC),
                BottomNavigationBarItem(
                    icon: const Icon(Icons.mosque),
                    label: "Qiblah",
                    backgroundColor: palette.getSecC),
                BottomNavigationBarItem(
                    icon: const Icon(Icons.settings),
                    label: "Settings",
                    backgroundColor: palette.getSecC)
              ],
            ),
          ),
          backgroundColor: palette.getBackC,
          body: SafeArea(child: pages[activePage]));
    });
  }
}

class PrayerTimeWidget extends StatefulWidget {
  const PrayerTimeWidget({super.key});

  @override
  State<PrayerTimeWidget> createState() => PrayerTimeWidgetState();
}

class PrayerTimeWidgetState extends State<PrayerTimeWidget> {
  late PageController pageViewCont;
  late ValueNotifier nextPrayerRemainingTimeNotifier;
  Timer? timer;

  @override
  void initState() {
    super.initState();
    pageViewCont = PageController(initialPage: 1);
    nextPrayerRemainingTimeNotifier = ValueNotifier({
      "timeLeft": DateTime.now().toString(),
      "prayerName": "",
      "time": "",
      "remainPercentage": 0
    });
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
          future: getPrayerTime(),
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
                    Expanded(
                      child: Container(
                        color: palette.getBackC,
                        width: double.infinity,
                        child: PageView.builder(
                            controller: pageViewCont,
                            itemCount: snapshot.data!.length,
                            itemBuilder: (context, i) {
                              int americanDateIndex = 7;

                              return PrayerDayWidget(
                                  dateString: snapshot.data![i]
                                      [americanDateIndex],
                                  times: snapshot.data[i]);
                            }),
                      ),
                    )
                  ],
                );
              } else {
                return const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Icon(Icons.warning,
                          size: 40, color: Color.fromRGBO(255, 0, 0, 1)),
                      Text(
                        "No Internet Connection",
                        style: TextStyle(color: Colors.orange),
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
    Map nextPrayerData = await getNextPrayer(false);

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

class PrayerDayWidget extends StatefulWidget {
  // date as a string
  final String dateString;
  final List times;
  const PrayerDayWidget({
    super.key,
    required this.dateString,
    required this.times,
  });

  @override
  State<PrayerDayWidget> createState() => _PrayerDayWidgetState();
}

class _PrayerDayWidgetState extends State<PrayerDayWidget> {
  DateTime? lastPrayerOfDay;
  @override
  Widget build(BuildContext context) {
    lastPrayerOfDay = DateTime.parse("${widget.dateString} ${widget.times[0]}");

    return SingleChildScrollView(
      child: Container(
        padding: const EdgeInsets.fromLTRB(0, 10, 0, 0),
        child: Consumer<ColorPalette>(builder: (context, palette, child) {
          return Column(children: [
            // format the american date to Weekday, day month
            Text(getEnglishLanguageDate(widget.dateString),
                style: TextStyle(color: palette.getSecC)),
            // hijri date is at index 6
            Text(
              widget.times[6],
              style: TextStyle(color: palette.getSecC),
            ),
            ...prayerDayWidgetBuilder()
          ]);
        }),
      ),
    );
  }

  List prayerDayWidgetBuilder() {
    List prayersWidgets = [];
    for (int i = 0; i < Constants.prayerNames.length; i++) {
      var prayer = Constants.prayerNames[i];
      DateTime date = DateTime.parse("${widget.dateString} ${widget.times[i]}");
      if (date.difference(lastPrayerOfDay!).isNegative) {
        date = date.add(const Duration(days: 1));
      }

      lastPrayerOfDay = date;

      prayersWidgets.add(PrayerWidget(
        name: prayer == "Dhuhr" && date.weekday == 5 ? "Jumu'a" : prayer,
        time: date,
      ));
    }
    return prayersWidgets;
  }
}

class PrayerWidget extends StatefulWidget {
  final String name;
  final DateTime time;

  const PrayerWidget({
    super.key,
    required this.name,
    required this.time,
  });

  @override
  State<PrayerWidget> createState() => _PrayerWidgetState();
}

class _PrayerWidgetState extends State<PrayerWidget> {
  Timer? timer;
  Future? firstUpdate;
  @override
  void initState() {
    firstUpdate =
        Future.delayed(Duration(seconds: 60 - DateTime.now().second), () {
      setState(() {});
      timer = Timer.periodic(const Duration(minutes: 1), (timer) {
        setState(() {});
      });
    }).catchError((e) {});
    super.initState();
  }

  @override
  void dispose() {
    if (timer != null) {
      timer!.cancel();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    TimeOfDay timeOfDay = TimeOfDay.fromDateTime(widget.time);
    int hour = timeOfDay.hourOfPeriod;
    int minutes = timeOfDay.minute;
    String dayPeriod = timeOfDay.period == DayPeriod.am ? "AM" : "PM";

    // get time left for the prayer
    Duration difference = widget.time.difference(DateTime.now());
    String diff = difference.toString();
    diff = diff.substring(0, diff.lastIndexOf(":"));
    if (difference.inHours >= 24 || difference.inHours <= -24) {
      diff = "";
    }

    return Consumer<ColorPalette>(builder: (context, palette, c) {
      return InkWell(
        onLongPress: () {
          Navigator.of(context).push(MaterialPageRoute(
              builder: (context) =>
                  PrayerNotificationSettingsPage(prayer: widget.name)));
        },
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              margin: const EdgeInsets.all(5),
              decoration: BoxDecoration(
                  color: palette.getSecC,
                  borderRadius: const BorderRadius.all(Radius.circular(10))),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 3,
                        height: 20,
                        color: palette.getMainC,
                        margin: const EdgeInsets.fromLTRB(0, 0, 10, 0),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.name,
                            style: TextStyle(color: palette.getMainC),
                          ),
                          Text("$hour:${"$minutes".padLeft(2, "0")} $dayPeriod",
                              style: TextStyle(color: palette.getMainC))
                        ],
                      ),
                    ],
                  ),
                  Text(diff, style: TextStyle(color: palette.getMainC))
                ],
              ),
            ),
          ],
        ),
      );
    });
  }
}

// functions
Future<dynamic> getPrayerTime() async {
  // return the 30 days to the user

  List daysTime = [];
  // loop on the next 30 days
  for (int i = 0; i < 30; i++) {
    DateTime dateO = DateTime.now().add(Duration(days: i - 1));
    SharedPreferences spref = Constants.prefs!;

    // get the american and normal dates
    String date = getShortDate(dateO, false);
    String americanDate = getShortDate(dateO, true);

    String? country;
    String? city;

    if (!spref.containsKey("city")) {
      List data = await getPosition(false);
      if (data.isEmpty) {
        return [];
      }
      country = data[0];
      city = data[1];

      spref.setString("city", city!);
      spref.setString("country", country!);
    }
    if (!spref.containsKey("prayers")) {
      spref.setString("prayers", jsonEncode({}));
    }
    // get the old data
    Map prayerDays = jsonDecode(spref.getString("prayers")!);

    // if the date is saved on the device, add it to be returned later, else, get it from the API

    if (prayerDays.containsKey(americanDate)) {
      daysTime.add(prayerDays[americanDate]);
    } else {
      var url = Uri.https("api.aladhan.com", "/v1/timingsByCity/$date", {
        "city": spref.getString("city"),
        "country": spref.getString("country")
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
            americanDate
          ];

          // add the date to the preferences and remove the date behind it with 30 days
          prayerDays[americanDate] = dayWrap;

          String dateToRemove = getShortDate(
              DateTime.parse(americanDate).subtract(const Duration(days: 30)),
              true);

          if (prayerDays.containsKey(dateToRemove)) {
            prayerDays.remove(dateToRemove);
          }

          spref.setString("prayers", jsonEncode(prayerDays));
          daysTime.add(dayWrap);
        }
      } catch (e) {
        // print(e);
      }
    }
  }
  return daysTime;
}

Future<Map> getNextPrayer(bool onlyDateAndName) async {
  if (!Constants.prefs!.containsKey("prayers")) {
    return {};
  }
  Map prayers = jsonDecode(Constants.prefs!.getString("prayers")!);

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
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString("nextPrayerTime", nextPrayer.toString());
    prefs.setString("nextPrayerName", nextPrayerName);
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
