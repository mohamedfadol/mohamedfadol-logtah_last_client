class Roles{

  List<RoleModel>? roles;

  Roles.fromJson(Map<String, dynamic> json) {
    if (json['roles'] != null) {
      roles = <RoleModel>[];
      json['roles'].forEach((v) {
        roles!.add(RoleModel.fromJson(v));
      });
    }
  }

}

class RoleModel {

  int? roleId;
  String? roleName;
  // int? memberId;

  RoleModel({
    this.roleId,
    this.roleName,
    // this.memberId
  });

  RoleModel.fromJson(Map<String, dynamic> json) {
    roleId = json['id'];
    roleName = json['name'];
    // memberId = json['member_id'];
  }


}