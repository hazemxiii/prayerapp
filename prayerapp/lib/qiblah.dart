import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'package:provider/provider.dart';
import 'main.dart';
// import 'package:flutter_compass/flutter_compass.dart';

class Qiblah extends StatefulWidget {
  const Qiblah({super.key});

  @override
  State<Qiblah> createState() => _QiblahState();
}

class _QiblahState extends State<Qiblah> with TickerProviderStateMixin {
  @override
  void initState() {
    super.initState();
  }

  // the angle of rotation
  double? qiblah = 0;

  @override
  Widget build(BuildContext context) {
    // the compass size
    double dimension = min(
        MediaQuery.of(context).size.height, MediaQuery.of(context).size.width);
    return Center(
      child: Consumer<ColorPalette>(builder: (context, palette, child) {
        return Transform.rotate(
          angle: toRad(qiblah!),
          child: InkWell(
            onTap: () async {
              qiblah = await changeCompass();
              setState(() {});
            },
            child: Container(
              height: dimension / 2,
              width: dimension / 2,
              decoration: BoxDecoration(
                  color: palette.getSecC,
                  borderRadius: BorderRadius.all(Radius.circular(dimension))),
              child: Column(
                children: [
                  Icon(
                    Icons.arrow_upward,
                    color: palette.getMainC,
                  )
                ],
              ),
            ),
          ),
        );
      }),
    );
  }
}

double toDeg(double angle) {
  return angle * 180 / pi;
}

double toRad(double angle) {
  return angle * pi / 180;
}

Future<double> changeCompass() async {
  // The Ka'bah location
  double la2 = toRad(21.42250867030901);
  double lo2 = toRad(39.8261959472982950);
  // deviation from north
  double? north = 0;
  FlutterCompass.events!.first.then((v) {
    north = (v.heading! + 360) % 360;
  });

  // get your current position
  List coordinates = await getPosition(true);
  double la1 = toRad(coordinates[0]);
  double lo1 = toRad(coordinates[0]);

  // Calculate bearing
  double diff = lo2 - lo1;

  double x = sin(diff) * cos(la2);
  double y = cos(la1) * sin(la2) - cos(la2) * sin(la1) * cos(diff);

  double bearing = (toDeg(atan2(x, y)) + 360) % 360;

  return (bearing - north! + 360) % 360;
}
