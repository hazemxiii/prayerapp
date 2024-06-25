import "package:flutter/material.dart";

class ColorPalette extends ChangeNotifier {
  /// The class is used to rebuild the pages when the color is changed
  Color main = Colors.lightBlue;
  Color second = Colors.white;
  Color back = Colors.lightBlue[50]!;

  // getters
  Color get getMainC => main;
  Color get getSecC => second;
  Color get getBackC => back;

  // setters
  void setMainC(Color c) {
    main = c;
    // to update everything that uses this class
    notifyListeners();
  }

  void setSecC(Color c) {
    second = c;
    notifyListeners();
  }

  void setBackC(Color c) {
    back = c;
    notifyListeners();
  }
}
