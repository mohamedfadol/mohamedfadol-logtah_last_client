import 'package:diligov_members/models/committee_model.dart';
import 'package:diligov_members/models/member.dart';

class PerformanceRewardData{

  List<PerformanceRewardModel>? performanceRewards;
  PerformanceRewardData.fromJson(Map<String, dynamic> json) {
    if (json['performance_rewards'] != null) {
      performanceRewards = <PerformanceRewardModel>[];
      json['performance_rewards'].forEach((v) {
        performanceRewards!.add(PerformanceRewardModel.fromJson(v));
      });
    }
  }
}

class PerformanceRewardModel {
  int? performanceId;
  String? originalBonusScheme;
  String? businessId;
  String? bonusScheme;
  String? createdAt;
  bool? published;
  Committee? committee;
  List<Member>? members;

  PerformanceRewardModel(
      {this.performanceId,
        this.bonusScheme,
        this.businessId,
        this.published,
        this.originalBonusScheme,
        this.createdAt,
        this.committee,
        this.members,
      });
  // create new converter
  PerformanceRewardModel.fromJson(Map<String, dynamic> json) {
    performanceId = json['id'];
    bonusScheme = json['bonus_scheme'];
    createdAt = json['created_at'];
    published = json['published'];
    businessId = json['business_id']?.toString();
    committee = json['committee'] != null ? Committee.fromJson(json['committee']) : null;
    originalBonusScheme = json['original_bonus_scheme'];

    if (json['members'] != null) {
      members = <Member>[];
      json['members'].forEach((v) {
        members!.add(Member.fromJson(v));
      });
    }


  }

}