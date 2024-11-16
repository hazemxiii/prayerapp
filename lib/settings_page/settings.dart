import 'package:flutter/material.dart';
import 'package:prayerapp/main.dart';
import 'package:prayerapp/settings_page/settings_rows.dart';
import '../location_settings_page.dart';
import '../vibration_settings.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  @override
  Widget build(BuildContext context) {
    final palette = Palette.of(context);
    return SingleChildScrollView(
      child: Column(
        children: [
          SettingRowWidget(
            onTap: () {
              Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => const VibrationSettingsPage()));
            },
            text: Text(
              "Vibration",
              style: TextStyle(color: palette.mainColor),
            ),
            icon: Icon(
              Icons.arrow_right,
              color: palette.mainColor,
            ),
          ),
          // TODO: make the colorKey the constants from PrefsKeys class
          ColorPickerRowWidget(
            name: "Main Color",
            pickerColor: palette.mainColor,
            colorKey: "primaryColor",
          ),
          ColorPickerRowWidget(
            name: "Secondary Color",
            pickerColor: palette.secColor,
            colorKey: "secondaryColor",
          ),
          ColorPickerRowWidget(
            name: "Background Color",
            pickerColor: palette.backColor,
            colorKey: "backColor",
          ),
          SettingRowWidget(
            onTap: () {
              Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => const LocationSettingsPage()));
            },
            text: Text(
              "Location",
              style: TextStyle(color: palette.mainColor),
            ),
            icon: Icon(
              Icons.arrow_right,
              color: palette.mainColor,
            ),
          ),
          SettingRowWidget(
            text: Text(
              "Hijri Calibration",
              style: TextStyle(color: palette.mainColor),
            ),
            icon: const HijriCalibrationWidget(),
          ),
          SettingRowWidget(
              text: Text(
                "Next Prayer Notification",
                style: TextStyle(color: palette.mainColor),
              ),
              icon: Switch(
                activeColor: palette.mainColor,
                value: true,
                onChanged: (v) {
                  setState(() {});
                },
              ),
              onTap: () {
                setState(() {});
              })
        ],
      ),
    );
  }
}
