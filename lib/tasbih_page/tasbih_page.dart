import 'package:prayerapp/color_notifier.dart';
import 'package:prayerapp/tasbih_page/tasbih_notifier.dart';
import "package:flutter/material.dart";
import 'package:prayerapp/tasbih_page/tasbih_buttons.dart';
import 'package:prayerapp/tasbih_page/tasbih_info_widget.dart';
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
