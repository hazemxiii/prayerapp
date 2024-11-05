import 'package:flutter/material.dart';
import 'package:prayerapp/service.dart';
import 'global.dart';
import 'package:provider/provider.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'location.dart';
import 'vibration_settings.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  late bool nextPrayerIsVisible;
  @override
  void initState() {
    nextPrayerIsVisible = Prefs.prefs.getBool("nextPrayerVisible") ?? true;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Consumer<ColorPalette>(builder: (context, palette, child) {
        return Column(
          children: [
            SettingRowWidget(
              onTap: () {
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => const VibrationSettingsPage()));
              },
              text: Text(
                "Vibration",
                style: TextStyle(color: palette.getMainC),
              ),
              icon: Icon(
                Icons.arrow_right,
                color: palette.getMainC,
              ),
            ),
            ColorPickerRowWidget(
              name: "Main Color",
              pickerColor: palette.getMainC,
              colorKey: "primaryColor",
            ),
            ColorPickerRowWidget(
              name: "Secondary Color",
              pickerColor: palette.getSecC,
              colorKey: "secondaryColor",
            ),
            ColorPickerRowWidget(
              name: "Background Color",
              pickerColor: palette.getBackC,
              colorKey: "backColor",
            ),
            SettingRowWidget(
              onTap: () {
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => const LocationSettingsPage()));
              },
              text: Text(
                "Location",
                style: TextStyle(color: palette.getMainC),
              ),
              icon: Icon(
                Icons.arrow_right,
                color: palette.getMainC,
              ),
            ),
            SettingRowWidget(
                text: Text(
                  "Next Prayer Notification",
                  style: TextStyle(color: palette.getMainC),
                ),
                icon: Switch(
                  activeColor: palette.getMainC,
                  value: nextPrayerIsVisible,
                  onChanged: (v) {
                    setState(() {
                      nextPrayerIsVisible =
                          toggleNextPrayerIsVisible(nextPrayerIsVisible);
                    });
                  },
                ),
                onTap: () {
                  setState(() {
                    nextPrayerIsVisible =
                        toggleNextPrayerIsVisible(nextPrayerIsVisible);
                  });
                })
          ],
        );
      }),
    );
  }
}

class SettingRowWidget extends StatefulWidget {
  final Widget text;
  final Widget icon;
  final Function onTap;

  const SettingRowWidget({
    super.key,
    required this.text,
    required this.icon,
    required this.onTap,
  });

  @override
  State<SettingRowWidget> createState() => _SettingRowWidgetState();
}

class _SettingRowWidgetState extends State<SettingRowWidget> {
  @override
  Widget build(BuildContext context) {
    return Consumer<ColorPalette>(builder: (context, palette, child) {
      return InkWell(
        onTap: () {
          widget.onTap();
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 5),
          margin: const EdgeInsets.all(3),
          width: double.infinity,
          decoration: BoxDecoration(
              color: palette.getSecC,
              borderRadius: const BorderRadius.all(Radius.circular(5))),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [widget.text, widget.icon],
          ),
        ),
      );
    });
  }
}

class ColorPickerRowWidget extends StatefulWidget {
  final String name;
  final Color pickerColor;

  final String colorKey;

  const ColorPickerRowWidget({
    super.key,
    required this.name,
    required this.pickerColor,
    required this.colorKey,
  });

  @override
  State<ColorPickerRowWidget> createState() => _ColorPickerRowWidgetState();
}

class _ColorPickerRowWidgetState extends State<ColorPickerRowWidget> {
  late TextEditingController hexController;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ColorPalette>(builder: (context, palette, child) {
      return InkWell(
        splashColor: Colors.transparent,
        onTap: () {
          showDialog(
              context: context,
              builder: (context) {
                Color? color;
                return AlertDialog(
                  backgroundColor: palette.getSecC,
                  title: Text(
                    "Pick a color",
                    style: TextStyle(color: palette.getMainC),
                  ),
                  content: SingleChildScrollView(
                    child: ColorPicker(
                      displayThumbColor: true,
                      // hexInputColor: palette.getMainC,
                      enableAlpha: false,
                      labelTypes: const [],
                      hexInputBar: true,
                      pickerColor: widget.pickerColor,
                      onColorChanged: (c) {
                        color = c;
                      },
                    ),
                  ),
                  actions: [
                    TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                          switch (widget.colorKey) {
                            case "primaryColor":
                              Provider.of<ColorPalette>(context, listen: false)
                                  .setMainC(color!);
                              break;
                            case "secondaryColor":
                              Provider.of<ColorPalette>(context, listen: false)
                                  .setSecC(color!);
                              break;
                            case "backColor":
                              Provider.of<ColorPalette>(context, listen: false)
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
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 5),
          margin: const EdgeInsets.all(3),
          width: double.infinity,
          decoration: BoxDecoration(
              color: palette.getSecC,
              borderRadius: const BorderRadius.all(Radius.circular(5))),
          child:
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text(
              widget.name,
              style: TextStyle(color: palette.getMainC),
            ),
            Container(
              height: 20,
              width: 20,
              decoration: BoxDecoration(
                  border: Border.all(color: palette.getMainC, width: 1),
                  color: widget.pickerColor,
                  borderRadius: const BorderRadius.all(Radius.circular(999))),
            )
          ]),
        ),
      );
    });
  }
}

List getColors() {
  List colors = [];
  if (!Prefs.prefs.containsKey("primaryColor")) {
    Prefs.prefs.setString("primaryColor", Colors.lightBlue.toHexString());
  }
  if (!Prefs.prefs.containsKey("secondaryColor")) {
    Prefs.prefs.setString("secondaryColor", Colors.white.toHexString());
  }
  if (!Prefs.prefs.containsKey("backColor")) {
    Prefs.prefs.setString("backColor", Colors.lightBlue[50]!.toHexString());
  }

  colors.add(Prefs.prefs.getString("primaryColor"));
  colors.add(Prefs.prefs.getString("secondaryColor"));
  colors.add(Prefs.prefs.getString("backColor"));

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

void saveColor(String color, String hex) {
  Prefs.prefs.setString(color, hex);
}

bool toggleNextPrayerIsVisible(bool visible) {
  if (!Prefs.prefs.containsKey("nextPrayerVisible")) {
    Prefs.prefs.setBool("nextPrayerVisible", !visible);
  }
  Prefs.prefs.setBool("nextPrayerVisible", !visible);
  if (visible) {
    stopBackgroundService();
  } else {
    startBackgroundService();
  }
  return !visible;
}
