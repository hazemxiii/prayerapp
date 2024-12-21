import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:prayerapp/global.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationManager {
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  AndroidInitializationSettings initializationSettingsAndroid =
      const AndroidInitializationSettings('launch_background');

  void init() async {
    final InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
    );
    await flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  void notify(String title, String text) async {
    const AndroidNotificationDetails androidNotificationDetails =
        AndroidNotificationDetails('PrayerNotification', 'Prayer Notification',
            channelDescription: 'Notifies user when prayer comes',
            importance: Importance.max,
            priority: Priority.high,
            ticker: 'ticker');
    const NotificationDetails notificationDetails =
        NotificationDetails(android: androidNotificationDetails);
    await flutterLocalNotificationsPlugin.show(
        0, title, text, notificationDetails);
  }

  void notifyAfter(
      String title, String text, Duration delay, bool isBefore) async {
    String prayerKey = "${title}_${isBefore ? "b" : "a"}";
    int id = _getPrayerID(prayerKey, isBefore);
    tz.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation(DateTime.now().timeZoneName));
    await flutterLocalNotificationsPlugin.zonedSchedule(
        id,
        title,
        text,
        tz.TZDateTime.now(tz.local).add(delay),
        NotificationDetails(
            android: AndroidNotificationDetails(prayerKey, title,
                channelDescription: 'Prayer Notification')),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime);
  }

  int _getPrayerID(String prayer, bool isBefore) {
    int index = Constants.prayerNames.values.toList().indexOf(prayer);
    if (index == -1) {
      index = 6;
    }

    return isBefore ? index : index + 100;
  }

  void show() async {
    final List<PendingNotificationRequest> pendingNotificationRequests =
        await flutterLocalNotificationsPlugin.pendingNotificationRequests();

    for (int i = 0; i < pendingNotificationRequests.length; i++) {
      debugPrint(pendingNotificationRequests[i].id.toString());
    }
  }
}
