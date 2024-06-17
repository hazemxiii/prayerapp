import "dart:async";
import "dart:convert";
import "package:flutter/material.dart";
import 'package:http/http.dart' as http;
import "qiblah.dart";
import "package:shared_preferences/shared_preferences.dart";
import "tasbih.dart";
import "settings.dart";
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:provider/provider.dart';

class ColorPalette extends ChangeNotifier {
  /// The class is used to rebuild the pages when the color is changed
  Color main = Colors.lightBlue;
  Color second = Colors.white;
  Color back = Colors.lightBlue[50]!;

  // getters
  Color get getMainC => main;
  Color get getSecC => second;
  Color get getBackC => back;

  // setters
  void setMainC(Color c) {
    main = c;
    // to update everything that uses this class
    notifyListeners();
  }

  void setSecC(Color c) {
    second = c;
    notifyListeners();
  }

  void setBackC(Color c) {
    back = c;
    notifyListeners();
  }
}

void main() async {
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
  @override
  void initState() {
    super.initState();

    // the pages controlled by the bottom navbar
    pages = [
      const PrayerTime(),
      const Tasbih(),
      const Qiblah(),
      const Settings(),
    ];

    pagesDrawers = const [null, TasbihDrawer(), null, null];

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
    List pagesAppBars = const [
      null,
      {"title": ""},
      null,
      {"title": "Settings"},
    ];
    return Consumer<ColorPalette>(builder: (context, palette, child) {
      return Scaffold(
          appBar: pagesAppBars[activePage] != null
              ? AppBar(
                  backgroundColor: palette.getBackC,
                  foregroundColor: palette.getMainC,
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

class PrayerTime extends StatefulWidget {
  const PrayerTime({super.key});

  @override
  State<PrayerTime> createState() => PrayerTimeState();
}

class PrayerTimeState extends State<PrayerTime> {
  @override
  Widget build(BuildContext context) {
    ValueNotifier nextPrayerRemainingTimeNotifier =
        ValueNotifier(DateTime.now().toString());
    return Consumer<ColorPalette>(builder: (context, palette, child) {
      return FutureBuilder(
          future: getPrayerTime(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              if (snapshot.data!.length > 0) {
                Map nextPrayerData =
                    getNextPrayer(snapshot.data![0], snapshot.data![1]);

                String nextPrayerName = nextPrayerData["name"];
                String timeLeft = nextPrayerData["timeLeft"];
                String time = nextPrayerData["time"];
                double remianingTimePercentage =
                    nextPrayerData["percentageLeft"];
                nextPrayerRemainingTimeNotifier.value = timeLeft;

                Timer.periodic(const Duration(seconds: 1), (timer) {
                  Map nextPrayerData =
                      getNextPrayer(snapshot.data![0], snapshot.data![1]);

                  nextPrayerName = nextPrayerData["name"];
                  timeLeft = nextPrayerData["timeLeft"];
                  time = nextPrayerData["time"];
                  remianingTimePercentage = nextPrayerData["percentageLeft"];
                  nextPrayerRemainingTimeNotifier.value = timeLeft;
                });

                return Column(
                  children: [
                    Container(
                      height: MediaQuery.of(context).size.height / 4,
                      width: double.infinity,
                      decoration: BoxDecoration(
                          color: palette.getSecC,
                          borderRadius: const BorderRadius.only(
                              bottomLeft: Radius.circular(10),
                              bottomRight: Radius.circular(10))),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              Column(
                                children: [
                                  Text(
                                    nextPrayerName,
                                    style: TextStyle(
                                        color: palette.getMainC, fontSize: 20),
                                  ),
                                  Text(
                                    time,
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
                            itemCount: snapshot.data!.length,
                            itemBuilder: (context, i) {
                              int americanDateIndex = 7;
                              return PrayerDay(
                                  // the last index (7) contains the american day to format and display
                                  time: snapshot.data![i][americanDateIndex],
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
                      Text("No Internet Connection")
                    ],
                  ),
                );
              }
            } else {
              return Center(
                child: CircularProgressIndicator(
                  color: palette.getMainC,
                ),
              );
            }
          });
    });
  }
}

class PrayerDay extends StatefulWidget {
  final String time;
  final List times;

  const PrayerDay({
    super.key,
    required this.time,
    required this.times,
  });

  @override
  State<PrayerDay> createState() => _PrayerDayState();
}

class _PrayerDayState extends State<PrayerDay> {
  @override
  Widget build(BuildContext context) {
    String dhuhr = "Dhuhr";
    if (numbersDateToText(widget.time).contains("Friday")) {
      dhuhr = "Jumu'a";
    }
    return SingleChildScrollView(
      child: Container(
        padding: const EdgeInsets.fromLTRB(0, 10, 0, 0),
        child: Consumer<ColorPalette>(builder: (context, palette, child) {
          return Column(children: [
            // format the american date to Weekday, day month
            Text(numbersDateToText(widget.time),
                style: TextStyle(color: palette.getMainC)),
            // hijri date is at index 6
            Text(
              widget.times[6],
              style: TextStyle(color: palette.getMainC),
            ),
            // the prayers are in order [fajr,sunrise,dhuhr,asr,maghrib,isha]
            Prayer(
              name: "Fajr",
              time: DateTime.parse("${widget.time} ${widget.times[0]}"),
            ),
            Prayer(
              name: "Sunrise",
              time: DateTime.parse("${widget.time} ${widget.times[1]}"),
            ),
            Prayer(
              name: dhuhr,
              time: DateTime.parse("${widget.time} ${widget.times[2]}"),
            ),
            Prayer(
              name: "Asr",
              time: DateTime.parse("${widget.time} ${widget.times[3]}"),
            ),
            Prayer(
              name: "Maghrib",
              time: DateTime.parse("${widget.time} ${widget.times[4]}"),
            ),
            Prayer(
              name: "Isha'a",
              time: DateTime.parse("${widget.time} ${widget.times[5]}"),
            )
          ]);
        }),
      ),
    );
  }
}

class Prayer extends StatefulWidget {
  final String name;
  final DateTime time;

  const Prayer({
    super.key,
    required this.name,
    required this.time,
  });

  @override
  State<Prayer> createState() => _Prayer();
}

class _Prayer extends State<Prayer> {
  @override
  Widget build(BuildContext context) {
    int hour = widget.time.hour;
    int minutes = widget.time.minute;
    String dayPeriod = "AM";

    // change to PM if it's 12 or higher
    if (hour >= 12) {
      hour = hour - 12;
      dayPeriod = "PM";
    }

    // change to 12 if it's 0
    if (hour == 0) {
      hour = 12;
    }

    // get time left for the prayer
    Duration difference = widget.time.difference(DateTime.now());
    String diff = difference.toString();
    diff = diff.substring(0, diff.lastIndexOf(":"));
    if (difference.inHours >= 24 || difference.inHours <= -24) {
      diff = "";
    }
    // take only the hours and minutes

    return Consumer<ColorPalette>(builder: (context, palette, c) {
      return Column(
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
      DateTime dateO = DateTime.now().add(Duration(days: i));

      // get the american and normal dates
      String date = parseDate(dateO, false);
      String americanDate = parseDate(dateO, true);

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

            String dateToRemove = parseDate(
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

String parseDate(DateTime date, bool toAmerican) {
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
    Geolocator.openLocationSettings();
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

Map getNextPrayer(List todayPrayers, List tommorowPrayers) {
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
      nextPrayerName = prayerNames[i];
      if (i != 0) {
        lastPrayer = DateTime.parse("$todayDateString ${todayPrayers[i - 1]}");
      } else {
        lastPrayer = DateTime.parse("$tommorowDateString ${todayPrayers[5]}");
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
