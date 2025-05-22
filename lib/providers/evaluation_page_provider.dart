import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:rename/platform_file_editors/abs_platform_file_editor.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../NetworkHandler.dart';
import '../models/category_model.dart';
import '../models/member.dart';
import '../models/user.dart';

class EvaluationPageProvider extends ChangeNotifier{
  var log = Logger();
  User user = User();
  NetworkHandler networkHandler = NetworkHandler();

  late List<TextEditingController> categoryControllers = [];
  late List<List<TextEditingController>> questionControllers = [];
  List<List<Widget>> categoryItems = [];
  List<List<Widget>> criteriaItems = [];
  List<Map<String, dynamic>> formData = [];
  Map<int, Map<int, int>> _evaluations = {}; // {memberId: {questionId: score}}
  MyData? dataOfMembers;
  Member _member = Member();
  Member get member => _member;
  void setMember(Member member) async {
    _member =  member;
    notifyListeners();
  }


  Categories? dataOfCategories;
  Category _category = Category();
  Category get category => _category;
  void setCategory(Category category) async {
    _category =  category;
    notifyListeners();
  }


  bool _loading = false;
  bool get loading => _loading;
  void setLoading(value) async {
    _loading =  value;
    notifyListeners();
  }


  bool _isSelected = false;
  bool get isSelected => _isSelected;

  bool _isBack = false;
  bool get isBack => _isBack;
  void setIsBack(value) async {
    _isBack =  value;
    notifyListeners();
  }

  // Track expanded state of categories
  Map<int, bool> _expandedCategories = {};

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


  // Track which questions belong to which categories
  Map<int, List<int>> _categoryQuestions = {};

  void setCategoryQuestions(Map<int, List<int>> categoryQuestions) {
    _categoryQuestions = categoryQuestions;
    //notifyListeners();
  }
  Map<int, List<int>> getCategoryQuestions() {
    return _categoryQuestions;
  }
  // Update a score
  void updateScore(int memberId, int questionId, int score) {
    if (!_evaluations.containsKey(memberId)) {
      _evaluations[memberId] = {};
    }
    _evaluations[memberId]![questionId] = score;
    // log.i("Updated Evaluations: $_evaluations");
    notifyListeners();
  }

  // Get a score
  int getScore(int memberId, int questionId) {
    return _evaluations[memberId]?[questionId] ?? 0;
  }

  // Calculate average for a category for a member
  double calculateCategoryAverage(int memberId, int categoryId) {
    // Check if the category exists in _categoryQuestions
    if (!_categoryQuestions.containsKey(categoryId)) {
      // log.w("Category $categoryId not found in _categoryQuestions");
      return 0.0;
    }

    // Check if the member has evaluations
    if (!_evaluations.containsKey(memberId)) {
      // log.w("No evaluations found for Member $memberId");
      return 0.0;
    }

    // Get question IDs for the category
    final categoryQuestionIds = _categoryQuestions[categoryId]!;

    // Retrieve scores for the category's questions
    final scores = categoryQuestionIds
        .map((qId) => _evaluations[memberId]?[qId] ?? 0)
        .where((score) => score > 0) // Include only scored questions
        .toList();

    // Return 0.0 if there are no valid scores
    if (scores.isEmpty) {
      // log.i("No valid scores for Member $memberId in Category $categoryId");
      return 0.0;
    }

    // Calculate and return the average
    final average = scores.reduce((a, b) => a + b) / scores.length;
    // log.i("Category Average: Member $memberId, Category $categoryId, Average $average");
    return average;
  }


  // Calculate total average for all categories
  Map<int, double> calculateAllCategoryAverages(int memberId) {
    return _categoryQuestions.keys.fold({}, (map, categoryId) {
      map[categoryId] = calculateCategoryAverage(memberId, categoryId);
      return map;
    });
  }

  double calculateOverallAverage(int memberId) {
    final categories = dataOfCategories?.categories ?? [];
    if (categories.isEmpty) return 0.0;

    double totalScore = 0.0;
    int categoryCount = 0;

    for (final category in categories) {
      final categoryId = category.categoryId!;
      final categoryAverage = calculateCategoryAverage(memberId, categoryId);
      totalScore += categoryAverage;
      categoryCount++;
    }

    return categoryCount > 0 ? totalScore / categoryCount : 0.0;
  }

  bool validateMemberAnswers(int memberId) {
    final categories = dataOfCategories?.categories ?? [];
    if (categories.isEmpty) return false;

    for (final category in categories) {
      for (final question in category.questions!) {
        final questionId = question.questionId!;
        // Check if a score exists for this member and question
        if (_evaluations[memberId] == null || !_evaluations[memberId]!.containsKey(questionId)) {
          return false; // Question is unanswered
        }
      }
    }

    return true; // All questions have been answered
  }

