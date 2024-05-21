import 'package:flutter/material.dart';
import "package:shared_preferences/shared_preferences.dart";
import 'package:flutter_colorpicker/flutter_colorpicker.dart';

class Settings extends StatefulWidget {
  const Settings({super.key});

  @override
  State<Settings> createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  bool vibration = true;
  String hint = "00";
  Color mainColor = Colors.lightBlue;
  Color secondaryColor = Colors.white;
  Color backColor = Colors.lightBlue[50]!;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    getVibrationData().then((data) {
      setState(() {
        vibration = data[0];
        hint = "${data[1]}";
      });
    });

    getColors().then((data) {
      setState(() {
        mainColor = hexToColor(data[0]);
        secondaryColor = hexToColor(data[1]);
        backColor = hexToColor(data[2]);
      });
    });

    return SingleChildScrollView(
      child: Column(
        children: [
          const SizedBox(
            height: 20,
          ),
          Text("Settings",
              style: TextStyle(
                fontSize: 30,
                color: mainColor,
              )),
          const SizedBox(
            height: 10,
          ),
          SettingRow(
              color: secondaryColor,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Allow Vibrations",
                    style: TextStyle(color: mainColor),
                  ),
                  Switch(
                      activeColor: mainColor,
                      inactiveThumbColor: backColor,
                      inactiveTrackColor: secondaryColor,
                      value: vibration,
                      onChanged: (v) {
                        allowVibration(v);
                        setState(() {
                          vibration = v;
                        });
                      })
                ],
              )),
          SettingRow(
              color: secondaryColor,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Vibrate on:",
                    style: TextStyle(color: mainColor),
                  ),
                  SizedBox(
                    width: 25,
                    child: TextField(
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        enabled: vibration,
                        hintText: hint,
                        hintStyle: TextStyle(color: mainColor),
                      ),
                      onChanged: (v) {
                        try {
                          updateVibrationCount(int.parse(v));
                        } catch (e) {
                          // print(e);
                        }
                      },
                    ),
                  )
                ],
              )),
          ColorPickerRow(
            name: "Main Color",
            pickerColor: mainColor,
            colorKey: "primaryColor",
            rowColor: secondaryColor,
            textColor: mainColor,
          ),
          ColorPickerRow(
            name: "Secondary Color",
            pickerColor: secondaryColor,
            colorKey: "secondaryColor",
            rowColor: secondaryColor,
            textColor: mainColor,
          ),
          ColorPickerRow(
            name: "Background Color",
            pickerColor: backColor,
            colorKey: "backColor",
            rowColor: secondaryColor,
            textColor: mainColor,
          )
        ],
      ),
    );
  }
}

class SettingRow extends StatefulWidget {
  final Widget child;
  final Color color;
  const SettingRow({super.key, required this.child, required this.color});

  @override
  State<SettingRow> createState() => _SettingRowState();
}

class _SettingRowState extends State<SettingRow> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      margin: const EdgeInsets.all(10),
      width: double.infinity,
      decoration: BoxDecoration(
          color: widget.color,
          borderRadius: const BorderRadius.all(Radius.circular(10))),
      child: widget.child,
    );
  }
}

Future<List> getVibrationData() async {
  List data = [];
  await SharedPreferences.getInstance().then((prefs) {
    if (!prefs.containsKey("vibrationBool")) {
      prefs.setBool("vibrationBool", true);
    }
    if (!prefs.containsKey("vibrationCount")) {
      prefs.setInt("vibrationCount", 33);
    }
    data.add(prefs.getBool("vibrationBool"));
    data.add(prefs.getInt("vibrationCount"));
  });

  return data;
}

void allowVibration(bool allow) async {
  await SharedPreferences.getInstance().then((prefs) {
    prefs.setBool("vibrationBool", allow);
  });
}

void updateVibrationCount(int count) async {
  await SharedPreferences.getInstance().then((prefs) {
    prefs.setInt("vibrationCount", count);
  });
}

class ColorPickerRow extends StatefulWidget {
  final String name;
  final Color pickerColor;
  final Color rowColor;
  final String colorKey;
  final Color textColor;
  const ColorPickerRow(
      {super.key,
      required this.name,
      required this.pickerColor,
      required this.colorKey,
      required this.rowColor,
      required this.textColor});

  @override
  State<ColorPickerRow> createState() => _ColorPickerRowState();
}

class _ColorPickerRowState extends State<ColorPickerRow> {
  @override
  Widget build(BuildContext context) {
    return SettingRow(
        color: widget.rowColor,
        child:
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text(
            widget.name,
            style: TextStyle(color: widget.textColor),
          ),
          InkWell(
            splashColor: Colors.transparent,
            onTap: () {
              showDialog(
                  context: context,
                  builder: (context) {
                    Color? color;
                    return AlertDialog(
                      title: Text(
                        "Pick a color",
                        style: TextStyle(color: widget.textColor),
                      ),
                      content: ColorPicker(
                        pickerColor: widget.pickerColor,
                        onColorChanged: (c) {
                          color = c;
                        },
                      ),
                      actions: [
                        TextButton(
                            onPressed: () {
                              saveColor(widget.colorKey, color!.toHexString());
                            },
                            child: Text(
                              "save",
                              style: TextStyle(color: widget.textColor),
                            ))
                      ],
                    );
                  });
            },
            child: Container(
              height: 20,
              width: 20,
              decoration: BoxDecoration(
                  color: widget.pickerColor,
                  borderRadius: const BorderRadius.all(Radius.circular(999))),
            ),
          )
        ]));
  }
}

Future<List> getColors() async {
  List colors = [];
  await SharedPreferences.getInstance().then((prefs) {
    if (!prefs.containsKey("primaryColor")) {
      prefs.setString("primaryColor", Colors.lightBlue.toHexString());
    }
    if (!prefs.containsKey("secondaryColor")) {
      prefs.setString("secondaryColor", Colors.white.toHexString());
    }
    if (!prefs.containsKey("backColor")) {
      prefs.setString("backColor", Colors.lightBlue[50]!.toHexString());
    }

    colors.add(prefs.getString("primaryColor"));
    colors.add(prefs.getString("secondaryColor"));
    colors.add(prefs.getString("backColor"));
  });

  return colors;
}

Color hexToColor(String hex) {
  String red;
  String green;
  String blue;

  red = hex.substring(2, 4);
  green = hex.substring(4, 6);
  blue = hex.substring(6, 8);

  int r = rgbFromHex(red);
  int g = rgbFromHex(green);
  int b = rgbFromHex(blue);

  return Color.fromRGBO(r, g, b, 1);
}

int rgbFromHex(String c) {
  Map toNum = {};
  for (int i = 0; i < 10; i++) {
    toNum["$i"] = i;
  }
  toNum["A"] = 10;
  toNum["B"] = 11;
  toNum["C"] = 12;
  toNum["D"] = 13;
  toNum["E"] = 14;
  toNum["F"] = 15;

  return toNum[c[0]] * 16 + toNum[c[1]];
}

void saveColor(String color, String hex) async {
  await SharedPreferences.getInstance().then((prefs) {
    prefs.setString(color, hex);
  });
}
