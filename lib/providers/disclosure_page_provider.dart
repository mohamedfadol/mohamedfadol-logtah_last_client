import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../NetworkHandler.dart';
import '../models/disclosure_model.dart';
import '../models/user.dart';

class DisclosurePageProvider extends ChangeNotifier {
  var log = Logger();
  User user = User();
  NetworkHandler networkHandler = NetworkHandler();
  Disclosures? disclosuresData;
  DisclosureModel _disclosure = DisclosureModel();
  DisclosureModel get disclosure => _disclosure;
  void setDisclosure(DisclosureModel disclosure) async {
    _disclosure = disclosure;
    notifyListeners();
  }

  bool _loading = false;
  bool get loading => _loading;
  void setLoading(value) async {
    _loading = value;
    notifyListeners();
  }
  bool _isBack = false;
  bool get isBack => _isBack;
  void setIsBack(value) async {
    _isBack = value;
    notifyListeners();
  }

  String _yearSelected = '2025';
  String get yearSelected => _yearSelected;

  void setYearSelected(year) async {
    _yearSelected =  year;
    notifyListeners();
  }

  Future getListOfDisclosures(_yearSelected, String committeeId) async{
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    user =  User.fromJson(json.decode(prefs.getString("user")!)) ;
    final Map<String, String>  queryParams = {
      'business_id': user.businessId.toString(),
      'yearSelected': _yearSelected,
      "committee_id": committeeId
    };
    var response = await networkHandler.post1('/get-list-disclosures', queryParams);
    if (response.statusCode == 200 || response.statusCode == 201) {
      log.d("get-list-disclosures form provider response statusCode == 200");
      var responseData = json.decode(response.body);
      var responseDisclosureData = responseData['data'];
      disclosuresData = Disclosures.fromJson(responseDisclosureData);
      log.d(disclosuresData!.disclosures!.length);
      notifyListeners();
    } else {
      log.d("get-list-disclosures form provider response statusCode unknown");
      log.d(response.statusCode);
      log.d(json.decode(response.body)['message']);
    }
  }

  Future getListOfAllDisclosures(_yearSelected) async{
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    user =  User.fromJson(json.decode(prefs.getString("user")!)) ;
    final Map<String, String>  queryParams = {
      'business_id': user.businessId.toString(),
      'yearSelected': _yearSelected
    };
    var response = await networkHandler.post1('/get-list-of-all-disclosures', queryParams);
    if (response.statusCode == 200 || response.statusCode == 201) {
      log.d("get-list-disclosures form provider response statusCode == 200");
      var responseData = json.decode(response.body);
      var responseDisclosureData = responseData['data'];
      disclosuresData = Disclosures.fromJson(responseDisclosureData);
      log.d(disclosuresData!.disclosures!.length);
      notifyListeners();
    } else {
      log.d("get-list-disclosures form provider response statusCode unknown");
      log.d(response.statusCode);
      log.d(json.decode(response.body)['message']);
    }
  }



  Future<Map<String, dynamic>>  makeSignedDisclosure(Map<String, dynamic> data)async{
    var result;
    setLoading(true);
    var response = await networkHandler.post1('/make-sign-disclosure', data);
    if (response.statusCode == 200 || response.statusCode == 201) {
      log.d("sign disclosure response statusCode == 200");
      var responseData = json.decode(response.body) ;
      var responseDisclosure = responseData['data'];
      _disclosure = DisclosureModel.fromJson(responseDisclosure['disclosure']);
      setDisclosure(_disclosure);
      setIsBack(true);
      result = {'status': true, 'message': 'Successful', 'disclosure': _disclosure};
    } else {
      log.d("sign disclosure response statusCode unknown");
      log.d(response.statusCode);
      log.i(json.decode(response.body)['message']);
      setLoading(false);
      setIsBack(false);
      result = {'status': false,'message': json.decode(response.body)['message']};
    }
    setLoading(false);
    return result;
  }


}