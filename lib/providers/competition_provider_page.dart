import 'dart:convert';
import 'dart:math' as Math;

import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../NetworkHandler.dart';
import '../models/competition_model.dart';
import '../models/member.dart';
import '../models/user.dart';

class CompetitionProviderPage extends ChangeNotifier {
  var log = Logger();
  User user = User();
  NetworkHandler networkHandler = NetworkHandler();

  late List<TextEditingController> categoryControllersEn = [];
  late List<TextEditingController> categoryControllersAr = [];
  late List<List<TextEditingController>> questionControllers = [];
  List<List<Widget>> categoryItems = [];

  Map<int, TextEditingController> textResponses = {};
  Map<int, bool> checkboxResponses = {};
  String memberName = '';
  bool isSubmitting = false;


  // Loading state
  bool _loading = false;
  bool get loading => _loading;

  // Status tracking
  bool _isSelected = false;
  bool get isSelected => _isSelected;

  bool _isBack = false;
  bool get isBack => _isBack;

  // Error handling
  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  // Track expanded state of categories
  Map<int, bool> _expandedCategories = {};

  // Track which questions belong to which categories
  Map<int, List<int>> _categoryQuestions = {};

  // In CompetitionProviderPage
  bool _isInitializing = false;

  String _yearSelected = '2025';
  String get yearSelected => _yearSelected;

  Competitions? competitionsData;
  CompetitionModel _competition = CompetitionModel();
  CompetitionModel get competition => _competition;

  CompetitionsRelatedParties? competitionsRelatedPartiesData;
  CompetitionRelatedPartiesModel _competitionRelatedParties = CompetitionRelatedPartiesModel();
  CompetitionRelatedPartiesModel get competitionRelatedParties => _competitionRelatedParties;

  CompetitionsConfirmationOfIndependence? competitionsConfirmationOfIndependenceData;
  CompetitionConfirmationOfIndependenceModel _competitionConfirmationOfIndependenceModel = CompetitionConfirmationOfIndependenceModel();
  CompetitionConfirmationOfIndependenceModel get competitionConfirmationOfIndependenceModel => _competitionConfirmationOfIndependenceModel;

  void setYearSelected(year) async {
    _yearSelected =  year;
    notifyListeners();
  }

  void setCompetition(CompetitionModel competition) {
    _competition = competition;
    notifyListeners();
  }

  void setRelatedPartiesCompetition(CompetitionRelatedPartiesModel competitionRelatedParties) {
    _competitionRelatedParties = competitionRelatedParties;
    notifyListeners();
  }

  void setConfirmationOfIndependenceCompetition(CompetitionConfirmationOfIndependenceModel competitionConfirmationOfIndependenceModel) {
    _competitionConfirmationOfIndependenceModel = competitionConfirmationOfIndependenceModel;
    notifyListeners();
  }

  void initializeResponseControllers() {
    if (_isInitializing) return; // Prevent recursive calls
    _isInitializing = true;
    // Use Future.microtask to schedule after current build
    Future.microtask(() {
      if (competitionsData?.competitions != null) {
        for (var competition in competitionsData!.competitions!) {
          final id = competition.competitionId ?? 0;
          if (!textResponses.containsKey(id)) {
            textResponses[id] = TextEditingController();
            checkboxResponses[id] = false;
          }
        }
      }
      _isInitializing = false;
      notifyListeners();
    });
  }

  void initializeResponseConfirmationOfIndependenceControllers() {
    if (_isInitializing) return; // Prevent recursive calls
    _isInitializing = true;
    // Use Future.microtask to schedule after current build
    Future.microtask(() {
      if (competitionsConfirmationOfIndependenceData?.competitions != null) {
        for (var competition in competitionsConfirmationOfIndependenceData!.competitions!) {
          final id = competition.competitionId ?? 0;
          if (!textResponses.containsKey(id)) {
            textResponses[id] = TextEditingController();
            checkboxResponses[id] = false;
          }
        }
      }
      _isInitializing = false;
      notifyListeners();
    });
  }


