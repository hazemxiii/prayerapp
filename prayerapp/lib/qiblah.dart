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
        return FutureBuilder(
            future: getPosition(true),
            builder: (context, snap) {
              if (snap.connectionState == ConnectionState.done) {
                if (snap.data!.isEmpty) {
                  return const RefreshProgressIndicator();
                }
                return StreamBuilder<CompassEvent>(
                    stream: FlutterCompass.events,
                    builder: (context, snapshot) {
                      double angle = 0;
                      if (snapshot.hasData) {
                        angle = changeCompass(snap.data![0], snap.data![1],
                            snapshot.data!.heading);
                      }
                      return Transform.rotate(
                        angle: angle,
                        child: Container(
                          height: dimension / 2,
                          width: dimension / 2,
                          decoration: BoxDecoration(
                              color: palette.getSecC,
                              borderRadius:
                                  BorderRadius.all(Radius.circular(dimension))),
                          child: Column(
                            children: [
                              Icon(
                                Icons.arrow_upward,
                                color: palette.getMainC,
                              )
                            ],
                          ),
                        ),
                      );
                    });
              } else {
                return const LinearProgressIndicator();
              }
            });
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

double changeCompass(double? la1, double? lo1, double? north) {
  // The Ka'bah location
  double la2 = toRad(21.42250867030901);
  double lo2 = toRad(39.8261959472982950);

  la1 = toRad(la1!);
  lo1 = toRad(lo1!);
  // deviation from north
  north = (north! + 360) % 360;

  // Calculate bearing
  double diff = lo2 - lo1;

  double x = sin(diff) * cos(la2);
  double y = cos(la1) * sin(la2) - cos(la2) * sin(la1) * cos(diff);

  double bearing = (toDeg(atan2(x, y)) + 360) % 360;

  return toRad((bearing - north + 360) % 360);
}
