import "dart:convert";

import "package:flutter/material.dart";
import "package:shared_preferences/shared_preferences.dart";

class Constants {
  static Map prayerNames = {
    0: "Fajr",
    1: "Sunrise",
    2: "Dhuhr",
    3: "Asr",
    4: "Maghrib",
    5: "Isha'a"
  };
}

class PrefsKeys {
  static const String nextPrayerName = "nextPrayerName";
  static const String nextPrayerTime = "nextPrayerTime";
  static const String isServiceOn = "isServiceOn";
  static const String city = "city";
  static const String country = "country";
  static const String primaryColor = "primaryColor";
  static const String secondaryColor = "secondaryColor";
  static const String backColor = "backColor";
  static const String prayers = "prayers";
  static const String la = "la";
  static const String lo = "lo";
  static const String totalTasbih = "totalTasbih";
  static const String totalTasbihToday = "totalTasbihToday";
  static const String tasbihNow = "tasbihNow";
  static const String tasbihDate = "tasbihDate";
  static const String isVibrateOn = "isVibrateOn";
  static const String vibrateNumber = "vibrateNumber";
  static const String isVibrationModeAt = "isVibrationModeAt";
}

class Prefs {
  static late SharedPreferences prefs;
  static Future<void> initPrefs() async {
    prefs = await SharedPreferences.getInstance();
    if (!prefs.containsKey(PrefsKeys.nextPrayerName)) {
      prefs.setString(PrefsKeys.nextPrayerName, "");
    }
    if (!prefs.containsKey(PrefsKeys.nextPrayerTime)) {
      prefs.setString(PrefsKeys.nextPrayerTime, DateTime.now().toString());
    }
    if (!prefs.containsKey(PrefsKeys.isServiceOn)) {
      prefs.setBool(PrefsKeys.isServiceOn, true);
    }
    if (!prefs.containsKey(PrefsKeys.city)) {
      prefs.setString(PrefsKeys.city, "");
    }
    if (!prefs.containsKey(PrefsKeys.country)) {
      prefs.setString(PrefsKeys.country, "");
    }
    if (!prefs.containsKey(PrefsKeys.primaryColor)) {
      prefs.setInt(PrefsKeys.primaryColor, Colors.lightBlue.value);
    }
    if (!prefs.containsKey(PrefsKeys.secondaryColor)) {
      prefs.setInt(PrefsKeys.secondaryColor, Colors.white.value);
    }
    if (!prefs.containsKey(PrefsKeys.backColor)) {
      prefs.setInt(PrefsKeys.backColor, Colors.lightBlue[200]!.value);
    }
    if (!prefs.containsKey(PrefsKeys.prayers)) {
      prefs.setString(PrefsKeys.prayers, jsonEncode({}));
    }
    if (!Prefs.prefs.containsKey(PrefsKeys.totalTasbih)) {
      Prefs.prefs.setInt(PrefsKeys.totalTasbih, 0);
    }
    if (!Prefs.prefs.containsKey(PrefsKeys.totalTasbihToday)) {
      Prefs.prefs.setInt(PrefsKeys.totalTasbihToday, 0);
    }
    if (!Prefs.prefs.containsKey(PrefsKeys.tasbihNow)) {
      Prefs.prefs.setInt(PrefsKeys.tasbihNow, 0);
    }
    if (!Prefs.prefs.containsKey(PrefsKeys.tasbihDate)) {
      String date = DateTime.now().toString();
      date = date.substring(0, date.indexOf(" "));

      Prefs.prefs.setString(PrefsKeys.tasbihDate, date);
    }
    if (!Prefs.prefs.containsKey(PrefsKeys.isVibrateOn)) {
      Prefs.prefs.setBool(PrefsKeys.isVibrateOn, true);
    }
    if (!Prefs.prefs.containsKey(PrefsKeys.vibrateNumber)) {
      Prefs.prefs.setString(PrefsKeys.vibrateNumber, "33");
    }
    if (!Prefs.prefs.containsKey(PrefsKeys.isVibrationModeAt)) {
      Prefs.prefs.setBool(PrefsKeys.isVibrationModeAt, false);
    }
  }

  void printPrefs() {
    List keys = prefs.getKeys().toList();
    debugPrint(keys.toString());
    for (int i = 0; i < keys.length; i++) {
      String key = keys[i];
      debugPrint("$key: ${prefs.get(key).toString()}");
    }
  }
}
