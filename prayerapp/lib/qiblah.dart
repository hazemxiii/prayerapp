import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'package:provider/provider.dart';
import 'main.dart';

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
                // location services are off
                if (snap.data!.isEmpty) {
                  return const RefreshProgressIndicator();
                }
                return StreamBuilder<CompassEvent>(
                    stream: FlutterCompass.events,
                    builder: (context, snapshot) {
                      double north = 0;
                      // bearing angle
                      double angle = 0;
                      if (snapshot.hasData) {
                        north = (snapshot.data!.heading! + 360) % 360;
                        angle =
                            changeCompass(snap.data![0], snap.data![1], north);
                      }
                      return Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Transform.rotate(
                            angle: -toRad(north),
                            child: SizedBox(
                              height: dimension - dimension / 4,
                              width: dimension - dimension / 4,
                              child: CustomPaint(
                                painter: CompassPainter(palette.getSecC,
                                    palette.getMainC, toRad(angle)),
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
                                "$north°",
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
                      child: const LinearProgressIndicator()),
                );
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

  // Calculate bearing
  double diff = lo2 - lo1;

  double x = sin(diff) * cos(la2);
  double y = cos(la1) * sin(la2) - cos(la2) * sin(la1) * cos(diff);

  // difference between north and qiblah
  double bearing = (toDeg(atan2(x, y)) + 360) % 360;

  // return toRad((bearing - north! + 360) % 360);
  return bearing;
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
