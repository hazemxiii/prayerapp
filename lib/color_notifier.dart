import 'package:flutter/material.dart';
import 'package:prayerapp/global.dart';

class ColorNotifier extends ChangeNotifier {
  /// The class is used to rebuild the pages when the color is changed
  Color _main = Colors.lightBlue;
  // Color _second = Colors.white;
  Color _back = Colors.lightBlue[50]!;

  // getters
  Color get getMainC => _main;
  Color get getSecC => Color.lerp(_main, _back, 0.9)!;
  Color get getBackC => _back;

  void initPalette() {
    _main = Color(Prefs.prefs.getInt(PrefsKeys.primaryColor)!);
    // _second = Color(Prefs.prefs.getInt(PrefsKeys.secondaryColor)!);
    _back = Color(Prefs.prefs.getInt(PrefsKeys.backColor)!);
  }

  // setters
  void setMainC(Color c) {
    _main = c;
    Prefs.prefs.setInt(PrefsKeys.primaryColor, c.toARGB32());
    notifyListeners();
  }

  void setColor(String colorKey, Color? c) {
    if (c == null) {
      return;
    }
    if (colorKey == PrefsKeys.primaryColor) {
      _main = c;
    } else {
      _back = c;
    }
    Prefs.prefs.setInt(colorKey, c.toARGB32());
    notifyListeners();
  }

  // void setSecC(Color c) {
  //   _second = c;
  //   Prefs.prefs.setInt(PrefsKeys.secondaryColor, c.toARGB32());
  //   notifyListeners();
  // }

  void setBackC(Color c) {
    _back = c;
    Prefs.prefs.setInt(PrefsKeys.backColor, c.toARGB32());
    notifyListeners();
  }
}
