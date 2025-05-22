
class MemberSignedModel{
  int? memberSignedId;
  String? memberProfileImage;
  String? memberFirstName;
  String? memberLastName;
  String? memberMiddelName;
  int? businessId;
  MemberSignedModel({
    this.memberSignedId,
    this.memberProfileImage,
    this.memberFirstName,
    this.memberLastName,
    this.businessId,
    this.memberMiddelName
  });

  MemberSignedModel.fromJson(Map<String, dynamic> json) {
    memberSignedId = json['id'];
    memberProfileImage = json['member_profile_image'];
    memberFirstName = json['member_first_name'];
    memberLastName = json['member_last_name'];
    memberMiddelName = json['member_middel_name'];
    businessId = json['business_id'];
  }


}