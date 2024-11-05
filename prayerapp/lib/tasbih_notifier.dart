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
// gets the total in the button before resetting it
    if (!Prefs.prefs.containsKey("totalTasbih")) {
      Prefs.prefs.setInt("totalTasbih", 0);
    }
    if (!Prefs.prefs.containsKey("totalTasbihToday")) {
      Prefs.prefs.setInt("totalTasbihToday", 0);
    }
    if (!Prefs.prefs.containsKey("tasbihNow")) {
      Prefs.prefs.setInt("tasbihNow", 0);
    }
    if (!Prefs.prefs.containsKey("tasbihDate")) {
      String date = DateTime.now().toString();
      date = date.substring(0, date.indexOf(" "));

      Prefs.prefs.setString("tasbihDate", date);
    }

    // if the date changed, reset the total of the day to 0
    String today = DateTime.now().toString();
    today = today.substring(0, today.indexOf(" "));

    String? date = Prefs.prefs.getString("tasbihDate");

    if (today != date) {
      Prefs.prefs.setInt("totalTasbihToday", 0);
      Prefs.prefs.setString("tasbihDate", today);
    }

    _now = Prefs.prefs.getInt("tasbihNow")!;

    if (!Prefs.prefs.containsKey("totalTasbih")) {
      Prefs.prefs.setInt("totalTasbih", 0);
    }
    if (!Prefs.prefs.containsKey("totalTasbihToday")) {
      Prefs.prefs.setInt("totalTasbihToday", 0);
    }
    _total = Prefs.prefs.getInt("totalTasbih")!;
    _today = Prefs.prefs.getInt("totalTasbihToday")!;

    if (!Prefs.prefs.containsKey("vibrationBool")) {
      Prefs.prefs.setBool("vibrationBool", true);
    }
    if (!Prefs.prefs.containsKey("vibrationCount")) {
      Prefs.prefs.setString("vibrationCount", "33");
    }
    if (!Prefs.prefs.containsKey("isOn")) {
      Prefs.prefs.setBool("isOn", false);
    }
    _vibrate = Prefs.prefs.getBool("vibrationBool")!;
    _vibrateOn = Prefs.prefs.getString("vibrationCount")!;
    _isOn = Prefs.prefs.getBool("isOn")!;
    _vibrateNums = _vibrateOn.split(",");
    // notifyListeners();
  }

  void clearTasbihNow() {
    Prefs.prefs.setInt("tasbihNow", 0);
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
    Prefs.prefs.setInt("totalTasbih", _total);

    _today = today + number;
    Prefs.prefs.setInt("totalTasbihToday", today);

    _now = _now + number;
    Prefs.prefs.setInt("tasbihNow", now);

    notifyListeners();
  }

  void clearTasbih() {
    // clears the tasbih total
    _today = 0;
    _total = 0;
    Prefs.prefs.setInt("totalTasbihToday", 0);
    Prefs.prefs.setInt("totalTasbih", 0);
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
