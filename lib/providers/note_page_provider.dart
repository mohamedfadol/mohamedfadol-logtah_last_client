import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:logger/logger.dart';

import '../NetworkHandler.dart';
import '../models/board_model.dart';
import '../models/boards_model.dart';
import '../models/committee_model.dart';
import '../models/meeting_model.dart';
import '../models/note_model.dart';
import '../models/user.dart';

class NotePageProvider extends ChangeNotifier{

  Notes? notesData;
  Meetings? dataOfMeetings;
  Boards? boardsData;
  DataComm? committeesData;

  Note _note = Note();
  Note get note => _note;

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

  void setNote (Note note) async {
    _note =  note;
    notifyListeners();
  }

  bool _isChecked = true;
  bool get isChecked => _isChecked;
  void setChecked(bool value) {
    _isChecked = value;
    log.d(_isChecked);
    notifyListeners();
  }


  List<Meeting>? get meetings => dataOfMeetings?.meetings;
  void toggleMeetingParentMenu(int index) {
    meetings![index].isExpanded = !meetings![index].isExpanded!;
    notifyListeners(); // Notify listeners to rebuild the UI
  }

  List<Board>? get boards => boardsData?.boards;
  void toggleBoardParentMenu(int index) {
    boards![index].isExpanded = !boards![index].isExpanded!;
    notifyListeners(); // Notify listeners to rebuild the UI
  }

  List<Committee>? get committees => committeesData?.committees;
  void toggleCommitteeParentMenu(int index) {
    committees![index].isExpanded = !committees![index].isExpanded;
    notifyListeners(); // Notify listeners to rebuild the UI
  }




  Future getListOfBoardNotes(context) async{
    var response = await networkHandler.post1('/get-list-board-notes',context);
    if (response.statusCode == 200 || response.statusCode == 201) {
      log.d("get-list-board-notes form provider response statusCode == 200");
      var responseData = json.decode(response.body) ;
      var responseBoardsData = responseData['data'];
      log.d(responseBoardsData);
      boardsData = Boards.fromJson(responseBoardsData);
      log.d(boardsData!.boards!.length);
      notifyListeners();
    } else {
      log.d("get-list-board-notes dataOfMeetings form provider response statusCode unknown");
      log.d(response.statusCode);
      log.d(json.decode(response.body)['message']);
    }
  }

  Future getListOfCommitteeNotes(context) async{
    var response = await networkHandler.post1('/get-list-committee-notes',context);
    if (response.statusCode == 200 || response.statusCode == 201) {
      log.d("get-list-committee-notes form provider response statusCode == 200");
      var responseData = json.decode(response.body) ;
      var responseCommitteesData = responseData['data'];
      log.d(responseCommitteesData);
      committeesData = DataComm.fromJson(responseCommitteesData);
      log.d(committeesData!.committees!.length);
      notifyListeners();
    } else {
      log.d("get-list-committee-notes dataOfMeetings form provider response statusCode unknown");
      log.d(response.statusCode);
      log.d(json.decode(response.body)['message']);
    }
  }

  Future<void> insertNewNote(Map<String, dynamic> data)async{
    setLoading(true);
    notifyListeners();
    var response = await networkHandler.post1('/insert-new-note', data);
    if (response.statusCode == 200 || response.statusCode == 201) {
      setLoading(false);
      notifyListeners();
      log.d("insert new note response statusCode == 200");
      var responseData = json.decode(response.body) ;
      var responseMinuteData = responseData['data'];
      _note = Note.fromJson(responseMinuteData['note']);
      notesData!.notes!.add(_note);
      log.d(notesData!.notes!.length);
      setLoading(false);
      notifyListeners();
    } else {
      setLoading(false);
      notifyListeners();
      log.d("insert new note response statusCode unknown");
      log.d(response.statusCode);
      print(json.decode(response.body)['message']);
    }
  }


  Future<void> updateNote(Map<String, dynamic> data)async{
    setLoading(true);
    notifyListeners();
    var response = await networkHandler.post1('/update-note', data);
    if (response.statusCode == 200 || response.statusCode == 201) {
      setLoading(false);
      notifyListeners();
      log.d("update note response statusCode == 200");
      var responseData = json.decode(response.body) ;
      var responseMinuteData = responseData['data'];
      _note = Note.fromJson(responseMinuteData['note']);
      notesData!.notes!.add(_note);
      log.d(notesData!.notes!.length);
      setLoading(false);
      notifyListeners();
    } else {
      setLoading(false);
      notifyListeners();
      log.d("update note response statusCode unknown");
      log.d(response.statusCode);
      print(json.decode(response.body)['message']);
    }
  }

  Future<void> insertNewMinuteNote(Map<String, dynamic> data)async{
    setLoading(true);
    notifyListeners();
    var response = await networkHandler.post1('/insert-new-minute-note', data);
    if (response.statusCode == 200 || response.statusCode == 201) {
      setLoading(false);
      notifyListeners();
      log.d("insert new note response statusCode == 200");
      var responseData = json.decode(response.body) ;
      var responseMinuteData = responseData['data'];
      _note = Note.fromJson(responseMinuteData['note']);
      setNote(_note);
      notesData!.notes!.add(_note);
      log.d(notesData!.notes!.length);
      setLoading(false);
      notifyListeners();
    } else {
      setLoading(false);
      notifyListeners();
      log.d("insert new note response statusCode unknown");
      log.d(response.statusCode);
      print(json.decode(response.body)['message']);
    }
  }


  Future<void> updateMinuteNote(Map<String, dynamic> data)async{
    setLoading(true);
    notifyListeners();
    var response = await networkHandler.post1('/update-minute-note', data);
    if (response.statusCode == 200 || response.statusCode == 201) {
      setLoading(false);
      notifyListeners();
      log.d("update note response statusCode == 200");
      var responseData = json.decode(response.body) ;
      var responseMinuteData = responseData['data'];
      _note = Note.fromJson(responseMinuteData['note']);
      log.d("------------------- ${responseMinuteData['note']}");
      setNote(_note);
      notesData!.notes!.add(_note);
      log.d(notesData!.notes!.length);
      setLoading(false);
      notifyListeners();
    } else {
      setLoading(false);
      notifyListeners();
      log.d("update note response statusCode unknown");
      log.d(response.statusCode);
      print(json.decode(response.body)['message']);
    }
  }

}


