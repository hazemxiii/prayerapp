import 'dart:math';
import 'settings.dart';
import "package:shared_preferences/shared_preferences.dart";
import "package:flutter/material.dart";
import 'package:vibration/vibration.dart';
import 'vibration_settings.dart';

// ignore: must_be_immutable
class Tasbih extends StatefulWidget {
  GlobalKey<ScaffoldState> scaffoldKey;
  Tasbih({super.key, required this.scaffoldKey});
  @override
  State<Tasbih> createState() => _Tasbih();
}

class _Tasbih extends State<Tasbih> with TickerProviderStateMixin {
  int? tasbih = 0;
  Color mainColor = Colors.lightBlue;
  Color secondaryColor = Colors.white;
  Color backColor = Colors.lightBlue[50]!;

  // controllers and the animations
  late AnimationController shrinkController;
  late Animation<double> shrinkAnimation;

  late AnimationController growController;
  late Animation<double> growAnimation;

  @override
  void initState() {
    super.initState();

    shrinkController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 50));
    shrinkAnimation = Tween<double>(begin: 0, end: 20).animate(shrinkController)
      ..addListener(() {
        setState(() {
          // when it's done shrinking, start the growing
          if (shrinkAnimation.status == AnimationStatus.completed) {
            shrinkController.reverse();
            growController.forward();
          }
        });
      });

    growController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 150));
    growAnimation = Tween<double>(begin: 0, end: 30).animate(growController)
      ..addListener(() {
        setState(() {
          // when it's done growing, bring back to normal
          if (growAnimation.status == AnimationStatus.completed) {
            growController.reverse();
          }
        });
      });

    // update the number in the button when the data returns from the shared prefs
    getTasbihNow().then((v) {
      setState(() {
        tasbih = v;
      });
    });

    getColors().then((data) {
      setState(() {
        mainColor = hexToColor(data[0]);
        secondaryColor = hexToColor(data[1]);
        backColor = hexToColor(data[2]);
      });
    });

    getVibrationData().then((data) {
      vibrate = data[0];
      vibrateOn = data[1];
      isOn = data[2];
      vibrateNums = vibrateOn.split(",");
    });
  }

  bool vibrate = false;
  String vibrateOn = "-1";
  bool isOn = true;
  List vibrateNums = [];

  @override
  void dispose() {
    super.dispose();
    shrinkController.dispose();
    growController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // get what's minimum, the width of the screen or the height
    double screenWidth = min(
        MediaQuery.of(context).size.width, MediaQuery.of(context).size.height);
    return Column(
      children: [
        Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                decoration: BoxDecoration(
                    borderRadius: const BorderRadius.all(Radius.circular(1000)),
                    color: secondaryColor),
                width: screenWidth / 2 + 30,
                height: screenWidth / 2 + 30,
                child: Center(
                  child: InkWell(
                    borderRadius: const BorderRadius.all(Radius.circular(1000)),
                    child: Container(
                        width: screenWidth / 2 -
                            shrinkAnimation.value +
                            growAnimation.value,
                        height: screenWidth / 2 -
                            shrinkAnimation.value +
                            growAnimation.value,
                        decoration: BoxDecoration(
                          color: mainColor,
                          borderRadius:
                              const BorderRadius.all(Radius.circular(1000)),
                        ),
                        child: Center(
                            child: Text("$tasbih",
                                style: TextStyle(
                                    fontSize: 20, color: secondaryColor)))),
                    onTap: () {
                      setState(() {
                        // vibrate when there are 33 tasbih
                        tasbih = tasbih! + 1;
                        increaseTasbih();
                        try {
                          if (vibrate) {
                            if (isOn && vibrateNums.contains("$tasbih")) {
                              Vibration.vibrate(duration: 1000);
                            } else if (!isOn &&
                                tasbih! % int.parse(vibrateOn) == 0) {
                              Vibration.vibrate(duration: 1000);
                            }
                          }
                        } catch (e) {
                          //
                        }

                        // start the animation on click
                        shrinkController.forward();
                      });
                    },
                  ),
                ),
              ),
              Container(
                height: 10,
              ),
              InkWell(
                borderRadius: const BorderRadius.all(Radius.circular(1000)),
                child: Container(
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                      color: mainColor,
                      borderRadius:
                          const BorderRadius.all(Radius.circular(1000))),
                ),
                onTap: () {
                  // reset the tasbih
                  setState(() {
                    tasbih = 0;
                    clearTasbihNow();
                  });
                },
              )
            ],
          ),
        )
      ],
    );
  }
}

