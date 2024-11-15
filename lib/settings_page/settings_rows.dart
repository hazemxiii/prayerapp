import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:prayerapp/color_notifier.dart';
import 'package:prayerapp/global.dart';
import 'package:prayerapp/sqlite.dart';
import 'package:provider/provider.dart';

class SettingRowWidget extends StatefulWidget {
  final Widget text;
  final Widget icon;
  final Function()? onTap;

  const SettingRowWidget({
    super.key,
    required this.text,
    required this.icon,
    this.onTap,
  });

  @override
  State<SettingRowWidget> createState() => _SettingRowWidgetState();
}

class _SettingRowWidgetState extends State<SettingRowWidget> {
  @override
  Widget build(BuildContext context) {
    return Consumer<ColorNotifier>(builder: (context, palette, child) {
      return InkWell(
        onTap: widget.onTap,
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

class HijriCalibrationWidget extends StatefulWidget {
  const HijriCalibrationWidget({super.key});

  @override
  State<HijriCalibrationWidget> createState() => _HijriCalibrationWidgetState();
}

class _HijriCalibrationWidgetState extends State<HijriCalibrationWidget> {
  int _oldValue = Prefs.prefs.getInt(PrefsKeys.adjustment)!;
  late int _adjustment;
  @override
  void initState() {
    _adjustment = _oldValue;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ColorNotifier>(builder: (context, clrs, _) {
      return Column(
        children: [
          Row(
            children: [
              IconButton(
                  color: clrs.getMainC,
                  onPressed: () {
                    _changeAdjustment(false);
                  },
                  icon: const Icon(Icons.arrow_left)),
              Text(
                  style: TextStyle(color: clrs.getMainC),
                  textAlign: TextAlign.center,
                  _adjustment.toString()),
              IconButton(
                  color: clrs.getMainC,
                  onPressed: () {
                    _changeAdjustment(true);
                  },
                  icon: const Icon(Icons.arrow_right)),
            ],
          ),
          Visibility(
              visible: _adjustment != _oldValue,
              child: Row(
                children: [
                  TextButton(
                      onPressed: _resetAdjustment, child: const Text("Cancel")),
                  TextButton(
                      style: ButtonStyle(
                          backgroundColor:
                              WidgetStatePropertyAll(clrs.getMainC)),
                      onPressed: _saveAdjustment,
                      child: Text(
                        "Save",
                        style: TextStyle(color: clrs.getSecC),
                      ))
                ],
              ))
        ],
      );
    });
  }

  void _saveAdjustment() {
    setState(() {
      Prefs.prefs.setInt(PrefsKeys.adjustment, _adjustment);
      _oldValue = _adjustment;
    });
    Db().deletePrayers();
  }

  void _resetAdjustment() {
    setState(() {
      _adjustment = _oldValue;
    });
  }

  void _changeAdjustment(bool increase) {
    setState(() {
      _adjustment = _adjustment + (increase ? 1 : -1);
    });
  }
}
