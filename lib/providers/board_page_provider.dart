import 'dart:convert'; 
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../NetworkHandler.dart';
import '../models/board_model.dart';
import '../models/boards_model.dart';
import '../models/user.dart';
class BoardPageProvider extends ChangeNotifier{

  var log = Logger();
  User user = User();
  NetworkHandler networkHandler = NetworkHandler();

  FlutterSecureStorage storage = const FlutterSecureStorage();
  Boards? boardsData;
  Board _board = Board();
  String _yearSelected = DateTime.now().year.toString();
  String get yearSelected => _yearSelected;

  Board get board => _board;
  void setBoard (Board board) async {
    _board =  board;
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

  void setYearSelected(year) async {
    _yearSelected = year;
    getListOfBoardsByFilterDate(_yearSelected);
  }



  Future getListOfBoardsByFilterDate(yearSelected) async{
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    user =  User.fromJson(json.decode(prefs.getString("user")!)) ;
    final Map<String, String> queryParams = {
      'business_id': user.businessId.toString(),
      'yearSelected': yearSelected,
    };
    var response = await networkHandler.post1('/get-list-boards-by-filter-date',queryParams);
    if (response.statusCode == 200 || response.statusCode == 201) {
      log.d("get-list-boards-by-filter-date form provider response statusCode == 200");
      var responseData = json.decode(response.body) ;
      var responseBoardsData = responseData['data'];
      boardsData = Boards.fromJson(responseBoardsData);
      log.d(boardsData!.boards!.length);
      setLoading(false);
    } else {
      setLoading(false);
      log.d("get-list-boards-by-filter-date form provider response statusCode unknown");
      log.d(response.statusCode);
      log.d(json.decode(response.body)['message']);
    }
  }

  Future getListOfBoards(context) async{
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    user =  User.fromJson(json.decode(prefs.getString("user")!)) ;
    print(user.businessId);
    var response = await networkHandler.get('/get-list-boards/${user.businessId.toString()}');
    if (response.statusCode == 200 || response.statusCode == 201) {
      log.d("get-list-boards form provider response statusCode == 200");
      var responseData = json.decode(response.body) ;
      var responseBoardsData = responseData['data'];
      boardsData = Boards.fromJson(responseBoardsData);
      log.d(boardsData!.boards!.length);
      notifyListeners();
    } else {
      log.d("get-list-boards form provider response statusCode unknown");
      log.d(response.statusCode);
      log.d(json.decode(response.body)['message']);
    }
  }


}