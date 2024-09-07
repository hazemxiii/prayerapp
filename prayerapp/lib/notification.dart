import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import "global.dart";
import 'service.dart';

class PrayerNotificationSettingsPage extends StatefulWidget {
  final String prayer;
  const PrayerNotificationSettingsPage({super.key, required this.prayer});

  @override
  State<PrayerNotificationSettingsPage> createState() =>
      _PrayerNotificationSettingsPageState();
}

class _PrayerNotificationSettingsPageState
    extends State<PrayerNotificationSettingsPage> {
  ValueNotifier beforeAdhanTime = ValueNotifier(-1);
  ValueNotifier afterAdhanTime = ValueNotifier(-1);

  @override
  void initState() {
    super.initState();

    getNotificationsData(widget.prayer).then((data) {
      setState(() {
        beforeAdhanTime = ValueNotifier(data[0]);
        afterAdhanTime = ValueNotifier(data[1]);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ColorPalette>(builder: (context, palette, child) {
      return Scaffold(
        backgroundColor: palette.getSecC,
        appBar: AppBar(
          foregroundColor: palette.getSecC,
          backgroundColor: palette.getMainC,
          title: Text("${widget.prayer} Notification"),
          centerTitle: true,
        ),
        body: Column(
          children: [
            PickTimeRowWidget(
              notifier: beforeAdhanTime,
              min: 0,
              // max: 30,
              max: 720,
              step: 1,
              text: "Before Adhan",
            ),
            PickTimeRowWidget(
              notifier: afterAdhanTime,
              min: 1,
              // max: 15,
              max: 720,
              step: 1,
              text: "After Adhan",
            ),
            Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              MaterialButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  color: palette.getSecC,
                  textColor: palette.getMainC,
                  child: const Text("Cancel")),
              const SizedBox(
                width: 10,
              ),
              MaterialButton(
                  onPressed: () {
                    saveNotificationTimes(widget.prayer, beforeAdhanTime.value,
                        afterAdhanTime.value);
                    Navigator.of(context).pop();
                  },
                  color: palette.getMainC,
                  textColor: palette.getSecC,
                  child: const Text("Save"))
            ])
          ],
        ),
      );
    });
  }
}

class PickTimeRowWidget extends StatefulWidget {
  final ValueNotifier notifier;
  final int min;
  final int max;
  final int step;
  final String text;
  const PickTimeRowWidget(
      {super.key,
      required this.notifier,
      required this.min,
      required this.max,
      required this.step,
      required this.text});

  @override
  State<PickTimeRowWidget> createState() => _PickTimeRowWidgetState();
}

class _PickTimeRowWidgetState extends State<PickTimeRowWidget> {
  @override
  Widget build(BuildContext context) {
    return Consumer<ColorPalette>(builder: (context, palette, child) {
      return InkWell(
          onTap: () {
            showDialog(
                context: context,
                builder: (context) {
                  return Dialog(
                    child: ValueListenableBuilder(
                        valueListenable: widget.notifier,
                        builder: (context, value, child) {
                          return NumberPickerWidget(
                            min: widget.min,
                            max: widget.max,
                            step: widget.step,
                            value: widget.notifier,
                          );
                        }),
                  );
                });
          },
          child: Container(
            padding: const EdgeInsets.all(10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  widget.text,
                  style: TextStyle(color: palette.getMainC),
                ),
                ValueListenableBuilder(
                    valueListenable: widget.notifier,
                    builder: (context, value, child) {
                      return Text(
                        value >= widget.min ? "$value" : "OFF",
                        style: TextStyle(color: palette.getMainC),
                      );
                    }),
              ],
            ),
          ));
    });
  }
}

class NumberPickerWidget extends StatefulWidget {
  final int min;
  final int max;
  final int step;
  final ValueNotifier value;
  const NumberPickerWidget(
      {super.key,
      required this.min,
      required this.max,
      required this.step,
      required this.value});

  @override
  State<NumberPickerWidget> createState() => _NumberPickerWidgetState();
}

class _NumberPickerWidgetState extends State<NumberPickerWidget> {
  late PageController controller;

  @override
  void initState() {
    super.initState();
    controller = PageController(
        initialPage:
            ((widget.value.value - widget.min) / widget.step).floor() + 1);
  }

  @override
  Widget build(BuildContext context) {
    int count = ((widget.max - widget.min) / widget.step).floor() + 2;
    return Consumer<ColorPalette>(builder: (context, palette, child) {
      return Container(
          decoration: BoxDecoration(
              borderRadius: const BorderRadius.all(Radius.circular(20)),
              color: palette.getMainC),
          height: 40,
          width: 40,
          child: PageView.builder(
              scrollDirection: Axis.vertical,
              controller: controller,
              onPageChanged: (i) {
                widget.value.value = (i - 1) * widget.step + widget.min;
              },
              itemCount: count,
              itemBuilder: (context, i) => Center(
                    child: Text(
                      i != 0 ? "${(i - 1) * widget.step + widget.min}" : "OFF",
                      style: TextStyle(color: palette.getSecC),
                    ),
                  )));
    });
  }
}

void saveNotificationTimes(String prayer, int before, int after) async {
  SharedPreferences spref = await SharedPreferences.getInstance();

  String keyBefore = "${prayer}_notification_b";
  String keyAfter = "${prayer}_notification_a";

  spref.setInt(keyBefore, before);
  spref.setInt(keyAfter, after);
}
