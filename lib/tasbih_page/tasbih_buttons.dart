import 'dart:math';
import 'package:flutter/material.dart';
import 'package:prayerapp/main.dart';
import 'package:prayerapp/tasbih_page/tasbih_notifier.dart';
import 'package:provider/provider.dart';

class BigButton extends StatefulWidget {
  const BigButton({super.key});

  @override
  State<BigButton> createState() => _BigButtonState();
}

class _BigButtonState extends State<BigButton> with TickerProviderStateMixin {
  late AnimationController shrinkController;
  late Animation<double> shrinkAnimation;

  late AnimationController growController;
  late Animation<double> growAnimation;

  @override
  void initState() {
    initShrinkAnimation();
    initGrowAnimation();
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    shrinkController.dispose();
    growController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = min(
        MediaQuery.of(context).size.width, MediaQuery.of(context).size.height);
    return Consumer<TasbihNotifier>(builder: (context, tasbihNot, _) {
      return Container(
        decoration: BoxDecoration(
            borderRadius: const BorderRadius.all(Radius.circular(1000)),
            color: Palette.of(context).secColor),
        width: screenWidth / 2 + 30,
        height: screenWidth / 2 + 30,
        child: Center(
          child: InkWell(
            borderRadius: const BorderRadius.all(Radius.circular(1000)),
            onTap: onTap,
            child: Container(
                width: screenWidth / 2 -
                    shrinkAnimation.value +
                    growAnimation.value,
                height: screenWidth / 2 -
                    shrinkAnimation.value +
                    growAnimation.value,
                decoration: BoxDecoration(
                  color: Palette.of(context).mainColor,
                  borderRadius: const BorderRadius.all(Radius.circular(1000)),
                ),
                child: Center(
                    child: Text("${tasbihNot.now}",
                        style: TextStyle(
                            fontSize: 20,
                            color: Palette.of(context).secColor)))),
          ),
        ),
      );
    });
  }

  void onTap() {
    Provider.of<TasbihNotifier>(context, listen: false).changeTasbih(true);
    growController.reset();
    shrinkController.forward();
  }

  void initGrowAnimation() {
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

  void initShrinkAnimation() {
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
  }
}

class SmallButton extends StatelessWidget {
  final Function onTap;
  final IconData iconData;
  const SmallButton({super.key, required this.onTap, required this.iconData});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: const BorderRadius.all(Radius.circular(1000)),
      onTap: () {
        onTap();
      },
      child: Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(
            color: Palette.of(context).secColor,
            borderRadius: const BorderRadius.all(Radius.circular(1000))),
        child: Icon(
          iconData,
          color: Palette.of(context).mainColor,
        ),
      ),
    );
  }
}
