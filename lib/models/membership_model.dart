class MembershipModel{

  int? memberShipId;
  int? committeeId;
  int? memberIsAdmin;

  MembershipModel(
      {this.memberShipId,
        this.committeeId,
        this.memberIsAdmin,
      });
  MembershipModel.fromJson(Map<String, dynamic> json) {
    memberShipId = json['member_id'];
    committeeId = json['committee_id'];
    memberIsAdmin = json['is_admin'];}
}