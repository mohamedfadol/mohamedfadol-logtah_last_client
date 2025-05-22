import 'package:diligov_members/models/committee_model.dart';
import 'package:diligov_members/models/member.dart';


class DataOfGroups {
  List<Group>? groups;
  DataOfGroups.fromJson(Map<String, dynamic> json) {
    if (json['groups'] != null) {
      groups = <Group>[];
      json['groups'].forEach((v) {
        groups!.add(Group.fromJson(v));
      });
    }
  }
}

class Group {
  int? id;
  String? boardName;
  String? term;
  List<Member>? members;
  List<Committee>? committees;

  Group({
    this.id,
    this.boardName,
    this.term,
    this.members,
    this.committees,
  });

  Group.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        boardName = json['board_name'],
        term = json['term'],
        members = (json['members'] as List<dynamic>?)
            ?.map((m) => Member.fromJson(m))
            .toList(),
        committees = (json['committees'] as List<dynamic>?)
            ?.map((c) => Committee.fromJson(c))
            .toList();
}
