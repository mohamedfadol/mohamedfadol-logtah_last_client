import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../NetworkHandler.dart';
import '../models/action_tracker_model.dart';
import '../models/user.dart';
class ActionsTrackerPageProvider extends ChangeNotifier {
  var log = Logger();
  User user = User();
  NetworkHandler networkHandler = NetworkHandler();
  ActionsTrackers? actionsData;
  List<ActionTracker>? originalActionsData;
  ActionTracker _action_track = ActionTracker();
  ActionTracker get action_track => _action_track;

  String _yearSelected = '2024';

  bool _enableFilter = false;
  bool get enableFilter => _enableFilter;

  int currentSortColumn = 0;
  bool isAscending = true;
  Map<String, int> statusCounts = {};
  Map<String, double> statusPercentages = {};

  bool _loading = false;
  bool get loading => _loading;

  bool _isBack = false;
  bool get isBack => _isBack;

  void setActionTracker(ActionTracker action_track) async {
    _action_track = action_track;
    notifyListeners();
  }

  void setLoading(value) async {
    _loading = value;
    notifyListeners();
  }

  void setIsBack(value) async {
    _isBack = value;
    notifyListeners();
  }

  String get yearSelected => _yearSelected;
  void setYearSelected(year) async {
    _yearSelected =  year;
    notifyListeners();
  }

  Future<void> updateActionTracker(Map<String, dynamic> data, ActionTracker oldAction) async {
    final index = actionsData!.actions!.indexOf(actionsData!.actions!.where((element) => element.actionsId==oldAction.actionsId).first);
    ActionTracker action = actionsData!.actions![index];
    String actionsId =  action.actionsId.toString();
    setLoading(true);
    var response = await networkHandler.post1('/edit-actions-tracker/$actionsId', data);
    if (response.statusCode == 200 || response.statusCode == 201) {
      log.d("update action response statusCode == 200");
      var responseData = json.decode(response.body) ;
      var responseBoardData = responseData['data'];
      actionsData!.actions![index] = ActionTracker.fromJson(responseBoardData['action']);
      setActionTracker(_action_track);
      log.d(actionsData!.actions!.length);
      setIsBack(true);
    } else {
      log.d("update action response statusCode unknown");
      log.d(response.statusCode);
      print(json.decode(response.body)['message']);
      setIsBack(false);
    }
    setLoading(false);
  }


  Future<void> resetFilter(Map<String, dynamic> data) async {
    _enableFilter = false;
    final response = await networkHandler.post1('/get-list-actions-reset-filter', data);
    _handleResponse(response, updateActionsData: true);
  }

  Future<void> getListOfActionTrackersWhereLike(context) async {
    _enableFilter = true;
    final response = await networkHandler.post1('/get-list-actions-trackers-where-like', context);
    _handleResponse(response, updateActionsData: true);
  }

  Future<void> getListOfActionTrackers(context) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    user = User.fromJson(json.decode(prefs.getString("user")!));
    final response = await networkHandler.post1('/get-list-actions-trackers', context);
    _handleResponse(response, updateActionsData: true);
  }

  void sortBy(int index, int Function(ActionTracker a, ActionTracker b) compare) {
    _enableFilter = true;
    isAscending = !isAscending;
    currentSortColumn = index;
    actionsData?.actions?.sort((a, b) => isAscending ? compare(a, b) : compare(b, a));
    notifyListeners();
  }

  void sortByStatus(int index) => sortBy(index, (a, b) => a.actionStatus!.compareTo(b.actionStatus!));
  void sortByTaskName(int index) => sortBy(index, (a, b) => a.actionsTasks!.compareTo(b.actionsTasks!));
  void sortByActionDateAssigned(int index) => sortBy(index, (a, b) => a.actionsDateAssigned!.compareTo(b.actionsDateAssigned!));
  void sortByActionMeetingName(int index) => sortBy(index, (a, b) => a.meeting!.meetingTitle!.compareTo(b.meeting!.meetingTitle!));
  void sortByActionDateDue(int index) => sortBy(index, (a, b) => a.actionsDateDue!.compareTo(b.actionsDateDue!));


  void _handleResponse(response, {bool updateActionsData = false}) {
    if (response.statusCode == 200 || response.statusCode == 201) {
      final responseData = json.decode(response.body);
      if (updateActionsData) {
        actionsData = ActionsTrackers.fromJson(responseData['data']);
        originalActionsData = actionsData?.actions;
        _updateStatusCounts();
      }
      log.d("Response successful, data length: ${actionsData?.actions?.length}");
      notifyListeners();
    } else {
      log.d("Response status code unknown: ${response.statusCode}");
      log.d(json.decode(response.body)['message']);
    }
  }

  void _updateStatusCounts() {
    statusCounts = {};
    actionsData?.actions?.forEach((action) {
      if (action.actionStatus != null) {
        statusCounts[action.actionStatus!] = (statusCounts[action.actionStatus!] ?? 0) + 1;
      }
    });
  }

  // to get count of status use below code
  // int ongoingCount = provider.statusCounts['ONGOING'] ?? 0.0;
  // int delayedCount = provider.statusCounts['DELAYED'] ?? 0.0;


  void _updateStatusPercentages() {
    statusPercentages = {};
    final totalActions = actionsData?.actions?.length ?? 0;
    if (totalActions > 0) {
      statusCounts.forEach((status, count) {
        statusPercentages[status] = (count / totalActions) * 100;
      });
    }
  }

  Map<String, Map<String, dynamic>> getStatusCountsAndPercentages() {
    _updateStatusCounts();
    _updateStatusPercentages();
    Map<String, Map<String, dynamic>> result = {};
    statusCounts.forEach((status, count) {
      result[status] = {
        'count': count,
        'percentage': statusPercentages[status] ?? 0.0,
      };
    });
    return result;
  }

  Map<String, double> prepareChartData(Map<String, Map<String, dynamic>> statusCounts) {
    Map<String, double> chartData = {};
    statusLabels.forEach((status) {
      chartData[status] = (statusCounts[status]?['percentage'] ?? 0.0);
    });
    return chartData;
  }

  // get percentage of each status dynamically
  // Map<String, double> percentages = provider.getStatusPercentages();

}