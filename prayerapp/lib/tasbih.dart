import 'dart:math';
import 'package:prayerapp/color_notifier.dart';
import 'package:prayerapp/tasbih_notifier.dart';
import "package:flutter/material.dart";
import 'package:vibration/vibration.dart';
import 'package:provider/provider.dart';

class TasbihPage extends StatefulWidget {
  const TasbihPage({super.key});
  @override
  State<TasbihPage> createState() => _Tasbih();
}

class _Tasbih extends State<TasbihPage> with TickerProviderStateMixin {
  late AnimationController shrinkController;
  late Animation<double> shrinkAnimation;

  late AnimationController growController;
  late Animation<double> growAnimation;

  @override
  void initState() {
    super.initState();

    Provider.of<TasbihNotifier>(context, listen: false).setData();

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
              child:
                  Consumer<ColorNotifier>(builder: (context, palette, child) {
                return Consumer<TasbihNotifier>(
                    builder: (context, tasbihNot, child) {
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
                                    child: Text("${tasbihNot.now}",
                                        style: TextStyle(
                                            fontSize: 20,
                                            color: palette.getSecC)))),
                            onTap: () {
                              Provider.of<TasbihNotifier>(context,
                                      listen: false)
                                  .changeTasbih(true);
                              try {
                                if (tasbihNot.vibrate) {
                                  if (tasbihNot.isOn &&
                                      tasbihNot.vibrateNums
                                          .contains("$tasbihNot.tasbih")) {
                                    Vibration.vibrate(duration: 1000);
                                  } else if (!tasbihNot.isOn &&
                                      tasbihNot.now %
                                              int.parse(tasbihNot.vibrateOn) ==
                                          0) {
                                    Vibration.vibrate(duration: 1000);
                                  }
                                }
                              } catch (e) {
                                //
                              }

                              // start the animation on click
                              shrinkController.forward();
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
                                Provider.of<TasbihNotifier>(context,
                                        listen: false)
                                    .clearTasbihNow();
                              }),
                          const SizedBox(width: 10),
                          SmallButton(
                            iconData: Icons.remove,
                            onTap: () {
                              Provider.of<TasbihNotifier>(context,
                                      listen: false)
                                  .changeTasbih(false);
                            },
                          )
                        ],
                      )
                    ],
                  );
                });
              }),
            )
          ],
        ),
        Consumer<ColorNotifier>(builder: (context, palette, child) {
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
    return Consumer<ColorNotifier>(builder: (context, palette, child) {
      return InkWell(
        borderRadius: const BorderRadius.all(Radius.circular(1000)),
        onTap: () {
          onTap();
        },
        child: Container(
          width: 50,
          height: 50,
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
  bool infoVisible = false;

  @override
  void initState() {
    showInfoAnimationCont = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 300));

    showInfoAnimation = Tween<double>(begin: animationMin, end: animationMax)
        .animate(showInfoAnimationCont);

    showInfoAnimationCont.addListener(() {
      setState(() {
        if (showInfoAnimationCont.isCompleted) {
          infoVisible = !infoVisible;
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
        hoverColor: Colors.transparent,
        onTap: () {
          if (!infoVisible) {
            showInfoAnimationCont.forward();
          } else {
            infoVisible = !infoVisible;
            showInfoAnimationCont.reverse();
          }
        },
        child: Container(
          width: mapValue(showInfoAnimation.value, animationMin, animationMax,
              30, MediaQuery.of(context).size.width - 20),
          height: mapValue(
              showInfoAnimation.value, animationMin, animationMax, 30, 150),
          decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(
                    color: const Color.fromRGBO(0, 0, 0, 0.5),
                    spreadRadius: mapValue(
                        showInfoAnimation.value,
                        animationMin,
                        animationMax,
                        -5,
                        MediaQuery.of(context).size.height))
              ],
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
                  ),
                ),
        ),
      ),
    );
  }
}

class TasbihInfoNumbers extends StatefulWidget {
  final Color color;

  const TasbihInfoNumbers({
    super.key,
    required this.color,
  });

  @override
  State<TasbihInfoNumbers> createState() => _TasbihInfoNumbersState();
}

class _TasbihInfoNumbersState extends State<TasbihInfoNumbers> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<TasbihNotifier>(builder: (context, tasbihNot, child) {
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
                  "${tasbihNot.total}",
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
                height: 100,
              ),
              IconButton(
                  onPressed: () {
                    Provider.of<TasbihNotifier>(context, listen: false)
                        .clearTasbih();
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
                  "${tasbihNot.today}",
                  style: TextStyle(color: widget.color),
                )
              ],
            ),
          )
        ],
      );
    });
  }
}

double mapValue(
    double value, double min, double max, double newMin, double newMax) {
  return (value - min) / (max - min) * (newMax - newMin) + newMin;
}
