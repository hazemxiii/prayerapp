import 'package:flutter/material.dart';
import 'package:prayerapp/color_notifier.dart';
import 'package:prayerapp/prayer_page/prayers_widgets.dart';
import 'package:provider/provider.dart';

class NoInternetWidget extends StatelessWidget {
  final Color color;
  const NoInternetWidget({super.key, required this.color});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(Icons.warning, size: 40, color: color),
          Text(
            "No Internet Connection",
            style: TextStyle(color: color),
          )
        ],
      ),
    );
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

class _NextPrayerWidgetState extends State<NextPrayerWidget> {
  @override
  Widget build(BuildContext context) {
    return Consumer<ColorNotifier>(builder: (context, palette, snapshot) {
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
