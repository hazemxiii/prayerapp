import "package:flutter/material.dart";
import 'package:prayerapp/main.dart';
import 'package:prayerapp/tasbih_settings/settings_model.dart';
import 'package:prayerapp/tasbih_settings/tasbih_inputs.dart';
import 'package:prayerapp/tasbih_settings/vibration_section.dart';
import 'package:prayerapp/widgets/section.dart';
import '../global.dart';

class TasbihSettingsPage extends StatefulWidget {
  const TasbihSettingsPage({super.key});

  @override
  State<TasbihSettingsPage> createState() => _TasbihSettingsPageState();
}

class _TasbihSettingsPageState extends State<TasbihSettingsPage> {
  final vibrationController = TextEditingController(
      text: Prefs.prefs.getString(PrefsKeys.vibrateNumber));
  final _formKey = GlobalKey<FormState>();
  final _progressController = TextEditingController(
      text: Prefs.prefs.getInt(PrefsKeys.tasbihDailyProgress)!.toString());
  final _progressFormKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final palette = Palette.of(context);
    return Scaffold(
      backgroundColor: palette.backColor,
      appBar: AppBar(
        backgroundColor: palette.mainColor,
        foregroundColor: palette.secColor,
        centerTitle: true,
        title: const Text("Vibration Settings"),
      ),
      body: Column(
        children: [
          VibrationSection(formKey: _formKey, controller: vibrationController),
          DailyGoalSection(
              formKey: _progressFormKey, controller: _progressController),
          _saveButton()
        ],
      ),
    );
  }

  Widget _saveButton() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      child: MaterialButton(
        color: Palette.of(context).mainColor,
        onPressed: _onSave,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Save Settings",
              style: TextStyle(color: Palette.of(context).secColor),
            )
          ],
        ),
      ),
    );
  }

  void _onSave() {
    if (_formKey.currentState!.validate()) {
      updateSettings();
      Navigator.of(context).pop();
    }
  }

  void updateSettings() {
    Prefs.prefs.setString(PrefsKeys.vibrateNumber, vibrationController.text);
    Prefs.prefs
        .setBool(PrefsKeys.isVibrationModeAt, TasbihSettingsModel.isModeAt!);
    Prefs.prefs.setBool(PrefsKeys.isVibrateOn, TasbihSettingsModel.isEnabled!);
    Prefs.prefs.setInt(
        PrefsKeys.tasbihDailyProgress, int.parse(_progressController.text));
  }
}

class DailyGoalSection extends StatelessWidget {
  final TextEditingController controller;
  final GlobalKey<FormState> formKey;
  const DailyGoalSection(
      {super.key, required this.controller, required this.formKey});

  @override
  Widget build(BuildContext context) {
    return Section(
      content: [
        const SizedBox(
          height: 10,
        ),
        Text(
          "Number Of Tasbih's Per Day",
          style: TextStyle(color: Palette.of(context).mainColor),
        ),
        const SizedBox(
          height: 5,
        ),
        NumberInput(controller: controller, formKey: formKey)
      ],
      title: "Daily Goal",
    );
  }
}
