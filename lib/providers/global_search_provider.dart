import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../NetworkHandler.dart';
import '../models/searchable.dart';
import '../models/user.dart';

class GlobalSearchProvider extends ChangeNotifier {
  var log = Logger();
  static FlutterSecureStorage storage = const FlutterSecureStorage();
  static NetworkHandler networkHandler = NetworkHandler();
  TextEditingController controller = TextEditingController();

  bool _loading = false;
  bool get isLoading => _loading;

  bool _isWrite = false;
  bool get isWrite => _isWrite;


  bool _isPress = false;
  bool get isPress => _isPress;


  List<SearchableModel>? searchResults;

  void setLoading(value) async {
    _loading = value;
    notifyListeners();
  }

  void setWrite(value) async {
    _isWrite = value;
    notifyListeners();
  }

  void setPress(value) async {
    _isPress = value;
    notifyListeners();
  }

  GlobalSearchProvider() {
    controller.addListener(onTextChanged);
    controller.addListener(() {
      setWrite(true);
      if (controller.text.isEmpty) {
        clearSearch();
      }
    });
  }

  Timer? _debounce;
  void onTextChanged() {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(seconds: 4), () {
      if (controller.text.isNotEmpty) {
        extractTextsWithinAllFilesDocuments(controller.text);
      }
    });
    notifyListeners();
  }

  // This method is called whenever the text changes.
  // void onTextChanged() {
  //   notifyListeners(); // Notify listeners to update the icon based on text presence.
  // }

  void clearText() {
    controller.clear();
    clearSearch();
  }

  void clearSearch() {
    searchResults = [];
    notifyListeners();
  }

  Icon get icon => controller.text.isEmpty
      ? const Icon(Icons.search,color: Colors.green, size: 30,)
      : const Icon(Icons.clear, color: Colors.red, size: 30.0,);

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  Future<void> extractTextsWithinAllFilesDocuments(String query) async {
    if (query.trim().isEmpty) {
        clearSearch();
       return;
    }

    setLoading(true);
    notifyListeners();

    try {
          final SharedPreferences prefs = await SharedPreferences.getInstance();
          final user = User.fromJson(json.decode(prefs.getString("user")!));
          final data = {"searchText": query.trim()};
          final response = await networkHandler.post1('/get-all-extract-text', data);
          if (response.statusCode == 200 || response.statusCode == 201) {
              log.d("get all extract text extractTextsWithinAllFilesDocuments function response statusCode == 200");
              final responseData = json.decode(response.body);
              final searchableData = (responseData['data']['files'] as List).map((searchable) => SearchableModel.fromJson(searchable)).toList();
              log.e("searchableData when fetching search results: ${searchableData.map((searchable) =>  searchable.fileDir).toList()}");
              searchResults = searchableData;
              setLoading(false);
              setPress(false);
          } else {
              log.e("Error fetching search results: ${response.body}");
              searchResults = [];
              setLoading(false);
              setPress(false);
              setWrite(false);
          }
      } catch (e) {
          log.e("Exception when fetching search results: $e");
          searchResults = [];
          setLoading(false);
          setPress(false);
          setWrite(false);
      } finally {
      setLoading(false);
      setPress(false);
      setWrite(false);
    }
  }
}
