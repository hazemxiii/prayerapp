import 'package:flutter/material.dart';
import 'package:prayerapp/sqlite.dart';

class NextPrayerNot extends ChangeNotifier {
  String _name = "";
  String _date = "";
  String _time = "";
  String _timeLeft = "";
  double _percentageLeft = 0;

  void updateNextPrayer() async {
    final r = await Db().getNextPrayer();
    try {
      _name = r['name'];
      if (_name == "Dhuhr" && DateTime.now().weekday == DateTime.friday) {
        _name = "Jumu'a";
      }
      _date = r['date'];
      _percentageLeft = r['percentageLeft'];
      _time = r['time'];
      _timeLeft = r['timeLeft'];

      notifyListeners();
    } catch (e) {
      debugPrint("Error getting next prayer: ${e.toString()}");
    }
  }

  String get name => _name;
  String get date => _date;
  String get time => _time;
  String get timeLeft => _timeLeft;
  double get percentageLeft => _percentageLeft;
}
