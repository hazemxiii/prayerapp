import 'package:prayerapp/global.dart';

class TasbihSettingsModel {
  static bool? isEnabled;
  static bool? isModeAt;

  static void init() {
    isEnabled = Prefs.prefs.getBool(PrefsKeys.isVibrateOn);
    isModeAt = Prefs.prefs.getBool(PrefsKeys.isVibrationModeAt);
  }

  static void toggleVibration() {
    isEnabled = !isEnabled!;
  }

  static void setIsModeAt(bool v) {
    isModeAt = v;
  }
}
