import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../NetworkHandler.dart';
import '../models/notification_model.dart';
import '../models/user.dart';

class NotificationPageProvider with ChangeNotifier {

  Notifications? notificationsData;

  var log = Logger();
  User user = User();
  NetworkHandler networkHandler = NetworkHandler();


  List<NotificationModel> _normalNotifications = [];
  List<NotificationModel> _pendingNotifications = [];
  List<NotificationModel> _newsNotifications = [];

  List<NotificationModel> get normalNotifications => _normalNotifications;
  List<NotificationModel> get pendingNotifications => _pendingNotifications;
  List<NotificationModel> get newsNotifications => _newsNotifications;

  bool _loading = false;
  bool get loading => _loading;
  void setLoading(value) async {
    _loading =  value;
    notifyListeners();
  }


  int _selectedTabIndex = 0;

  int get selectedTabIndex => _selectedTabIndex;

  void setSelectedTabIndex(int index) {
    _selectedTabIndex = index;
    notifyListeners();
  }

  List<NotificationModel>? get notifications => notificationsData?.notifications;

  int? get notificationCount => notifications?.length ?? 0;


  Future fetchNotifications()async{
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    user =  User.fromJson(json.decode(prefs.getString("user")!)) ;
    var response = await networkHandler.get('/get-list-of-members-notifications');
    if (response.statusCode == 200 || response.statusCode == 201) {
      log.d("get-list-notifications response statusCode == 200");
      var responseData = json.decode(response.body);
      var notificationsDataResponse = responseData['data'];
      notificationsData = Notifications.fromJson(notificationsDataResponse);
      print(notificationsData!.notifications!.length);
      notifyListeners();
    } else {
      log.d("get-list-notifications response statusCode unknown");
      log.d(response.statusCode);
      print(json.decode(response.body)['message']);
    }
  }


  Future<void> fetchNotificationsByType(String type) async {
    try {
      setLoading(true);

      // Fetch user from shared preferences
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      user = User.fromJson(json.decode(prefs.getString("user")!));

      // Make a network call to fetch notifications of the specified type
      var response = await networkHandler.get('/get-list-of-members-notifications?type=$type');

      if (response.statusCode == 200 || response.statusCode == 201) {
        log.d("get-list-notifications by type ($type) response statusCode == 200");
        var responseData = json.decode(response.body);
        var notificationsDataResponse = responseData['data'];
        var fetchedNotifications = notificationsDataResponse['notifications'] as List;

        // Parse the fetched notifications into the appropriate type list
        List<NotificationModel> notifications = fetchedNotifications
            .map((notification) => NotificationModel.fromJson(notification))
            .toList();
  // log.d(notifications);
        switch (type) {
          case 'normal':
            _normalNotifications = notifications;
            break;
          case 'pending':
            _pendingNotifications = notifications;
            break;
          case 'news':
            _newsNotifications = notifications;
            break;
          default:
            log.d("Unknown type: $type");
            break;
        }

        notifyListeners();
      } else {
        log.d("get-list-notifications by type ($type) response statusCode unknown");
        log.d(response.statusCode);
        print(json.decode(response.body)['message']);
      }
    } catch (e) {
      log.e("Error fetching notifications by type: $e");
    } finally {
      setLoading(false);
    }
  }



  // Method to fetch last 10 notifications
  List<NotificationModel> get lastTenNotifications => notifications!.reversed.take(10).toList();
}