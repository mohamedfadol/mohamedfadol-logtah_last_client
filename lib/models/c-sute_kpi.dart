import 'package:diligov_members/models/business_model.dart';
import 'package:diligov_members/models/committee_model.dart';
import 'package:diligov_members/models/user.dart';

class CsuiteKpiData {
  List<CsuiteKpiModel>? csuiteKpis;

  CsuiteKpiData.fromJson(Map<String, dynamic> json) {
    if (json['c_suite_kpis'] != null) {
      csuiteKpis = <CsuiteKpiModel>[];
      json['c_suite_kpis'].forEach((v) {
        csuiteKpis!.add(CsuiteKpiModel.fromJson(v));
      });
    }
  }

}

class CsuiteKpiModel {

  int? csuiteKpiId;
  String? csuiteKpiName;
  String? ceoKeyKpi;
  String? longTerm;
  String? shortTerm;
  String? createdAt;
  User? user;
  Business? business;
  Committee? committee;

  CsuiteKpiModel(
      {this.csuiteKpiId,
        this.csuiteKpiName,
        this.ceoKeyKpi,
        this.longTerm,
        this.shortTerm,
        this.createdAt,
        this.user,
        this.business,
        this.committee,
      });

  CsuiteKpiModel.fromJson(Map<String, dynamic> json) {
    csuiteKpiId = json['id'];
    csuiteKpiName = json['ceo_key_kpi'];
    ceoKeyKpi = json['ceo_key_kpi'];
    longTerm = json['long_term'];
    shortTerm = json['short_term'];
    createdAt = json['created_at'];
    user = json['user'] != null ? User.fromJson(json['user']) : null;
    business = json['business'] != null ? Business.fromJson(json['business']) : null;
    committee = json['committee'] != null ? Committee.fromJson(json['committee']) : null;
  }
}