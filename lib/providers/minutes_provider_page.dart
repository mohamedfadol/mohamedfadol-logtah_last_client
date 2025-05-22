import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../NetworkHandler.dart';
import '../models/minutes_model.dart';
import '../models/user.dart';

class MinutesProviderPage extends ChangeNotifier{
  var log = Logger();
  User user = User();
  int? _userId;
  NetworkHandler networkHandler = NetworkHandler();
  Minutes? minutesData;
  String _yearSelected = '2024';
  String get yearSelected => _yearSelected;
  int? get userId => _userId;


  Minute _minute = Minute();
  Minute get minute => _minute;
  void setMinute(Minute minute) async {
    _minute =  minute;
    notifyListeners();
  }

  void setYearSelected(year) async {
    _yearSelected =  year;
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

  Future<void> getListOfMinutes(String? yearSelected) async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      user = User.fromJson(json.decode(prefs.getString("user")!));
      _userId = user.businessId;

      final queryParams = {
        'business_id': _userId.toString(),
        if (yearSelected != null) 'yearSelected': yearSelected,
      };

      var response = await networkHandler.post('/get-list-minutes', queryParams);

      if (response.statusCode == 200 || response.statusCode == 201) {
        var responseData = json.decode(response.body);
        minutesData = Minutes.fromJson(responseData['data']);
        log.d("Minutes fetched length : ${responseData['data']}");
      } else {
        throw Exception("Failed to fetch minutes: ${response.statusCode}");
      }
    } catch (e) {
      log.e("Error fetching minutes: $e");
      setLoading(false);
      setIsBack(false);
      // Optionally, handle or rethrow the error as needed
    } finally {
      notifyListeners();
    }
  }

  // Method to submit the data
  Future<void> submitAgendaDetails(Map<String, dynamic> data) async {
    setLoading(true);
    log.i(data);
    final response = await networkHandler.post1('/insert-agenda-details', data);

    if (response.statusCode == 200 || response.statusCode == 201) {
      // log.d('Data submitted successfully');
      log.d(response.body);
      var responseData = json.decode(response.body);

      var responseMinuteData = responseData['data'];
      _minute = Minute.fromJson(responseMinuteData['minute']);
      log.d(_minute);
      minutesData!.minutes!.add(_minute);
      log.d(responseData['data']);
      setLoading(true);
      notifyListeners();

    } else {
      setLoading(false);
      setIsBack(false);
      log.d('Failed to submit data');
      log.d(response.body);
    }
    setLoading(false);
    notifyListeners();
  }

  Future<void> insertMinute(Map<String, dynamic> data)async{
    var response = await networkHandler.post1('/insert-new-minute', data);
    if (response.statusCode == 200 || response.statusCode == 201) {
      log.d("insert new minute response statusCode == 200");
      var responseData = json.decode(response.body) ;
      var responseMinuteData = responseData['data'];
      _minute = Minute.fromJson(responseMinuteData['minute']);
      minutesData!.minutes!.add(_minute);
      log.d(minutesData!.minutes!.length);
      setIsBack(true);
      setLoading(true);
      notifyListeners();
    } else {
      setLoading(false);
      setIsBack(false);
      notifyListeners();
      log.d("insert new minute response statusCode unknown");
      log.d(response.statusCode);
      print(json.decode(response.body)['message']);
    }
  }

  Future<void> insertMinuteFile(Map<String, dynamic> data)async{
    setLoading(true);
    notifyListeners();
    var response = await networkHandler.post1('/insert-minute-file', data);
    if (response.statusCode == 200 || response.statusCode == 201) {
      log.d("insert new minute response statusCode == 200");
      var responseData = json.decode(response.body) ;
      var responseMinuteData = responseData['data'];
      log.d(responseMinuteData['minute']);
      _minute = Minute.fromJson(responseMinuteData['minute']);
      final index = minutesData!.minutes?.indexWhere((minute) => minute.minuteId == _minute.minuteId);
      minutesData!.minutes![index!].minuteFile = _minute.minuteFile;
      setMinute(_minute);
      setIsBack(true);
      setLoading(true);
      notifyListeners();
    } else {
      setLoading(false);
      setIsBack(false);
      notifyListeners();
      log.d("insert new minute response statusCode unknown");
      log.d(response.statusCode);
      print(json.decode(response.body)['message']);
    }
  }

  Future<void> updateMinute(Map<String, dynamic> data)async{
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    user =  User.fromJson(json.decode(prefs.getString("user")!)) ;
    var response = await networkHandler.post1('/update-minutes-by-id', data);
    if (response.statusCode == 200 || response.statusCode == 201) {
      log.d("update minute response statusCode == 200");
      var responseData = json.decode(response.body) ;
      var responseMinuteData = responseData['data'];
      _minute = Minute.fromJson(responseMinuteData['minute']);
      // minutesData!.minutes!.add(_minute);
      // log.d(minutesData!.minutes!.length);
      setIsBack(true);
      setLoading(true);
      notifyListeners();
    } else {
      setLoading(false);
      setIsBack(false);
      notifyListeners();
      log.d(json.decode(response.body)['message']);
      log.d(response.statusCode);
    }
  }

  Future<void> removeMinute(Minute deleteMinute)async{
    setLoading(true);
    final index = minutesData!.minutes!.indexOf(deleteMinute);
    Minute minute = minutesData!.minutes![index];
    String minuteId =  minute.minuteId.toString();
    Map<String, dynamic> data = {"minute_id": minuteId};
    notifyListeners();
    var response = await networkHandler.post1('/delete-minutes-by-id', data);
    if (response.statusCode == 200 || response.statusCode == 201) {
      log.d("deleted minute response statusCode == 200");
      minutesData!.minutes!.remove(minute);
      log.d(minutesData!.minutes!.length);
      setIsBack(true);
      setLoading(false);
      notifyListeners();
    } else {
      setLoading(false);
      setIsBack(false);
      notifyListeners();
      log.d(json.decode(response.body)['message']);
      log.d(response.statusCode);
    }
  }

  Future<Map<String, dynamic>>  makeSignedMinute(Map<String, dynamic> data)async{
    var result;
    setLoading(true);
    notifyListeners();
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    user =  User.fromJson(json.decode(prefs.getString("user")!)) ;
    var response = await networkHandler.post1('/make-sign-minute', data);
    if (response.statusCode == 200 || response.statusCode == 201) {
      setIsBack(true);
      notifyListeners();
      log.d("sign minute response statusCode == 200");
      var responseData = json.decode(response.body) ;
      var responseResolutionData = responseData['data'];
      _minute = Minute.fromJson(responseResolutionData['minute']);
      setMinute(_minute);
      setIsBack(true);
      setLoading(true);
      notifyListeners();
      result = {'status': true, 'message': 'Successful', 'minute': _minute};
    } else {
      setLoading(false);
      setIsBack(false);
      notifyListeners();
      log.d("sign minute response statusCode unknown");
      log.d(response.statusCode);
      log.i(json.decode(response.body)['message']);
      result = {'status': false,'message': json.decode(response.body)['message']
      };

    }
    return result;
  }

}