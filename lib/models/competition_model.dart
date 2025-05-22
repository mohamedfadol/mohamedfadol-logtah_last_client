import 'package:diligov_members/models/business_model.dart';
import 'package:diligov_members/models/committee_model.dart';
import 'package:diligov_members/models/member.dart';
import 'package:diligov_members/models/user.dart';

class Competitions{
  List<CompetitionModel>? competitions;

  Competitions.fromJson(Map<String, dynamic> json) {
    if (json['competitions'] != null) {
      competitions = <CompetitionModel>[];
      json['competitions'].forEach((v) {
        competitions!.add(CompetitionModel.fromJson(v));
      });
    }
  }
}

class CompetitionModel{
  int? competitionId;
  String? competitionEnName;
  String? competitionArName;
  String? competitionCreateAt;
  int? agree;
  String? comment;
  Business? business;
  Committee? committee;
  List<Member>? members;
  User? user;

  CompetitionModel({
        this.competitionId,
        this.competitionEnName,
        this.competitionArName,
        this.competitionCreateAt,
        this.business,
        this.members,
        this.user,
        this.committee
  });

  CompetitionModel.fromJson(Map<String, dynamic> json) {
    competitionId = json['id'];
    competitionEnName = json['category_name_en'];
    competitionArName = json['category_name_ar'];
    agree = json['agree'];
    comment = json['comment'];
    competitionCreateAt = json['created_at'];
    committee = json['committee'] != null ? Committee.fromJson(json['committee']) : null;
    business = json['business'] != null ? Business.fromJson(json['business']) : null;
    user = json['user'] != null ? User.fromJson(json['user']) : null;
    if (json['members'] != null) {
      members = <Member>[];
      json['members'].forEach((v) {
        members!.add(Member.fromJson(v));
      });
    }
  }


}


class CompetitionsRelatedParties{
  List<CompetitionRelatedPartiesModel>? competitions;

  CompetitionsRelatedParties.fromJson(Map<String, dynamic> json) {
    if (json['competitions'] != null) {
      competitions = <CompetitionRelatedPartiesModel>[];
      json['competitions'].forEach((v) {
        competitions!.add(CompetitionRelatedPartiesModel.fromJson(v));
      });
    }
  }
}

class CompetitionRelatedPartiesModel{
  int? competitionId;
  String? competitionEnName;
  String? competitionArName;
  String? competitionCreateAt;
  Business? business;
  Committee? committee;
  List<Member>? members;
  User? user;
  int? agree;
  String? comment;

  CompetitionRelatedPartiesModel({
    this.competitionId,
    this.competitionEnName,
    this.competitionArName,
    this.competitionCreateAt,
    this.business,
    this.members,
    this.user,
    this.agree,
    this.comment,
    this.committee
  });

  CompetitionRelatedPartiesModel.fromJson(Map<String, dynamic> json) {
    competitionId = json['id'];
    competitionEnName = json['category_name_en'];
    competitionArName = json['category_name_ar'];
    agree = json['agree'];
    comment = json['comment'];
    competitionCreateAt = json['created_at'];
    committee = json['committee'] != null ? Committee.fromJson(json['committee']) : null;
    business = json['business'] != null ? Business.fromJson(json['business']) : null;
    user = json['user'] != null ? User.fromJson(json['user']) : null;
    if (json['members'] != null) {
      members = <Member>[];
      json['members'].forEach((v) {
        members!.add(Member.fromJson(v));
      });
    }
  }


}


class CompetitionsConfirmationOfIndependence{
  List<CompetitionConfirmationOfIndependenceModel>? competitions;

  CompetitionsConfirmationOfIndependence.fromJson(Map<String, dynamic> json) {
    if (json['competitions'] != null) {
      competitions = <CompetitionConfirmationOfIndependenceModel>[];
      json['competitions'].forEach((v) {
        competitions!.add(CompetitionConfirmationOfIndependenceModel.fromJson(v));
      });
    }
  }
}

class CompetitionConfirmationOfIndependenceModel{
  int? competitionId;
  String? competitionEnName;
  String? competitionArName;
  String? competitionCreateAt;
  Business? business;
  Committee? committee;
  List<Member>? members;
  User? user;
  int? agree;
  String? comment;

  CompetitionConfirmationOfIndependenceModel({
    this.competitionId,
    this.competitionEnName,
    this.competitionArName,
    this.competitionCreateAt,
    this.business,
    this.agree,
    this.members,
    this.comment,
    this.user,
    this.committee
  });

  CompetitionConfirmationOfIndependenceModel.fromJson(Map<String, dynamic> json) {
    competitionId = json['id'];
    competitionEnName = json['category_name_en'];
    competitionArName = json['category_name_ar'];
    competitionCreateAt = json['created_at'];
    agree = json['agree'];
    comment = json['comment'];
    committee = json['committee'] != null ? Committee.fromJson(json['committee']) : null;
    business = json['business'] != null ? Business.fromJson(json['business']) : null;
    user = json['user'] != null ? User.fromJson(json['user']) : null;
    if (json['members'] != null) {
      members = <Member>[];
      json['members'].forEach((v) {
        members!.add(Member.fromJson(v));
      });
    }
  }


}