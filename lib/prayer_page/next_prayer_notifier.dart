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
    _name = r['name'];
    _date = r['date'];
    _percentageLeft = r['percentageLeft'];
    _time = r['time'];
    _timeLeft = r['timeLeft'];

    notifyListeners();
  }

  String get name => _name;
  String get date => _date;
  String get time => _time;
  String get timeLeft => _timeLeft;
  double get percentageLeft => _percentageLeft;
}
