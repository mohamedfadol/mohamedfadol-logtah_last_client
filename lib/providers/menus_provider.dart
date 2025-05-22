
import 'package:diligov_members/circle_menus/board_circle_menu.dart';
import 'package:diligov_members/circle_menus/committ_circle_menu.dart';
import 'package:flutter/material.dart';

class MenusProvider with ChangeNotifier {

  var menu = null;
  String iconName = "Home";
  bool _menuPressed = false;

  final List<String> _menuHistory = []; // Stack to store menu history
  // Widget? get getCurrentMenu => menu;
  dynamic get getCurrentMenu => menu;
  String get getIconName => iconName;
  bool get menuPressed => _menuPressed;
  // Add a state for showing the Home icon
  bool _showHomeIcon = false;
  bool get showHomeIcon => _showHomeIcon;



  // Method to get the correct icon path
  String get getIconPath {
    if (_showHomeIcon) {
      return "images/diligov_icon.png"; // Temporary Home icon
    }
    if (_menuHistory.isNotEmpty && _menuHistory.last == "Board") {
      return "images/diligov_icon.png"; // Show Home icon if previous was Board
    }
    return "icons/board_circle_menu_icons/committee_icon.png"; // Default menu icon
  }

  void backToHomeMenu(){
    menu = null;
    iconName = "Home";
    notifyListeners();
  }

   Map<String, Widget> menusMap = {
    "Board": BoardCircleMenu(),
    "Committees": CommitteeCircleMenu(),
  };

  // Change the menu and add current menu to history
  void changeMenu(String chosenMenu) {
    if (chosenMenu == "Home") {
      backToHomeMenu();
      _menuHistory.clear(); // Clear history when navigating to Home
    } else {
      if (menu != null && iconName != "Home") {
        _menuHistory.add(iconName); // Save the current menu to history
      }
      menu = menusMap[chosenMenu];
      iconName = chosenMenu;
    }
    notifyListeners();
  }

  // Getter for the previous menu's iconName
  String? get getPreviousMenuIconName {
    if (_menuHistory.isNotEmpty) {
      return _menuHistory.last; // The last item in the history stack
    }
    return null; // Return null if there's no history
  }

  void changeIconName(String newIconName){
    iconName = newIconName;
    notifyListeners();
  }

  void changeMenuPressed(){
    _menuPressed = !_menuPressed;
    notifyListeners();
  }

  void goToPreviousMenu() {
    if (_menuHistory.isNotEmpty) {
      final previousMenu = _menuHistory.removeLast();
      menu = menusMap[previousMenu];
      iconName = previousMenu;
      print("No previous menu to navigate to. $iconName  $menu");
    } else {
      backToHomeMenu();
    }
    notifyListeners();
  }

  // Show Home icon temporarily
  void toggleHomeIcon(bool value) {
    _showHomeIcon = value;
    notifyListeners();
  }
}