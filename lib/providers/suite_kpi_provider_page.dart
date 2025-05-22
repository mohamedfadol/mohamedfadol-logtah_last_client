import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../NetworkHandler.dart';
import '../models/c-sute_kpi.dart';
import '../models/user.dart';

class SuiteKpiProviderPage extends ChangeNotifier{
  var log = Logger();
  User user = User();
  NetworkHandler networkHandler = NetworkHandler();
  CsuiteKpiData? csuiteKpiData;
  CsuiteKpiModel _csuiteKpi = CsuiteKpiModel();
  CsuiteKpiModel get csuiteKpi => _csuiteKpi;

  void setCsuiteKpi(CsuiteKpiModel csuiteKpi) async {
    _csuiteKpi =  csuiteKpi;
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

  // Define constants for file keys
  static const String CEO_KPI = 'ceo-kpi';
  static const String LONG_TERM_INCENTIVE = 'long-term-incentive';
  static const String SHORT_TERM_INCENTIVE = 'short-term-incentive';

  Map<String, File?> uploadedFiles = {}; // Store uploaded files by key
  Map<String, String> fileTypes = {}; // Store file types by key
  Map<String, bool> fileValidationErrors = {}; // Track validation errors
  Map<String, bool> isUploading = {}; // Track upload state by key
  Map<String, String> enteredNames = {}; // Store entered names per nominee

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

  /// Pick and upload file
  Future<void> pickFile(String fileKey, String fileType) async {
    try {
      setLoading(true);

      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'], // Restrict to PDFs
      );

      if (result != null) {
        File file = File(result.files.single.path!);
        log.i("Selected file: ${file.path} for type: $fileType");

        // Store both the file and its type
        uploadedFiles[fileKey] = file;
        fileTypes[fileKey] = fileType; // Store the file type
        fileValidationErrors[fileKey] = false;

        notifyListeners();
      } else {
        // User canceled the picker
        log.i("File picking canceled for $fileKey");
      }
    } catch (e) {
      log.e("Error picking file: $e");
      fileValidationErrors[fileKey] = true;
    } finally {
      setLoading(false);
    }
  }

// Define constants for file keys and whether they're required
  static const Map<String, bool> FILE_REQUIREMENTS = {
    'ceo-kpi': true,         // Required
    'long-term-incentive': true,  // Required
    'short-term-incentive': true,  // Required
  };


  // Check if all required files are uploaded
  bool validateAllRequired() {
    bool allValid = true;

    FILE_REQUIREMENTS.forEach((fileKey, isRequired) {
      if (isRequired && uploadedFiles[fileKey] == null) {
        fileValidationErrors[fileKey] = true;
        allValid = false;
      }
    });

    notifyListeners();
    return allValid;
  }

  // Convert all files to base64 and create payload list
  Future<List<Map<String, dynamic>>> prepareFilePayloads(String committeeId) async {
    List<Map<String, dynamic>> payloads = [];
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    user =  User.fromJson(json.decode(prefs.getString("user")!));
    for (var entry in uploadedFiles.entries) {
      String fileKey = entry.key;
      File? file = entry.value;

      if (file != null) {
        // Read file
        List<int> fileBytes = await file.readAsBytes();
        String base64File = base64Encode(fileBytes);

        // Get file type and name
        String fileType = fileTypes[fileKey] ?? "unknown";
        String fileName = file.path.split('/').last;

        // Create payload
        Map<String, dynamic> payload = {
          'fileName': fileName,
          'fileData': base64File,
          'fileType': fileType,
          'fileKey': fileKey,
          'committeeId': committeeId,
          'business_id': user.businessId,
          'user_id': user.userId,
          'year': yearSelected,
        };

        payloads.add(payload);
      }
    }

    return payloads;
  }

  // Submit all files in a single request
  Future<void> submitAllFiles(String committeeId) async {
    try {
      setLoading(true);
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      user =  User.fromJson(json.decode(prefs.getString("user")!));
      // Validate and prepare file payloads
      // if (!validateAllRequired()) {
      //   return false;
      // }

      // Prepare all file payloads
      List<Map<String, dynamic>> filePayloads =
      await prepareFilePayloads(committeeId);

      // if (filePayloads.isEmpty) {
      //   log.w("No files to upload");
      //   return false;
      // }

      // Create a single request with all files
      Map<String, dynamic> batchPayload = {
        'files': filePayloads,
        'business_id': user.businessId,
        'user_id': user.userId,
        'committeeId': committeeId,
        'year': yearSelected,
      };

      // Send batch request
      var response = await networkHandler.post1('/uploadKpiFiles/batch', batchPayload);

      if (response.statusCode == 200 || response.statusCode == 201) {
        log.i("All files uploaded successfully");
        var responseData = json.decode(response.body) ;
        var responsePerformanceRewardData = responseData['data'];
        setLoading(false);
        _csuiteKpi = CsuiteKpiModel.fromJson(responsePerformanceRewardData['suite_kpi']);
        setCsuiteKpi(_csuiteKpi);
        csuiteKpiData!.csuiteKpis!.add(_csuiteKpi);
        log.d(csuiteKpiData!.csuiteKpis!.length);
        setLoading(false);
        // Clear validation errors on success
        FILE_REQUIREMENTS.keys.forEach((key) {
          fileValidationErrors[key] = false;
        });

        // return true;
      } else {
        log.e("Error uploading files: ${response.body}");
        log.d("insert new performance response statusCode unknown");
        log.d(response.statusCode);
        print(json.decode(response.body)['message']);
        setLoading(false);
        // return false;
      }
    } catch (e) {
      log.e("Exception uploading files: $e");
      setLoading(false);
      // return false;
    } finally {
      setLoading(false);

    }
  }

