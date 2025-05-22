import 'package:diligov_members/models/annual_audit_details_model.dart';

class AnnualAuditCategoriesData {
  List<AnnualAuditCategoryModel>? annualAuditCategoriesData;
  AnnualAuditCategoriesData.fromJson(Map<String, dynamic> json) {
    if (json['annual_audit_reports'] != null) {
      annualAuditCategoriesData = <AnnualAuditCategoryModel>[];
      json['annual_audit_reports'].forEach((v) {
        annualAuditCategoriesData!.add(AnnualAuditCategoryModel.fromJson(v));
      });
    }
  }
}

class AnnualAuditCategoryModel {

  int? categoryId;
  String? categoryEnglishName;
  String? categoryArabicName;
  List<AnnualAuditDetailsModel>? details;

  AnnualAuditCategoryModel({
    this.categoryId,
    this.categoryEnglishName,
    this.categoryArabicName,
    this.details
  });

  AnnualAuditCategoryModel.fromJson(Map<String, dynamic> json) {

    categoryId= json['id'];
    categoryEnglishName= json['category_en'];
    categoryArabicName= json['category_ar'];

    if (json['details'] != null) {
      details = <AnnualAuditDetailsModel>[];
      json['details'].forEach((v) {
        details!.add(AnnualAuditDetailsModel.fromJson(v));
      });
    }

  }



}