import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:prayerapp/color_notifier.dart';
import 'package:prayerapp/global.dart';
import 'package:prayerapp/main.dart';
import 'package:prayerapp/sqlite.dart';
import 'package:provider/provider.dart';

class MoreSettingWidget extends StatefulWidget {
  final String text;
  final Widget icon;
  final Function()? onTap;

  const MoreSettingWidget({
    super.key,
    required this.text,
    required this.icon,
    this.onTap,
  });

  @override
  State<MoreSettingWidget> createState() => _MoreSettingWidgetState();
}

class _MoreSettingWidgetState extends State<MoreSettingWidget> {
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: widget.onTap,
      child: Container(
        padding: const EdgeInsets.all(5),
        margin: const EdgeInsets.all(3),
        width: double.infinity,
        decoration: BoxDecoration(
            border: Border.fromBorderSide(
                BorderSide(color: Palette.of(context).backColor, width: 1)),
            color: Palette.of(context).secColor,
            borderRadius: const BorderRadius.all(Radius.circular(5))),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              widget.text,
              style: TextStyle(color: Palette.of(context).mainColor),
            ),
            widget.icon
          ],
        ),
      ),
    );
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
    final palette = Palette.of(context);
    return InkWell(
      splashColor: Colors.transparent,
      onTap: () {
        showDialog(
            context: context,
            builder: (context) {
              Color? color;
              return AlertDialog(
                backgroundColor: palette.secColor,
                title: Text(
                  "Pick a color",
                  style: TextStyle(color: palette.mainColor),
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
                        final provider =
                            Provider.of<ColorNotifier>(context, listen: false);
                        Navigator.of(context).pop();
                        provider.setColor(widget.colorKey, color);
                      },
                      child: Text(
                        "save",
                        style: TextStyle(color: palette.mainColor),
                      ))
                ],
              );
            });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 5),
        margin: const EdgeInsets.all(3),
        decoration: BoxDecoration(
            color: palette.secColor,
            borderRadius: const BorderRadius.all(Radius.circular(5))),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.name,
              style: TextStyle(
                  color: palette.mainColor, fontWeight: FontWeight.bold),
            ),
            const SizedBox(
              height: 5,
            ),
            Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Container(
                    height: 30,
                    width: 30,
                    decoration: BoxDecoration(
                        border: Border.all(color: palette.mainColor, width: 1),
                        color: widget.pickerColor,
                        borderRadius:
                            const BorderRadius.all(Radius.circular(5))),
                  ),
                  const VerticalDivider(
                    width: 10,
                  ),
                  Container(
                    padding: const EdgeInsets.all(5),
                    decoration: BoxDecoration(
                        borderRadius:
                            const BorderRadius.all(Radius.circular(5)),
                        border: Border.fromBorderSide(
                            BorderSide(color: palette.backColor))),
                    child: Text(
                      "#${widget.pickerColor.toHexString()}",
                      style: TextStyle(color: palette.mainColor),
                    ),
                  ),
                ]),
          ],
        ),
      ),
    );
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
    final palette = Palette.of(context);
    return Column(
      children: [
        Row(
          children: [
            IconButton(
                color: palette.mainColor,
                onPressed: () {
                  _changeAdjustment(false);
                },
                icon: const Icon(Icons.arrow_left)),
            Text(
                style: TextStyle(color: palette.mainColor),
                textAlign: TextAlign.center,
                _adjustment.toString()),
            IconButton(
                color: palette.mainColor,
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
                            WidgetStatePropertyAll(palette.mainColor)),
                    onPressed: _saveAdjustment,
                    child: Text(
                      "Save",
                      style: TextStyle(color: palette.secColor),
                    ))
              ],
            ))
      ],
    );
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
