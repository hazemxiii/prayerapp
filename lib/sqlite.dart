import 'dart:io';

import 'package:flutter/material.dart';
import 'package:prayerapp/global.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart';

class Db {
  static late Database database;
  static String path = "";
  Future<void> init() async {
    if (Platform.isWindows) {
      sqfliteFfiInit();
      var databaseFactory = databaseFactoryFfi;
      path = join((await getApplicationDocumentsDirectory()).path, "prayerapp",
          "db.db");
      database = await databaseFactory.openDatabase(path);
    } else {
      path = join(await getDatabasesPath(), "db.db");
      database = await openDatabase(path);
    }
    await database.execute(
        "CREATE TABLE IF NOT EXISTS prayers(prayerName text,`date` date,`time` time,displayDate date)");

    await database.execute(
        "CREATE TABLE IF NOT EXISTS hijriDate(`date` date, hijri text)");
  }

  Future<void> deleteDb() async {
    await deleteDatabase(path);
  }

  void _insertHijriDate(DateTime date, String hijriDate) async {
    String dateString = CustomDateFormat.getShortDate(date, true);
    await database
        .rawDelete("DELETE FROM hijriDate WHERE `date` = '$dateString'");
    await database.rawInsert("INSERT INTO hijriDate(`date`,hijri) VALUES(?,?)",
        [dateString, hijriDate]);
  }

  Future<String> getHijriDate(DateTime date) async {
    final r = await database.rawQuery(
        "SELECT hijri FROM hijriDate WHERE `date` = '${CustomDateFormat.getShortDate(date, true)}'");

    if (r.isEmpty) {
      return "";
    }

    return r[0]['hijri'] as String;
  }

  void _insertPrayer(Transaction tr, List values) {
    try {
      tr.rawInsert(
          "INSERT INTO prayers(prayerName,date,time,displayDate) VALUES(?,?,?,?)",
          values);
    } catch (e) {
      debugPrint("Error inserting data: ${e.toString()}");
    }
  }

  void insertPrayerDay(List prayerDay) async {
    int americanDateIndex = 7;
    List rows = [];
    DateTime date = DateTime.parse(prayerDay[americanDateIndex]);
    DateTime lastPrayerOfDayDate =
        DateTime.parse("${prayerDay[americanDateIndex]} ${prayerDay[0]}");
    for (int i = 0; i < Constants.prayerNames.length; i++) {
      String prayerName = Constants.prayerNames[i];
      DateTime prayerDate =
          DateTime.parse("${prayerDay[americanDateIndex]} ${prayerDay[i]}");

      DateTime displayDate = prayerDate;

      if (prayerDate.isBefore(lastPrayerOfDayDate)) {
        prayerDate = prayerDate.add(const Duration(days: 1));
      }
      lastPrayerOfDayDate = prayerDate;
      rows.add([
        prayerName,
        CustomDateFormat.getShortDate(prayerDate, true),
        CustomDateFormat.timeToString(TimeOfDay.fromDateTime(prayerDate)),
        CustomDateFormat.getShortDate(displayDate, true),
      ]);
    }
    database.transaction((tr) async {
      for (int i = 0; i < rows.length; i++) {
        _insertPrayer(tr, rows[i]);
      }
    });
    _insertHijriDate(date, prayerDay[6]);
    _deletePrayerDaysBefore(
        lastPrayerOfDayDate.subtract(const Duration(days: 29)));
  }

  Future<List<Map>> getPrayersOfDay(DateTime date) async {
    return await database.rawQuery(
        "SELECT * FROM prayers WHERE displayDate == '${CustomDateFormat.getShortDate(date, true)}'");
  }

  Future<Map> _getNextPrayerData(String date, String time) async {
    List data = await database.rawQuery(
        "SELECT * FROM prayers WHERE (date == '$date' and time > '$time' or date>'$date') order by date limit 1");
    if (data.isEmpty) {
      return {};
    }
    return data[0];
  }

  Future<Map> _getLastPrayerData(String date, String time) async {
    List data = await database.rawQuery(
        "SELECT * FROM prayers WHERE (date == '$date' and time <= '$time' or date<'$date') order by date desc, time desc limit 1");
    if (data.isEmpty) {
      return {};
    }
    return data[0];
  }

  Future<void> deletePrayers() async {
    await database.rawDelete("DELETE FROM prayers");
  }

  Future<Map> getNextPrayer() async {
    String date = CustomDateFormat.getShortDate(DateTime.now(), true);
    String time = CustomDateFormat.timeToString(TimeOfDay.now());
    Map nextPrayer = await _getNextPrayerData(date, time);
    Map lastPrayer = await _getLastPrayerData(date, time);

    if (nextPrayer.isEmpty || lastPrayer.isEmpty) {
      return {};
    }
    DateTime nextPrayerDate = _parsePrayerDate(nextPrayer);
    DateTime lastPrayerDate = _parsePrayerDate(lastPrayer);

    Duration timeTillNextPrayer = nextPrayerDate.difference(DateTime.now());
    Duration totalDifference = nextPrayerDate.difference(lastPrayerDate);

    return {
      "name": nextPrayer['prayerName'],
      "timeLeft": _formatTimeLeft(timeTillNextPrayer),
      "time": CustomDateFormat.formatTimeAs12HourFromDate(nextPrayerDate),
      "percentageLeft":
          _getPercentageOfTimeLeft(totalDifference, timeTillNextPrayer)
    };
  }

  DateTime _parsePrayerDate(Map prayer) {
    return DateTime.parse("${prayer['date']} ${prayer['time']}");
  }

  String _formatTimeLeft(Duration timeLeft) {
    String s = timeLeft.toString();
    return s.substring(0, s.indexOf(".")).padLeft(8, "0");
  }

  double _getPercentageOfTimeLeft(
      Duration totalDifference, Duration timeLeftTillNextPrayer) {
    return timeLeftTillNextPrayer.inSeconds.toDouble() /
        totalDifference.inSeconds.toDouble();
  }

  void _deletePrayerDaysBefore(DateTime date) {
    String dateText = CustomDateFormat.getShortDate(date, true);
    database.rawDelete("DELETE FROM prayers WHERE displayDate < '$dateText'");
  }
}
