import 'dart:math';
import "package:shared_preferences/shared_preferences.dart";
import "package:flutter/material.dart";
import 'package:vibration/vibration.dart';
import 'vibration_settings.dart';
import 'global.dart';
import 'package:provider/provider.dart';

Function? reset;
bool infoVisible = false;
Function? toggleInfoVisible;

class TasbihPage extends StatefulWidget {
  const TasbihPage({super.key});
  @override
  State<TasbihPage> createState() => _Tasbih();
}

class _Tasbih extends State<TasbihPage> with TickerProviderStateMixin {
  int? tasbih = 0;
  // controllers and the animations
  late AnimationController shrinkController;
  late Animation<double> shrinkAnimation;

  late AnimationController growController;
  late Animation<double> growAnimation;

  @override
  void initState() {
    super.initState();
    // TODO: turn this into a change notifier
    toggleInfoVisible = () {
      setState(() {});
      infoVisible = !infoVisible;
    };
    reset = () {
      getTasbihNow().then((v) {
        setState(() {
          tasbih = v;
        });
      });

      getVibrationData().then((data) {
        setState(() {
          vibrate = data[0];
          vibrateOn = data[1];
          isOn = data[2];
          vibrateNums = vibrateOn.split(",");
        });
      });
    };
    // update the number in the button when the data returns from the shared prefs
    reset!();

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
    return Stack(
      children: [
        Column(
          children: [
            Expanded(
              child: Consumer<ColorPalette>(builder: (context, palette, child) {
                return Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                          borderRadius:
                              const BorderRadius.all(Radius.circular(1000)),
                          color: palette.getSecC),
                      width: screenWidth / 2 + 30,
                      height: screenWidth / 2 + 30,
                      child: Center(
                        child: InkWell(
                          borderRadius:
                              const BorderRadius.all(Radius.circular(1000)),
                          child: Container(
                              width: screenWidth / 2 -
                                  shrinkAnimation.value +
                                  growAnimation.value,
                              height: screenWidth / 2 -
                                  shrinkAnimation.value +
                                  growAnimation.value,
                              decoration: BoxDecoration(
                                color: palette.getMainC,
                                borderRadius: const BorderRadius.all(
                                    Radius.circular(1000)),
                              ),
                              child: Center(
                                  child: Text("$tasbih",
                                      style: TextStyle(
                                          fontSize: 20,
                                          color: palette.getSecC)))),
                          onTap: () {
                            setState(() {
                              // vibrate when there are 33 tasbih
                              // TODO make it only update the preferences
                              tasbih = tasbih! + 1;
                              changeTasbih(true);
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
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SmallButton(
                            iconData: Icons.close,
                            onTap: () {
                              // reset the tasbih
                              setState(() {
                                tasbih = 0;
                                clearTasbihNow();
                              });
                            }),
                        const SizedBox(width: 10),
                        SmallButton(
                          iconData: Icons.remove,
                          onTap: () {
                            setState(() {
                              if (tasbih! <= 0) {
                                return;
                              }
                              tasbih = tasbih! - 1;
                              changeTasbih(false);
                            });
                          },
                        )
                      ],
                    )
                  ],
                );
              }),
            )
          ],
        ),
        Container(
          height: infoVisible ? MediaQuery.of(context).size.height : 0,
          width: infoVisible ? MediaQuery.of(context).size.width : 0,
          color: const Color.fromRGBO(0, 0, 0, 0.5),
        ),
        Consumer<ColorPalette>(builder: (context, palette, child) {
          return TasbihInfo(
            backC: palette.getMainC,
            textC: palette.getSecC,
          );
        }),
      ],
    );
  }
}

class SmallButton extends StatelessWidget {
  final Function onTap;
  final IconData iconData;
  const SmallButton({super.key, required this.onTap, required this.iconData});

  @override
  Widget build(BuildContext context) {
    return Consumer<ColorPalette>(builder: (context, palette, child) {
      return InkWell(
        borderRadius: const BorderRadius.all(Radius.circular(1000)),
        onTap: () {
          onTap();
        },
        child: Container(
          width: 30,
          height: 30,
          decoration: BoxDecoration(
              color: palette.getSecC,
              borderRadius: const BorderRadius.all(Radius.circular(1000))),
          child: Icon(
            iconData,
            color: palette.getMainC,
          ),
        ),
      );
    });
  }
}

