import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:prayerapp/global.dart';
import 'package:prayerapp/main.dart';
import 'package:provider/provider.dart';

class PrayerNotificationSettingsModel extends ChangeNotifier {
  final String prayer;
  final List data;

  PrayerNotificationSettingsModel(this.prayer)
      : data = Prefs().getPrayerNotification(prayer);

  void updateData(int index, bool isBefore) {
    data[isBefore ? 0 : 1] = index;
    notifyListeners();
  }

  void saveData(BuildContext context) {
    Prefs().setPrayerNotification(prayer, data);
    Navigator.of(context).pop();
  }
}

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
    afterChoices = [...beforeChoices];
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
        actions: [
          IconButton(
              onPressed: () => context
                  .read<PrayerNotificationSettingsModel>()
                  .saveData(context),
              icon: const Icon(Icons.save))
        ],
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
            Consumer<PrayerNotificationSettingsModel>(
              builder: (context, state, _) {
                return NumberPicker(
                    isBefore: true,
                    choices: beforeChoices,
                    active: state.data[0]);
              },
            ),
            const SizedBox(
              height: 15,
            ),
            Consumer<PrayerNotificationSettingsModel>(
              builder: (context, state, _) {
                return NumberPicker(
                    isBefore: false,
                    choices: afterChoices,
                    active: state.data[1]);
              },
            ),
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

class NumberPicker extends StatefulWidget {
  final List choices;
  final bool isBefore;
  final int active;
  const NumberPicker(
      {super.key,
      required this.choices,
      required this.active,
      required this.isBefore});

  @override
  State<NumberPicker> createState() => _NumberPickerState();
}

class _NumberPickerState extends State<NumberPicker> {
  @override
  Widget build(BuildContext context) {
    String title = widget.isBefore ? "Before" : "After";
    final palette = Palette.of(context);
    int choice = widget.choices[widget.active];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Notify $title",
          style:
              TextStyle(color: palette.mainColor, fontWeight: FontWeight.bold),
        ),
        _numberInput(),
        Text(
          widget.active == 0
              ? "You Won't Receive Notifications $title The Adhan"
              : "You Will Receive Notification $title The Adhan By $choice Minute(s)",
          style: TextStyle(
              color: Color.lerp(palette.mainColor, palette.secColor, 0.3)),
        )
      ],
    );
  }

  Widget _numberInput() {
    int choice = widget.choices[widget.active];
    return Row(
      children: [
        IconButton(
            color: Palette.of(context).mainColor,
            onPressed: widget.active != 0
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
            onPressed: widget.active < widget.choices.length - 1
                ? () {
                    changeActive(true);
                  }
                : null,
            icon: const Icon(Icons.add)),
      ],
    );
  }

  void changeActive(bool increase) {
    final model = context.read<PrayerNotificationSettingsModel>();
    model.updateData(model.data[widget.isBefore ? 0 : 1] + (increase ? 1 : -1),
        widget.isBefore);
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
    final model = context.read<PrayerNotificationSettingsModel>();
    model.updateData(v, widget.isBefore);
  }
}
