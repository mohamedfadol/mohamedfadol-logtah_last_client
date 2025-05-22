import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import '../colors.dart';

class ThemeProvider extends ChangeNotifier {
  ThemeMode themeMode = ThemeMode.system;
  String lightIconPath = "images/diligov_icon.png";
  String darkIconPath = "images/iconsFroDarkMode/diligov_logo_darkmode.png";

  // Get the current icon path based on the theme
  String get getIconPath {
    if (isDarkMode) {
      return darkIconPath;
    } else {
      return lightIconPath;
    }
  }


  // bool get isDarkMode => themeMode == ThemeMode.dark;
  bool get isDarkMode {
    if (themeMode == ThemeMode.system) {
      final brightness = SchedulerBinding.instance.window.platformBrightness;
      return brightness == Brightness.dark;
    } else {
      return themeMode == ThemeMode.dark;
    }
  }

  void setSystemTheme() {
    themeMode = ThemeMode.system;
    notifyListeners();
  }

  void toggleTheme(bool isOn) {
    themeMode = isOn ? ThemeMode.dark : ThemeMode.light;
    print("from ThemeProvider ${themeMode}");
    notifyListeners();
  }

  void setTheme(ThemeMode mode) {
    themeMode = mode;
    notifyListeners();
  }

}

class MyThemes {

  static final darkTheme = ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: Colour().mainBackGroundColor,
    primaryColor: Colour().darkHeadingColumnDataTables,
    // iconTheme: IconThemeData(color: Colour().buttonBackGroundRedColor, opacity: 0.8),
    iconTheme: IconThemeData(color: Colour().iconsGreyColor, opacity: 0.8),
    textTheme: TextTheme(bodyMedium: TextStyle(color: Colour().mainWhiteTextColor)),
    // textSelectionTheme: TextSelectionThemeData(selectionColor: Colors.red, selectionHandleColor: Colors.blue),
    textSelectionTheme: TextSelectionThemeData(
      selectionColor: Colour().buttonBackGroundRedColor,
      selectionHandleColor: Colors.black,
    ),
    // colorScheme: const ColorScheme.dark().copyWith(primarySwatch: Colors.blue, background: Colour().darkBackgroundColor),
  );

  static final lightTheme = ThemeData(
    scaffoldBackgroundColor: Colour().mainBackGroundWhiteColor,
    brightness: Brightness.light,
    // primaryColor: Colors.white,
    // colorScheme: const ColorScheme.light(),

    primaryColor: Colour().mainBackGroundWhiteColor,
    colorScheme: const ColorScheme.light(),

    iconTheme: IconThemeData(color: Colour().mainBlackIconColor, opacity: 0.8),
    // textTheme: TextTheme(bodyMedium: TextStyle(color: Colour().mainBlackTextColor)),
    // textSelectionTheme: TextSelectionThemeData(selectionColor: Colors.red, selectionHandleColor: Colors.blue),

    textTheme: TextTheme(
      bodyMedium: TextStyle(color: Colour().mainBlackTextColor),
    ),
    textSelectionTheme: TextSelectionThemeData(
      selectionColor: Colour().buttonBackGroundRedColor,
      selectionHandleColor: Colors.blue,
    ),

  );
}