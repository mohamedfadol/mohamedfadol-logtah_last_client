import 'dart:async';
import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';

import 'core/domains/app_uri.dart';

class NetworkHandler {
  String baseurl = '${AppUri.baseApi}';
  var log = Logger();
  FlutterSecureStorage storage = const FlutterSecureStorage();

  Future<http.Response> get(String url) async {
    try{
    String token = (await storage.read(key: "token"))!;
    print(token);
    url = formater(url);
    var response = await http.get(
      Uri.parse(url),
      headers: {
        "Accept": "application/json",
        "Content-type": "application/json",
        "Authorization": "Bearer $token",
        "Connection": "Keep-Alive"
      },
    ).timeout(const Duration(seconds: 1000));
    // print(json.decode(response.body));
    log.i(response.statusCode);
    return response;
    } on TimeoutException catch (e) {
    // Handle timeout exception
    log.i("Request to $url timed out: ${e.message}");
    throw Exception("Request timed out: ${e.message}");
    } on http.ClientException catch (e) {
    // Handle client-side error (e.g., network issues)
    log.i("Client exception occurred: ${e.message}");
    throw Exception("Client exception occurred: ${e.message}");
    } catch (e) {
    // Handle any other exceptions
    log.i("An unexpected error occurred: $e");
    throw Exception("An unexpected error occurred: $e");
    }
  }

  Future<http.Response> post(String url, Map<String, String> body) async {
    String token = (await storage.read(key: "token"))!;
    url = formater(url);
    var response = await http.post(
      Uri.parse(url),
      headers: {
        "Accept": "application/json",
        "Content-type": "application/json",
        "Authorization": "Bearer $token",
        "Connection": "Keep-Alive"
      },
      body: json.encode(body),
    );
    // log.d(json.decode(response.body));
    return response;
  }

  Future<http.Response> post1(String url, var body) async {
    try{
    String token = (await storage.read(key: "token"))!;
    url = formater(url);
    log.d(body);
    var response = await http.post(
      Uri.parse(url),
      headers: {
        "Accept": "application/json",
        "Content-type": "application/json",
        "Authorization": "Bearer $token",
        "Connection": "Keep-Alive"
      },
      body: json.encode(body),
    ).timeout(const Duration(seconds: 1000));
    log.i(response.statusCode); // Assuming log.i is a logging method you've defined elsewhere.
    return response;
    } on TimeoutException catch (e) {
    // Handle timeout exception
    log.i("Request to $url timed out: ${e.message}");
    throw Exception("Request timed out: ${e.message}");
    } on http.ClientException catch (e) {
    // Handle client-side error (e.g., network issues)
    log.i("Client exception occurred: ${e.message}");
    throw Exception("Client exception occurred: ${e.message}");
    } catch (e) {
    // Handle any other exceptions
    log.i("An unexpected error occurred: $e");
    throw Exception("An unexpected error occurred: $e");
    }
  }

  String formater(String url) {
    return baseurl + url;
  }

}