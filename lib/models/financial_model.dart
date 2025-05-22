
import 'package:diligov_members/models/business_model.dart';
import 'package:diligov_members/models/meeting_model.dart';
import 'package:diligov_members/models/member.dart';
import 'package:diligov_members/models/user.dart';

class FinancialData {
  List<FinancialModel>? financials;

  FinancialData.fromJson(Map<String, dynamic> json) {
    if (json['financials'] != null) {
      financials = <FinancialModel>[];
      json['financials'].forEach((v) {
        financials!.add(FinancialModel.fromJson(v));
      });
    }
  }
}

class FinancialModel {
  int? financialId;
  String? financialArabicName;
  String? financialEnglishName;
  String? financialDate;
  String? financialFile;
  User? user;
  Business? business;
  Meeting? meeting;
  List<Member>? members;

  FinancialModel({this.members,this.financialId,this.financialArabicName,this.financialEnglishName,this.financialDate,this.financialFile,this.user,this.business,this.meeting});

  // create new converter
  FinancialModel.fromJson(Map<String, dynamic> json) {
    financialId = json['id'] is int ? json['id'] : int.tryParse(json['id'].toString());
    financialFile = json['financial_file'];
    financialArabicName = json['financial_name_ar'];
    financialEnglishName = json['financial_name_en'];
    financialDate = json['created_at'];
    user = json['user'] != null ? User.fromJson(json['user']) : null;
    business = json['business'] != null ? Business.fromJson(json['business']) : null;
    meeting = json['meeting'] != null ? Meeting.fromJson(json['meeting']) : null;
    if (json['members'] != null) {
      members = <Member>[];
      json['members'].forEach((v) {
        members!.add(Member.fromJson(v));
      });
    }
  }


}