import "dart:convert";
import "dart:math";
import "package:flutter/material.dart";
import 'package:http/http.dart' as http;
import "package:shared_preferences/shared_preferences.dart";
import "tasbih.dart";
import "settings.dart";

void main() {
  runApp(const App());
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
  Color mainColor = Colors.lightBlue;
  Color secondaryColor = Colors.white;
  Color backColor = Colors.lightBlue[50]!;
  // the pages controlled by the bottom nav bar
  late List<Widget> pages;
  late List<dynamic> pagesDrawers;
  late GlobalKey<ScaffoldState> scaffoldKey;
  @override
  void initState() {
    super.initState();

    scaffoldKey = GlobalKey();

    // the pages controlled by the bottom navbar
    pages = [
      Column(
        children: [
          Container(
            decoration: const BoxDecoration(
                borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(10),
                    bottomRight: Radius.circular(10)),
                image: DecorationImage(
                  image: AssetImage("images/masjid.jpeg"),
                  fit: BoxFit.cover,
                )),
            height: 250,
            width: double.infinity,
          ),
          Expanded(
            child: FutureBuilder(
              future: getPrayerTime(),
              builder: (context, snapshot) {
                // when the data loads, show it. else show loading
                if (snapshot.connectionState == ConnectionState.done) {
                  // if there's data, display. else display no internet
                  if (snapshot.data!.length > 0) {
                    return PageView.builder(
                        itemCount: snapshot.data!.length,
                        itemBuilder: (context, i) {
                          return PrayerDay(
                              dateColor: mainColor,
                              color: secondaryColor,
                              // the last index (7) contains the american day to format and display
                              time: snapshot.data![i][7],
                              times: snapshot.data[i]);
                        });
                  } else {
                    return const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Icon(Icons.warning,
                            size: 40, color: Color.fromRGBO(255, 0, 0, 1)),
                        Text("No Internet Connection")
                      ],
                    );
                  }
                } else {
                  return const Center(child: CircularProgressIndicator());
                }
              },
            ),
          )
        ],
      ),
      Tasbih(
        scaffoldKey: scaffoldKey,
      ),
      const Settings()
    ];

    pagesDrawers = const [Placeholder(), TasbihDrawer(), Placeholder()];
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    getColors().then((data) {
      setState(() {
        mainColor = hexToColor(data[0]);
        secondaryColor = hexToColor(data[1]);
        backColor = hexToColor(data[2]);
      });
    });
    return Scaffold(
        drawer: pagesDrawers[activePage],
        key: scaffoldKey,
        bottomNavigationBar: SizedBox(
          height: 40,
          child: BottomNavigationBar(
            currentIndex: activePage,
            backgroundColor: secondaryColor,
            selectedItemColor: mainColor,
            unselectedItemColor: backColor,
            iconSize: 14,
            selectedFontSize: 10,
            unselectedFontSize: 10,
            onTap: (v) {
              setState(() {
                activePage = v;
              });
            },
            items: const [
              BottomNavigationBarItem(
                  icon: Icon(Icons.alarm), label: "Prayer Times"),
              BottomNavigationBarItem(
                icon: Icon(Icons.circle),
                label: "Tasbih",
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.settings),
                label: "Settings",
              )
            ],
          ),
        ),
        backgroundColor: backColor,
        body: pages[activePage]);
  }
}

class PrayerDay extends StatefulWidget {
  final String time;
  final List times;
  final Color color;
  final Color dateColor;
  const PrayerDay(
      {super.key,
      required this.time,
      required this.times,
      required this.color,
      required this.dateColor});

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
        // color: Colors.lightBlue[50],
        padding: const EdgeInsets.fromLTRB(0, 10, 0, 0),
        child: Column(children: [
          // format the american date to Weekday, day month
          Text(numbersDateToText(widget.time),
              style: TextStyle(color: widget.dateColor)),
          // hijri date is at index 6
          Text(
            widget.times[6],
            style: TextStyle(color: widget.dateColor),
          ),
          // the prayers are in order [fajr,sunrise,dhuhr,asr,maghrib,isha]
          Prayer(
            color: widget.color,
            name: "Fajr",
            time: DateTime.parse("${widget.time} ${widget.times[0]}"),
          ),
          Prayer(
            color: widget.color,
            name: "Sunrise",
            time: DateTime.parse("${widget.time} ${widget.times[1]}"),
          ),
          Prayer(
            color: widget.color,
            name: dhuhr,
            time: DateTime.parse("${widget.time} ${widget.times[2]}"),
          ),
          Prayer(
            color: widget.color,
            name: "Asr",
            time: DateTime.parse("${widget.time} ${widget.times[3]}"),
          ),
          Prayer(
            color: widget.color,
            name: "Maghrib",
            time: DateTime.parse("${widget.time} ${widget.times[4]}"),
          ),
          Prayer(
            color: widget.color,
            name: "Isha'a",
            time: DateTime.parse("${widget.time} ${widget.times[5]}"),
          )
        ]),
      ),
    );
  }
}

class Prayer extends StatefulWidget {
  final String name;
  final DateTime time;
  final Color color;
  const Prayer(
      {super.key, required this.name, required this.time, required this.color});

  @override
  State<Prayer> createState() => _Prayer();
}

class _Prayer extends State<Prayer> {
  // create random color away from white
  int red = Random().nextInt(256);
  int green = Random().nextInt(256);
  int blue = Random().nextInt(256);

  @override
  Widget build(BuildContext context) {
    Color color = Color.fromRGBO(red, green, blue, 1);

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

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          margin: const EdgeInsets.all(5),
          decoration: BoxDecoration(
              color: widget.color,
              borderRadius: const BorderRadius.all(Radius.circular(10))),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 3,
                    height: 20,
                    color: color,
                    margin: const EdgeInsets.fromLTRB(0, 0, 10, 0),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.name,
                        style: TextStyle(color: color),
                      ),
                      Text("$hour:${"$minutes".padLeft(2, "0")} $dayPeriod",
                          style: TextStyle(color: color))
                    ],
                  ),
                ],
              ),
              Text(diff, style: TextStyle(color: color))
            ],
          ),
        ),
      ],
    );
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
      // get the old data
      Map prayerDays = jsonDecode(spref.getString("prayers")!);
      // if the date is saved on the device, add it to be returned later, else, get it from the API
      if (prayerDays.containsKey(americanDate)) {
        daysTime.add(prayerDays[americanDate]);
      } else {
        var url = Uri.https("api.aladhan.com", "/v1/timingsByCity/$date",
            {"city": "Alexandria", "country": "Egypt"});
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
