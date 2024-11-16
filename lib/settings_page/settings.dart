import 'package:flutter/material.dart';
import 'package:prayerapp/global.dart';
import 'package:prayerapp/main.dart';
import 'package:prayerapp/settings_page/settings_rows.dart';
import 'package:prayerapp/sqlite.dart';
import 'package:prayerapp/widgets/section.dart';
import '../location_settings_page.dart';
import '../vibration_settings.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

// TODO: move widget to their correct files
class _SettingsPageState extends State<SettingsPage> {
  @override
  Widget build(BuildContext context) {
    return const SingleChildScrollView(
      child: Column(
        children: [
          MoreSettingsSection(),
          ColorsSettingsSection(),
          HijriCalibrationSection()
        ],
      ),
    );
  }
}

class MoreSettingsSection extends StatefulWidget {
  const MoreSettingsSection({super.key});

  @override
  State<MoreSettingsSection> createState() => _MoreSettingsSectionState();
}

class _MoreSettingsSectionState extends State<MoreSettingsSection> {
  @override
  Widget build(BuildContext context) {
    final palette = Palette.of(context);
    return Section(
      content: [
        MoreSettingWidget(
            onTap: () {
              goToPage(const VibrationSettingsPage());
            },
            text: "Tasbih Settings",
            icon: Icon(
              Icons.arrow_right,
              color: palette.mainColor,
            )),
        MoreSettingWidget(
            onTap: () {
              goToPage(const LocationSettingsPage());
            },
            text: "Location Settings",
            icon: Icon(
              Icons.arrow_right,
              color: palette.mainColor,
            ))
      ],
      title: "More Settings",
    );
  }

  void goToPage(Widget page) {
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => page));
  }
}

class ColorsSettingsSection extends StatelessWidget {
  const ColorsSettingsSection({super.key});

  @override
  Widget build(BuildContext context) {
    final palette = Palette.of(context);
    return Section(
      content: [
        ColorPickerRowWidget(
            name: "Main Color",
            pickerColor: palette.mainColor,
            colorKey: PrefsKeys.primaryColor),
        ColorPickerRowWidget(
            name: "Secondary Color",
            pickerColor: palette.secColor,
            colorKey: PrefsKeys.secondaryColor),
        ColorPickerRowWidget(
            name: "Background Color",
            pickerColor: palette.backColor,
            colorKey: PrefsKeys.backColor)
      ],
      title: "Colors Settings",
      icon: Icon(
        Icons.color_lens,
        color: Palette.of(context).mainColor,
      ),
    );
  }
}

class HijriCalibrationSection extends StatefulWidget {
  const HijriCalibrationSection({super.key});

  @override
  State<HijriCalibrationSection> createState() =>
      _HijriCalibrationSectionState();
}

class _HijriCalibrationSectionState extends State<HijriCalibrationSection> {
  late int _oldAdjustment;
  late int _newAdjustment;

  @override
  void initState() {
    _oldAdjustment = Prefs.prefs.getInt(PrefsKeys.adjustment)!;
    _newAdjustment = _oldAdjustment;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Section(
      content: [
        Row(
          children: [
            Icon(
              Icons.nightlight_outlined,
              color: Palette.of(context).mainColor,
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 0),
              decoration: const BoxDecoration(
                  // border: Border.fromBorderSide(
                  //     BorderSide(color: Palette.of(context).backColor)),
                  borderRadius: BorderRadius.all(Radius.circular(5))),
              child: DropdownButton(
                  style: TextStyle(
                      color: Color.lerp(Palette.of(context).mainColor,
                          Palette.of(context).secColor, 0.3)),
                  underline: const SizedBox(),
                  value: _newAdjustment,
                  items: List.generate(21, (i) {
                    int days = i - 10;
                    return DropdownMenuItem(
                      value: days,
                      child: Text("$days day(s)"),
                    );
                  }),
                  onChanged: (v) {
                    setState(() {
                      _newAdjustment = v!;
                    });
                  }),
            ),
          ],
        ),
      ],
      title: "Hijri Calibration",
      icon: IconButton(
          disabledColor: Palette.of(context).backColor,
          color: Palette.of(context).mainColor,
          onPressed: _oldAdjustment == _newAdjustment ? null : _saveAdjustment,
          icon: const Icon(Icons.save)),
    );
  }

  void _saveAdjustment() {
    setState(() {
      Prefs.prefs.setInt(PrefsKeys.adjustment, _newAdjustment);
      _oldAdjustment = _newAdjustment;
    });
    Db().deletePrayers();
  }
}
