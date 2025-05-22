import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
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
  final boardNameController = TextEditingController();
  final termController = TextEditingController();
  final fiscalYearController = TextEditingController();

  String? fileName;
  String? filePath;
  String? fileBase64;

  String dropdownValue = '51';

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

  String? selectedBoardId;
  String? selectedBoardName;
  String? _dropdownError;
  String? get dropdownError => _dropdownError;

  void setYearSelected(year) async {
    _yearSelected = year;
    getListOfBoardsByFilterDate(_yearSelected);
  }

  void selectCollectionBoard(String? boardId, context) {
    if (boardId != null) {
      selectedBoardId = boardId;
      // Ensure `boardsData?.boards` is not null and find the matching board
      Board? selectedBoard = boardsData?.boards?.firstWhere(
            (board) => board.boarId.toString() == boardId,
        orElse: () => Board(boarId: -1, boardName: "Unknown"), // Fallback if not found
      );
      // Extract the board name correctly
      selectedBoardName = (selectedBoard != null && selectedBoard.boarId != -1)
          ? selectedBoard.boardName
          : "Unknown";
      _dropdownError = null;
      log.i("Selected Board: ID = $selectedBoardId, Name = $selectedBoardName");
      notifyListeners();
    }
  }

  Future getListOfBoardsByFilterDate(yearSelected) async{
    setLoading(true);
    notifyListeners();
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
      notifyListeners();
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

  Future<void> insertBoard(Map<String, dynamic> data)async{
    setLoading(true);
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    user =  User.fromJson(json.decode(prefs.getString("user")!)) ;
    var response = await networkHandler.post1('/insert-new-board', data);
    if (response.statusCode == 200 || response.statusCode == 201) {
      setIsBack(true);
      log.d("insert new board response statusCode == 200");
      var responseData = json.decode(response.body) ;
      var responseBoardData = responseData['data'];
      _board = Board.fromJson(responseBoardData);
      boardsData!.boards!.add(_board);
      log.d(boardsData!.boards!.length);
      setIsBack(true);
      setLoading(false);
    } else {
      setLoading(false);
      setIsBack(false);
      log.d("insert new board response statusCode unknown");
      log.d(response.statusCode);
      print(json.decode(response.body)['message']);
    }
  }

  Future getBoardById(int id) async{
    var response = await networkHandler.get('/get-board-byId/$id');
    if (response.statusCode == 200 || response.statusCode == 201) {
      log.d("get-board-byId form provider response statusCode == 200");
      var responseData = json.decode(response.body) ;
      var boardsData = responseData['data'];
     final Board board = Board.fromJson(boardsData);
     setBoard(board);
    } else {
      log.d("get-board-byId form provider response statusCode unknown");
      log.d(response.statusCode);
      log.d(json.decode(response.body)['message']);
    }
  }

  Future<void> pickBoardFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(type: FileType.custom, allowedExtensions: ['pdf']);
      if (result != null && result.files.single.path != null) {
        final pickedFile = result.files.single;
        filePath = pickedFile.path!;
        fileName = pickedFile.name;
        fileBase64 = base64.encode(File(filePath!).readAsBytesSync());
        notifyListeners();
      }
    } catch (e) {
      print("File pick error: $e");
    }
  }

  Future<bool> createBoard() async {
    try {
      setLoading(true);
      final prefs = await SharedPreferences.getInstance();
      final user = User.fromJson(json.decode(prefs.getString("user")!));

      final data = {
        "term": termController.text,
        "quorum": dropdownValue,
        "fiscal_year": fiscalYearController.text,
        "board_name": boardNameController.text,
        "charter_board": fileName,
        "fileSelf": fileBase64,
        "business_id": user.businessId.toString(),
      };

      final response = await networkHandler.post1('/insert-new-board', data);
      if (response.statusCode == 200 || response.statusCode == 201) {
        await getListOfBoardsByFilterDate(_yearSelected); // 🔁 Refresh UI

        setLoading(false);
        return true;
      } else {
        log.e("Board creation failed: ${response.body}");
        return false;
      }
    } catch (e) {
      log.e("Error creating board: $e");
      return false;
    }
  }


  Future<bool> updateBoard(int boardId) async {
    try {
      setLoading(true);
      final prefs = await SharedPreferences.getInstance();
      final user = User.fromJson(json.decode(prefs.getString("user")!));

      final data = {
        "id": boardId,
        "term": termController.text,
        "quorum": dropdownValue,
        "fiscal_year": fiscalYearController.text,
        "board_name": boardNameController.text,
        "charter_board": fileName,
        "fileSelf": fileBase64,
        "business_id": user.businessId.toString(),
      };

      final response = await networkHandler.post1('/update-board', data);
      if (response.statusCode == 200 || response.statusCode == 201) {
        await getListOfBoardsByFilterDate(_yearSelected); // refresh
        setLoading(false);
        return true;
      } else {
        log.e("Update failed: ${response.body}");
        return false;
      }
    } catch (e) {
      log.e("Error updating board: $e");
      return false;
    }
  }

  Future<bool> deleteBoard(int boardId) async {
    try {
      setLoading(true);
      final response = await networkHandler.get('/board/$boardId');
      if (response.statusCode == 200 || response.statusCode == 204) {
        boardsData?.boards?.removeWhere((b) => b.boarId == boardId);
        setLoading(false);
        return true;
      } else {
        log.e("Failed to delete: ${response.body}");
        return false;
      }
    } catch (e) {
      log.e("Delete error: $e");
      return false;
    }
  }


  void clearForm() {
    boardNameController.clear();
    termController.clear();
    fiscalYearController.clear();
    fileName = null;
    filePath = null;
    fileBase64 = null;
    dropdownValue = '51';
    notifyListeners();
  }

  @override
  void dispose() {
    boardNameController.dispose();
    termController.dispose();
    fiscalYearController.dispose();
    super.dispose();
  }

}