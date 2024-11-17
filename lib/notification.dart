import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:prayerapp/main.dart';
// import 'package:flutter/cupertino.dart';

class PrayerNotificationSettingsPage extends StatefulWidget {
  final String prayer;
  const PrayerNotificationSettingsPage({super.key, required this.prayer});

  @override
  State<PrayerNotificationSettingsPage> createState() =>
      _PrayerNotificationSettingsPageState();
}

class _PrayerNotificationSettingsPageState
    extends State<PrayerNotificationSettingsPage> {
  late List beforeChoices;
  late List afterChoices;
  @override
  void initState() {
    beforeChoices = _getChoices();
    afterChoices = beforeChoices;
    afterChoices.remove(0);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final palette = Palette.of(context);
    return Scaffold(
      backgroundColor: palette.secColor,
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: palette.mainColor,
        foregroundColor: palette.secColor,
        title: Text("${widget.prayer} Notification"),
      ),
      body: Container(
        padding: const EdgeInsets.all(30),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Choose When You Want To Be Notified Before And After Each Adhan",
              style: TextStyle(color: palette.mainColor),
            ),
            const SizedBox(
              height: 20,
            ),
            NumberPicker(title: "Before", choices: beforeChoices),
            const SizedBox(
              height: 15,
            ),
            NumberPicker(title: "After", choices: afterChoices),
          ],
        ),
      ),
    );
  }

  List _getChoices() {
    return List.generate(62, (i) {
      return i - 1;
    });
  }
}

// TODO: save this in the database
class NumberPicker extends StatefulWidget {
  final List choices;
  final String title;
  const NumberPicker({super.key, required this.choices, required this.title});

  @override
  State<NumberPicker> createState() => _NumberPickerState();
}

class _NumberPickerState extends State<NumberPicker> {
  int active = 0;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final palette = Palette.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Notify ${widget.title}",
          style:
              TextStyle(color: palette.mainColor, fontWeight: FontWeight.bold),
        ),
        _numberInput(),
        Text(
          active == 0
              ? "You Won't Receive Notifications ${widget.title} The Adhan"
              : "You Will Receive Notification ${widget.title} The Adhan By ${widget.choices[active]} Minute(s)",
          style: TextStyle(
              color: Color.lerp(palette.mainColor, palette.secColor, 0.3)),
        )
      ],
    );
  }

  Widget _numberInput() {
    int choice = widget.choices[active];
    return Row(
      children: [
        IconButton(
            color: Palette.of(context).mainColor,
            onPressed: active != 0
                ? () {
                    changeActive(false);
                  }
                : null,
            icon: const Icon(Icons.remove)),
        InkWell(
          onTap: _showPicker,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
                border: Border.fromBorderSide(
                    BorderSide(color: Palette.of(context).backColor)),
                borderRadius: const BorderRadius.all(Radius.circular(5))),
            child: Text(
              choice < 0 ? "OFF" : "${choice.toString()} Minute(s)",
              style: TextStyle(color: Palette.of(context).mainColor),
            ),
          ),
        ),
        IconButton(
            color: Palette.of(context).mainColor,
            onPressed: active < widget.choices.length - 1
                ? () {
                    changeActive(true);
                  }
                : null,
            icon: const Icon(Icons.add)),
      ],
    );
  }

  void changeActive(bool increase) {
    setState(() {
      active += (increase ? 1 : -1);
    });
  }

  void _showPicker() {
    showCupertinoModalPopup(
        context: context,
        builder: (_) {
          return Container(
            color: Palette.of(context).secColor,
            height: 300,
            child: CupertinoPicker(
              onSelectedItemChanged: _setActive,
              itemExtent: 50,
              children: [
                ...widget.choices.map((e) {
                  return Text(
                    e == -1 ? "OFF" : e.toString(),
                    style: TextStyle(color: Palette.of(context).mainColor),
                  );
                })
              ],
            ),
          );
        });
  }

  void _setActive(int v) {
    setState(() {
      active = v;
    });
  }
}

class NotificationSettingsModel {}