class TasbihDrawer extends StatefulWidget {
  const TasbihDrawer({super.key});

  @override
  State<TasbihDrawer> createState() => _TasbihDrawer();
}

class _TasbihDrawer extends State<TasbihDrawer> {
  Color color = Colors.lightBlue;
  Color secondaryColor = Colors.white;

  @override
  void initState() {
    getColors().then((data) {
      color = hexToColor(data[0]);
      secondaryColor = hexToColor(data[1]);
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    double drawerWidth = MediaQuery.of(context).size.width / 3 * 2;
    return FutureBuilder(
        future: getTotalTasbihCount(),
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.done) {
            return Container(
              color: color,
              width: drawerWidth,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TasbihNumber(
                    color: color,
                    width: drawerWidth,
                    name: "Total",
                    number: snap.data![0],
                  ),
                  TasbihNumber(
                    color: color,
                    width: drawerWidth,
                    name: "Total Today",
                    number: snap.data![1],
                  ),
                  TextButton(
                    style: TextButton.styleFrom(
                        shape: const RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.all(Radius.circular(10))),
                        backgroundColor: secondaryColor),
                    onPressed: () {
                      setState(() {
                        clearTasbih();
                      });
                    },
                    child: Text(
                      "Clear",
                      style: TextStyle(color: color),
                    ),
                  )
                ],
              ),
            );
          } else {
            return Container(
              color: Colors.white,
              width: drawerWidth,
            );
          }
        });
  }
}

// ignore: must_be_immutable
class TasbihNumber extends StatefulWidget {
  final String name;
  int number;
  final double width;
  final Color color;
  TasbihNumber(
      {super.key,
      required this.name,
      required this.number,
      required this.width,
      required this.color});

  @override
  State<TasbihNumber> createState() => _TasbihNumberState();
}

class _TasbihNumberState extends State<TasbihNumber> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(0, 5, 0, 5),
      width: widget.width,
      margin: const EdgeInsets.all(5),
      decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.all(Radius.circular(10))),
      child: Column(
        children: [
          Text(
            widget.name,
            style: TextStyle(color: widget.color),
          ),
          Text("${widget.number}", style: TextStyle(color: widget.color))
        ],
      ),
    );
  }
}

Future<List> getTotalTasbihCount() async {
  // gets the total of tasbih today and overall
  List total = [];
  await SharedPreferences.getInstance().then((prefs) {
    if (!prefs.containsKey("totalTasbih")) {
      prefs.setInt("totalTasbih", 0);
    }
    if (!prefs.containsKey("totalTasbihToday")) {
      prefs.setInt("totalTasbihToday", 0);
    }
    total = [prefs.getInt("totalTasbih"), prefs.getInt("totalTasbihToday")];
  });
  return total;
}

Future<int?> getTasbihNow() async {
  // gets the total in the button before resetting it
  int? tasbih = 0;
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

    tasbih = prefs.getInt("tasbihNow");
  });

  return tasbih;
}

void increaseTasbih() async {
  // increases all tasbih totals by 1
  await SharedPreferences.getInstance().then((prefs) {
    int? oldTotal = prefs.getInt("totalTasbih");
    prefs.setInt("totalTasbih", oldTotal! + 1);

    int? oldTotalToday = prefs.getInt("totalTasbihToday");
    prefs.setInt("totalTasbihToday", oldTotalToday! + 1);

    int? oldNow = prefs.getInt("tasbihNow");
    prefs.setInt("tasbihNow", oldNow! + 1);
  });
}

void clearTasbihNow() async {
  // clears the tasbih number in the button
  await SharedPreferences.getInstance().then((prefs) {
    prefs.setInt("tasbihNow", 0);
  });
}

void clearTasbih() async {
  // clears the tasbih total
  await SharedPreferences.getInstance().then((prefs) {
    prefs.setInt("totalTasbihToday", 0);
    prefs.setInt("totalTasbih", 0);
  });
}
