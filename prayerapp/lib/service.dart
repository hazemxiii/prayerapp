import 'dart:async';
import 'dart:convert';
import 'dart:ui';
import 'package:prayerapp/global.dart';
import "package:shared_preferences/shared_preferences.dart";
import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

void startBackgroundService() {
  final service = FlutterBackgroundService();
  service.startService();
}

void stopBackgroundService() {
  final service = FlutterBackgroundService();
  service.invoke("stop");
}

Future<void> initializeService() async {
  final service = FlutterBackgroundService();

  const AndroidNotificationChannel channel = AndroidNotificationChannel(
    "prayerNotifier", // id
    'prayerNotifier', // title
    description: "Notifies the user when it's time for prayers", // description
    importance: Importance.low, // importance must be at low or higher level
  );

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(channel);

  await service.configure(
      androidConfiguration: AndroidConfiguration(
          // this will be executed when app is in foreground or background in separated isolate
          onStart: onStart,

          // auto start service
          autoStart: true,
          isForegroundMode: true,
          notificationChannelId:
              "prayerNotifier", // this must match with notification channel you created above.
          initialNotificationTitle: 'prayerNotifier',
          initialNotificationContent: 'Initializing',
          foregroundServiceNotificationId: 15,
          autoStartOnBoot: true),
      iosConfiguration: IosConfiguration());
}

@pragma('vm:entry-point')
Future<bool> onIosBackground(ServiceInstance service) async {
  WidgetsFlutterBinding.ensureInitialized();
  DartPluginRegistrant.ensureInitialized();

  return true;
}

@pragma('vm:entry-point')
Future<void> onStart(ServiceInstance service) async {
  // Only available for flutter 3.0.0 and later
  DartPluginRegistrant.ensureInitialized();

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  service.on("stop").listen((event) {
    service.stopSelf();
  });

  service.on("start").listen((event) {});

  showNotification(service, flutterLocalNotificationsPlugin);
}

void showNotification(ServiceInstance service,
    FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin) async {
  List prayerNotificationData = await getPrayerNotification();
  Duration delay = prayerNotificationData[0];
  String prayerName = prayerNotificationData[1];

  Future.delayed(delay, () async {
    if (service is AndroidServiceInstance) {
      if (await service.isForegroundService()) {
        flutterLocalNotificationsPlugin.show(
          16,
          prayerName,
          '',
          const NotificationDetails(
            android: AndroidNotificationDetails(
              "notificationChannelId",
              'MY FOREGROUND SERVICE',
              icon: 'ic_bg_service_small',
              ongoing: false,
            ),
          ),
        );
      }
    }
    showNotification(service, flutterLocalNotificationsPlugin);
  });
}

Future<List> getPrayerNotification() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  Map prayers = jsonDecode(prefs.getString("prayers")!);
  DateTime today = DateTime.now();
  DateTime yesterday = DateTime.now().subtract(const Duration(days: 1));
  DateTime tomorrow = DateTime.now().add(const Duration(days: 1));
  List todayPrayers = prayers[
      "${today.year}-${'${today.month}'.padLeft(2, "0")}-${'${today.day}'.padLeft(2, "0")}"];
  List tomorrowPrayers = prayers[
      "${tomorrow.year}-${'${tomorrow.month}'.padLeft(2, "0")}-${'${tomorrow.day}'.padLeft(2, "0")}"];
  List yesterdayPrayers = prayers[
      "${yesterday.year}-${'${yesterday.month}'.padLeft(2, "0")}-${'${yesterday.day}'.padLeft(2, "0")}"];

  List minYesterday =
      await getNextNotificationForADay(yesterday, yesterdayPrayers, prefs);
  List minToday = await getNextNotificationForADay(today, todayPrayers, prefs);
  List minTomorrow =
      await getNextNotificationForADay(tomorrow, tomorrowPrayers, prefs);

  DateTime min = minYesterday[0];
  String minPrayer = minYesterday[1];
  if (minToday[0].isBefore(min)) {
    min = minToday[0];
    minPrayer = minToday[1];
  }
  if (minTomorrow[0].isBefore(min)) {
    min = minTomorrow[0];
    minPrayer = minTomorrow[1];
    if (min.weekday == 5 && minPrayer == "Dhuhr") {
      minPrayer = "Jumu'a";
    }
  }
  return [min.difference(DateTime.now()), minPrayer];
}

Future<List> getNextNotificationForADay(
    DateTime day, List dayPrayers, SharedPreferences prefs) async {
  DateTime now = DateTime.now();
  DateTime minDate = now.add(const Duration(days: 10));
  String minPrayer = "";
  for (int i = 0; i < 6; i++) {
    String prayerName = PrayerNames.prayerNames[i];
    String prayerTime = dayPrayers[i];
    DateTime prayerDate = DateTime.parse(
        "${day.toString().substring(0, day.toString().indexOf(" "))} $prayerTime");
    List notificationData = await getNotificationsData(prayerName);
    int before = notificationData[0];
    int after = notificationData[1];
    if (before != -1) {
      DateTime notificationBefore =
          prayerDate.subtract(Duration(minutes: before));
      if (!notificationBefore.isBefore(now) &&
          notificationBefore.isBefore(minDate)) {
        minDate = notificationBefore;
        minPrayer = prayerName;
      }
    }
    if (after != -1) {
      DateTime notificationAfter = prayerDate.add(Duration(minutes: after));

      if (!notificationAfter.isBefore(now) &&
          notificationAfter.isBefore(minDate)) {
        minDate = notificationAfter;
        minPrayer = prayerName;
      }
    }
  }
  return [minDate, minPrayer];
}

Future<List> getNotificationsData(String prayer) async {
  SharedPreferences sprefs = await SharedPreferences.getInstance();

  String keyBefore = "${prayer}_notification_b";
  String keyAfter = "${prayer}_notification_a";

  if (!sprefs.containsKey(keyBefore)) {
    sprefs.setInt(keyBefore, -1);
  }

  if (!sprefs.containsKey(keyAfter)) {
    sprefs.setInt(keyAfter, -1);
  }

  return [sprefs.getInt(keyBefore), sprefs.getInt(keyAfter)];
}
