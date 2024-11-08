import "package:flutter/material.dart";
import 'package:prayerapp/color_notifier.dart';
import 'package:provider/provider.dart';
import 'global.dart';

class VibrationSettingsPage extends StatefulWidget {
  const VibrationSettingsPage({super.key});

  @override
  State<VibrationSettingsPage> createState() => _VibrationSettingsPageState();
}

class _VibrationSettingsPageState extends State<VibrationSettingsPage> {
  late TextEditingController vibrationController;

  @override
  void initState() {
    vibrationController = TextEditingController();
    List data = getVibrationData();
    setState(() {
      vibrationOn = data[0];
      vibrationController.text = data[1];
      vibrateRadio = data[2] ? "on" : "every";
    });
    super.initState();
  }

  String vibrateRadio = "on";
  bool vibrationOn = true;
  @override
  Widget build(BuildContext context) {
    return Consumer<ColorNotifier>(builder: (context, palette, child) {
      return Scaffold(
        backgroundColor: palette.getSecC,
        appBar: AppBar(
          backgroundColor: palette.getMainC,
          foregroundColor: palette.getSecC,
          centerTitle: true,
          title: const Text("Vibration Settings"),
        ),
        body: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              margin: const EdgeInsets.all(10),
              width: double.infinity,
              decoration: BoxDecoration(
                  color: palette.getSecC,
                  borderRadius: const BorderRadius.all(Radius.circular(10))),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Allow Vibrations",
                    style: TextStyle(color: palette.getMainC),
                  ),
                  Switch(
                      activeColor: palette.getMainC,
                      inactiveThumbColor: palette.getMainC,
                      inactiveTrackColor: palette.getSecC,
                      value: vibrationOn,
                      onChanged: (v) {
                        allowVibration(v);
                        setState(() {
                          vibrationOn = v;
                        });
                      })
                ],
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Column(
                  children: [
                    Radio(
                        fillColor: WidgetStatePropertyAll(palette.getMainC),
                        value: "on",
                        groupValue: vibrateRadio,
                        onChanged: (v) {
                          setState(() {
                            vibrateRadio = v!;
                          });
                        }),
                    Text("Vibrate on",
                        style: TextStyle(color: palette.getMainC))
                  ],
                ),
                const SizedBox(
                  width: 10,
                ),
                Column(
                  children: [
                    Radio(
                        fillColor: WidgetStatePropertyAll(palette.getMainC),
                        value: "every",
                        groupValue: vibrateRadio,
                        onChanged: (v) {
                          setState(() {
                            vibrateRadio = v!;
                          });
                        }),
                    Text(
                      "Vibrate every",
                      style: TextStyle(color: palette.getMainC),
                    )
                  ],
                )
              ],
            ),
            Container(
                padding: const EdgeInsets.all(10),
                margin: const EdgeInsets.all(10),
                child: TextField(
                  controller: vibrationController,
                  style: TextStyle(color: palette.getMainC),
                  cursorColor: palette.getMainC,
                  decoration: InputDecoration(
                      hintText:
                          "Difference between two vibrations for every | Exact numbers for on",
                      enabledBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: palette.getBackC)),
                      focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: palette.getMainC))),
                )),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
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
                      onSave(vibrationController.text, vibrateRadio == "on",
                          vibrationController, context);
                    },
                    textColor: palette.getSecC,
                    color: palette.getMainC,
                    child: const Text("Save"))
              ],
            )
          ],
        ),
      );
    });
  }
}

void onSave(
    String value, bool isOn, TextEditingController cont, BuildContext context) {
  if (isOn) {
    final regex = RegExp("([0-9]+,{0,1})+");
    bool match = regex.firstMatch(value)![0] == value;
    if (!match) {
      cont.text = "Invalid";
      return;
    }
  } else {
    try {
      int.parse(value);
    } catch (e) {
      cont.text = "Invalid";
      return;
    }
  }
  Navigator.of(context).pop();
  updateVibrationCount(value, isOn);
}

List getVibrationData() {
  List data = [];
  if (!Prefs.prefs.containsKey("vibrationBool")) {
    Prefs.prefs.setBool("vibrationBool", true);
  }
  if (!Prefs.prefs.containsKey("vibrationCount")) {
    Prefs.prefs.setString("vibrationCount", "33");
  }
  if (!Prefs.prefs.containsKey("isOn")) {
    Prefs.prefs.setBool("isOn", false);
  }
  data.add(Prefs.prefs.getBool("vibrationBool"));
  data.add(Prefs.prefs.getString("vibrationCount"));
  data.add(Prefs.prefs.getBool("isOn"));

  return data;
}

void allowVibration(bool allow) {
  Prefs.prefs.setBool("vibrationBool", allow);
}

void updateVibrationCount(String count, bool isOn) {
  Prefs.prefs.setString("vibrationCount", count);
  Prefs.prefs.setBool("isOn", isOn);
}
