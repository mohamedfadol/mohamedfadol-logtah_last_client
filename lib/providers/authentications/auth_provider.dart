import 'package:diligov_members/core/domains/app_uri.dart';
import 'package:diligov_members/utility/shared_preference.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';
import '../../NetworkHandler.dart';
import '../../models/user.dart';

enum Status {
  NotLoggedIn,
  NotRegistered,
  LoggedIn,
  Registered,
  Authenticating,
  Registering,
  LoggedOut
}

class AuthProvider extends ChangeNotifier {
 
  final log = Logger();
  final networkHandler = NetworkHandler();
  String baseApi = AppUri.baseApi;
  var client = http.Client();

  bool _loading = false;
  bool get loading => _loading;

  setLoading(bool value) {
    _loading = value;
    notifyListeners();
  }

  bool _isObscured = true;

  bool get isObscured => _isObscured;

  void toggleVisibility() {
    _isObscured = !_isObscured;
    notifyListeners();
  }

  bool isOldPasswordObscured = true;
  bool isNewPasswordObscured = true;
  bool isConfirmPasswordObscured = true;

  void toggleOldPasswordVisibility() {
    isOldPasswordObscured = !isOldPasswordObscured;
    notifyListeners();
  }

  void toggleNewPasswordVisibility() {
    isNewPasswordObscured = !isNewPasswordObscured;
    notifyListeners();
  }

  void toggleConfirmPasswordVisibility() {
    isConfirmPasswordObscured = !isConfirmPasswordObscured;
    notifyListeners();
  }

  bool _isBack = false;
  bool get isBack => _isBack;
  void setIsBack(value) async {
    _isBack =  value;
    notifyListeners();
  }

  Status _loggedInStatus = Status.NotLoggedIn;
  Status _registeredInStatus = Status.NotRegistered;
  Status get loggedInStatus => _loggedInStatus;

  set loggedInStatus(Status value) {
    _loggedInStatus = value;
  }

  Status get registeredInStatus => _registeredInStatus;

  set registeredInStatus(Status value) {
    _registeredInStatus = value;
  }

  Future<Map<String, dynamic>> login(String email, String password) async {
    setLoading(true);
    var result;
    try {
      final tokenCode = await FirebaseMessaging.instance.getToken();
      var response = await client.post(
        Uri.parse("$baseApi/login"),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(<String, String>{'email': email, 'password': password, 'token': tokenCode!}),
      );
      // print(json.decode(response.body));
      print(response.statusCode);
      if (response.statusCode == 200) {
        var responseData = json.decode(response.body);
        var userData = responseData['data'];
        var authUser = userFromJson(json.encode(userData));
        print(authUser.user);
        final storage = FlutterSecureStorage();
        await storage.write(key: "token", value: authUser.token);
        await storage.write(key: "user", value: json.encode(authUser.user));
        UserPreferences().saveUser(authUser);
        setLoading(false);
        _loggedInStatus = Status.LoggedIn;
        notifyListeners();
        result = {'status': true, 'message': 'Successful', 'user': authUser};
      } else {
        print(json.decode(response.body)['message']);
        result = {
          'status': false,
          'message': json.decode(response.body)['message']
        };
      }
    } catch (error) {
      result = {
        'status': false,
        'message': 'An error occurred during login. Please try again later.'
      };
    } finally {
      _loggedInStatus = result['status'] ? Status.LoggedIn : Status.NotLoggedIn;
      setLoading(false);
      notifyListeners();
    }
    return result;
  }


  Future<Map<String, dynamic>>  resetPassword(String email) async {
    setLoading(true);
    var result;
    var response = await client.post(
      Uri.parse("$baseApi/reset-password"),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(<String, String>{'email': email}),
    );
    print(response.statusCode);
    print(json.decode(response.body));

    if (response.statusCode == 200 || response.statusCode == 201) {
      print("update password response statusCode == 200");
      var responseData = json.decode(response.body);

      var userData = responseData['data'];
      print(userData['message']);
      setLoading(false);
      notifyListeners();
      result = {'status': true, 'message': userData['message']};
    } else {
      setLoading(false);
      notifyListeners();
      result = {
        'status': false,
        'message': json.decode(response.body)['message']
      };
    }
    return result;
  }


  Future<void> changePassword(Map<String, dynamic> data) async {
    setLoading(true);
    var result;
    log.i(data);
    setLoading(true);
    notifyListeners();
    var response = await networkHandler.post1('/change-password', data);
    if (response.statusCode == 200 || response.statusCode == 201) {
      print("update password response statusCode == 200");
      var responseData = json.decode(response.body);
      var userData = responseData['data'];
      var authUser = userFromJson(json.encode(userData));
      final storage = FlutterSecureStorage();
      await storage.write(key: "token", value: authUser.token);
      await storage.write(key: "user", value: json.encode(authUser.user));
      UserPreferences().saveUser(authUser);
      setLoading(false);
      setIsBack(true);
      _loggedInStatus = Status.LoggedIn;
      notifyListeners();
      result = {'status': true, 'message': 'Successful',};
    } else {
      setLoading(false);
      setIsBack(false);
      notifyListeners();
      log.d("update password response statusCode unknown");
      log.d(response.statusCode);
      print(json.decode(response.body)['message']);
    }
    return result;
  }
  
