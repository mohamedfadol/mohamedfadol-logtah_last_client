import 'package:diligov_members/providers/theme_provider.dart';
import 'package:flutter/material.dart';

class IconsProvider with ChangeNotifier{

  final ThemeProvider themeProvider;

  IconsProvider(this.themeProvider);

  String get getIconPath => themeProvider.getIconPath;

  void updateIcon(String lightPath, String darkPath) {
    themeProvider.lightIconPath = lightPath;
    themeProvider.darkIconPath = darkPath;
    notifyListeners();
  }
}

