import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../NetworkHandler.dart';
import '../models/nomination_model.dart';
import '../models/user.dart';

class NominationPageProvider extends ChangeNotifier{
  NominationsData? nominationsData;

  NominationModel _nomination = NominationModel();
  NominationModel get nomination => _nomination;

  var log = Logger();
  User user = User();
  NetworkHandler networkHandler = NetworkHandler();

  bool _isBack = false;
  bool get isBack => _isBack;
  void setIsBack(value) async {
    _isBack =  value;
    notifyListeners();
  }

  bool _loading = false;
  bool get loading => _loading;
  void setLoading(value) async {
    _loading =  value;
    notifyListeners();
  }

  String _yearSelected = '2025';

  String get yearSelected => _yearSelected;

  void setYearSelected(year) async {
    _yearSelected =  year;
    notifyListeners();
  }

  Map<String, File?> uploadedFiles = {}; // Store uploaded files per nominee
  Map<String, String> enteredNames = {}; // Store entered names per nominee
  Map<String, bool> fileValidationErrors = {}; // Track if file is required

  /// Pick and upload file
  Future<void> pickFile(String nomineeName) async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );

    if (result != null) {
      File file = File(result.files.single.path!);
      uploadedFiles[nomineeName] = file;
      fileValidationErrors[nomineeName] = false; // Remove validation error when file is picked
      notifyListeners();
    }
  }

  /// Save entered name
  void saveEnteredName(String nomineeName, String newName) {
    enteredNames[nomineeName] = newName;
    notifyListeners();
  }

  /// Get uploaded file name
  String? getUploadedFileName(String nomineeName) {
    return uploadedFiles[nomineeName]?.path.split('/').last;
  }

  /// Get entered name
  String getEnteredName(String nomineeName) {
    return enteredNames[nomineeName] ?? "";
  }

  /// Convert file to Base64
  Future<String?> getFileAsBase64(String nomineeName) async {
    File? file = uploadedFiles[nomineeName];
    if (file != null) {
      List<int> fileBytes = await file.readAsBytes();
      return base64Encode(fileBytes);
    }
    return null;
  }

  /// Validate file (returns true if valid, false if missing)
  bool validateFile(String nomineeName) {
    if (uploadedFiles[nomineeName] == null) {
      fileValidationErrors[nomineeName] = true;
      notifyListeners();
      return false;
    }
    return true;
  }

  void setNominationModel(NominationModel nomination) async {
    _nomination =  nomination;
    notifyListeners();
  }

  Future getListOfNominations(_yearSelected) async{
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    user =  User.fromJson(json.decode(prefs.getString("user")!)) ;
    final Map<String, String>  queryParams = {
      'business_id': user.businessId.toString(),
      'yearSelected': _yearSelected,
    };
    log.d("get-list-nominations_yearSelected $_yearSelected");
    var response = await networkHandler.post1('/get-list-nominations-by-filter-date',queryParams);
    if (response.statusCode == 200 || response.statusCode == 201) {
      log.d("get-list-nominations form provider response statusCode == 200");
      var responseData = json.decode(response.body) ;
      var responseNominationsDataData = responseData['data'];
      log.d(responseNominationsDataData);
      nominationsData = NominationsData.fromJson(responseNominationsDataData);
      log.d(nominationsData!.nominations!.length);
      notifyListeners();
    } else {
      log.d("get-list-nominations form provider response statusCode unknown");
      log.d(response.statusCode);
      log.d(json.decode(response.body)['message']);
    }
  }

  Future<void> insertNewNomination(Map<String, dynamic> data)async{
    setLoading(true);
    notifyListeners();
    var response = await networkHandler.post1('/insert-new-nomination', data);
    if (response.statusCode == 200 || response.statusCode == 201) {
      setLoading(false);
      notifyListeners();
      log.d("insert new nomination response statusCode == 200");
      var responseData = json.decode(response.body) ;
      var responseNominateData = responseData['data'];
      _nomination = NominationModel.fromJson(responseNominateData['nomination']);
      setNominationModel(_nomination);
      nominationsData!.nominations!.add(_nomination);
      log.d(nominationsData!.nominations!.length);
      setLoading(false);
      notifyListeners();
    } else {
      setLoading(false);
      notifyListeners();
      log.d("insert new nomination response statusCode unknown");
      log.d(response.statusCode);
      print(json.decode(response.body)['message']);
    }
  }

  Future<void> removeNominate(NominationModel deleteNominate)async{
    setLoading(true);
    setIsBack(false);
    final index = nominationsData!.nominations!.indexOf(deleteNominate);
    NominationModel nominate = nominationsData!.nominations![index];
    String minuteId =  nominate.nominateId.toString();
    Map<String, dynamic> data = {"nominate_id": minuteId};
    notifyListeners();
    var response = await networkHandler.post1('/delete-nominate-by-id', data);
    if (response.statusCode == 200 || response.statusCode == 201) {
      log.d("deleted nominate response statusCode == 200");
      nominationsData!.nominations!.remove(nominate);
      log.d(nominationsData!.nominations!.length);
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
}