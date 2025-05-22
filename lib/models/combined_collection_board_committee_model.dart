import 'package:diligov_members/models/roles_model.dart';

class CombinedCollectionBoardCommitteeData {
  List<CombinedCollectionBoardCommitteeModel>?
      combinedCollectionBoardCommitteeData;

  CombinedCollectionBoardCommitteeData.fromJson(Map<String, dynamic> json) {
    if (json['combinedCollection'] != null) {
      combinedCollectionBoardCommitteeData =
          <CombinedCollectionBoardCommitteeModel>[];
      json['combinedCollection'].forEach((v) {
        combinedCollectionBoardCommitteeData!
            .add(CombinedCollectionBoardCommitteeModel.fromJson(v));
      });
    }
  }
}

class CombinedCollectionBoardCommitteeModel {
  int? id;
  String? name;
  String? type;
  List<RoleModel>? roles;

  CombinedCollectionBoardCommitteeModel({this.id, this.name, this.type, this.roles});

  CombinedCollectionBoardCommitteeModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    type = json['type'];
    roles = json['roles'];
  }
}
