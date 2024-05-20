import 'dart:math';
import "package:shared_preferences/shared_preferences.dart";
import "package:flutter/material.dart";
import 'package:vibration/vibration.dart';

// ignore: must_be_immutable
class Tasbih extends StatefulWidget {
  GlobalKey<ScaffoldState> scaffoldKey;
  Tasbih({super.key, required this.scaffoldKey});
  @override
  State<Tasbih> createState() => _Tasbih();
}

class _Tasbih extends State<Tasbih> with TickerProviderStateMixin {
  int? tasbih = 0;

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
  }

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
        const SizedBox(
          height: 20,
        ),
        Row(
          children: [
            IconButton(
                onPressed: () {
                  widget.scaffoldKey.currentState!.openDrawer();
                },
                icon: const Icon(Icons.menu))
          ],
        ),
        Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                decoration: const BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(1000)),
                    color: Colors.white),
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
                        decoration: const BoxDecoration(
                          color: Colors.lightBlue,
                          borderRadius: BorderRadius.all(Radius.circular(1000)),
                        ),
                        child: Center(
                            child: Text("$tasbih",
                                style: const TextStyle(
                                    fontSize: 20, color: Colors.white)))),
                    onTap: () {
                      setState(() {
                        // vibrate when there are 33 tasbih
                        tasbih = tasbih! + 1;
                        increaseTasbih();
                        if (tasbih == 33) {
                          Vibration.vibrate(duration: 1000);
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
                  decoration: const BoxDecoration(
                      color: Colors.lightBlue,
                      borderRadius: BorderRadius.all(Radius.circular(1000))),
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
  @override
  Widget build(BuildContext context) {
    double drawerWidth = MediaQuery.of(context).size.width / 3 * 2;
    return FutureBuilder(
        future: getTotalTasbihCount(),
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.done) {
            return Container(
              color: Colors.lightBlue,
              width: drawerWidth,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TasbihNumber(
                    width: drawerWidth,
                    name: "Total",
                    number: snap.data![0],
                  ),
                  TasbihNumber(
                    width: drawerWidth,
                    name: "Total Today",
                    number: snap.data![1],
                  ),
                  TextButton(
                    style: TextButton.styleFrom(
                        shape: const RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.all(Radius.circular(10))),
                        backgroundColor: Colors.white),
                    onPressed: () {
                      setState(() {
                        clearTasbih();
                      });
                    },
                    child: const Text(
                      "Clear",
                      style: TextStyle(color: Colors.lightBlue),
                    ),
                  )
                ],
              ),
            );
          } else {
            return Container(
              color: Colors.lightBlue,
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
  TasbihNumber(
      {super.key,
      required this.name,
      required this.number,
      required this.width});

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
            style: const TextStyle(color: Colors.lightBlue),
          ),
          Text("${widget.number}",
              style: const TextStyle(color: Colors.lightBlue))
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
