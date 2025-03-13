import 'dart:async';
import 'package:flutter/material.dart';
import 'package:prayerapp/global.dart';
import 'package:prayerapp/main.dart';
import 'package:prayerapp/notification/notification.dart';
import 'package:prayerapp/prayer_page/next_prayer_notifier.dart';
import 'package:provider/provider.dart';

class PrayerDayWidget extends StatefulWidget {
  final String displayDateString;
  final List times;
  final List realDates;
  final String hijriDate;
  final Function changeDate;
  const PrayerDayWidget({
    super.key,
    required this.displayDateString,
    required this.times,
    required this.realDates,
    required this.hijriDate,
    required this.changeDate,
  });

  @override
  State<PrayerDayWidget> createState() => _PrayerDayWidgetState();
}

class _PrayerDayWidgetState extends State<PrayerDayWidget> {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        padding: const EdgeInsets.fromLTRB(0, 10, 0, 0),
        child: Column(children: [
          _dateWidget(),
          const SizedBox(
            height: 20,
          ),
          ...prayerDayWidgetBuilder()
        ]),
      ),
    );
  }

  Widget _dateWidget() {
    return InkWell(
      onTap: () => widget.changeDate(),
      child: Column(
        children: [
          Text(getEnglishLanguageDate(widget.displayDateString),
              style: TextStyle(
                  color: Palette.of(context).secColor,
                  fontSize: 20,
                  fontWeight: FontWeight.bold)),
          const SizedBox(
            height: 10,
          ),
          Text(
            widget.hijriDate,
            style: TextStyle(
                color: Color.lerp(Palette.of(context).secColor,
                    Palette.of(context).backColor, 0.5)),
          ),
        ],
      ),
    );
  }

  String getEnglishLanguageDate(String sdate) {
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

  List prayerDayWidgetBuilder() {
    List prayersWidgets = [];
    for (int i = 0; i < Constants.prayerNames.length; i++) {
      String prayer = Constants.prayerNames[i];
      DateTime displayDate =
          DateTime.parse("${widget.displayDateString} ${widget.times[i]}");

      DateTime realDate =
          DateTime.parse("${widget.realDates[i]} ${widget.times[i]}");

      prayersWidgets.add(PrayerWidget(
        realDate: realDate,
        icon: Constants.prayerIcons[i],
        name: prayer == "Dhuhr" && displayDate.weekday == 5 ? "Jumu'a" : prayer,
      ));
    }
    return prayersWidgets;
  }
}

class PrayerWidget extends StatefulWidget {
  final String name;
  final IconData icon;
  final DateTime realDate;

  const PrayerWidget({
    super.key,
    required this.name,
    required this.icon,
    required this.realDate,
  });

  @override
  State<PrayerWidget> createState() => _PrayerWidgetState();
}

class _PrayerWidgetState extends State<PrayerWidget> {
  Timer? timer;
  // Future? firstUpdate;

  late TimeOfDay _timeOfDay;
  late int _hour;
  late int _minutes;
  late String _dayPeriod;
  late Duration _difference;
  late String _diff;
  @override
  void initState() {
    startTimer();
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
    final palette = Palette.of(context);
    return InkWell(
      onTap: () {
        Navigator.of(context).push(MaterialPageRoute(
            builder: (context) => ChangeNotifierProvider(
                  create: (context) =>
                      PrayerNotificationSettingsModel(widget.name),
                  child: PrayerNotificationSettingsPage(prayer: widget.name),
                )));
      },
      child: Consumer<NextPrayerNot>(builder: (context, nextPrayerNot, _) {
        bool isNext = nextPrayerNot.name == widget.name &&
            CustomDateFormat.getShortDate(widget.realDate, true) ==
                nextPrayerNot.date;
        initTime(isNext);
        Color backC = isNext ? palette.mainColor : palette.secColor;
        Color textC = isNext ? palette.secColor : palette.mainColor;
        return Column(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              margin: const EdgeInsets.symmetric(horizontal: 10),
              decoration: BoxDecoration(
                  color: backC,
                  borderRadius: const BorderRadius.all(Radius.circular(5))),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(
                        widget.icon,
                        color: textC,
                      ),
                      const VerticalDivider(
                        width: 5,
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.name,
                            style: TextStyle(color: textC),
                          ),
                          Text(
                              "$_hour:${"$_minutes".padLeft(2, "0")} $_dayPeriod",
                              style: TextStyle(color: textC))
                        ],
                      ),
                    ],
                  ),
                  Text(_diff, style: TextStyle(color: textC))
                ],
              ),
            ),
            Container(
              margin: const EdgeInsets.only(bottom: 10, right: 12, left: 12),
              child: isNext
                  ? LinearProgressIndicator(
                      borderRadius: const BorderRadius.all(Radius.circular(10)),
                      value: 1 - nextPrayerNot.percentageLeft,
                      backgroundColor: palette.secColor,
                      color: palette.mainColor,
                    )
                  : null,
            )
          ],
        );
      }),
    );
  }

  void initTime(bool isNext) {
    _timeOfDay = TimeOfDay.fromDateTime(widget.realDate);
    _hour = _timeOfDay.hourOfPeriod;
    _minutes = _timeOfDay.minute;
    _dayPeriod = _timeOfDay.period == DayPeriod.am ? "AM" : "PM";

    _difference = widget.realDate.difference(DateTime.now());
    _diff = _difference.toString();
    _diff = _diff.substring(0, _diff.lastIndexOf(isNext ? "." : ":"));
    if (_difference.inHours >= 24 || _difference.inHours <= -24) {
      _diff = "";
    }
  }

  void startTimer() {
    Provider.of<NextPrayerNot>(context, listen: false).updateNextPrayer();
    timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      Provider.of<NextPrayerNot>(context, listen: false).updateNextPrayer();
      setState(() {});
    });
  }
}
