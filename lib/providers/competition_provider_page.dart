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

  String memberName = '';

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