import 'dart:async';
import 'package:flutter/material.dart';
import 'package:prayerapp/global.dart';
import 'package:prayerapp/notification.dart';
import 'package:provider/provider.dart';

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