  void initializeResponseRelatedPartiesControllers() {
    if (_isInitializing) return; // Prevent recursive calls
    _isInitializing = true;
    // Use Future.microtask to schedule after current build
    Future.microtask(() {
      if (competitionsRelatedPartiesData?.competitions != null) {
        for (var competition in competitionsRelatedPartiesData!.competitions!) {
          final id = competition.competitionId ?? 0;
          if (!textResponses.containsKey(id)) {
            textResponses[id] = TextEditingController();
            checkboxResponses[id] = false;
          }
        }
      }
      _isInitializing = false;
      notifyListeners();
    });
  }

  void updateCheckboxResponse(int questionId, bool value) {
    checkboxResponses[questionId] = value;
    notifyListeners(); // This triggers UI update
  }

  void setLoading(bool value) {
    _loading = value;
    notifyListeners();
  }

  void setIsBack(bool value) {
    _isBack = value;
    notifyListeners();
  }

  void setErrorMessage(String? message) {
    _errorMessage = message;
    notifyListeners();
  }

  // Get expanded state for a category
  bool isCategoryExpanded(int categoryId) {
    _isSelected = !_isSelected;
    return _expandedCategories[categoryId] ?? false;
  }

  // Toggle expanded state for a category
  void toggleCategoryExpanded(int categoryId) {
    _isSelected = !_isSelected;
    _expandedCategories[categoryId] = !(_expandedCategories[categoryId] ?? false);
    notifyListeners();
  }

  void setCategoryQuestions(Map<int, List<int>> categoryQuestions) {
    _categoryQuestions = categoryQuestions;
  }

  Map<int, List<int>> getCategoryQuestions() {
    return _categoryQuestions;
  }


  // Add a new form item for both languages
  void addParentForm() {
    categoryControllersEn.add(TextEditingController());
    categoryControllersAr.add(TextEditingController());
    categoryItems.add([]);
    questionControllers.add([]);
    notifyListeners();
  }

  // Remove a form item
  void removeParentForm(int index) {
    if (index < 0 || index >= categoryControllersEn.length || index < 0 || index >= categoryControllersAr.length) {
      log.e("Index out of range: $index");
      return;
    }

    // Dispose and remove controllers
    categoryControllersAr[index].dispose();
    categoryControllersAr.removeAt(index);

    categoryControllersEn[index].dispose();
    categoryControllersEn.removeAt(index);

    notifyListeners();
  }

  // Reorder child items
  void reorderChildItems(int parentIndex, int oldIndex, int newIndex) {
    if (newIndex > oldIndex) {
      newIndex -= 1;
    }
    notifyListeners();
  }

  // Clear all controllers
  void clearAllControllers() {
    for (var controller in categoryControllersAr) {
      controller.clear();
    }
    for (var controller in categoryControllersEn) {
      controller.clear();
    }
    notifyListeners();
  }

// Improved collectFormData method that properly pairs English and Arabic entries
  List<Map<String, dynamic>> collectFormData() {
    List<Map<String, dynamic>> formData = [];

    // When in dual language mode, we need to pair Arabic and English entries together
    final bool isDualMode = categoryControllersEn.isNotEmpty && categoryControllersAr.isNotEmpty;

    if (isDualMode) {
      // Use the shorter length to avoid index out of bounds
      final int minLength = Math.min(categoryControllersEn.length, categoryControllersAr.length);

      for (int i = 0; i < minLength; i++) {
        // Only add if at least one field has content
        if (categoryControllersEn[i].text.isNotEmpty || categoryControllersAr[i].text.isNotEmpty) {
          Map<String, dynamic> categoryData = {
            'category_en': categoryControllersEn[i].text,
            'category_ar': categoryControllersAr[i].text,
          };
          formData.add(categoryData);
        }
      }
    } else {
      // If only English is available
      if (categoryControllersEn.isNotEmpty && categoryControllersAr.isEmpty) {
        for (int i = 0; i < categoryControllersEn.length; i++) {
          if (categoryControllersEn[i].text.isNotEmpty) {
            Map<String, dynamic> categoryData = {
              'category_en': categoryControllersEn[i].text,
              'category_ar': '',  // Empty string for Arabic
            };
            formData.add(categoryData);
          }
        }
      }
      // If only Arabic is available
      else if (categoryControllersAr.isNotEmpty && categoryControllersEn.isEmpty) {
        for (int i = 0; i < categoryControllersAr.length; i++) {
          if (categoryControllersAr[i].text.isNotEmpty) {
            Map<String, dynamic> categoryData = {
              'category_en': '',  // Empty string for English
              'category_ar': categoryControllersAr[i].text,
            };
            formData.add(categoryData);
          }
        }
      }
    }

    // Log the form data for debugging
    log.d("Form data: $formData");

    return formData;
  }


