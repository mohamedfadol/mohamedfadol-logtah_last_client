import 'package:diligov_members/models/annual_audit_category.dart';
import 'package:diligov_members/models/business_model.dart';
import 'package:diligov_members/models/committee_model.dart';
import 'package:diligov_members/models/member.dart';
import 'package:diligov_members/models/user.dart';

class AnnualAuditReportData {
  List<AnnualAuditReportModel>? annual_audit_reports_data;
  AnnualAuditReportData.fromJson(Map<String, dynamic> json) {
    if (json['annual_audit_reports'] != null) {
      annual_audit_reports_data = <AnnualAuditReportModel>[];
      json['annual_audit_reports'].forEach((v) {
        annual_audit_reports_data!.add(AnnualAuditReportModel.fromJson(v));
      });
    }
  }
}

class AnnualAuditReportModel {
  int? annualAuditReportId;
  String? annualAuditReportTitleEn;
  String? annualAuditReportTitleAr;
  String? annualAuditReportFileEdited;

  User? user;
  Business? business;
  List<Member>? members;
  List<AnnualAuditCategoryModel>? annualAuditCategories;
  Committee? committee;

  AnnualAuditReportModel({this.members,this.annualAuditReportId,this.annualAuditReportTitleEn,this.annualAuditReportTitleAr,this.user,this.business, this.annualAuditCategories, this.annualAuditReportFileEdited});

  // create new converter
  AnnualAuditReportModel.fromJson(Map<String, dynamic> json) {
    annualAuditReportId = json['id'];
    annualAuditReportTitleEn	 = json['annual_audit_report_title_en'];
    annualAuditReportTitleAr = json['annual_audit_report_title_ar'];
    annualAuditReportFileEdited = json['file_edited'];

    user = json['user'] != null ? User.fromJson(json['user']) : null;
    business = json['business'] != null ? Business.fromJson(json['business']) : null;
    committee = json['committee'] != null ? Committee.fromJson(json['committee']) : null;
    if (json['members'] != null) {
      members = <Member>[];
      json['members'].forEach((v) {
        members!.add(Member.fromJson(v));
      });
    }

    if (json['categories'] != null) {
      annualAuditCategories = <AnnualAuditCategoryModel>[];
      json['categories'].forEach((v) {
        annualAuditCategories!.add(AnnualAuditCategoryModel.fromJson(v));
      });
    }


  }

}