  Future<Map<String, dynamic>> updateFcm(Map<String, dynamic> body) async {
    String token = await UserPreferences().getToken();
    setLoading(true);
    var result;
    var response = await client.post(
      Uri.parse("$baseApi/user/update/fcm"),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token'
      },
      body: json.encode(body),
    );
    if (response.statusCode == 200 || response.statusCode == 201) {
      print("update response statusCode == 200");
      var responseData = json.decode(response.body);
      var userData = responseData['data'];
      var authUser = User.fromJson(userData['user']);
      UserPreferences().updateUser(authUser);
      setLoading(false);
      _loggedInStatus = Status.LoggedIn;
      notifyListeners();
      result = {'status': true, 'message': 'Successful', 'user': authUser};
    } else {
      _loggedInStatus = Status.NotLoggedIn;
      setLoading(false);
      notifyListeners();
      result = {
        'status': false,
        'message': json.decode(response.body)['message']
      };
    }
    return result;
  }

  Future<Map<String, dynamic>> updateProfile(Map<String, dynamic> body) async {
    String token = await UserPreferences().getToken();
    setLoading(true);
    var result;
    var response = await client.post(
      Uri.parse("$baseApi/update-user-profile/user"),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token'
      },
      body: json.encode(body),
    );
    if (response.statusCode == 200 || response.statusCode == 201) {
      print("yes update response statusCode == 200");
      setLoading(false);
      print("$baseApi/update-user-profile/user");
      print(json.decode(response.body));
      var responseData = json.decode(response.body);
      var userData = responseData['data'];
      var authUser = User.fromJson(userData['user']);
      UserPreferences().updateUser(authUser);
      setLoading(false);
      _loggedInStatus = Status.LoggedIn;
      notifyListeners();
      result = {'status': true, 'message': 'Successful', 'user': authUser};
    } else {
      _loggedInStatus = Status.NotLoggedIn;
      setLoading(false);
      notifyListeners();
      result = {
        'status': false,
        'message': json.decode(response.body)['message']
      };
    }
    return result;
  }

  Future<http.StreamedResponse> patchImage(String url, String filepath) async {
    url = formater(baseApi);
    String token = await UserPreferences().getToken();
    setLoading(true);
    print('image path filepath');
     
    var request = http.MultipartRequest('POST', Uri.parse(url));
    request.files
        .add(await http.MultipartFile.fromPath("profile_iamges", filepath));
    request.headers.addAll({
      "Content-type": "multipart/form-data",
      "Authorization": "Bearer $token"
    });
    // print('respons come form patchImage ready to send');
    var response = request.send();
    // print(response);
    return response;
  }

  String formater(String url) {
    return baseApi + url;
  }

  // Future<Map<String, dynamic>> register(String email, String password) async {
  //   final Map<String, dynamic> apiBodyData = {
  //     'email': email,
  //     'password': password
  //   };
  //
  //   return  await client.post(Uri.parse("$baseApi/register"),
  //       body: json.encode(apiBodyData),
  //       headers: {'Content-Type':'application/json'}
  //   ).then(onValue)
  //       .catchError(onError);
  // }
  //
  //
  // notify(){
  //   notifyListeners();
  // }
  //
  // static Future<FutureOr> onValue (Response response) async {
  //   var result ;
  //
  //   final Map<String, dynamic> responseData = json.decode(response.body);
  //
  //   print(responseData);
  //
  //   if(response.statusCode == 200){
  //
  //     var userData = responseData['data'];
  //
  //     // now we will create a user model
  //     User authUser = User.fromJson(responseData);
  //
  //     // now we will create shared preferences and save data
  //     UserPreferences().saveUser(authUser);
  //
  //     result = {
  //       'status':true,
  //       'message':'Successfully registered',
  //       'data':authUser
  //     };
  //
  //   }else{
  //     result = {
  //       'status':false,
  //       'message':'Successfully registered',
  //       'data':responseData
  //     };
  //   }
  //   return result;
  // }

  static onError(error) {
    print('the error is ${error.detail}');
    return {'status': false, 'message': 'Unsuccessful Request', 'data': error};
  }

  Future<Map<String, dynamic>> logout(String email, String password) async {
    setLoading(true);
    var result;
    var response = await client.post(
      Uri.parse("$baseApi/logout"),
      headers: {
        'Content-Type': 'application/json',
      },
    );
    if (response.statusCode == 200) {
      var responseData = json.decode(response.body);
      var userData = responseData['data'];
      var authUser = userFromJson(json.encode(userData));
      print(authUser.user);
      UserPreferences().saveUser(authUser);
      setLoading(false);
      _loggedInStatus = Status.LoggedIn;
      notifyListeners();
      result = {'status': true, 'message': 'Successful', 'user': authUser};
    } else {
      _loggedInStatus = Status.NotLoggedIn;
      setLoading(false);
      notifyListeners();
      result = {
        'status': false,
        'message': json.decode(response.body)['message']
      };
    }
    return result;
  }
}
