import "dart:async";
import "dart:convert";
import "package:flutter/material.dart";
import 'package:http/http.dart' as http;
import "package:prayerapp/notification.dart";
import "qiblah.dart";
import "package:shared_preferences/shared_preferences.dart";
import "tasbih.dart";
import "settings.dart";
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:provider/provider.dart';
import 'package:workmanager/workmanager.dart';
import "global.dart";
// import 'package:flutter_local_notifications/flutter_local_notifications.dart';

@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    return Future.value(true);
  });
}

void main() async {
  // WidgetsFlutterBinding.ensureInitialized();
  // Workmanager().initialize(callbackDispatcher, isInDebugMode: true);

  runApp(ChangeNotifierProvider(
    create: (context) => ColorPalette(),
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
  late List<dynamic> pagesDrawers;
  late List pagesAppBars;
  @override
  void initState() {
    super.initState();

    // the pages controlled by the bottom navbar
    pages = [
      const PrayerTimeWidget(),
      const TasbihPage(),
      const QiblahPage(),
      const SettingsPage(),
    ];

    pagesDrawers = const [null, TasbihDrawer(), null, null];

    pagesAppBars = const [
      {"title": "", "height": 10.0},
      {"title": ""},
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
                  toolbarHeight: pagesAppBars[activePage]["height"],
                  backgroundColor: palette.getBackC,
                  foregroundColor: palette.getSecC,
                  title: Text(pagesAppBars[activePage]["title"]),
                  centerTitle: true,
                )
              : null,
          drawer: pagesDrawers[activePage],
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
          body: pages[activePage]);
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
  late Timer timer;
  String? nextPrayerName;
  String? timeLeft;
  String? time;
  double? remianingTimePercentage;

  @override
  void initState() {
    super.initState();

    pageViewCont = PageController(initialPage: 1);
    nextPrayerRemainingTimeNotifier = ValueNotifier(DateTime.now().toString());
  }

  @override
  void dispose() {
    super.dispose();
    pageViewCont.dispose();
    timer.cancel();
    // nextPrayerRemainingTimeNotifier.dispose();
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
                    Container(
                      padding: const EdgeInsets.all(10),
                      margin: const EdgeInsets.all(10),
                      width: double.infinity,
                      decoration: BoxDecoration(
                          color: palette.getSecC,
                          borderRadius:
                              const BorderRadius.all(Radius.circular(10))),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              Column(
                                children: [
                                  Text(
                                    nextPrayerName!,
                                    style: TextStyle(
                                        color: palette.getMainC, fontSize: 20),
                                  ),
                                  Text(
                                    time!,
                                    style: TextStyle(
                                        color: palette.getMainC, fontSize: 18),
                                  )
                                ],
                              ),
                              ValueListenableBuilder(
                                  valueListenable:
                                      nextPrayerRemainingTimeNotifier,
                                  builder: (context, value, child) {
                                    return Column(
                                      children: [
                                        CircularProgressIndicator(
                                          value: remianingTimePercentage,
                                          color: palette.getMainC,
                                        ),
                                        Text(value,
                                            style: TextStyle(
                                                color: palette.getMainC,
                                                fontSize: 18))
                                      ],
                                    );
                                  })
                            ],
                          ),
                        ],
                      ),
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
                                  // the last index (7) contains the american day to format and display
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

  void updateNextPrayerTime(data) {
    Map nextPrayerData = getNextPrayer(data![0], data![1], data![2]);

    nextPrayerName = nextPrayerData["name"];
    timeLeft = nextPrayerData["timeLeft"];
    time = nextPrayerData["time"];
    remianingTimePercentage = nextPrayerData["percentageLeft"];
    nextPrayerRemainingTimeNotifier.value = timeLeft;
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
            Text(numbersDateToText(widget.dateString),
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
    List prayerNames = ["Fajr", "Sunrise", "Dhuhr", "Asr", "Maghrib", "Isha'a"];
    for (int i = 0; i < prayerNames.length; i++) {
      var prayer = prayerNames[i];
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
    // take only the hours and minutes

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
  await SharedPreferences.getInstance().then((spref) async {
    // loop on the next 30 days
    for (int i = 0; i < 30; i++) {
      DateTime dateO = DateTime.now().add(Duration(days: i - 1));

      // get the american and normal dates
      String date = dateToString(dateO, false);
      String americanDate = dateToString(dateO, true);

      // if there's no data, create one
      if (!spref.containsKey("prayers")) {
        spref.setString("prayers", jsonEncode({}));
      }

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

            String dateToRemove = dateToString(
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
  });
  return daysTime;
}

String numbersDateToText(String sdate) {
  // converts a date from numbers to weekday, day month
  DateTime dd = DateTime.parse(sdate);
  String day = "";
  int date = dd.day;

  switch (dd.weekday) {
    case 1:
      day = "Monday";
      break;
    case 2:
      day = "Tuesday";
      break;
    case 3:
      day = "Wednesday";
      break;
    case 4:
      day = "Thursday";
      break;
    case 5:
      day = "Friday";
      break;
    case 6:
      day = "Saturday";
      break;
    case 7:
      day = "Sunday";
      break;
  }

  var monthDict = {
    1: "January",
    2: "February",
    3: "March",
    4: "April",
    5: "May",
    6: "June",
    7: "July",
    8: "August",
    9: "September",
    10: "October",
    11: "November",
    12: "December"
  };
  String? month = monthDict[dd.month];

  return "$day, $date $month";
}

String dateToString(DateTime date, bool toAmerican) {
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

Future<List> getPosition(bool coordinates) async {
  bool serviceEnabled;
  LocationPermission permission;

  serviceEnabled = await Geolocator.isLocationServiceEnabled();
  if (!serviceEnabled) {
    // return Future.error('Location services are disabled.');
    return [];
  }

  permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied) {
      // return Future.error('Location permissions are denied');
      return [];
    }
  }

  if (permission == LocationPermission.deniedForever) {
    // return Future.error(
    //     'Location permissions are permanently denied, we cannot request permissions.');
    return [];
  }
  Position position = await Geolocator.getCurrentPosition();
  if (coordinates) {
    return [position.latitude, position.longitude];
  }

  List address = [];
  try {
    await placemarkFromCoordinates(position.latitude, position.longitude)
        .then((data) {
      address.add(data[0].toJson()['country']);
      address.add(data[0].toJson()['administrativeArea']);
    });
  } catch (e) {
    //
  }

  return address;
}

Map getNextPrayer(
    List yesterdayPrayers, List todayPrayers, List tommorowPrayers) {
  String yesterdayPrayersString = yesterdayPrayers[yesterdayPrayers.length - 1];
  String todayDateString = todayPrayers[todayPrayers.length - 1];
  String tommorowDateString = tommorowPrayers[tommorowPrayers.length - 1];

  List prayerNames = ["Fajr", "Sunrise", "Dhuhr", "Asr", "Maghrib", "Isha'a"];

// initialise the next prayer as tomorrow's fajr and the last prayer as today's Isha'a
  DateTime nextPrayer =
      DateTime.parse("$tommorowDateString ${tommorowPrayers[0]}");

  String nextPrayerName = prayerNames[0];

  DateTime lastPrayer = DateTime.parse("$todayDateString ${todayPrayers[5]}");

  DateTime now = DateTime.now();
  for (int i = 0; i < todayPrayers.length - 2; i++) {
    DateTime prayer = DateTime.parse("$todayDateString ${todayPrayers[i]}");
    if (!prayer.difference(now).isNegative) {
      nextPrayer = prayer;
      nextPrayerName = prayerNames[i] == "Dhuhr" && nextPrayer.weekday == 5
          ? "Jumu'a"
          : prayerNames[i];
      if (i != 0) {
        lastPrayer = DateTime.parse("$todayDateString ${todayPrayers[i - 1]}");
      } else {
        lastPrayer =
            DateTime.parse("$yesterdayPrayersString ${yesterdayPrayers[5]}");
      }
      break;
    }
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
