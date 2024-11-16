import 'dart:math';
import 'package:prayerapp/global.dart';
import 'package:prayerapp/main.dart';
import 'package:prayerapp/tasbih_page/tasbih_notifier.dart';
import "package:flutter/material.dart";
import 'package:prayerapp/tasbih_page/tasbih_buttons.dart';
import 'package:provider/provider.dart';

class TasbihPage extends StatefulWidget {
  const TasbihPage({super.key});
  @override
  State<TasbihPage> createState() => _Tasbih();
}

class _Tasbih extends State<TasbihPage> with TickerProviderStateMixin {
  @override
  void initState() {
    super.initState();

    Provider.of<TasbihNotifier>(context, listen: false).setData();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          const SizedBox(
            height: 20,
          ),
          Consumer<TasbihNotifier>(builder: (context, tasbihNot, child) {
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const BigButton(),
                Container(
                  height: 10,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SmallButton(
                        iconData: Icons.close,
                        onTap: () {
                          Provider.of<TasbihNotifier>(context, listen: false)
                              .clearTasbihNow();
                        }),
                    const SizedBox(width: 10),
                    SmallButton(
                      iconData: Icons.remove,
                      onTap: () {
                        Provider.of<TasbihNotifier>(context, listen: false)
                            .changeTasbih(false);
                      },
                    )
                  ],
                ),
                const TasbihDailyProgressWidget(),
                const OverallTasbihProgressWidget()
              ],
            );
          })
        ],
      ),
    );
  }
}

class TasbihDailyProgressWidget extends StatelessWidget {
  const TasbihDailyProgressWidget({super.key});

  @override
  Widget build(BuildContext context) {
    int tasbihDailyProgress =
        Prefs.prefs.getInt(PrefsKeys.tasbihDailyProgress)!;
    return Consumer<TasbihNotifier>(builder: (context, tasbihNot, _) {
      return TasbihPageSection(
        backC: Palette.of(context).secColor,
        textC: Palette.of(context).mainColor,
        title: "Daily Progress",
        icon: Icon(
          Icons.today,
          color: Palette.of(context).mainColor,
        ),
        content: [
          const SizedBox(
            height: 20,
          ),
          LinearProgressIndicator(
            borderRadius: const BorderRadius.all(Radius.circular(10)),
            backgroundColor: Palette.of(context).backColor,
            color: Palette.of(context).mainColor,
            value: min(tasbihNot.today / tasbihDailyProgress, 1),
          ),
          const SizedBox(
            height: 5,
          ),
          Text(
            "${tasbihNot.today}/$tasbihDailyProgress",
            style: TextStyle(color: Palette.of(context).mainColor),
          )
        ],
      );
    });
  }
}

class OverallTasbihProgressWidget extends StatelessWidget {
  const OverallTasbihProgressWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<TasbihNotifier>(builder: (context, tasbihNot, _) {
      return TasbihPageSection(
        backC: Palette.of(context).secColor,
        textC: Palette.of(context).mainColor,
        title: "Total Tasbih",
        icon: IconButton(
            color: Colors.red,
            onPressed: () {
              Provider.of<TasbihNotifier>(context, listen: false).clearTasbih();
            },
            icon: const Row(
              children: [
                Icon(Icons.delete_outline),
                Text(
                  "Delete",
                  style: TextStyle(color: Colors.red),
                )
              ],
            )),
        content: [
          Text(
            tasbihNot.total.toString(),
            style: TextStyle(
                color: Palette.of(context).mainColor,
                fontWeight: FontWeight.bold),
          )
        ],
      );
    });
  }
}

class TasbihPageSection extends StatelessWidget {
  final List<Widget> content;
  final String title;
  final Widget icon;
  final Color backC;
  final Color textC;
  const TasbihPageSection(
      {super.key,
      required this.content,
      required this.title,
      required this.icon,
      required this.backC,
      required this.textC});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      margin: const EdgeInsets.all(10),
      decoration: BoxDecoration(
          color: backC,
          borderRadius: const BorderRadius.all(Radius.circular(5))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: TextStyle(
                    color: textC, fontSize: 18, fontWeight: FontWeight.bold),
              ),
              icon
            ],
          ),
          ...content
        ],
      ),
    );
  }
}
