import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:prayerapp/color_notifier.dart';
import 'package:provider/provider.dart';

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
