import "dart:convert";
import "dart:math";
import "package:flutter/material.dart";
import 'package:http/http.dart' as http;
// import 'package:shared_preferences/shared_preferences.dart';
// import "package:geolocator/geolocator.dart";
// import 'package:geocoding/geocoding.dart';

void main() {
  runApp(const App());
}

class App extends StatelessWidget {
  const App({super.key});
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(home: PrayerTime());
  }
}

class PrayerTime extends StatefulWidget {
  const PrayerTime({super.key});
  @override
  State<PrayerTime> createState() => _PrayerTime();
}

class _PrayerTime extends State<PrayerTime> {
  List dates = ["2024-05-15", "2024-05-16"];

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
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
            child: PageView.builder(
                onPageChanged: (v) {},
                itemCount: dates.length,
                itemBuilder: (context, i) {
                  return PrayerDay(time: dates[i]);
                }),
          )
        ],
      ),
    );
  }
}

class PrayerDay extends StatelessWidget {
  final String time;
  const PrayerDay({super.key, required this.time});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 10, 0, 0),
      child: Column(children: [
        Text(numbersDateToText(time)),
        Prayer(
          name: "Fajr",
          time: DateTime.parse("$time 04:23"),
        ),
        Prayer(
          name: "dhuhr",
          time: DateTime.parse("$time 12:57"),
        ),
        Prayer(
          name: "Asr",
          time: DateTime.parse("$time 16:36"),
        )
      ]),
    );
  }
}

class Prayer extends StatefulWidget {
  final String name;
  final DateTime time;
  const Prayer({super.key, required this.name, required this.time});

  @override
  State<Prayer> createState() => _Prayer();
}

class _Prayer extends State<Prayer> {
  int red = Random().nextInt(241);
  int green = Random().nextInt(241);
  int blue = Random().nextInt(241);

  @override
  Widget build(BuildContext context) {
    Color color = Color.fromRGBO(red, green, blue, 1);
    int hour = widget.time.hour;
    int minutes = widget.time.minute;
    String dayPeriod = "AM";

    if (hour >= 12) {
      hour = hour - 12;
      dayPeriod = "PM";
    }
    if (hour == 0) {
      hour = 12;
    }

    String diff = widget.time.difference(DateTime.now()).toString();
    diff = diff.substring(0, diff.lastIndexOf(":"));

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.name,
                    style: TextStyle(color: color),
                  ),
                  Text("$hour:$minutes $dayPeriod",
                      style: TextStyle(color: color))
                ],
              ),
              Text(diff, style: TextStyle(color: color))
            ],
          ),
        ),
        Container(
          color: color,
          height: 3,
        )
      ],
    );
  }
}

// functions
Future<List> getPrayerTime(date) async {
  // obtains the data from the api
  var url = Uri.https("api.aladhan.com", "/v1/timingsByCity/:$date",
      {"city": "Alexandria", "country": "Egypt"});
  var r = await http.get(url);
  if (r.statusCode == 200) {
    var data = jsonDecode(r.body)['data'];
    var timings = data['timings'];
    var hijri = data['date']['hijri'];
    var hirjiDay = hijri['day'];
    var hijriMonth = hijri['month']['en'];
    var hijriYear = hijri['year'];
    return [
      timings['Fajr'],
      timings['Sunrise'],
      timings['Dhuhr'],
      timings['Asr'],
      timings['Maghrib'],
      timings['Isha'],
      "$hirjiDay - $hijriMonth - $hijriYear"
    ];
  } else {
    return [];
  }
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
