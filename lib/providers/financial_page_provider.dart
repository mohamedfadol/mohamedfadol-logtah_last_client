import 'dart:convert';
import 'dart:io';

import 'package:diligov_members/NetworkHandler.dart';
import 'package:diligov_members/models/financial_model.dart';
import 'package:diligov_members/models/user.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FinancialPageProvider extends ChangeNotifier{

  var log = Logger();
  User user = User();
  NetworkHandler networkHandler = NetworkHandler();

  FinancialData? financialData;
  FinancialModel _financial = FinancialModel();
  FinancialModel get financial => _financial;
  void setFinancial(FinancialModel financial) async {
    _financial =  financial;
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

  String _yearSelected = '2025';

  String get yearSelected => _yearSelected;

  void setYearSelected(year) async {
    _yearSelected =  year;
    notifyListeners();
  }

  File? _pdfFile;
  File? get pdfFile => _pdfFile;

  Map<String, File?> uploadedFiles = {}; // Store uploaded files per nominee
  Map<String, String> enteredNames = {}; // Store entered names per nominee
  Map<String, bool> fileValidationErrors = {}; // Track if file is required

  /// Pick and upload file
  Future<void> pickFile(String nomineeName) async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'], // Restrict to PDFs
    );
    if (result != null) {
      File file = File(result.files.single.path!);
      log.i("file $file");
      uploadedFiles[nomineeName] = file;
      fileValidationErrors[nomineeName] = false; // Clear error when file is picked
      log.i("uploadedFiles[nomineeName] ${fileValidationErrors[nomineeName]}");
      notifyListeners();
    } else {
      fileValidationErrors[nomineeName] = true; // Set error if no file is picked
      notifyListeners();
    }
  }

  /// Validate file (returns true if valid, false if missing or invalid)
  // bool validateFile(String nomineeName) {
  //   if (uploadedFiles[nomineeName] == null) {
  //     fileValidationErrors[nomineeName] = true;
  //     notifyListeners();
  //     return false;
  //   }
  //   String fileName = uploadedFiles[nomineeName]!.path.split('/').last;
  //   if (!fileName.endsWith('.pdf')) {
  //     fileValidationErrors[nomineeName] = true;
  //     notifyListeners();
  //     return false;
  //   }
  //   fileValidationErrors[nomineeName] = false;
  //   notifyListeners();
  //   return true;
  // }

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

  void clearUploadedFile(String bonusScheme) {
    uploadedFiles.remove(bonusScheme);
    fileValidationErrors.remove(bonusScheme);
    notifyListeners();
  }

  Future getListOfFinancials(_yearSelected) async{
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    user =  User.fromJson(json.decode(prefs.getString("user")!)) ;
    final Map<String, String>  queryParams = {
      'business_id': user.businessId.toString(),
      'yearSelected': _yearSelected,
    };
    log.d("get-list-financials $_yearSelected");
    var response = await networkHandler.post1('/get-list-financials',queryParams);
    if (response.statusCode == 200 || response.statusCode == 201) {
      log.d("get-list-financials response statusCode == 200");
      var responseData = json.decode(response.body) ;
      var financialsResponseData = responseData['data'];
      financialData = FinancialData.fromJson(financialsResponseData);
      notifyListeners();
    } else {
      log.d("get-list-financials response statusCode unknown");
      log.d(response.statusCode);
      print(json.decode(response.body)['message']);
    }
  }

  Future<void> insertFinancial(Map<String, dynamic> data)async{
    try{
      setLoading(true);
      var response = await networkHandler.post1('/create-new-financial', data);
      if (response.statusCode == 200 || response.statusCode == 201) {
        log.d("create-new-financial response statusCode == 200");
        var responseData = json.decode(response.body) ;
        var responseFinancialData = responseData['data'];
        _financial = FinancialModel.fromJson(responseFinancialData['financial']);
        financialData!.financials!.add(_financial);
        log.d(financialData!.financials!.length);
        setLoading(false);
        setIsBack(true);
      } else {
        log.d("create-new-financial response statusCode unknown");
        log.d(response.statusCode);
        print(json.decode(response.body)['message']);
        setLoading(false);
      }
    } catch (e) {
    // Handle not found
    print(" not found: $e");
    setLoading(false);
  }

  }

  Future<void> removeFinancial(FinancialModel deleteFinancial)async{
    setLoading(false);
    final index = financialData!.financials!.indexOf(deleteFinancial);
    FinancialModel financial = financialData!.financials![index];
    String financialId =  financial.financialId.toString();
    Map<String, dynamic> data = {"financial_id": financialId};
    var response = await networkHandler.post1('/delete-financial-by-id', data);
    if (response.statusCode == 200 || response.statusCode == 201) {
      log.d("deleted minute response statusCode == 200");
      financialData!.financials!.remove(financial);
      log.d(financialData!.financials!.length);
      setLoading(false);
      setIsBack(true);
    } else {
      log.d(json.decode(response.body)['message']);
      log.d(response.statusCode);
      setLoading(false);
      setIsBack(false);
    }
    setLoading(false);
  }

  Future<Map<String, dynamic>>  makeSignedFinancial(Map<String, dynamic> data)async{
    var result;
    setLoading(true);
    var response = await networkHandler.post1('/make-sign-financial', data);
    if (response.statusCode == 200 || response.statusCode == 201) {
      log.d("sign financial response statusCode == 200");
      var responseData = json.decode(response.body) ;
      var responseFinancialData = responseData['data'];
      _financial = FinancialModel.fromJson(responseFinancialData['financial']);
      setFinancial(_financial);
      setIsBack(true);
      result = {'status': true, 'message': 'Successful', 'financial': _financial};
    } else {
      log.d("sign financial response statusCode unknown");
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