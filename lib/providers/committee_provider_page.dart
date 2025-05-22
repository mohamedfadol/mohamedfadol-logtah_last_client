import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../models/committee_model.dart';
import '../NetworkHandler.dart';
import '../models/user.dart';

class CommitteeProviderPage extends ChangeNotifier{

  var logger = Logger();
  User user = User();
  NetworkHandler networkHandler = NetworkHandler();
  bool isLoading = false;

  DataComm? committeesData;
  Committee _committee = Committee();
  Committee get committee => _committee;
  void setCommittee (Committee committee) async {
    _committee = committee;
    notifyListeners();
  }

  bool _loading = false;
  bool get loading => _loading;
  void setLoading(value) async {
    _loading =  value;
    notifyListeners();
  }

  bool _isBack = false;
  bool get isBack => _isBack;
  void setIsBack(value) async {
    _isBack =  value;
    notifyListeners();
  }
  String? _committeeId;
  String? get committeeId => _committeeId;
  String? selectedCombined;

  String? _dropdownError;
  String? get dropdownError => _dropdownError;

  int? _userId;
  String _yearSelected = '2024';
  String get yearSelected => _yearSelected;
  int? get userId => _userId;

  void validateDropdown() {
    if (selectedCombined == null || selectedCombined!.isEmpty) {
      _dropdownError = "Please select an item";
    } else {
      _dropdownError = null;
    }
    notifyListeners();
  }

  void setCombinedCollectionBoardCommittee(String? committeeId, String committeeName) {
    if (committeeId != null) {
      _committeeId = committeeId;
      selectedCombined = committeeName;
      _dropdownError = null;
      logger.d('Selected Committee ID: $_committeeId'); // Log selected ID
      notifyListeners();
    }
  }

  // Future getListOfCommittees (context) async{
  //   final SharedPreferences prefs = await SharedPreferences.getInstance();
  //   user =  User.fromJson(json.decode(prefs.getString("user")!)) ;
  //   print(user.businessId);
  //   var response = await networkHandler.get('/get-list-committees/${user.businessId.toString()}');
  //   if (response.statusCode == 200 || response.statusCode == 201) {
  //     logger.d("get-list-committees form provider response statusCode == 200");
  //     var responseData = json.decode(response.body) ;
  //     var boardsData = responseData['data'];
  //     committeesData = DataComm.fromJson(boardsData);
  //     logger.d(committeesData!.committees!.length);
  //     notifyListeners();
  //   } else {
  //     logger.d("get-list-committees form provider response statusCode unknown");
  //     logger.d(response.statusCode);
  //     logger.d(json.decode(response.body)['message']);
  //   }
  // }

  void setYearSelected(year) async {
    _yearSelected =  year;
    notifyListeners();
  }

  // Changed to store only IDs instead of entire Position objects
  List<dynamic> _selectedCommitteesIds = [];
  List<dynamic> get selectedCommitteesIds => _selectedCommitteesIds;


  // Get selected positions as Position objects if needed
  List<Committee> get selectedCommittees => _selectedCommitteesIds
      .map((id) => committeesData!.committees!
      .firstWhere((p) => p.id == id))
      .toList();

  // Function to set the member's selected committees when opening edit dialog
  void setSelectedCommittees(List<dynamic> committees) {
    _selectedCommitteesIds = List.from(committees);
    // notifyListeners();
  }

  // Function to remove a position from selected list
  void removeSelectedCommittees(dynamic positionId) {
    logger.i("Removing ID: $positionId");

    // Ensure that the list is updated with a new reference
    _selectedCommitteesIds = List.from(_selectedCommitteesIds)..remove(positionId);
    notifyListeners();
  }

  // Function to add a single position if needed
  void addSelectedCommittees(dynamic positionId) {
    if (!_selectedCommitteesIds.contains(positionId)) {
      _selectedCommitteesIds.add(positionId);
      notifyListeners();
    }
  }


  Future<void> getListOfMeetingsCommitteesByFilter(String? yearSelected) async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      user = User.fromJson(json.decode(prefs.getString("user")!));
      _userId = user.businessId;

      final queryParams = {
        'business_id': _userId.toString(),
        if (yearSelected != null) 'yearSelected': yearSelected,
      };

