import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../NetworkHandler.dart';
import '../models/position_model.dart';
import '../models/user.dart';

class PositionsProviderPage extends ChangeNotifier  {

  var log = Logger();
  User user = User();
  NetworkHandler networkHandler = NetworkHandler();


  Positions? dataOfPositions;
  Position _position = Position();
  Position get position => _position;

  void setPosition(Position position) async {
    _position = position;
    notifyListeners();
  }

  // Changed to store only IDs instead of entire Position objects
  List<dynamic> _selectedPositionsIds = [];
  List<dynamic> get selectedPositionsIds => _selectedPositionsIds;

  bool _isBack = false;
  bool get isBack => _isBack;
  void setIsBack(value) async {
    _isBack = value;
    notifyListeners();
  }

  bool get loading => _loading;
  bool _loading = false;
  void setLoading(value) async {
    _loading = value;
    notifyListeners();
  }


  // Get selected positions as Position objects if needed
  List<Position> get selectedPositions => _selectedPositionsIds
      .map((id) => dataOfPositions!.positions!
      .firstWhere((p) => p.positionId == id))
      .toList();

  // Function to set new selected positions
  // void setSelectedPositions(List<dynamic> values) {
  //   _selectedPositionsIds = values;
  //   notifyListeners();
  // }

  // Function to remove a position from selected list
  void removeSelectedPosition(dynamic positionId) {
    log.i("Removing ID: $positionId");

    // Ensure that the list is updated with a new reference
    _selectedPositionsIds = List.from(_selectedPositionsIds)..remove(positionId);
    notifyListeners();
  }

  // Function to add a single position if needed
  void addSelectedPosition(dynamic positionId) {
    if (!_selectedPositionsIds.contains(positionId)) {
      _selectedPositionsIds.add(positionId);
      notifyListeners();
    }
  }


  Future getDataOfPositions() async{
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    user =  User.fromJson(json.decode(prefs.getString("user")!)) ;
    var businessId = user.businessId;
    var response = await networkHandler.get('/get-list-positions/${businessId}');
    if (response.statusCode == 200 || response.statusCode == 201) {
      log.d("get-list-positions response statusCode == 200");
      var responseData = json.decode(response.body);
      log.d(responseData);
      var meetingsData = responseData['data'];
      dataOfPositions =  Positions.fromJson(meetingsData);
      notifyListeners();
    } else {
      log.d("get-list-positions response statusCode unknown");
      log.d(response.statusCode);
      print(json.decode(response.body)['message']);
    }
  }




}