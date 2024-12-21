// ignore_for_file: use_build_context_synchronously
import "dart:io";
import "package:flutter/material.dart";
import "package:prayerapp/color_notifier.dart";
import "package:prayerapp/location_class/location_class.dart";
import "package:prayerapp/notification/notification_manager.dart";
import "package:prayerapp/prayer_page/next_prayer_notifier.dart";
import "package:prayerapp/prayer_page/prayer_page.dart";
import "package:prayerapp/sqlite.dart";
import "package:prayerapp/tasbih_page/tasbih_notifier.dart";
import "package:workmanager/workmanager.dart";
// import "qiblah.dart";
import "tasbih_page/tasbih_page.dart";
import "settings_page/settings.dart";
import 'package:provider/provider.dart';
import "global.dart";
import "service.dart";

@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    await Prefs.initPrefs();
    await Db().init();
    List prayers = Constants.prayerNames.values.toList();
    DateTime now = DateTime.now();
    for (int i = 0; i < prayers.length; i++) {
      String prayer = prayers[i];
      List<int> notificationTimes = Prefs().getPrayerNotification(prayer);
      int notificationBeforeIndex = notificationTimes[0];
      int notificationAfterIndex = notificationTimes[1];

      final prayerData = await Db().getNextPrayerData(
          CustomDateFormat.getShortDate(now, true),
          CustomDateFormat.timeToString(TimeOfDay.fromDateTime(now)),
          prayer: prayer);

      final prayerDate =
          DateTime.tryParse("${prayerData['date']} ${prayerData['time']}");
      if (prayerDate == null) {
        return Future.value(false);
      }
      if (notificationBeforeIndex != 0) {
        // int notificationBefore = notificationBeforeIndex - 1;
        // DateTime notificationDate = prayerDate.copyWith();
        // notificationDate =
        //     notificationDate.subtract(Duration(minutes: notificationBefore));
        // Duration timeLeft = notificationDate.difference(now);

        // NotificationManager().notifyAfter(prayer,
        //     "$prayer Adhan In $notificationBefore Minutes", timeLeft, true);
        setNotification(
            prayer, true, now, notificationBeforeIndex - 1, prayerDate);
      }
      if (notificationAfterIndex != 0) {
        setNotification(prayer, false, now, notificationAfterIndex, prayerDate);
      }
    }

    return Future.value(true);
  });
}

void setNotification(String prayer, bool isBefore, DateTime now,
    int notificationTime, DateTime prayerDate) {
  DateTime notificationDate = prayerDate.copyWith();
  if (isBefore) {
    notificationDate =
        notificationDate.subtract(Duration(minutes: notificationTime));
  } else {
    notificationDate =
        notificationDate.add(Duration(minutes: notificationTime));
  }
  Duration timeLeft = notificationDate.difference(now);

  NotificationManager().notifyAfter(
      prayer,
      "$prayer ${isBefore ? "Adhan" : "Iqamah"} In $notificationTime Minutes",
      timeLeft,
      isBefore);
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Workmanager().initialize(
      callbackDispatcher, // The top level function, aka callbackDispatcher
      isInDebugMode:
          true // If enabled it will post a notification whenever the task is running. Handy for debugging tasks
      );
  // Workmanager().registerPeriodicTask(
  //   "fetchPrayerNotification",
  //   "fetchPrayerNotification",
  //   existingWorkPolicy: ExistingWorkPolicy.replace,
  //   frequency: const Duration(hours: 1),
  // );

  // Workmanager().registerOneOffTask("uniqueName", "taskName");
  await Prefs.initPrefs();

  LocationHandler.location.initFromPrefs();

  await Db().init();

  try {
    if (Platform.isAndroid) {
      await initializeService();
    }
  } catch (e) {
    //
  }
  runApp(MultiProvider(
    providers: [
      ChangeNotifierProvider(create: (context) => ColorNotifier()),
      ChangeNotifierProvider(create: (context) => TasbihNotifier()),
      ChangeNotifierProvider(create: (context) => NextPrayerNot())
    ],
    child: const App(),
  ));
}

class App extends StatelessWidget {
  const App({super.key});
  @override
  Widget build(BuildContext context) {
    Provider.of<ColorNotifier>(context, listen: false).initPalette();
    return Consumer<ColorNotifier>(builder: (context, palette, _) {
      return Palette(
        mainColor: palette.getMainC,
        secColor: palette.getSecC,
        backColor: palette.getBackC,
        child: MaterialApp(
            theme: ThemeData(
                colorScheme: ColorScheme.fromSeed(seedColor: palette.getMainC)),
            home: const MainPage()),
      );
    });
  }
}

class MainPage extends StatefulWidget {
  const MainPage({super.key});
  @override
  State<MainPage> createState() => _MainPage();
}

class _MainPage extends State<MainPage> {
  int activePage = 0;
  late List<Widget> pages;
  late List pagesAppBars;
  @override
  void initState() {
    super.initState();
    pages = [
      const PrayerTimePage(),
      const TasbihPage(),
      // const QiblahPage(),
      const Placeholder(),
      const SettingsPage(),
    ];

    pagesAppBars = [
      null,
      null,
      null,
      {"title": "Settings"},
    ];
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ColorNotifier>(builder: (context, palette, child) {
      return Scaffold(
          appBar: pagesAppBars[activePage] != null
              ? AppBar(
                  backgroundColor: palette.getBackC,
                  foregroundColor: palette.getMainC,
                  title: Text(pagesAppBars[activePage]["title"]),
                  centerTitle: true,
                )
              : null,
          bottomNavigationBar: SizedBox(
            height: 40,
            child: BottomNavigationBar(
              currentIndex: activePage,
              backgroundColor: palette.getSecC,
              selectedItemColor: palette.getMainC,
              unselectedItemColor: palette.getBackC,
              iconSize: 14,
              selectedFontSize: 10,
              unselectedFontSize: 10,
              onTap: (v) {
                setState(() {
                  activePage = v;
                });
              },
              items: [
                BottomNavigationBarItem(
                    icon: const Icon(Icons.alarm_outlined),
                    label: "Prayer Times",
                    backgroundColor: palette.getSecC),
                BottomNavigationBarItem(
                    icon: const Icon(Icons.circle_outlined),
                    label: "Tasbih",
                    backgroundColor: palette.getSecC),
                BottomNavigationBarItem(
                    icon: const Icon(Icons.mosque_outlined),
                    label: "Qiblah",
                    backgroundColor: palette.getSecC),
                BottomNavigationBarItem(
                    icon: const Icon(Icons.settings_outlined),
                    label: "Settings",
                    backgroundColor: palette.getSecC)
              ],
            ),
          ),
          backgroundColor: palette.getBackC,
          body: SafeArea(child: pages[activePage]));
    });
  }
}

class Palette extends InheritedWidget {
  const Palette({
    required this.mainColor,
    required this.secColor,
    super.key,
    required this.backColor,
    required super.child,
  });

  final Color backColor;
  final Color mainColor;
  final Color secColor;

  static Palette? maybeOf(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<Palette>();
  }

  static Palette of(BuildContext context) {
    final Palette? result = maybeOf(context);
    assert(result != null, 'No Inherited Widget found in context');
    return result!;
  }

  @override
  bool updateShouldNotify(Palette oldWidget) =>
      backColor != oldWidget.backColor ||
      mainColor != oldWidget.mainColor ||
      secColor != oldWidget.secColor;
}
