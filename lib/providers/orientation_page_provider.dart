import 'package:flutter/services.dart';
import 'package:flutter/material.dart';

class OrientationPageProvider with ChangeNotifier {
  bool _isLandscape = false;

  bool get isLandscape => _isLandscape;

  void toggleOrientation() {
    if (_isLandscape) {
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
        DeviceOrientation.portraitDown,
      ]);
    } else {
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.landscapeRight,
        DeviceOrientation.landscapeLeft,
      ]);
    }

    _isLandscape = !_isLandscape;
    notifyListeners();
  }
}
