import 'package:flutter/material.dart';
import 'package:prayerapp/tasbih_page/tasbih_notifier.dart';
import 'package:provider/provider.dart';

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
