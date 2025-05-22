import 'package:flutter/material.dart';
class Colour{

  static final Colour _instance = Colour._internal();
  factory Colour() => _instance;
  Colour._internal();

  final Color lightContainerColor = Colors.white;
  final Color darkContainerColor = const Color.fromRGBO(46, 49, 54, 1);
  final Color primaryColor = const Color.fromRGBO(84, 0, 0, 1);

  final Color buildMenuItemColor = Colors.white38;
  final Color drawerContainerColor = Colors.black12;
  final Color iconsColor = Colors.grey.shade700;
  final Color lightBackgroundColor = Colors.white;
  final Color darkBackgroundColor = Colors.grey.shade900;
  final Color buttonColor = Colors.grey.shade500;
  final Color grayButtonColor = Colors.grey.shade800;
  final Color mainBackGroundColor = const Color.fromRGBO(46, 49, 54,1);
  final Color darkHeadingColumnDataTables = const Color.fromRGBO(31, 32, 36,1);
  final Color mainColor =  const Color.fromRGBO(212, 212, 215,1);
  final Color mainContentColor =  const Color.fromRGBO(46, 49, 54,1);
  final Color darkGreyColor =  const Color.fromRGBO(191, 191, 191,1);
  final Color iconsGreyColor =  const Color.fromRGBO(84, 0, 0,1);
  final Color mainWhiteTextColor =   Colors.white;
  final Color mainBlackTextColor =   Colors.black;
  final Color mainWhiteIconColor =   Colors.white;
  final Color mainBlackIconColor =   Colors.black;
  final Color mainBackGroundWhiteColor =   Colors.white;
  final Color buttonBackGroundRedColor =   Color.fromRGBO(84, 0, 0,1);
  final Color buttonBackGroundMainColor =   Color.fromRGBO(31, 32, 36,1);
  final Color grayColor = Color.fromRGBO(191,191,191,255);




}