  List<int> getUnansweredQuestions(int memberId) {
    final List<int> unansweredQuestions = [];
    final categories = dataOfCategories?.categories ?? [];

    for (final category in categories) {
      for (final question in category.questions!) {
        final questionId = question.questionId!;
        if (_evaluations[memberId] == null || !_evaluations[memberId]!.containsKey(questionId)) {
          unansweredQuestions.add(questionId);
        }
      }
    }

    return unansweredQuestions;
  }


  List<Map<String, dynamic>> collectMemberAnswers(int memberId) {
    final categories = dataOfCategories?.categories ?? [];
    final List<Map<String, dynamic>> collectedData = [];

    for (final category in categories) {
      final List<Map<String, dynamic>> questionsData = [];

      for (final question in category.questions!) {
        final questionId = question.questionId!;
        final answer = _evaluations[memberId]?[questionId] ?? null; // Get the answer or null

        questionsData.add({
          "question_id": questionId,
          "answer": answer,
        });
      }

      collectedData.add({
        "category_id": category.categoryId!,
        "questions": questionsData,
      });
    }
  // logger.i("collectedData collectedData $collectedData");
    return collectedData;
  }

  Future<void> submitMemberAnswers(int memberId) async {
    final collectedData = collectMemberAnswers(memberId);

    // Construct the payload
    final Map<String, dynamic> payload = {
      "member_id": memberId,
      "categories": collectedData,
    };
    logger.i("payload payload $payload");
    try {
      final response = await networkHandler.post1("/insert-new-evaluations-member", payload);

      if (response.statusCode == 200 || response.statusCode == 201) {
        print("Answers submitted successfully!");
      } else {
        print("Failed to submit answers: ${response.statusCode}");
        print(response.body);
      }
    } catch (e) {
      print("Error while submitting answers: $e");
    }
  }


  void addParentForm() {
    categoryControllers.add(TextEditingController());
    categoryItems.add([]);
    questionControllers.add([]);
    notifyListeners();
  }

  void removeParentForm(int index) {
    if (index < 0 || index >= categoryControllers.length) {
      print("Index out of range: $index");
      return; // Guard clause to handle out-of-range index
    }
    log.i("Removing Index: $index");
    // Dispose and remove main field controllers
    categoryControllers[index].dispose();
    categoryControllers.removeAt(index);

    // Remove corresponding child controllers and lists if they exist
    if (index < categoryItems.length) {
      // Remove child controllers
      // Ensure the parent index exists in the child lists
      if (index < questionControllers.length) {
        for (int i = questionControllers[index].length - 1; i >= 0; i--) {
          // Safely remove each child controller
          removeChildItem(index, i);
        }

        // Remove the child controller lists after clearing their contents
        questionControllers.removeAt(index);
      }

      categoryItems.removeAt(index);
      if (index < questionControllers.length) questionControllers.removeAt(index);
    }

    notifyListeners(); // Notify listeners after state changes
  }

  void addChildItem(int parentIndex) {
    if (parentIndex >= 0) {
      void ensureListCapacity<T>(List<List<T>> list, int index) {
        while (list.length <= index) {
          list.add([]); // Add an empty list of the correct type
        }
      }
      ensureListCapacity<Widget>(categoryItems, parentIndex);
      ensureListCapacity<TextEditingController>(questionControllers, parentIndex);
      categoryItems[parentIndex].add(Text('Child Item ${categoryItems[parentIndex].length + 1}'));
      questionControllers[parentIndex].add(TextEditingController());
      notifyListeners();
    }
  }

  void removeChildItem(int parentIndex, int childIndex) {
    if (parentIndex < 0 || parentIndex >= categoryItems.length ||
        childIndex < 0 || childIndex >= categoryItems[parentIndex].length) {
      return; // Guard clause to prevent out-of-range access
    }

    if (parentIndex >= questionControllers.length || childIndex >= questionControllers[parentIndex].length) {
      print("Child index out of range for parent: $parentIndex, child: $childIndex");
      return; // Avoid accessing invalid indices
    }
    // Dispose child controllers
    questionControllers[parentIndex][childIndex].dispose();
    // Remove controllers from their respective lists
    questionControllers[parentIndex].removeAt(childIndex);
    // Remove child item widgets
    categoryItems[parentIndex].removeAt(childIndex);

    notifyListeners(); // Notify listeners after state changes
  }

  void reorderChildItems(int parentIndex, int oldIndex, int newIndex) {
    if (newIndex >oldIndex) {
      newIndex -= 1;
    }
    notifyListeners();
  }

