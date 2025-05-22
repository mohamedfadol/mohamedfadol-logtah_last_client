import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../NetworkHandler.dart';
import '../models/annual_audit_report_model.dart';
import '../models/combined_collection_board_committee_model.dart';
import '../models/user.dart';

class AnnualAuditReportProvider extends ChangeNotifier{

  var log = Logger();
  User user = User();
  NetworkHandler networkHandler = NetworkHandler();

  CombinedCollectionBoardCommitteeData? collectionBoardCommitteeData;
  late List<TextEditingController> categoryControllers = [];
  late List<List<TextEditingController>> questionControllers = [];
  List<List<Widget>> categoryItems = [];
  List<List<Widget>> criteriaItems = [];
  List<Map<String, dynamic>> formData = [];
  Map<int, Map<int, int>> _evaluations = {}; // {memberId: {questionId: score}}


  AnnualAuditReportData? annual_audit_reports_data;
  AnnualAuditReportModel _annual_audit_report = AnnualAuditReportModel();
  AnnualAuditReportModel get annual_audit_report => _annual_audit_report;
  void setAnnualAuditReport(AnnualAuditReportModel annual_audit_report) async {
    _annual_audit_report =  annual_audit_report;
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


  late List<TextEditingController> titleControllers = [];
  late List<TextEditingController> descriptionControllers = [];

  late List<TextEditingController> arabicTitleControllers = [];
  late List<TextEditingController> arabicDescriptionControllers = [];

  late List<List<TextEditingController>> titleControllersList = [];
  late List<List<TextEditingController>> descriptionControllersList = [];

  late List<List<TextEditingController>> arabicTitleControllersList = [];
  late List<List<TextEditingController>> arabicDescriptionControllersList = [];

  List<List<Widget>> childItems = [];
  List<List<Widget>> arabicChildItems = [];

  Map<String, dynamic>? combined;


  String? _dropdownError;
  String? get dropdownError => _dropdownError;


  bool _enableArabic = false;
  bool _enableEnglish = true;
  bool _enableArabicAndEnglish = false;
  bool get enableArabic => _enableArabic;
  bool get enableEnglish => _enableEnglish;
  bool get enableArabicAndEnglish => _enableArabicAndEnglish;

  String? selectedCombined;

  String _currentYear = DateTime.now().year.toString();
  String get currentYear => _currentYear;
  void updateYear() {
    _currentYear = DateTime.now().year.toString();
    notifyListeners();
  }

  String _yearSelected = '2025';

  String get yearSelected => _yearSelected;

  void setYearSelected(year) async {
    _yearSelected =  year;
    notifyListeners();
  }

  // Method to validate the dropdown selection
  void validateDropdown() {
    if (selectedCombined == null || selectedCombined!.isEmpty) {
      _dropdownError = "Please select an item";
    } else {
      _dropdownError = null;
    }
    notifyListeners();
  }


  void selectCombinedCollectionBoardCommittee(String? combinedModel) {
    if (combinedModel != null) {
      List<String> parts = combinedModel.split('-');
      if (parts.length == 2) {
        String name = parts[0];
        int? id = int.tryParse(parts[1]);
        combined = {"id": id, "type": name};
        log.i(combined);
        selectedCombined = name.toString();
        _dropdownError = null;
        notifyListeners();
      }
    }
  }

  void setCombinedCollectionBoardCommittee(String? combinedModel) {
    if (combinedModel != null) {
      List<String> parts = combinedModel.split('-');
      if (parts.length == 2) {
        String name = parts[0];
        int? id = int.tryParse(parts[1]);
        combined = {"id": id, "type": name};
        log.i(combined);
        selectedCombined = name.toString();
        _dropdownError = null;
        // fetchMeetings(false, _showUnPublished, false, _yearSelected,combined);
        notifyListeners();
      }
    }
  }

  Future getListOfCombinedCollectionBoardAndCommittee()async{
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    user =  User.fromJson(json.decode(prefs.getString("user")!)) ;
    var businessId = user.businessId;
    Map<String, dynamic> data = {"business_id": businessId};
    var response = await networkHandler.post1('/combined-collection-board-and-committees',data);
    if (response.statusCode == 200 || response.statusCode == 201) {
      log.d("get-list-meetings response statusCode == 200");
      var responseData = json.decode(response.body);
      log.d(responseData);
      var meetingsData = responseData['data'];
      collectionBoardCommitteeData = CombinedCollectionBoardCommitteeData.fromJson(meetingsData);
      print(collectionBoardCommitteeData!.combinedCollectionBoardCommitteeData!.length);
      notifyListeners();

    } else {
      log.d("get-list-meetings response statusCode unknown");
      log.d(response.statusCode);
      print(json.decode(response.body)['message']);
    }
  }


  void toggleEnableArabic() {
    _enableArabic = !_enableArabic;
    _enableEnglish = false;
    _enableArabicAndEnglish= false;
    log.i('arabic');
    notifyListeners();
  }

  void toggleEnableEnglish() {
    _enableEnglish = !_enableEnglish;
    _enableArabic = false;
    _enableArabicAndEnglish= false;
    log.i('english');
    notifyListeners();
  }

  void toggleEnableArabicAndEnglish() {
    _enableArabicAndEnglish = !_enableArabicAndEnglish;
    _enableEnglish = false;
    _enableArabic = false;
    log.i('dual');
    notifyListeners();
  }


  void initializeChildControllers(int parentIndex, int childCount) {
    // Ensure the parentIndex is valid and lists are initialized
    while (arabicTitleControllersList.length <= parentIndex) {
      titleControllersList.add([]);
      descriptionControllersList.add([]);

      arabicTitleControllersList.add([]);
      arabicDescriptionControllersList.add([]);
    }
    // Initialize child controllers
    if (titleControllersList[parentIndex].length < childCount) {
      titleControllersList[parentIndex] = List.generate(childCount, (_) => TextEditingController());
    }
    if (descriptionControllersList[parentIndex].length < childCount) {
      descriptionControllersList[parentIndex] = List.generate(childCount, (_) => TextEditingController());
    }
    // Initialize Arabic child controllers
    if (arabicTitleControllersList[parentIndex].length < childCount) {
      arabicTitleControllersList[parentIndex] = List.generate(childCount, (_) => TextEditingController());
    }
    if (arabicDescriptionControllersList[parentIndex].length < childCount) {
      arabicDescriptionControllersList[parentIndex] = List.generate(childCount, (_) => TextEditingController());
    }
  }

  void addNewEnglishParentForm() {
    titleControllers.add(TextEditingController());
    descriptionControllers.add(TextEditingController());
    childItems.add([]);
    titleControllersList.add([]);
    descriptionControllersList.add([]);
    notifyListeners();
  }

  void removeButtonForEnglishParentFormFields(int index) {
    if (index < 0 || index >= titleControllers.length) {
      print("Index out of range: $index");
      return; // Guard clause to handle out-of-range index
    }
    log.i("Removing Index: $index");
    // Dispose and remove main field controllers
    titleControllers[index].dispose();
    descriptionControllers[index].dispose();
    titleControllers.removeAt(index);
    descriptionControllers.removeAt(index);
    // Remove corresponding child controllers and lists if they exist
    if (index < childItems.length) {
      // Remove child controllers
      // Ensure the parent index exists in the child lists
      if (index < titleControllersList.length) {
        for (int i = titleControllersList[index].length - 1; i >= 0; i--) {
          // Safely remove each child controller
          removeEnglishChildItem(index, i);
        }
        // Remove the child controller lists after clearing their contents
        titleControllersList.removeAt(index);
        descriptionControllersList.removeAt(index);
      }
      childItems.removeAt(index);
      if (index < titleControllersList.length) titleControllersList.removeAt(index);
      if (index < descriptionControllersList.length) descriptionControllersList.removeAt(index);
    }

    notifyListeners(); // Notify listeners after state changes
  }

  void ensureListCapacity<T>(List<List<T>> list, int index) {
    while (list.length <= index) {
      list.add([]); // Add an empty list of the correct type
    }
  }

  void addNewFormForEnglishChildren(int parentIndex) {
    // Ensure the parent index is valid
    if (parentIndex >= 0) {
      // Step 1: Ensure the parent list for child items exists (as a List<List<Widget>>)
      ensureListCapacity<Widget>(childItems, parentIndex);
      ensureListCapacity<TextEditingController>(titleControllersList, parentIndex);
      ensureListCapacity<TextEditingController>(descriptionControllersList, parentIndex);
      // Step 4: Add new controllers for each child field for this parent
      titleControllersList[parentIndex].add(TextEditingController());
      descriptionControllersList[parentIndex].add(TextEditingController());
      // Step 3: Add a new child widget to the parent's list
      childItems[parentIndex].add(Text('Child Item ${childItems[parentIndex].length + 1}'));
      // Step 6: Notify listeners to update the UI
      notifyListeners();
    }
  }


  void initialAndEnsureListCapacity(int parentIndex) {
    // Ensure the parent index is valid
    if (parentIndex >= 0) {

      // Helper function to ensure a list has enough capacity and initialize elements
      void ensureListCapacity<T>(List<List<T>> list, int index) {
        while (list.length <= index) {
          list.add([]); // Add an empty list of the correct type
        }
      }
      // Step 1: Ensure the parent list for child items exists (as a List<List<Widget>>)
      ensureListCapacity<Widget>(childItems, parentIndex);

      // Step 3: Add a new child widget to the parent's list
      childItems[parentIndex].add(
          Text('Child Item ${childItems[parentIndex].length + 1}') // Example widget
      );

    }
  }

  void removeEnglishChildItem(int parentIndex, int childIndex) {
    if (parentIndex < 0 || parentIndex >= childItems.length ||
        childIndex < 0 || childIndex >= childItems[parentIndex].length) {
      return; // Guard clause to prevent out-of-range access
    }
    if (parentIndex >= titleControllersList.length || childIndex >= titleControllersList[parentIndex].length) {
      print("Child index out of range for parent: $parentIndex, child: $childIndex");
      return; // Avoid accessing invalid indices
    }
    // Dispose child controllers
    titleControllersList[parentIndex][childIndex].dispose();
    descriptionControllersList[parentIndex][childIndex].dispose();

    // Remove controllers from their respective lists
    titleControllersList[parentIndex].removeAt(childIndex);
    descriptionControllersList[parentIndex].removeAt(childIndex);

    // Remove child item widgets
    childItems[parentIndex].removeAt(childIndex);

    notifyListeners(); // Notify listeners after state changes
  }

  void addNewArabicParentForm() {
    arabicTitleControllers.add(TextEditingController());
    arabicDescriptionControllers.add(TextEditingController());
    arabicChildItems.add([]);  // Empty list for children
    arabicTitleControllersList.add([]);
    arabicDescriptionControllersList.add([]);
    notifyListeners();
  }

  void addArabicChildItem(int parentIndex) {
    // Ensure the parent index is valid
    if (parentIndex >= 0) {
      // Helper function to ensure a list has enough capacity and initialize elements
      void ensureListCapacity<T>(List<List<T>> list, int index) {
        while (list.length <= index) {
          list.add([]); // Add an empty list of the correct type
        }
      }
      // Step 1: Ensure the parent list for child items exists (as a List<List<Widget>>)
      ensureListCapacity<Widget>(arabicChildItems, parentIndex);
      // Step 2: Ensure the controller lists exist
      ensureListCapacity<TextEditingController>(arabicTitleControllersList, parentIndex);
      ensureListCapacity<TextEditingController>(arabicDescriptionControllersList, parentIndex);
      // Step 3: Add a new child widget to the parent's list
      arabicChildItems[parentIndex].add(
          Text('Child Item ${arabicChildItems[parentIndex].length + 1}') // Example widget
      );
      // Step 4: Add new controllers for each child field for this parent
      arabicTitleControllersList[parentIndex].add(TextEditingController());
      arabicDescriptionControllersList[parentIndex].add(TextEditingController());
      // Step 6: Notify listeners to update the UI
      notifyListeners();
    }
  }

  void removeArabicChildItem(int parentIndex, int childIndex) {
    log.i(arabicChildItems.length);
    // Check if the parent index is valid and within bounds
    if (parentIndex >= 0 && parentIndex < arabicChildItems.length) {
      // Check if the child index is valid for the parent list
      if (childIndex >= 0 && childIndex < arabicChildItems[parentIndex].length) {
        // Remove the child widget
        arabicChildItems[parentIndex].removeAt(childIndex);
        // Remove the corresponding controllers for this child
        arabicTitleControllersList[parentIndex].removeAt(childIndex);
        arabicDescriptionControllersList[parentIndex].removeAt(childIndex);
        // Notify listeners to update the UI
        notifyListeners();
      } else {
        // Handle case where the child index is out of bounds
        print("Invalid child index: $childIndex for parent index: $parentIndex");
      }
    } else {
      // Handle case where the parent index is out of bounds
      print("Invalid parent index: $parentIndex");
    }
  }

  void removeArabicFormParentFields(int index) {
    if (index < 0 || index >= arabicTitleControllers.length) {
      return; // Guard clause to handle out-of-range index
    }
    // Dispose and remove the main controllers
    arabicTitleControllers[index].dispose();
    arabicDescriptionControllers[index].dispose();
    arabicTitleControllers.removeAt(index);
    arabicDescriptionControllers.removeAt(index);
    // Check if there are child items and remove them
    if (index < arabicChildItems.length) {
      for (var child in arabicChildItems[index]) {
        int childIndex = arabicChildItems[index].indexOf(child);
        arabicTitleControllersList[index][childIndex].dispose();
        arabicDescriptionControllersList[index][childIndex].dispose();
      }
      // Clear the lists after disposing of the controllers
      arabicTitleControllersList[index].clear();
      arabicDescriptionControllersList[index].clear();
      arabicChildItems.removeAt(index);
      arabicTitleControllersList.removeAt(index);
      arabicDescriptionControllersList.removeAt(index);
    }

    notifyListeners();
  }
  // Method to clear all controllers
  void clearAllControllers() {
    for (var controller in titleControllers) {
      controller.clear();
    }
    for (var controller in descriptionControllers) {
      controller.clear();
    }

    for (var controller in arabicTitleControllers) {
      controller.clear();
    }
    for (var controller in arabicDescriptionControllers) {
      controller.clear();
    }

    for (var controllerList in titleControllersList) {
      for (var controller in controllerList) {
        controller.clear();
      }
    }
    for (var controllerList in descriptionControllersList) {
      for (var controller in controllerList) {
        controller.clear();
      }
    }

    for (var controllerList in arabicTitleControllersList) {
      for (var controller in controllerList) {
        controller.clear();
      }
    }
    for (var controllerList in arabicDescriptionControllersList) {
      for (var controller in controllerList) {
        controller.clear();
      }
    }
    // Clear child items
    childItems.clear();
    arabicChildItems.clear();

    notifyListeners();
  }

  void reorderChildItems(int parentIndex, int oldIndex, int newIndex) {
    if (newIndex >oldIndex) {
      newIndex -= 1;
    }
    notifyListeners();
  }

  void reorderArabicChildItems(int parentIndex, int oldIndex, int newIndex) {
    if (newIndex >oldIndex) {
      newIndex -= 1;
    }
    notifyListeners();
  }

  Future getListOfAnnualAuditReports(_yearSelected)async{
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    user =  User.fromJson(json.decode(prefs.getString("user")!)) ;
    final Map<String, String>  queryParams = {
      'business_id': user.businessId.toString(),
      'yearSelected': _yearSelected,
    };
    log.d("get-list-annual_audit_reports_yearSelected $_yearSelected");
    var response = await networkHandler.post1('/get-list-annual-audit-reports',queryParams);
    if (response.statusCode == 200 || response.statusCode == 201) {
      log.d("get-list-annual_audit_reports response statusCode == 200");
      var responseData = json.decode(response.body) ;
      var annualReportsResponseData = responseData['data'];
      // log.d("get-list-annual_audit_reports $annualReportsResponseData");
      annual_audit_reports_data = AnnualAuditReportData.fromJson(annualReportsResponseData);
      notifyListeners();
    } else {
      log.d("get-list-annual_audit_reports response statusCode unknown");
      log.d(response.statusCode);
      print(json.decode(response.body)['message']);
    }
  }

  Future<void> insertAnnualAuditReport(Map<String, dynamic> data)async{
    setLoading(true);
    var response = await networkHandler.post1('/create-new-annual-report', data);
    if (response.statusCode == 200 || response.statusCode == 201) {
      log.d("create-new-annual-audit_report response statusCode == 200");
      var responseData = json.decode(response.body) ;
      var responseAnnualReportsData = responseData['data'];
      _annual_audit_report = AnnualAuditReportModel.fromJson(responseAnnualReportsData['annual_report']);
      annual_audit_reports_data!.annual_audit_reports_data!.add(_annual_audit_report);
      log.d(annual_audit_reports_data!.annual_audit_reports_data!.length);
      setIsBack(true);
    } else {
      log.d("create-new-annual-audit_report response statusCode unknown");
      log.d(response.statusCode);
      print(json.decode(response.body)['message']);
    }
    setLoading(false);
  }


  Future<void> insertNewAnnualAuditReport(Map<String, dynamic> data)async{
    setLoading(true);
    notifyListeners();
    var response = await networkHandler.post1('/create-annual-audit-report', data);
    if (response.statusCode == 200 || response.statusCode == 201) {
      log.d("insert new meeting response statusCode == 200");
      var responseData = json.decode(response.body) ;
      var meetingsData = responseData['data'];
      _annual_audit_report = AnnualAuditReportModel.fromJson(meetingsData['annual_audit_report']);
      // log.d(_meeting);
      annual_audit_reports_data!.annual_audit_reports_data!.add(_annual_audit_report);
      log.d(annual_audit_reports_data!.annual_audit_reports_data!.length);

      setIsBack(true);
      setLoading(false);
      clearAllControllers(); // Clear controllers after successful insert
      notifyListeners();
    } else {
      setLoading(false);
      setIsBack(false);
      notifyListeners();
      log.d("insert new meeting response statusCode unknown");
      log.d(response.statusCode);
      print(json.decode(response.body)['message']);
    }
  }

  Future<void> removeAnnualAuditReport(AnnualAuditReportModel deleteAnnualReport)async{
    final index = annual_audit_reports_data!.annual_audit_reports_data!.indexOf(deleteAnnualReport);
    AnnualAuditReportModel annual_audit_report = annual_audit_reports_data!.annual_audit_reports_data![index];
    String annualAuditReportId =  annual_audit_report.annualAuditReportId.toString();
    Map<String, dynamic> data = {"annual_audit_report_id": annualAuditReportId};
    var response = await networkHandler.post1('/delete-annual-report-by-id', data);
    if (response.statusCode == 200 || response.statusCode == 201) {
      log.d("deleted annual-audit_report-by-id response statusCode == 200");
      annual_audit_reports_data!.annual_audit_reports_data!.remove(annual_audit_report);
      log.d(annual_audit_reports_data!.annual_audit_reports_data!.length);
      setIsBack(true);
    } else {
      log.d(json.decode(response.body)['message']);
      log.d(response.statusCode);
      setLoading(false);
      setIsBack(false);
    }
    setLoading(false);
  }

  Future<Map<String, dynamic>>  makeSignedAnnualReport(Map<String, dynamic> data)async{
    var result;
    setLoading(true);
    var response = await networkHandler.post1('/make-sign-annual-report', data);
    if (response.statusCode == 200 || response.statusCode == 201) {
      log.d("sign annual-audit-report response statusCode == 200");
      var responseData = json.decode(response.body) ;
      var responseAnnualReportData = responseData['data'];
      _annual_audit_report = AnnualAuditReportModel.fromJson(responseAnnualReportData['annual_report']);
      setAnnualAuditReport(_annual_audit_report);
      setIsBack(true);
      result = {'status': true, 'message': 'Successful', 'annual_audit_report': _annual_audit_report};
    } else {
      log.d("sign annual_audit-report response statusCode unknown");
      log.d(response.statusCode);
      log.i(json.decode(response.body)['message']);
      setLoading(false);
      setIsBack(false);
      result = {'status': false,'message': json.decode(response.body)['message']};
    }
    setLoading(false);
    return result;
  }


  Future<void> insertAnnualAuditReportFile(Map<String, dynamic> data)async{
    setLoading(true);
    notifyListeners();
    var response = await networkHandler.post1('/insert-annual_audit_report-file', data);
    if (response.statusCode == 200 || response.statusCode == 201) {
      log.d("insert new minute response statusCode == 200");
      var responseData = json.decode(response.body) ;
      var responseMinuteData = responseData['data'];
      log.d(responseMinuteData['annual_report']);
      _annual_audit_report = AnnualAuditReportModel.fromJson(responseMinuteData['annual_report']);
      final index = annual_audit_reports_data!.annual_audit_reports_data?.indexWhere((annual) => annual.annualAuditReportId == _annual_audit_report.annualAuditReportId);
      annual_audit_reports_data!.annual_audit_reports_data![index!].annualAuditReportFileEdited = _annual_audit_report.annualAuditReportFileEdited;
      setAnnualAuditReport(_annual_audit_report);
      setIsBack(false);
      setLoading(false);
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

}