import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../NetworkHandler.dart';
import '../models/annual_audit_report_model.dart';
import '../models/combined_collection_board_committee_model.dart';
import '../models/user.dart';

class AnnualAuditReportProvider extends ChangeNotifier{

  var log = Logger();
  User user = User();
  NetworkHandler networkHandler = NetworkHandler();

  AnnualAuditReportData? annual_audit_reports_data;
  AnnualAuditReportModel _annual_audit_report = AnnualAuditReportModel();
  AnnualAuditReportModel get annual_audit_report => _annual_audit_report;
  void setAnnualAuditReport(AnnualAuditReportModel annual_audit_report) async {
    _annual_audit_report =  annual_audit_report;
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

  String _currentYear = DateTime.now().year.toString();
  String get currentYear => _currentYear;
  void updateYear() {
    _currentYear = DateTime.now().year.toString();
    notifyListeners();
  }

  String _yearSelected = '2025';
  String get yearSelected => _yearSelected;
  void setYearSelected(year) async {
    _yearSelected =  year;
    notifyListeners();
  }

  Future getListOfAnnualAuditReports(_yearSelected)async{
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    user =  User.fromJson(json.decode(prefs.getString("user")!)) ;
    final Map<String, String>  queryParams = {
      'business_id': user.businessId.toString(),
      'yearSelected': _yearSelected,
    };
    log.d("get-list-annual_audit_reports_yearSelected $_yearSelected");
    var response = await networkHandler.post1('/get-list-annual-audit-reports',queryParams);
    if (response.statusCode == 200 || response.statusCode == 201) {
      log.d("get-list-annual_audit_reports response statusCode == 200");
      var responseData = json.decode(response.body) ;
      var annualReportsResponseData = responseData['data'];
      // log.d("get-list-annual_audit_reports $annualReportsResponseData");
      annual_audit_reports_data = AnnualAuditReportData.fromJson(annualReportsResponseData);
      notifyListeners();
    } else {
      log.d("get-list-annual_audit_reports response statusCode unknown");
      log.d(response.statusCode);
      print(json.decode(response.body)['message']);
    }
  }


}