import 'dart:math';

import "package:flutter/material.dart";
import 'package:vibration/vibration.dart';

class Tasbih extends StatefulWidget {
  const Tasbih({super.key});
  @override
  State<Tasbih> createState() => _Tasbih();
}

class _Tasbih extends State<Tasbih> with TickerProviderStateMixin {
  late AnimationController srhinkController;
  late Animation<double> shrinkAnimation;

  late AnimationController growController;
  late Animation<double> growAnimation;

  @override
  void initState() {
    super.initState();

    srhinkController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 50));
    shrinkAnimation = Tween<double>(begin: 0, end: 20).animate(srhinkController)
      ..addListener(() {
        setState(() {
          if (shrinkAnimation.status == AnimationStatus.completed) {
            srhinkController.reverse();
            growController.forward();
          }
        });
      });

    growController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 150));
    growAnimation = Tween<double>(begin: 0, end: 30).animate(growController)
      ..addListener(() {
        setState(() {
          if (growAnimation.status == AnimationStatus.completed) {
            growController.reverse();
          }
        });
      });
  }

  int tasbih = 0;
  @override
  Widget build(BuildContext context) {
    double screenWidth = min(
        MediaQuery.of(context).size.width, MediaQuery.of(context).size.height);
    return Center(
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
                    tasbih++;
                    if (tasbih == 33) {
                      Vibration.vibrate(duration: 1000);
                    }
                    srhinkController.forward();
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
              setState(() {
                tasbih = 0;
              });
            },
          )
        ],
      ),
    );
  }
}
