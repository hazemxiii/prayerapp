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
            icon: "notification_icon",
            ticker: 'ticker');
    const NotificationDetails notificationDetails =
        NotificationDetails(android: androidNotificationDetails);
    await flutterLocalNotificationsPlugin.show(
        0, title, text, notificationDetails);
  }

  void notifyAfter(String title, String text, Duration delay,
      {required bool isBefore}) async {
    try {
      int id = _getPrayerID(title, isBefore);
      flutterLocalNotificationsPlugin.cancel(id);
      AndroidNotificationDetails androidNotificationDetails =
          const AndroidNotificationDetails("prayers", "Prayers Notifications",
              channelDescription: 'Notifies user when prayer comes',
              sound: RawResourceAndroidNotificationSound("notification"),
              importance: Importance.max,
              priority: Priority.high,
              icon: "notification_icon",
              ticker: 'ticker');
      tz.initializeTimeZones();
      tz.setLocalLocation(
          tz.getLocation(tz.TZDateTime.now(tz.local).timeZoneName));
      await flutterLocalNotificationsPlugin.zonedSchedule(
          id,
          title,
          text,
          tz.TZDateTime.now(tz.local).add(delay),
          NotificationDetails(android: androidNotificationDetails),
          androidScheduleMode: AndroidScheduleMode.alarmClock,
          // matchDateTimeComponents: DateTimeComponents.time,
          uiLocalNotificationDateInterpretation:
              UILocalNotificationDateInterpretation.absoluteTime);
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  Future<bool> isNotificationEnabled(String prayer, bool isBefore) async {
    int id = _getPrayerID(prayer, isBefore);
    final pendingNotifications =
        await flutterLocalNotificationsPlugin.pendingNotificationRequests();
    for (var not in pendingNotifications) {
      if (not.id == id) {
        return true;
      }
    }
    return false;
  }

  void cancel(String prayer, bool isBefore) {
    int id = _getPrayerID(prayer, isBefore);
    flutterLocalNotificationsPlugin.cancel(id);
  }

  void cancelAll() {
    flutterLocalNotificationsPlugin.cancelAll();
  }

  int _getPrayerID(String prayer, bool isBefore) {
    int index = Constants.prayerNames.values.toList().indexOf(prayer);
    if (index == -1) {
      index = 6;
    }

    return isBefore ? index : index + 100;
  }

  // Future<bool> _isNotificationPending(int id) async {
  //   final List<PendingNotificationRequest> pendingNotificationRequests =
  //       await flutterLocalNotificationsPlugin.pendingNotificationRequests();
  //   for (int i = 0; i < pendingNotificationRequests.length; i++) {
  //     if (pendingNotificationRequests[i].id == id) {
  //       pendingNotificationRequests[i];
  //       return true;
  //     }
  //   }
  //   return false;
  // }
}
