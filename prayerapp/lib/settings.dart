import 'package:flutter/material.dart';
import 'package:prayerappde/main.dart';
import 'package:provider/provider.dart';
import "package:shared_preferences/shared_preferences.dart";
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'location.dart';
import 'vibration_settings.dart';

class Settings extends StatefulWidget {
  const Settings({super.key});

  @override
  State<Settings> createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  @override
  void initState() {
    super.initState();

    getColors().then((data) {
      Provider.of<ColorPalette>(context, listen: false)
          .setMainC(hexToColor(data[0]));

      Provider.of<ColorPalette>(context, listen: false)
          .setSecC(hexToColor(data[1]));

      Provider.of<ColorPalette>(context, listen: false)
          .setBackC(hexToColor(data[2]));
    });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Consumer<ColorPalette>(builder: (context, palette, child) {
        return Column(
          children: [
            const SizedBox(
              height: 20,
            ),
            Text("Settings",
                style: TextStyle(
                  fontSize: 30,
                  color: palette.getMainC,
                )),
            const SizedBox(
              height: 10,
            ),
            InkWell(
              onTap: () {
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => const VibrationSettings()));
              },
              child: SettingRow(
                  child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Vibration",
                    style: TextStyle(color: palette.getMainC),
                  ),
                  Icon(
                    Icons.arrow_right,
                    color: palette.getMainC,
                  )
                ],
              )),
            ),
            ColorPickerRow(
              name: "Main Color",
              pickerColor: palette.getMainC,
              colorKey: "primaryColor",
            ),
            ColorPickerRow(
              name: "Secondary Color",
              pickerColor: palette.getSecC,
              colorKey: "secondaryColor",
            ),
            ColorPickerRow(
              name: "Background Color",
              pickerColor: palette.getBackC,
              colorKey: "backColor",
            ),
            InkWell(
              onTap: () {
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => const LocationSettings()));
              },
              child: SettingRow(
                  child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Location",
                    style: TextStyle(color: palette.getMainC),
                  ),
                  Icon(
                    Icons.arrow_right,
                    color: palette.getMainC,
                  )
                ],
              )),
            )
          ],
        );
      }),
    );
  }
}

class SettingRow extends StatefulWidget {
  final Widget child;

  const SettingRow({
    super.key,
    required this.child,
  });

  @override
  State<SettingRow> createState() => _SettingRowState();
}

class _SettingRowState extends State<SettingRow> {
  @override
  Widget build(BuildContext context) {
    return Consumer<ColorPalette>(builder: (context, palette, child) {
      return Container(
        padding: const EdgeInsets.all(10),
        margin: const EdgeInsets.all(10),
        width: double.infinity,
        decoration: BoxDecoration(
            color: palette.getSecC,
            borderRadius: const BorderRadius.all(Radius.circular(10))),
        child: widget.child,
      );
    });
  }
}

class ColorPickerRow extends StatefulWidget {
  final String name;
  final Color pickerColor;

  final String colorKey;

  const ColorPickerRow({
    super.key,
    required this.name,
    required this.pickerColor,
    required this.colorKey,
  });

  @override
  State<ColorPickerRow> createState() => _ColorPickerRowState();
}

class _ColorPickerRowState extends State<ColorPickerRow> {
  @override
  Widget build(BuildContext context) {
    return Consumer<ColorPalette>(builder: (context, palette, child) {
      return SettingRow(
          child:
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Text(
          widget.name,
          style: TextStyle(color: palette.getMainC),
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
                      style: TextStyle(color: palette.getMainC),
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
                            Navigator.of(context).pop();
                            switch (widget.colorKey) {
                              case "primaryColor":
                                Provider.of<ColorPalette>(context,
                                        listen: false)
                                    .setMainC(color!);
                                break;
                              case "secondaryColor":
                                Provider.of<ColorPalette>(context,
                                        listen: false)
                                    .setSecC(color!);
                                break;
                              case "backColor":
                                Provider.of<ColorPalette>(context,
                                        listen: false)
                                    .setBackC(color!);
                                break;
                            }
                            saveColor(widget.colorKey, color!.toHexString());
                          },
                          child: Text(
                            "save",
                            style: TextStyle(color: palette.getMainC),
                          ))
                    ],
                  );
                });
          },
          child: Container(
            height: 20,
            width: 20,
            decoration: BoxDecoration(
                border: Border.all(color: palette.getMainC, width: 1),
                color: widget.pickerColor,
                borderRadius: const BorderRadius.all(Radius.circular(999))),
          ),
        )
      ]));
    });
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
