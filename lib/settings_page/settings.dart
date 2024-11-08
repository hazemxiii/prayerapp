import 'package:flutter/material.dart';
import 'package:prayerapp/color_notifier.dart';
import 'package:prayerapp/settings_page/settings_rows.dart';
import 'package:provider/provider.dart';
import '../location_settings_page.dart';
import '../vibration_settings.dart';

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
            // TODO: make the colorKey the constants from PrefsKeys class
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
