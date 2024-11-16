import 'package:flutter/material.dart';
import 'package:prayerapp/global.dart';
import 'package:vibration/vibration.dart';

class TasbihNotifier extends ChangeNotifier {
  int _total = 0;
  int _now = 0;
  int _today = 0;

  bool _isVibrateOn = false;
  String _vibrateNumsString = "-1";
  bool _isVibrationModeAt = true;
  List _vibrateNums = [];

  void setData() {
    resetTasbihOnDayChange();

    _now = Prefs.prefs.getInt(PrefsKeys.tasbihNow)!;
    _total = Prefs.prefs.getInt(PrefsKeys.totalTasbih)!;
    _today = Prefs.prefs.getInt(PrefsKeys.totalTasbihToday)!;

    _isVibrateOn = Prefs.prefs.getBool(PrefsKeys.isVibrateOn)!;
    _vibrateNumsString = Prefs.prefs.getString(PrefsKeys.vibrateNumber)!;
    _isVibrationModeAt = Prefs.prefs.getBool(PrefsKeys.isVibrationModeAt)!;
    _vibrateNums = _vibrateNumsString.split(",");
  }

  void resetTasbihOnDayChange() {
    String today = DateTime.now().toString();
    today = today.substring(0, today.indexOf(" "));

    String date = Prefs.prefs.getString(PrefsKeys.tasbihDate)!;

    if (today != date) {
      Prefs.prefs.setInt(PrefsKeys.totalTasbihToday, 0);
      Prefs.prefs.setString(PrefsKeys.tasbihDate, today);
    }
  }

  void clearTasbihNow() {
    Prefs.prefs.setInt(PrefsKeys.tasbihNow, 0);
    _now = 0;
    notifyListeners();
  }

  void changeTasbih(bool increase) {
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

    if (increase) {
      vibrate();
    }

    notifyListeners();
  }

  void vibrate() {
    if (isVibrationNeeded()) {
      Vibration.vibrate(duration: 1000).catchError((e) {
        debugPrint("Couldn't vibrate ${e.toString()}");
      });
    }
  }

  bool isVibrationNeeded() {
    if (!_isVibrateOn) {
      return false;
    }
    if ((_isVibrationModeAt && _vibrateNums.contains(_now)) ||
        !_isVibrationModeAt && _now % int.parse(_vibrateNumsString) == 0) {
      return true;
    }
    return false;
  }

  void clearTasbih() {
    _today = 0;
    _total = 0;
    Prefs.prefs.setInt(PrefsKeys.totalTasbihToday, 0);
    Prefs.prefs.setInt(PrefsKeys.totalTasbih, 0);
    clearTasbihNow();
  }

  int get total => _total;
  int get now => _now;
  int get today => _today;

  bool get isVibrateOn => _isVibrateOn;
  String get vibrateNumsString => _vibrateNumsString;
  bool get isVibrationModeAt => _isVibrationModeAt;
  List get vibrateNums => _vibrateNums;
}