  // Validate if all required fields are filled based on language mode
  bool validateFormData({
    required bool isEnglish,
    required bool isArabic,
    required bool isDualLanguage
  }) {
    // English-only mode validation
    if (isEnglish && !isDualLanguage) {
      for (var controller in categoryControllersEn) {
        if (controller.text.isEmpty) {
          return false;
        }
      }
      return categoryControllersEn.isNotEmpty;
    }

    // Arabic-only mode validation
    if (isArabic && !isDualLanguage) {
      for (var controller in categoryControllersAr) {
        if (controller.text.isEmpty) {
          return false;
        }
      }
      return categoryControllersAr.isNotEmpty;
    }

    // Dual-language mode validation
    if (isDualLanguage) {
      int itemCount = Math.min(categoryControllersEn.length, categoryControllersAr.length);
      if (itemCount == 0) return false;

      for (int i = 0; i < itemCount; i++) {
        // In dual mode, both language fields should be filled
        if (categoryControllersEn[i].text.isEmpty || categoryControllersAr[i].text.isEmpty) {
          return false;
        }
      }
      return true;
    }

    return false;
  }


  Future getListOfMembersCompetitionWithCompany(_yearSelected, committeeId)async{
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    user = User.fromJson(json.decode(prefs.getString("user")!));
    final queryParams = {
      'business_id': user.businessId.toString(),
      'committee_id': committeeId,
      'yearSelected': yearSelected,
      'type': 'competition_with_company',
    };
    var response = await networkHandler.post1('/get-list-members-competitions-with-company',queryParams);
    if (response.statusCode == 200 || response.statusCode == 201) {
      log.d("get-list-members-competitions-with-company response statusCode == 200");
      var responseData = json.decode(response.body) ;
      var competitionResponseData = responseData['data'];
      log.d("get-list-members-competitions-with-company $competitionResponseData");
      competitionsData = Competitions.fromJson(competitionResponseData);
      notifyListeners();

    } else {
      log.d("get-list-members-competitions-with-company response statusCode unknown");
      log.d(response.statusCode);
      print(json.decode(response.body)['message']);
    }
  }

  Future getMemberCompetitions(String yearSelected, String memberId, String type) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    user = User.fromJson(json.decode(prefs.getString("user")!));