  // Alternate implementation: Submit files individually but in sequence
  Future<bool> submitFilesSequentially(String committeeId) async {
    try {
      setLoading(true);

      if (!validateAllRequired()) {
        return false;
      }

      bool overallSuccess = true;

      // Process each file sequentially
      for (var entry in uploadedFiles.entries) {
        String fileKey = entry.key;
        File? file = entry.value;

        if (file != null) {
          // Read file
          List<int> fileBytes = await file.readAsBytes();
          String base64File = base64Encode(fileBytes);

          // Get file type and name
          String fileType = fileTypes[fileKey] ?? "unknown";
          String fileName = file.path.split('/').last;

          // Create payload
          Map<String, dynamic> payload = {
            'fileName': fileName,
            'fileData': base64File,
            'fileType': fileType,
            'committeeId': committeeId,
            'year': yearSelected,
          };

          // Upload file
          var response = await networkHandler.post1('/api/uploadKpiFile', payload);

          if (response.statusCode != 200 && response.statusCode != 201) {
            log.e("Error uploading file $fileKey: ${response.body}");
            overallSuccess = false;
          }
        }
      }

      return overallSuccess;
    } catch (e) {
      log.e("Exception in sequential upload: $e");
      return false;
    } finally {
      setLoading(false);
    }
  }

  /// Validate all required files before submission
  bool validateAllFiles() {
    bool allValid = true;

    // List all required file types here
    List<String> requiredFiles = [CEO_KPI, LONG_TERM_INCENTIVE, SHORT_TERM_INCENTIVE];

    for (String fileType in requiredFiles) {
      if (!validateFile(fileType)) {
        allValid = false;
      }
    }

    return allValid;
  }

  /// Clear uploaded file and its type
  void clearUploadedFile(String fileKey) {
    uploadedFiles.remove(fileKey);
    fileTypes.remove(fileKey); // Also remove the file type
    fileValidationErrors.remove(fileKey);
    notifyListeners();
  }

  Future getListOfSuiteKpisByCommitteeId(_yearSelected, String committeeId) async{
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    user =  User.fromJson(json.decode(prefs.getString("user")!)) ;
    final Map<String, String>  queryParams = {
      'business_id': user.businessId.toString(),
      'yearSelected': _yearSelected,
      "committee_id": committeeId
    };
    log.d("get-list-c-suite-kpis-by-committeeId $_yearSelected");
    var response = await networkHandler.post1('/get-list-of-suite-kpis-by-committeeId',queryParams);
    if (response.statusCode == 200 || response.statusCode == 201) {
      log.d("get-list-c-suite-kpis-by-committeeId response statusCode == 200");
      var responseData = json.decode(response.body) ;
      var financialsResponseData = responseData['data'];
      csuiteKpiData = CsuiteKpiData.fromJson(financialsResponseData);
      notifyListeners();
    } else {
      log.d("get-list-c-suite-kpis-by-committeeId response statusCode unknown");
      log.d(response.statusCode);
      print(json.decode(response.body)['message']);
    }
  }


  Future<void> removeSuiteKpi(CsuiteKpiModel deleteCsuiteKpi)async{
    setLoading(false);
    final index = csuiteKpiData!.csuiteKpis!.indexOf(deleteCsuiteKpi);
    CsuiteKpiModel csuiteKpi = csuiteKpiData!.csuiteKpis![index];
    String csuiteKpiId =  csuiteKpi.csuiteKpiId.toString();
    Map<String, dynamic> data = {"suite_id": csuiteKpiId};
    var response = await networkHandler.post1('/delete-suite-by-id', data);
    if (response.statusCode == 200 || response.statusCode == 201) {
      log.d("deleted suite response statusCode == 200");
      csuiteKpiData!.csuiteKpis!.remove(csuiteKpi);
      log.d(csuiteKpiData!.csuiteKpis!.length);
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



}