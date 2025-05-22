
class Permissions {
  List<PermissionModel>? permissions;

  Permissions.fromJson(Map<String, dynamic> json) {
    if (json['permissions'] != null) {
      permissions = <PermissionModel>[];
      json['permissions'].forEach((v) {
        permissions!.add(PermissionModel.fromJson(v));
      });
    }
  }

}

class PermissionModel {

  int? permissionId;
  String? permissionName;
  // int? memberId;

  PermissionModel({
     this.permissionId,
     this.permissionName,
     // this.memberId
  });

  PermissionModel.fromJson(Map<String, dynamic> json) {
    permissionId = json['id'];
    permissionName = json['name'];
    // memberId = json['member_id'];
  }


}