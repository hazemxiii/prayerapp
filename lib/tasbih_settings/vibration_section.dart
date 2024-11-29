import 'package:flutter/material.dart';
import 'package:prayerapp/main.dart';
import 'package:prayerapp/tasbih_settings/settings_model.dart';
import 'package:prayerapp/tasbih_settings/tasbih_inputs.dart';
import 'package:prayerapp/widgets/section.dart';

class VibrationSection extends StatefulWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController controller;
  const VibrationSection(
      {super.key, required this.formKey, required this.controller});

  @override
  State<VibrationSection> createState() => _VibrationSectionState();
}

class _VibrationSectionState extends State<VibrationSection> {
  @override
  void initState() {
    TasbihSettingsModel.init();
    vibrateRadio = TasbihSettingsModel.isModeAt! ? "on" : "every";
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  late String vibrateRadio;

  @override
  Widget build(BuildContext context) {
    final palette = Palette.of(context);
    return Section(
      title: "Vibration",
      content: [
        Row(
          children: [
            Text(
              "Enable Vibration",
              style: TextStyle(color: palette.mainColor),
            ),
            Transform.scale(
              scale: 0.8,
              child: Switch(
                  activeColor: palette.mainColor,
                  inactiveThumbColor: palette.mainColor,
                  inactiveTrackColor: palette.secColor,
                  value: TasbihSettingsModel.isEnabled!,
                  onChanged: _toggleVibration),
            ),
          ],
        ),
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              children: [
                Radio(
                    fillColor: WidgetStatePropertyAll(palette.mainColor),
                    value: "on",
                    groupValue: vibrateRadio,
                    onChanged: _changeTasbihMode),
                Text("Vibrate On Specific Numbers",
                    style: TextStyle(color: palette.mainColor))
              ],
            ),
            const SizedBox(
              height: 10,
            ),
            Row(
              children: [
                Radio(
                    fillColor: WidgetStatePropertyAll(palette.mainColor),
                    value: "every",
                    groupValue: vibrateRadio,
                    onChanged: _changeTasbihMode),
                Text(
                  "Vibrate Every x tasbihas",
                  style: TextStyle(color: palette.mainColor),
                )
              ],
            ),
            vibrateRadio == "on"
                ? TasbihTextInput(
                    controller: widget.controller, formKey: widget.formKey)
                : NumberInput(
                    controller: widget.controller, formKey: widget.formKey),
          ],
        )
      ],
      icon: Icon(
        Icons.vibration_outlined,
        color: TasbihSettingsModel.isEnabled!
            ? Palette.of(context).mainColor
            : Palette.of(context).backColor,
      ),
    );
  }

  void _changeTasbihMode(dynamic v) {
    TasbihSettingsModel.setIsModeAt(v == "on");
    setState(() {
      vibrateRadio = v!;
    });
  }

  void _toggleVibration(dynamic v) {
    setState(() {
      TasbihSettingsModel.toggleVibration();
    });
  }
}
