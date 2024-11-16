import "package:flutter/material.dart";
import 'package:prayerapp/main.dart';
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
    setState(() {
      vibrationOn = Prefs.prefs.getBool(PrefsKeys.isVibrateOn)!;
      vibrationController.text =
          Prefs.prefs.getString(PrefsKeys.vibrateNumber)!;
      vibrateRadio =
          Prefs.prefs.getBool(PrefsKeys.isVibrationModeAt)! ? "on" : "every";
    });
    super.initState();
  }

  String vibrateRadio = "on";
  bool vibrationOn = true;
  @override
  Widget build(BuildContext context) {
    final palette = Palette.of(context);
    return Scaffold(
      backgroundColor: palette.secColor,
      appBar: AppBar(
        backgroundColor: palette.mainColor,
        foregroundColor: palette.secColor,
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
                color: palette.secColor,
                borderRadius: const BorderRadius.all(Radius.circular(10))),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Allow Vibrations",
                  style: TextStyle(color: palette.mainColor),
                ),
                Switch(
                    activeColor: palette.mainColor,
                    inactiveThumbColor: palette.mainColor,
                    inactiveTrackColor: palette.secColor,
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
                      fillColor: WidgetStatePropertyAll(palette.mainColor),
                      value: "on",
                      groupValue: vibrateRadio,
                      onChanged: (v) {
                        setState(() {
                          vibrateRadio = v!;
                        });
                      }),
                  Text("Vibrate on", style: TextStyle(color: palette.mainColor))
                ],
              ),
              const SizedBox(
                width: 10,
              ),
              Column(
                children: [
                  Radio(
                      fillColor: WidgetStatePropertyAll(palette.mainColor),
                      value: "every",
                      groupValue: vibrateRadio,
                      onChanged: (v) {
                        setState(() {
                          vibrateRadio = v!;
                        });
                      }),
                  Text(
                    "Vibrate every",
                    style: TextStyle(color: palette.mainColor),
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
                style: TextStyle(color: palette.mainColor),
                cursorColor: palette.mainColor,
                decoration: InputDecoration(
                    hintText:
                        "Difference between two vibrations for every | Exact numbers for on",
                    enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: palette.backColor)),
                    focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: palette.mainColor))),
              )),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              MaterialButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  color: palette.secColor,
                  textColor: palette.mainColor,
                  child: const Text("Cancel")),
              const SizedBox(
                width: 10,
              ),
              MaterialButton(
                  onPressed: () {
                    onSave(vibrationController.text, vibrateRadio == "on",
                        vibrationController, context);
                  },
                  textColor: palette.secColor,
                  color: palette.mainColor,
                  child: const Text("Save"))
            ],
          )
        ],
      ),
    );
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

void allowVibration(bool allow) {
  Prefs.prefs.setBool(PrefsKeys.isVibrateOn, allow);
}

void updateVibrationCount(String count, bool isOn) {
  Prefs.prefs.setString(PrefsKeys.vibrateNumber, count);
  Prefs.prefs.setBool(PrefsKeys.isVibrationModeAt, isOn);
}
