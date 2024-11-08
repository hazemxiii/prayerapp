import 'package:flutter/material.dart';
import 'package:prayerapp/global.dart';

class TasbihNotifier extends ChangeNotifier {
  int _total = 0;
  int _now = 0;
  int _today = 0;

  bool _vibrate = false;
  String _vibrateOn = "-1";
  bool _isOn = true;
  List _vibrateNums = [];

  void setData() {
    // if the date changed, reset the total of the day to 0
    String today = DateTime.now().toString();
    today = today.substring(0, today.indexOf(" "));

    String? date = Prefs.prefs.getString(PrefsKeys.tasbihDate);

    if (today != date) {
      Prefs.prefs.setInt(PrefsKeys.totalTasbihToday, 0);
      Prefs.prefs.setString(PrefsKeys.tasbihDate, today);
    }

    _now = Prefs.prefs.getInt(PrefsKeys.tasbihNow)!;

    if (!Prefs.prefs.containsKey(PrefsKeys.totalTasbih)) {
      Prefs.prefs.setInt(PrefsKeys.totalTasbih, 0);
    }
    if (!Prefs.prefs.containsKey(PrefsKeys.totalTasbihToday)) {
      Prefs.prefs.setInt(PrefsKeys.totalTasbihToday, 0);
    }
    _total = Prefs.prefs.getInt(PrefsKeys.totalTasbih)!;
    _today = Prefs.prefs.getInt(PrefsKeys.totalTasbihToday)!;

    _vibrate = Prefs.prefs.getBool(PrefsKeys.isVibrateOn)!;
    _vibrateOn = Prefs.prefs.getString(PrefsKeys.vibrateNumber)!;
    _isOn = Prefs.prefs.getBool(PrefsKeys.isVibrationModeAt)!;
    _vibrateNums = _vibrateOn.split(",");
    // notifyListeners();
  }

  void clearTasbihNow() {
    Prefs.prefs.setInt(PrefsKeys.tasbihNow, 0);
    _now = 0;
    notifyListeners();
  }

  void changeTasbih(bool increase) {
    // increases all tasbih totals by 1
    int number = increase ? 1 : -1;
    if (number == -1 && now == 0) {
      return;
    }
    _total = total + number;
    Prefs.prefs.setInt(PrefsKeys.totalTasbih, _total);

    _today = today + number;
    Prefs.prefs.setInt(PrefsKeys.totalTasbihToday, today);

    _now = _now + number;
    Prefs.prefs.setInt(PrefsKeys.tasbihNow, now);

    notifyListeners();
  }

  void clearTasbih() {
    // clears the tasbih total
    _today = 0;
    _total = 0;
    Prefs.prefs.setInt(PrefsKeys.totalTasbihToday, 0);
    Prefs.prefs.setInt(PrefsKeys.totalTasbih, 0);
    clearTasbihNow();
  }

  int get total => _total;
  int get now => _now;
  int get today => _today;

  bool get vibrate => _vibrate;
  String get vibrateOn => _vibrateOn;
  bool get isOn => _isOn;
  List get vibrateNums => _vibrateNums;
}
