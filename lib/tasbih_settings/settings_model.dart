import 'package:prayerapp/global.dart';

class TasbihSettingsModel {
  static bool isEnabled = Prefs.prefs.getBool(PrefsKeys.isVibrateOn)!;
  static bool isModeAt = Prefs.prefs.getBool(PrefsKeys.isVibrationModeAt)!;

  static void toggleVibration() {
    isEnabled = !isEnabled;
  }

  static void setIsModeAt(bool v) {
    isModeAt = v;
  }
}