  void clearAllControllers() {
    for (var controller in categoryControllers) {
      controller.clear();
    }
    for (var controller in questionControllers) {
      controller.clear();
    }
    notifyListeners();
  }

  List<Map<String, dynamic>> collectFormData() {
    for (int i = 0; i < categoryControllers.length; i++) {
      Map<String, dynamic> categoryData = {
        'category': categoryControllers[i].text,
        'questions': questionControllers[i].map((controller) => controller.text).toList(),
      };
      formData.add(categoryData);
    }

    return formData;
  }

  Future getListOfEvaluationsMember(context)async{
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    user =  User.fromJson(json.decode(prefs.getString("user")!)) ;
    var response = await networkHandler.get('/get-list-members/${user.businessId.toString()}');
    if (response.statusCode == 200 || response.statusCode == 201) {
      log.d("get-list-members response statusCode == 200");
      var responseData = json.decode(response.body) ;
      var membersResponseData = responseData['data'];
      dataOfMembers = MyData.fromJson(membersResponseData);
      notifyListeners();

    } else {
      log.d("get-list-members response statusCode unknown");
      log.d(response.statusCode);
      print(json.decode(response.body)['message']);
    }
  }


  Future insertNewCategoryWithQuestion(Map<String, dynamic> data) async{
    setLoading(true);
    notifyListeners();
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    user =  User.fromJson(json.decode(prefs.getString("user")!)) ;
    var response = await networkHandler.post1('/insert-new-category-with-question', data);
    if (response.statusCode == 200 || response.statusCode == 201) {
      setIsBack(true);
      notifyListeners();
      log.d("insert new category response statusCode == 200");
      var responseData = json.decode(response.body) ;
      var responseCategoryData = responseData['data'];

      _category = Category.fromJson(responseCategoryData['category']);
      setCategory(_category);
      // clearAllControllers();
      setIsBack(false);
      setLoading(false);
      notifyListeners();
    } else {
      setLoading(false);
      setIsBack(false);
      notifyListeners();
      log.d("insert new category response statusCode unknown");
      log.d(response.statusCode);
      print(json.decode(response.body)['message']);
    }
  }


  Future insertNewEvaluationsMember(Map<String, dynamic> data) async{
    setLoading(true);
    notifyListeners();
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    user =  User.fromJson(json.decode(prefs.getString("user")!)) ;
    var response = await networkHandler.post1('/insert-new-criteria-evaluations-member', data);
    if (response.statusCode == 200 || response.statusCode == 201) {
      setIsBack(true);
      notifyListeners();
      log.d("insert new criteria response statusCode == 200");
      var responseData = json.decode(response.body) ;
      var responseCriteriaData = responseData['data'];
      // print(responseCriteriaData['criteria']);
      // _criteria = Criteria.fromJson(responseCriteriaData['criteria']);
      // dataOfCriteria!.criterias!.add(_criteria);
      // log.d(dataOfCriteria!.criterias!.length);
      setIsBack(true);
      setLoading(true);
      notifyListeners();
    } else {
      setLoading(false);
      setIsBack(false);
      notifyListeners();
      log.d("insert new criteria response statusCode unknown");
      log.d(response.statusCode);
      print(json.decode(response.body)['message']);
    }
  }

  Future getListOfEvaluationsMemberCategories(context)async{
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    user =  User.fromJson(json.decode(prefs.getString("user")!)) ;
    var response = await networkHandler.get('/get-list-categories/${user.businessId.toString()}');
    if (response.statusCode == 200 || response.statusCode == 201) {
      log.d("get-list-Categories response statusCode == 200");
      var responseData = json.decode(response.body) ;
      var categoriesResponseData = responseData['data'];
      dataOfCategories = Categories.fromJson(categoriesResponseData);
      notifyListeners();
    } else {
      log.d("get-list-Categories response statusCode unknown");
      log.d(response.statusCode);
      print(json.decode(response.body)['message']);
    }
  }

  Future getListOfEvaluationsCategoriesWithQuestions() async{
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    user =  User.fromJson(json.decode(prefs.getString("user")!)) ;
    var response = await networkHandler.get('/get-list-categories-with-questions/${user.businessId.toString()}');
    if (response.statusCode == 200 || response.statusCode == 201) {
      log.d("get-list-Categories response statusCode == 200");
      var responseData = json.decode(response.body) ;
      var categoriesResponseData = responseData['data'];
      dataOfCategories = Categories.fromJson(categoriesResponseData);
      notifyListeners();
    } else {
      log.d("get-list-Categories response statusCode unknown");
      log.d(response.statusCode);
      print(json.decode(response.body)['message']);
    }
  }

}