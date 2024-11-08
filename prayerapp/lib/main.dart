// ignore_for_file: use_build_context_synchronously
import "dart:io";
import "package:flutter/material.dart";
import "package:prayerapp/color_notifier.dart";
import "package:prayerapp/location_class/location_class.dart";
import "package:prayerapp/prayer_page/prayer_page.dart";
import "package:prayerapp/tasbih_notifier.dart";
// import "qiblah.dart";
import "tasbih.dart";
import "settings.dart";
import 'package:provider/provider.dart';
import "global.dart";
import "service.dart";

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Prefs.initPrefs();

  LocationHandler.location.initFromPrefs();
  LocationHandler.location.printLocation();

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
      ChangeNotifierProvider(create: (context) => TasbihNotifier())
    ],
    child: const App(),
  ));
}

class App extends StatelessWidget {
  const App({super.key});
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(home: MainPage());
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
    Provider.of<ColorNotifier>(context, listen: false).initPalette();
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
                  foregroundColor: palette.getSecC,
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
                    icon: const Icon(Icons.alarm),
                    label: "Prayer Times",
                    backgroundColor: palette.getSecC),
                BottomNavigationBarItem(
                    icon: const Icon(Icons.circle),
                    label: "Tasbih",
                    backgroundColor: palette.getSecC),
                BottomNavigationBarItem(
                    icon: const Icon(Icons.mosque),
                    label: "Qiblah",
                    backgroundColor: palette.getSecC),
                BottomNavigationBarItem(
                    icon: const Icon(Icons.settings),
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