class TasbihInfo extends StatefulWidget {
  final Color backC;
  final Color textC;
  const TasbihInfo({
    super.key,
    required this.backC,
    required this.textC,
  });

  @override
  State<TasbihInfo> createState() => _TasbihInfoState();
}

class _TasbihInfoState extends State<TasbihInfo> with TickerProviderStateMixin {
  late AnimationController showInfoAnimationCont;
  late Animation showInfoAnimation;
  double animationMin = 0;
  double animationMax = 10;
  int totalTasbih = 0;
  int totalTasbihToday = 0;

  @override
  void initState() {
    showInfoAnimationCont = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 300));

    showInfoAnimation = Tween<double>(begin: animationMin, end: animationMax)
        .animate(showInfoAnimationCont);

    showInfoAnimationCont.addListener(() {
      setState(() {
        if (showInfoAnimationCont.isCompleted) {
          toggleInfoVisible!();
        }
      });
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: 10,
      top: 10,
      child: InkWell(
        onTap: () {
          if (!infoVisible) {
            showInfoAnimationCont.forward();
          } else {
            toggleInfoVisible!();
            showInfoAnimationCont.reverse();
          }
          getTotalTasbihCount().then((total) {
            totalTasbih = total[0];
            totalTasbihToday = total[1];
          });
        },
        child: Container(
          width: mapValue(showInfoAnimation.value, animationMin, animationMax,
              30, MediaQuery.of(context).size.width - 20),
          height: mapValue(
              showInfoAnimation.value, animationMin, animationMax, 30, 200),
          decoration: BoxDecoration(
              color: widget.backC,
              borderRadius: BorderRadius.all(
                  Radius.circular(showInfoAnimation.value + 10))),
          child: !infoVisible
              ? Icon(
                  Icons.question_mark,
                  color: widget.textC,
                )
              : Center(
                  child: TasbihInfoNumbers(
                      color: widget.textC,
                      today: totalTasbihToday,
                      total: totalTasbih),
                ),
        ),
      ),
    );
  }
}

class TasbihInfoNumbers extends StatefulWidget {
  final Color color;
  final int total;
  final int today;

  const TasbihInfoNumbers({
    super.key,
    required this.color,
    required this.total,
    required this.today,
  });

  @override
  State<TasbihInfoNumbers> createState() => _TasbihInfoNumbersState();
}

class _TasbihInfoNumbersState extends State<TasbihInfoNumbers> {
  int total = 0;
  int today = 0;

  @override
  void initState() {
    super.initState();
    total = widget.total;
    today = widget.today;
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "Total",
                style: TextStyle(color: widget.color, fontSize: 20),
              ),
              Text(
                "$total",
                style: TextStyle(color: widget.color),
              )
            ],
          ),
        ),
        Column(
          children: [
            Container(
              color: widget.color,
              width: 3,
              height: 150,
            ),
            IconButton(
                onPressed: () {
                  setState(() {
                    today = 0;
                    total = 0;
                  });
                  clearTasbih();
                  clearTasbihNow();
                  reset!();
                },
                icon: Icon(
                  Icons.close,
                  color: widget.color,
                ))
          ],
        ),
        Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "Today",
                style: TextStyle(color: widget.color, fontSize: 20),
              ),
              Text(
                "$today",
                style: TextStyle(color: widget.color),
              )
            ],
          ),
        )
      ],
    );
  }
}

double mapValue(
    double value, double min, double max, double newMin, double newMax) {
  return (value - min) / (max - min) * (newMax - newMin) + newMin;
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

void changeTasbih(bool increase) async {
  // increases all tasbih totals by 1
  await SharedPreferences.getInstance().then((prefs) {
    int number = increase ? 1 : -1;
    int? oldTotal = prefs.getInt("totalTasbih");
    prefs.setInt("totalTasbih", oldTotal! + number);

    int? oldTotalToday = prefs.getInt("totalTasbihToday");
    prefs.setInt("totalTasbihToday", oldTotalToday! + number);

    int? oldNow = prefs.getInt("tasbihNow");
    prefs.setInt("tasbihNow", oldNow! + number);
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
