import 'package:flutter/material.dart';
import 'package:prayerapp/main.dart';
import 'package:prayerapp/prayer_page/prayers_widgets.dart';

class NoInternetWidget extends StatelessWidget {
  const NoInternetWidget({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(Icons.warning, size: 40, color: Palette.of(context).mainColor),
          Text(
            "No Internet Connection",
            style: TextStyle(color: Palette.of(context).mainColor),
          )
        ],
      ),
    );
  }
}

class PrayersScrollWidget extends StatelessWidget {
  final List prayerTimes;
  final List displayDates;
  final List hijriDates;
  final List realDates;
  const PrayersScrollWidget({
    super.key,
    required this.prayerTimes,
    required this.displayDates,
    required this.hijriDates,
    required this.realDates,
  });

  @override
  Widget build(BuildContext context) {
    PageController pageViewCont = PageController(initialPage: 1);
    return Expanded(
      child: Container(
        color: Palette.of(context).backColor,
        width: double.infinity,
        child: PageView.builder(
            controller: pageViewCont,
            itemCount: prayerTimes.length,
            itemBuilder: (context, i) {
              return PrayerDayWidget(
                  realDates: realDates[i],
                  hijriDate: hijriDates[i],
                  displayDateString: displayDates[i],
                  times: prayerTimes[i]);
            }),
      ),
    );
  }
}
