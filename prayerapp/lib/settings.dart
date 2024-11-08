import 'package:flutter/material.dart';
import 'package:prayerapp/color_notifier.dart';
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
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Consumer<ColorNotifier>(builder: (context, palette, child) {
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
                  value: true,
                  onChanged: (v) {
                    setState(() {});
                  },
                ),
                onTap: () {
                  setState(() {});
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
    return Consumer<ColorNotifier>(builder: (context, palette, child) {
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
    return Consumer<ColorNotifier>(builder: (context, palette, child) {
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
                              Provider.of<ColorNotifier>(context, listen: false)
                                  .setMainC(color!);
                              break;
                            case "secondaryColor":
                              Provider.of<ColorNotifier>(context, listen: false)
                                  .setSecC(color!);
                              break;
                            case "backColor":
                              Provider.of<ColorNotifier>(context, listen: false)
                                  .setBackC(color!);
                              break;
                          }
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
