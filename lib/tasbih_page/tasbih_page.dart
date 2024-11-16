import 'dart:math';
import 'package:prayerapp/global.dart';
import 'package:prayerapp/main.dart';
import 'package:prayerapp/tasbih_page/tasbih_notifier.dart';
import "package:flutter/material.dart";
import 'package:prayerapp/tasbih_page/tasbih_buttons.dart';
import 'package:prayerapp/widgets/section.dart';
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
      return Section(
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
      return Section(
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
