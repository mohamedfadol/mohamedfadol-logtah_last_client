
import 'package:diligov_members/models/committee_model.dart';
import 'package:diligov_members/models/meeting_model.dart';
import 'package:diligov_members/models/member.dart';

import 'business_model.dart';

class Board {
   int? boarId;
   String? term;
   String? boardName;
   String? quorum;
   String? fiscalYear;
   String? serialNumber;
   String? charterBoard;
   bool? isExpanded;
   Business? business;
   List<Member>? members;
   List<Meeting>? meetings;
   List<Committee>? committees;

  Board({
       this.boarId, this.boardName, this.term, this.quorum, this.fiscalYear, this.serialNumber,this.charterBoard, this.business,this.members, this.meetings,  this.isExpanded = false});

   Board.fromJson(Map<String, dynamic> json) {
          boarId= json['id'];
          term= json['term'];
          isExpanded = json['isExpanded'] ?? false;
          boardName= json['board_name'];
          quorum= json['quorum'];
          fiscalYear= json['fiscal_year'];
          serialNumber= json['serial_number'];
          charterBoard= json['charter_board'];
          business =  json['business'] != null ? Business.fromJson(json['business']) : null;

          if (json['members'] != null) {
            members = <Member>[];
            json['members'].forEach((v) {
              members!.add(Member.fromJson(v));
            });
          }

          if (json['meetings'] != null) {
            meetings = <Meeting>[];
            json['meetings'].forEach((v) {
              meetings!.add(Meeting.fromJson(v));
            });
          }

          if (json['committees'] != null) {
            committees = <Committee>[];
            json['committees'].forEach((v) {
              committees!.add(Committee.fromJson(v));
            });
          }

          if (json['members'] != null) {
            members = <Member>[];
            json['members'].forEach((v) {
              members!.add(Member.fromJson(v));
            });
          }
   }

   Map<String, dynamic> toJson() {
     final Map<String, dynamic> data = <String, dynamic>{};
     data['id'] = boarId;
     data['board_name'] = boardName;
     data['term'] = term;
     data['fiscal_year'] = fiscalYear;
     data['business'] = business;
     data['isExpanded'] = isExpanded;

     if (committees != null) {
       data['committees'] = committees!.map((v) => v.toJson()).toList();
     }

     if (meetings != null) {
       data['meetings'] = meetings!.map((v) => v.toJson()).toList();
     }

     if (members != null) {
       data['members'] = members!.map((v) => v.toJson()).toList();
     }

     return data;
   }
}