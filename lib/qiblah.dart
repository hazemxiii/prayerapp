import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'package:prayerapp/color_notifier.dart';
import 'package:prayerapp/location_class/location_class.dart';
import 'package:provider/provider.dart';

class QiblahPage extends StatefulWidget {
  const QiblahPage({super.key});

  @override
  State<QiblahPage> createState() => _QiblahPageState();
}

class _QiblahPageState extends State<QiblahPage> with TickerProviderStateMixin {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // TODO: fix proguard issue with notification
    double dimension = min(
        MediaQuery.of(context).size.height, MediaQuery.of(context).size.width);
    return Center(
      child: Consumer<ColorNotifier>(builder: (context, palette, child) {
        return FutureBuilder(
            future: LocationHandler.location.getFromGps(context),
            builder: (context, snap) {
              if (snap.connectionState == ConnectionState.done) {
                // location services are off
                if (LocationHandler.location.isLocationEmpty()) {
                  return Center(
                    child: Icon(
                      size: 40,
                      Icons.location_off_outlined,
                      color: palette.getSecC,
                    ),
                  );
                }
                return StreamBuilder<CompassEvent>(
                    stream: FlutterCompass.events,
                    builder: (context, snapshot) {
                      double north = 0;
                      double bearingAngle = 0;
                      if (snapshot.hasData) {
                        north = (snapshot.data!.heading! + 360) % 360;
                        bearingAngle = changeCompass(
                            LocationHandler.location.la,
                            LocationHandler.location.lo,
                            north);
                      }
                      return Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "${LocationHandler.location.country}, ${LocationHandler.location.city}",
                            textAlign: TextAlign.center,
                            style: TextStyle(color: palette.getSecC),
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          Transform.rotate(
                            angle: -toRad(north),
                            child: SizedBox(
                              height: dimension - dimension / 4,
                              width: dimension - dimension / 4,
                              child: CustomPaint(
                                painter: CompassPainter(palette.getSecC,
                                    palette.getMainC, toRad(bearingAngle)),
                              ),
                            ),
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                "${north.floor()}°",
                                style: TextStyle(
                                    color: palette.getMainC, fontSize: 20),
                              )
                            ],
                          )
                        ],
                      );
                    });
              } else {
                return Center(
                  child: SizedBox(
                      width: dimension - dimension / 4,
                      // still loading
                      child: LinearProgressIndicator(
                        color: palette.getSecC,
                      )),
                );
              }
            });
      }),
    );
  }
}

class CompassPainter extends CustomPainter {
  Color compassC = Colors.white;
  Color textC = Colors.lightBlue;
  double qiblah = 0;

  CompassPainter(this.compassC, this.textC, this.qiblah);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = min(size.width / 2, size.height / 2);

    // the compass background
    final back = Paint()
      ..color = compassC
      ..style = PaintingStyle.fill;

    canvas.drawCircle(center, radius, back);

    // the indicator for qiblah
    final qiblahCircle = Paint()
      ..color = textC
      ..style = PaintingStyle.fill;

    canvas.drawCircle(
        Offset(center.dx + (radius) * cos(qiblah - pi / 2),
            center.dy + (radius) * sin(qiblah - pi / 2)),
        10,
        qiblahCircle);

    // numbers and dots of angles
    for (double i = 0; i < 360; i = i + 30) {
      Color dotC = textC;
      String text = "${i.floor()}";
      if (i == 0) {
        dotC = const Color.fromARGB(255, 255, 17, 0);
        text = "N";
      } else if (i == 90) {
        dotC = Colors.green;
        text = "E";
      } else if (i == 180) {
        dotC = Colors.blue;
        text = "S";
      } else if (i == 270) {
        dotC = Colors.yellow;
        text = "W";
      }

      // drawing dots
      var dot = Paint()
        ..color = dotC
        ..style = PaintingStyle.fill;

      double angle = toRad(i);

      Offset dotOff = Offset(center.dx + (radius - 30) * cos(angle - pi / 2),
          center.dy + (radius - 30) * sin(angle - pi / 2));

      canvas.drawCircle(dotOff, 2, dot);

      // drawing text
      var textPainter = TextPainter(
          text: TextSpan(text: text, style: TextStyle(color: dotC)),
          textDirection: TextDirection.ltr,
          textAlign: TextAlign.center);

      textPainter.layout();

      Offset textOff = Offset(center.dx + (radius - 15) * cos(angle - pi / 2),
          center.dy + (radius - 15) * sin(angle - pi / 2));

      // rotating the text
      canvas.save();
      canvas.translate(textOff.dx, textOff.dy);
      canvas.rotate(angle);
      textPainter.paint(
          canvas, Offset(-textPainter.width / 2, -textPainter.height / 2));
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
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

  // Calculate bearing
  double diff = lo2 - lo1;

  double x = sin(diff) * cos(la2);
  double y = cos(la1) * sin(la2) - cos(la2) * sin(la1) * cos(diff);

  // difference between north and qiblah
  double bearing = (toDeg(atan2(x, y)) + 360) % 360;

  // return toRad((bearing - north! + 360) % 360);
  return bearing;
}
