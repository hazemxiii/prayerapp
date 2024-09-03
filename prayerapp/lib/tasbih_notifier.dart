import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TasbihNotifier extends ChangeNotifier {
  int _total = 0;
  int _now = 0;
  int _today = 0;

  bool _vibrate = false;
  String _vibrateOn = "-1";
  bool _isOn = true;
  List _vibrateNums = [];

  void setData() async {
// gets the total in the button before resetting it
    await SharedPreferences.getInstance().then((prefs) {
      if (!prefs.containsKey("totalTasbih")) {
        prefs.setInt("totalTasbih", 0);
      }
      if (!prefs.containsKey("totalTasbihToday")) {
        prefs.setInt("totalTasbihToday", 0);
      }
      if (!prefs.containsKey("tasbihNow")) {
        prefs.setInt("tasbihNow", 0);
      }
      if (!prefs.containsKey("tasbihDate")) {
        String date = DateTime.now().toString();
        date = date.substring(0, date.indexOf(" "));

        prefs.setString("tasbihDate", date);
      }

      // if the date changed, reset the total of the day to 0
      String today = DateTime.now().toString();
      today = today.substring(0, today.indexOf(" "));

      String? date = prefs.getString("tasbihDate");

      if (today != date) {
        prefs.setInt("totalTasbihToday", 0);
        prefs.setString("tasbihDate", today);
      }

      _now = prefs.getInt("tasbihNow")!;

      if (!prefs.containsKey("totalTasbih")) {
        prefs.setInt("totalTasbih", 0);
      }
      if (!prefs.containsKey("totalTasbihToday")) {
        prefs.setInt("totalTasbihToday", 0);
      }
      _total = prefs.getInt("totalTasbih")!;
      _today = prefs.getInt("totalTasbihToday")!;

      if (!prefs.containsKey("vibrationBool")) {
        prefs.setBool("vibrationBool", true);
      }
      if (!prefs.containsKey("vibrationCount")) {
        prefs.setString("vibrationCount", "33");
      }
      if (!prefs.containsKey("isOn")) {
        prefs.setBool("isOn", false);
      }
      _vibrate = prefs.getBool("vibrationBool")!;
      _vibrateOn = prefs.getString("vibrationCount")!;
      _isOn = prefs.getBool("isOn")!;
      _vibrateNums = _vibrateOn.split(",");
    });
    notifyListeners();
  }

  void clearTasbihNow() async {
    await SharedPreferences.getInstance().then((prefs) {
      prefs.setInt("tasbihNow", 0);
      _now = 0;
      notifyListeners();
    });
  }

  void changeTasbih(bool increase) async {
    // increases all tasbih totals by 1
    await SharedPreferences.getInstance().then((prefs) {
      int number = increase ? 1 : -1;
      if (number == -1 && now == 0) {
        return;
      }
      _total = total + number;
      prefs.setInt("totalTasbih", _total);

      _today = today + number;
      prefs.setInt("totalTasbihToday", today);

      _now = _now + number;
      prefs.setInt("tasbihNow", now);

      notifyListeners();
    });
  }

  void clearTasbih() async {
    // clears the tasbih total
    await SharedPreferences.getInstance().then((prefs) {
      _today = 0;
      _total = 0;
      prefs.setInt("totalTasbihToday", 0);
      prefs.setInt("totalTasbih", 0);
      clearTasbihNow();
    });
  }

  int get total => _total;
  int get now => _now;
  int get today => _today;

  bool get vibrate => _vibrate;
  String get vibrateOn => _vibrateOn;
  bool get isOn => _isOn;
  List get vibrateNums => _vibrateNums;
}