      var response = await networkHandler.post('/get-list-committees', queryParams);

      if (response.statusCode == 200 || response.statusCode == 201) {
        var responseData = json.decode(response.body);
        committeesData = DataComm.fromJson(responseData['data']);
        logger.d("committees fetched length : ${responseData['data']}");
        notifyListeners();
      } else {
        throw Exception("Failed to fetch committees: ${response.statusCode}");
      }
    } catch (e) {
      logger.e("Error fetching committees: $e");
      setLoading(false);
      setIsBack(false);
      // Optionally, handle or rethrow the error as needed
    } finally {
      notifyListeners();
    }
  }

  Future<bool> updateCommittee(Map<String, dynamic> data) async {
    setLoading(true);
    notifyListeners();

    var response = await networkHandler.post1('/update-committee', data);

    if (response.statusCode == 200 || response.statusCode == 201) {
      logger.d("Committee updated successfully!");

      // Refresh the committee list
      await getListOfMeetingsCommitteesByFilter(yearSelected);

      setLoading(false);
      notifyListeners();
      return true;
    } else {
      setLoading(false);
      notifyListeners();
      logger.e("Failed to update committee: ${json.decode(response.body)['message']}");
      return false;
    }
  }


  Future<bool> deleteCommittee(Committee deleteCommittee) async {
    setIsBack(true);
    setLoading(true);

    final index = committeesData!.committees!.indexWhere((c) => c.id == deleteCommittee.id);
    if (index == -1) {
      logger.e("Committee not found in list");
      return false;
    }

    // Send request to backend to delete
    Map<String, dynamic> data = {
      'business_id': _userId.toString(),
      'committee_id': deleteCommittee.id.toString(),
    };

    var response = await networkHandler.post1('/delete-committee', data);

    if (response.statusCode == 200 || response.statusCode == 201) {
      logger.d("Deleted committee successfully!");

      // Fetch the latest committee list from the API to ensure data consistency
      await getListOfMeetingsCommitteesByFilter(yearSelected);

      setIsBack(false);
      setLoading(false);
      notifyListeners();  // Refresh UI

      return true;
    } else {
      setLoading(false);
      setIsBack(false);
      notifyListeners();

      logger.e("Failed to delete committee: ${json.decode(response.body)['message']}");
      return false;
    }
  }




  Future getListOfCommitteesData() async{
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    user =  User.fromJson(json.decode(prefs.getString("user")!)) ;
    print(user.businessId);
    var response = await networkHandler.get('/get-list-committees-by-business-id/${user.businessId.toString()}');
    if (response.statusCode == 200 || response.statusCode == 201) {
      logger.d("get-list-committees form provider response statusCode == 200");
      var responseData = json.decode(response.body) ;
      var boardsData = responseData['data'];
      committeesData = DataComm.fromJson(boardsData);
      logger.d(committeesData!.committees!.length);
      notifyListeners();
    } else {
      logger.d("get-list-committees form provider response statusCode unknown");
      logger.d(response.statusCode);
      logger.d(json.decode(response.body)['message']);
    }
  }

  Future<void> insertCommittee(Map<String, dynamic> data)async{
    setLoading(true);
    notifyListeners();
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    user =  User.fromJson(json.decode(prefs.getString("user")!)) ;
    var response = await networkHandler.post1('/insert-new-committee', data);
    if (response.statusCode == 200 || response.statusCode == 201) {
      setIsBack(true);
      notifyListeners();
      logger.d("insert new committee response statusCode == 200");
      var responseData = json.decode(response.body) ;
      var responseCommitteeData = responseData['data'];
      _committee = Committee.fromJson(responseCommitteeData['committee']);
      Future.delayed(Duration.zero, () {
        committeesData!.committees!.add(_committee);
        logger.d(committeesData!.committees!.length!);
      });
      setIsBack(true);
      setLoading(true);
      notifyListeners();
    } else {
      setLoading(false);
      setIsBack(false);
      notifyListeners();
      logger.d("insert new committee response statusCode unknown");
      logger.d(response.statusCode);
      print(json.decode(response.body)['message']);
    }
  }




}