    try {
      setLoading(true);

      // Add query parameters if needed
      final Map<String, String> queryParams = {
        'business_id': user.businessId.toString(),
        'member_id': memberId,
        'yearSelected': yearSelected,
        'type': type,
      };

      // Make the GET request
      var response = await networkHandler.post1('/get-member-competition',  queryParams);

      if (response.statusCode == 200 || response.statusCode == 201) {
        var responseData = json.decode(response.body) ;
        var competitionResponseData = responseData['data'];
        log.d("type is $type");
        log.d("get-list-members-competitions-with-company $competitionResponseData");
        if(type == 'competition_with_confirmation_of_independence'){
          competitionsConfirmationOfIndependenceData = CompetitionsConfirmationOfIndependence.fromJson(competitionResponseData);
        }else if(type == 'competition_with_related_parties'){
          competitionsRelatedPartiesData = CompetitionsRelatedParties.fromJson(competitionResponseData);
        }else{
          competitionsData = Competitions.fromJson(competitionResponseData);
        }

        notifyListeners();
      } else {
        log.e("getMemberCompetitions failed with status: ${response.statusCode}");
        log.d(json.decode(response.body)['message']);
      }
    } catch (e) {
      log.e("Exception in getMemberCompetitions: $e");
      setErrorMessage("Failed to retrieve competitions: $e");
    } finally {
      setLoading(false);
      notifyListeners();
    }
  }

  Future getListOfCompetitionsQuestionnaireForCompany(_yearSelected, committeeId)async{
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    user = User.fromJson(json.decode(prefs.getString("user")!));
    final queryParams = {
      'business_id': user.businessId.toString(),
      'committee_id': committeeId,
      'yearSelected': yearSelected,
      'type': 'competition_with_company',
    };
    var response = await networkHandler.post1('/get-list-competitions-questionnaire-for-company',queryParams);
    if (response.statusCode == 200 || response.statusCode == 201) {
      log.d("get-list-competitions-questionnaire-for-company response statusCode == 200");
      var responseData = json.decode(response.body) ;
      var competitionResponseData = responseData['data'];
      competitionsData = Competitions.fromJson(competitionResponseData);
      notifyListeners();

    } else {
      log.d("get-list-competitions-questionnaire-for-company response statusCode unknown");
      log.d(response.statusCode);
      print(json.decode(response.body)['message']);
    }
  }

  // Submit data to backend
  Future<bool> insertNewCompetitionsForCompany(Map<String, dynamic> data) async {
    setLoading(true);

    try {
      var response = await networkHandler.post1('/insert-new-competition-for-company', data);
      if (response.statusCode == 200 || response.statusCode == 201) {
        log.d("Category insert insert-new-competition-for-company successful: ${response.statusCode}");
        // Safely parse the response data
        var responseData = json.decode(response.body);
        // Check if 'competition' key exists and is not null
        if (responseData != null && responseData.containsKey('competition') && responseData['competition'] != null) {
          _competition = CompetitionModel.fromJson(responseData['competition']);
          setCompetition(_competition);
        }
        // clearAllControllers();
        setIsBack(true);
        setLoading(false);
        return true;
      } else {
        log.e("Category insert insert-new-competition-for-company failed: ${response.statusCode}");
        // Handle potential error response
        var errorResponse = response.body.isNotEmpty ? json.decode(response.body) : null;
        String errorMessage = 'Unknown error occurred insert-new-competition-for-company';
        if (errorResponse != null && errorResponse.containsKey('message')) {
          errorMessage = errorResponse['message'];
        }
        setErrorMessage(errorMessage);
        setLoading(false);
        setIsBack(false);
        return false;
      }
    } catch (e) {
      log.e("Exception in insertNewCategory: ${e.toString()}");
      setErrorMessage("An error occurred: ${e.toString()}");
      setLoading(false);
      setIsBack(false);
      return false;
    }
  }


  Future<bool> insertNewCompetitionsForRelatedParties(Map<String, dynamic> data) async {
    setLoading(true);

    try {
      var response = await networkHandler.post1('/insert-new-competition-for-company', data);
      if (response.statusCode == 200 || response.statusCode == 201) {
        log.d("Category  insert-new-competition-for-Related_Parties successful: ${response.statusCode}");
        // Safely parse the response data
        var responseData = json.decode(response.body);
        // Check if 'competition' key exists and is not null
        if (responseData != null && responseData.containsKey('competition') && responseData['competition'] != null) {
          _competitionRelatedParties = CompetitionRelatedPartiesModel.fromJson(responseData['competition']);
          setRelatedPartiesCompetition(_competitionRelatedParties);
        }
        // clearAllControllers();
        setIsBack(true);
        setLoading(false);
        return true;
      } else {
        log.e("Category insert-new-competition-for-Related_Parties failed: ${response.statusCode}");
        // Handle potential error response
        var errorResponse = response.body.isNotEmpty ? json.decode(response.body) : null;
        String errorMessage = 'Unknown error occurred';
        if (errorResponse != null && errorResponse.containsKey('message')) {
          errorMessage = errorResponse['message'];
        }
        setErrorMessage(errorMessage);
        setLoading(false);
        setIsBack(false);
        return false;
      }
    } catch (e) {
      log.e("Exception in insertNewCategory insert-new-competition-for-Related_Parties: ${e.toString()}");
      setErrorMessage("An error occurred: ${e.toString()}");
      setLoading(false);
      setIsBack(false);
      return false;
    }
  }


  Future<bool> insertNewCompetitionsForConfirmationOfIndependence(Map<String, dynamic> data) async {
    setLoading(true);

    try {
      var response = await networkHandler.post1('/insert-new-competition-for-company', data);
      if (response.statusCode == 200 || response.statusCode == 201) {
        log.d("Category  insert-new-competition-for-Confirmation Of Independence successful: ${response.statusCode}");
        // Safely parse the response data
        var responseData = json.decode(response.body);
        // Check if 'competition' key exists and is not null
        if (responseData != null && responseData.containsKey('competition') && responseData['competition'] != null) {
          _competitionConfirmationOfIndependenceModel = CompetitionConfirmationOfIndependenceModel.fromJson(responseData['competition']);
          setConfirmationOfIndependenceCompetition(_competitionConfirmationOfIndependenceModel);
        }
        // clearAllControllers();
        setIsBack(true);
        setLoading(false);
        return true;
      } else {
        log.e("Category insert-new-competition-for-Confirmation Of Independence failed: ${response.statusCode}");
        // Handle potential error response
        var errorResponse = response.body.isNotEmpty ? json.decode(response.body) : null;
        String errorMessage = 'Unknown error occurred';
        if (errorResponse != null && errorResponse.containsKey('message')) {
          errorMessage = errorResponse['message'];
        }
        setErrorMessage(errorMessage);
        setLoading(false);
        setIsBack(false);
        return false;
      }
    } catch (e) {
      log.e("Exception in insertNewCategory insert-new-competition-for-Confirmation Of Independence: ${e.toString()}");
      setErrorMessage("An error occurred: ${e.toString()}");
      setLoading(false);
      setIsBack(false);
      return false;
    }
  }

  Future<void> removeCompetition(CompetitionModel deleteFinancial)async{
    setLoading(false);
    final index = competitionsData!.competitions!.indexOf(deleteFinancial);
    CompetitionModel competition = competitionsData!.competitions![index];
    String competitionId =  competition.competitionId.toString();
    Map<String, dynamic> data = {"competition_id": competitionId};
    var response = await networkHandler.post1('/delete-competition-by-id', data);
    if (response.statusCode == 200 || response.statusCode == 201) {
      log.d("deleted minute response statusCode == 200");
      competitionsData!.competitions!.remove(competition);
      log.d(competitionsData!.competitions!.length);
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


  Future<void> removeCompetitionRelatedParties(CompetitionRelatedPartiesModel deleteFinancial)async{
    setLoading(false);
    final index = competitionsRelatedPartiesData!.competitions!.indexOf(deleteFinancial);
    CompetitionRelatedPartiesModel competition = competitionsRelatedPartiesData!.competitions![index];
    String competitionId =  competition.competitionId.toString();
    Map<String, dynamic> data = {"competition_id": competitionId};
    var response = await networkHandler.post1('/delete-competition-by-id', data);
    if (response.statusCode == 200 || response.statusCode == 201) {
      log.d("deleted minute response statusCode == 200");
      competitionsRelatedPartiesData!.competitions!.remove(competition);
      log.d(competitionsRelatedPartiesData!.competitions!.length);
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

  Future<void> removeCompetitionConfirmationOfIndependence(CompetitionConfirmationOfIndependenceModel deleteFinancial)async{
    setLoading(false);
    final index = competitionsConfirmationOfIndependenceData!.competitions!.indexOf(deleteFinancial);
    CompetitionConfirmationOfIndependenceModel competition = competitionsConfirmationOfIndependenceData!.competitions![index];
    String competitionId =  competition.competitionId.toString();
    Map<String, dynamic> data = {"competition_id": competitionId};
    var response = await networkHandler.post1('/delete-competition-by-id', data);
    if (response.statusCode == 200 || response.statusCode == 201) {
      log.d("deleted minute response statusCode == 200");
      competitionsConfirmationOfIndependenceData!.competitions!.remove(competition);
      log.d(competitionsConfirmationOfIndependenceData!.competitions!.length);
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

  Member _member = Member();
  Member get minute => _member;
  void setMember(Member minute) async {
    _member =  minute;
    notifyListeners();
  }

  Future<Map<String, dynamic>> memberMakeSignedCompetition(Map<String, dynamic> data)async{
    var result;
    setLoading(true);
    notifyListeners();
    var response = await networkHandler.post1('/member-make-sign-competition', data);
    if (response.statusCode == 200 || response.statusCode == 201) {

      log.d("member-make-sign-competition response statusCode == 200");
      var responseData = json.decode(response.body) ;
      var responseResolutionData = responseData['data'];
      _member = Member.fromJson(responseResolutionData);
      setIsBack(true);
      setLoading(false);
      result = {'status': true, 'message': 'Successful', 'member': _member};
    } else {
      setLoading(false);
      setIsBack(false);
      log.d("member-make-sign-competition response statusCode unknown");
      log.d(response.statusCode);
      log.i(json.decode(response.body)['message']);
      result = {'status': false,'message': json.decode(response.body)['message']
      };

    }
    return result;
  }


  // Set member name
  void setMemberName(String name) {
    memberName = name;
    notifyListeners();
  }

// Clear all responses
  void clearResponses() {
    textResponses.forEach((key, controller) {
      controller.clear();
    });

    checkboxResponses.forEach((key, value) {
      checkboxResponses[key] = false;
    });

    memberName = '';
    notifyListeners();
  }

// Set submitting state
  void setSubmitting(bool value) {
    isSubmitting = value;
    notifyListeners();
  }

// Submit competition responses
  Future<bool> submitCompetitionResponses(Map<String, dynamic> data) async {
    setSubmitting(true);
    setErrorMessage(null);

    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      user = User.fromJson(json.decode(prefs.getString("user")!));

      // Add the user ID to data if not present
      if (!data.containsKey('created_by')) {
        data['created_by'] = user.userId;
      }

      if (!data.containsKey('business_id')) {
        data['business_id'] = user.businessId;
      }

      // Make the API call
      var response = await networkHandler.post1('/submit-competition-responses', data);

      if (response.statusCode == 200 || response.statusCode == 201) {
        log.d("Responses submitted successfully: ${response.statusCode}");

        // Parse response data if needed
        var responseData = json.decode(response.body);

        // Clear form after successful submission
        clearResponses();

        setSubmitting(false);
        setIsBack(true);
        return true;
      } else {
        log.e("Response submission failed: ${response.statusCode}");
        var errorResponse = json.decode(response.body);
        setErrorMessage(errorResponse['message'] ?? 'Unknown error occurred');
        setSubmitting(false);
        setIsBack(false);
        return false;
      }
    } catch (e) {
      log.e("Exception in submitCompetitionResponses: ${e.toString()}");
      setErrorMessage("An error occurred: ${e.toString()}");
      setSubmitting(false);
      setIsBack(false);
      return false;
    }
  }

// Dispose method - call this when navigating away from the screen
  void disposeResponseControllers() {
    textResponses.forEach((key, controller) {
      controller.dispose();
    });
    textResponses.clear();
    checkboxResponses.clear();
    memberName = '';
    notifyListeners();
  }

// Get responses for a specific competition ID
  Map<String, dynamic>? getCompetitionResponse(int competitionId) {
    if (!textResponses.containsKey(competitionId)) {
      return null;
    }

    return {
      'text_response': textResponses[competitionId]?.text ?? '',
      'checkbox_selected': checkboxResponses[competitionId] ?? false
    };
  }

// Check if any responses have been filled
  bool hasAnyResponses() {
    // Check if any text field has content
    bool hasTextResponse = textResponses.values.any((controller) => controller.text.isNotEmpty);

    // Check if any checkbox is selected
    bool hasCheckboxResponse = checkboxResponses.values.any((checked) => checked == true);

    return hasTextResponse || hasCheckboxResponse;
  }

// Validate all required fields
  bool validateResponses() {
    // Add your validation logic here
    // For example, ensure member name is filled
    // if (memberName.isEmpty) {
    //   setErrorMessage("Please enter your name");
    //   return false;
    // }

    // Ensure at least one question is answered
    if (!hasAnyResponses()) {
      setErrorMessage("Please answer at least one question");
      return false;
    }

    return true;
  }


  Future getListOfCompetitionsQuestionnaireForRelatedParties(_yearSelected, committeeId)async{
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    user = User.fromJson(json.decode(prefs.getString("user")!));
    final queryParams = {
      'business_id': user.businessId.toString(),
      'committee_id': committeeId,
      'yearSelected': yearSelected,
      'type': 'competition_with_related_parties',
    };
    var response = await networkHandler.post1('/get-list-competitions-questionnaire-for-related-parties',queryParams);
    if (response.statusCode == 200 || response.statusCode == 201) {
      log.d("get-list-competitions-questionnaire-for-related-parties response statusCode == 200");
      var responseData = json.decode(response.body) ;
      var competitionResponseData = responseData['data'];
      competitionsRelatedPartiesData =  CompetitionsRelatedParties.fromJson(competitionResponseData);
      notifyListeners();

    } else {
      log.d("get-list-competitions-questionnaire-for-related-parties response statusCode unknown");
      log.d(response.statusCode);
      print(json.decode(response.body)['message']);
    }
  }

  Future getListOfCompetitionsQuestionnaireForConfirmationOfIndependence(_yearSelected, committeeId)async{
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    user = User.fromJson(json.decode(prefs.getString("user")!));
    final queryParams = {
      'business_id': user.businessId.toString(),
      'committee_id': committeeId,
      'yearSelected': yearSelected,
      'type': 'competition_with_confirmation_of_independence',
    };
    var response = await networkHandler.post1('/get-list-competitions-questionnaire-for-confirmation-of-independence',queryParams);
    if (response.statusCode == 200 || response.statusCode == 201) {
      log.d("get-list-competitions-questionnaire-for-confirmation-of-independence response statusCode == 200");
      var responseData = json.decode(response.body) ;
      var competitionResponseData = responseData['data'];
      competitionsConfirmationOfIndependenceData = CompetitionsConfirmationOfIndependence.fromJson(competitionResponseData);
      notifyListeners();

    } else {
      log.d("get-list-competitions-questionnaire-for-confirmation-of-independence response statusCode unknown");
      log.d(response.statusCode);
      print(json.decode(response.body)['message']);
    }
  }

  Future getListOfMembersCompetitionWithRelatedParties(_yearSelected, committeeId)async{
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    user = User.fromJson(json.decode(prefs.getString("user")!));
    final queryParams = {
      'business_id': user.businessId.toString(),
      'committee_id': committeeId,
      'yearSelected': yearSelected,
      'type': 'competition_with_related_parties',
    };
    var response = await networkHandler.post1('/get-list-members-competitions-with-related-parties',queryParams);
    if (response.statusCode == 200 || response.statusCode == 201) {
      log.d("get-list-members-competitions-with-related-parties response statusCode == 200");
      var responseData = json.decode(response.body) ;
      var competitionResponseData = responseData['data'];
      log.d("get-list-members-competitions-with-related-parties $competitionResponseData");
      competitionsRelatedPartiesData = CompetitionsRelatedParties.fromJson(competitionResponseData);
      notifyListeners();

    } else {
      log.d("get-list-members-competitions-with-related-parties response statusCode unknown");
      log.d(response.statusCode);
      print(json.decode(response.body)['message']);
    }
  }


  Future getListOfMembersCompetitionWithConfirmationOfIndependence(_yearSelected, committeeId)async{
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    user = User.fromJson(json.decode(prefs.getString("user")!));
    final queryParams = {
      'business_id': user.businessId.toString(),
      'committee_id': committeeId,
      'yearSelected': yearSelected,
      'type': 'competition_with_related_parties',
    };
    var response = await networkHandler.post1('/get-list-members-competitions-with-confirmation-of-independence',queryParams);
    if (response.statusCode == 200 || response.statusCode == 201) {
      log.d("get-list-members-competitions-with-confirmation-of-independence response statusCode == 200");
      var responseData = json.decode(response.body) ;
      var competitionResponseData = responseData['data'];
      log.d("get-list-members-competitions-with-confirmation-of-independence $competitionResponseData");
      competitionsConfirmationOfIndependenceData = CompetitionsConfirmationOfIndependence.fromJson(competitionResponseData);
      notifyListeners();

    } else {
      log.d("get-list-members-competitions-with-confirmation-of-independence response statusCode unknown");
      log.d(response.statusCode);
      print(json.decode(response.body)['message']);
    }
  }
}