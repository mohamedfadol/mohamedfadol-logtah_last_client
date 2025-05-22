import 'package:diligov_members/models/board_model.dart';
import 'package:diligov_members/models/committee_model.dart';
import 'package:diligov_members/models/member_sign_minutes.dart';
import 'package:diligov_members/models/membership_model.dart';
import 'package:diligov_members/models/position_model.dart';
import 'package:diligov_members/models/question_model.dart';
import 'package:diligov_members/models/roles_model.dart';
import 'package:diligov_members/models/signature_model.dart';
import 'business_model.dart';
import 'competition_model.dart';
import 'meeting_model.dart';
import 'minute_signature_model.dart';

class MyData {
  List<Member>? members;

  MyData.fromJson(Map<String, dynamic> json) {
    if (json['members'] != null) {
      members = <Member>[];
      json['members'].forEach((v) {
        members!.add(Member.fromJson(v));
      });
    }
  }
}

class Member{
   int? memberId;
   String? memberProfileImage;
   String? memberEmail;
   String? memberFirstName;
   String? memberMiddleName;
   String? memberLastName;
   String? memberMobile;
   String? memberSignature;
   String? memberBiography;
   String? memberPassword;
   int? businessId;
   bool? isActive;
   Signature? signature;
   MinuteSignature? minuteSignature;
   MembershipModel? memberShip;
   MemberSignMinutes? memberSignMinutes;
   bool? hasVote;
   Position? position;
   Business? business;
   dynamic meetingAttendedPivot;
   List<Position>? positions;
   List<Committee>? committees;
   List<Board>? boards;
   List<RoleModel>? roles;
   List<QuestionModel>? questions;
   MemberPivotCompetition? competitionPivot;
   List<CompetitionModel>? competitions;
   List<Member>? managementSignature;
   List<Meeting>? meetingAttendances;
   List<Meeting>? boardMeetingAttendances;
  Member(
      {this.memberId,
      this.memberProfileImage,
      this.memberEmail,
      this.memberFirstName,
      this.memberMiddleName,
      this.memberLastName,
      this.memberMobile,
      this.memberSignature,
      this.memberPassword,
      this.memberBiography,
      this.businessId,
      this.memberShip,
      this.isActive,
      this.signature,
      this.minuteSignature,
      this.memberSignMinutes,
      this.hasVote,
      this.positions,
      this.committees,
        this.boards,
        this.meetingAttendances,
        this.meetingAttendedPivot,
        this.roles,
        this.competitionPivot,
      this.questions,
        this.business,
        this.competitions,
        this.boardMeetingAttendances,
        this.managementSignature
      });
 // create new converter
  Member.fromJson(Map<String, dynamic> json) {
    memberId = json['id'];
    memberEmail = json['member_email'];
    memberFirstName = json['member_first_name'];
    memberMiddleName = json['member_middel_name'];
    memberLastName = json['member_last_name'];
    memberMobile = json['member_mobile'];
    memberSignature = json['signature'];
    memberPassword = json['member_password'];
    memberBiography = json['member_biography'];
    memberProfileImage = json['member_profile_image'];
    businessId = json['business_id'];
    isActive = json['is_active'];
    signature = json['signature_member'] != null ? Signature.fromJson(json['signature_member']) : null;
    memberShip = json['membership'] != null ? MembershipModel.fromJson(json['membership']) : null;
    minuteSignature = json['minute_signature'] != null ? MinuteSignature.fromJson(json['minute_signature']) : null;
    memberSignMinutes = json['minute_signature_member'] != null ? MemberSignMinutes.fromJson(json['minute_signature_member']) : null;
    competitionPivot = json['pivot'] != null ? MemberPivotCompetition.fromJson(json['pivot']) : null;

    hasVote = json['has_vote'];
    // position =  Position?.fromJson(json['position']);
    business = json['business'] != null ? Business.fromJson(json['business']) : null;

    if (json['positions'] != null) {
      positions = <Position>[];
      json['positions'].forEach((v) {
        positions!.add(Position.fromJson(v));
      });
    }

    // Board Meeting Attendances
    if (json['board_attendances'] != null) {
      boardMeetingAttendances = <Meeting>[];
      json['board_attendances'].forEach((v) {
        Meeting meeting = Meeting.fromJson(v);

        // Set board reference in each meeting so comparison works
        if (v['board'] != null) {
          meeting.board = Board.fromJson(v['board']);
        } else if (json['boards'] != null && json['boards'].isNotEmpty) {
          // Fallback: assign first board if meeting's board is missing
          meeting.board = Board.fromJson(json['boards'][0]);
        }

        if (v['pivot'] != null) {
          meeting.pivot = MemberMeetingPivot.fromJson(v['pivot']);
        }

        boardMeetingAttendances!.add(meeting);
      });
    }

// Committee Meeting Attendances
    if (json['attendances'] != null) {
      meetingAttendances = <Meeting>[];
      json['attendances'].forEach((v) {
        Meeting meeting = Meeting.fromJson(v);

        // Set committee reference in each meeting so comparison works
        if (v['committee'] != null) {
          meeting.committee = Committee.fromJson(v['committee']);
        } else if (json['committees'] != null && json['committees'].isNotEmpty) {
          // Fallback: assign first committee if meeting's committee is missing
          meeting.committee = Committee.fromJson(json['committees'][0]);
        }

        if (v['pivot'] != null) {
          meeting.pivot = MemberMeetingPivot.fromJson(v['pivot']);
        }

        meetingAttendances!.add(meeting);
      });
    }




    if (json['management_signature'] != null) {
      managementSignature = <Member>[];
      json['management_signature'].forEach((v) {
        managementSignature!.add(Member.fromJson(v));
      });
    }

    if (json['committees'] != null) {
      committees = <Committee>[];
      json['committees'].forEach((v) {
        committees!.add(Committee.fromJson(v));
      });
    }

    if (json['boards'] != null) {
      boards = <Board>[];
      json['boards'].forEach((v) {
        boards!.add(Board.fromJson(v));
      });
    }
    if (json['roles'] != null) {
      roles = <RoleModel>[];
      json['roles'].forEach((v) {
        roles!.add(RoleModel.fromJson(v));
      });
    }

    if (json['questions'] != null) {
      questions = <QuestionModel>[];
      json['questions'].forEach((v) {
        questions!.add(QuestionModel.fromJson(v));
      });
    }

    if (json['competitions'] != null) {
      competitions = <CompetitionModel>[];
      json['competitions'].forEach((v) {
        competitions!.add(CompetitionModel.fromJson(v));
      });
    }


  }


   Map<String, dynamic> toJson() {
     return {
       'id': memberId,
       'member_profile_image': memberProfileImage,
       'member_email': memberEmail,
       'member_first_name': memberFirstName,
       'member_middel_name': memberMiddleName,
       'member_last_name': memberLastName,
       'member_mobile': memberMobile,
       'signature': memberSignature,
       'member_password': memberPassword,
       'member_biography': memberBiography,
       'business_id': businessId,
       'is_active': isActive,
       // 'signature_member': signature?.toJson(),
       // 'minute_signature': minuteSignature?.toJson(),
       // 'minute_signature_member': memberSignMinutes?.toJson(),
       // 'membership': memberShip?.toJson(),
       // 'business': business?.toJson(),
       'position': position?.toJson(),
       'positions': positions?.map((p) => p.toJson()).toList(),
       'committees': committees?.map((c) => c.toJson()).toList(),
       'boards': boards?.map((b) => b.toJson()).toList(),
       // 'roles': roles?.map((r) => r.toJson()).toList(),
       // 'questions': questions?.map((q) => q.toJson()).toList(),
       // 'competitions': competitions?.map((c) => c.toJson()).toList(),
       'management_signature': managementSignature?.map((m) => m.toJson()).toList(),

       // 'pivot': pivot?.toJson(),
       'has_vote': hasVote,

       'attendances': meetingAttendances?.map((m) => m.toJson()).toList(),
       'board_attendances': boardMeetingAttendances?.map((m) => m.toJson()).toList(),

     };
   }


   // Get full name
   String get fullName {
     String firstName = memberFirstName ?? '';
     String middleName = memberMiddleName ?? '';
     String lastName = memberLastName ?? '';

     return [firstName, middleName, lastName]
         .where((part) => part.isNotEmpty)
         .join(' ');
   }
}

// Create a pivot class for meeting attendance
// class MemberMeetingPivot {
//   int? meetingId;
//   int? memberId;
//   bool? isAttended;
//   String? createdAt;
//   String? updatedAt;
//
//   MemberMeetingPivot({
//     this.meetingId,
//     this.memberId,
//     this.isAttended,
//     this.createdAt,
//     this.updatedAt,
//   });
//
//   factory MemberMeetingPivot.fromJson(Map<String, dynamic> json) {
//     return MemberMeetingPivot(
//       meetingId: json['meeting_id'],
//       memberId: json['member_id'],
//       isAttended: json['is_attended'] == 1, // Convert int to bool
//       createdAt: json['created_at'],
//       updatedAt: json['updated_at'],
//     );
//   }
// }

// Pivot table model
class MemberPivotCompetition {
  int? competitionId;
  int? memberId;
  int? agree;  // 1 for agree, 0 for disagree
  int? isAgree;  // 1 for agree, 0 for disagree
  int? isSigned;  // 1 for isSigned, 0 for isSigned
  String? comment;
  String? type;
  String? createdAt;
  String? updatedAt;

  MemberPivotCompetition({
    this.competitionId,
    this.memberId,
    this.agree,
    this.isAgree,
    this.isSigned,
    this.comment,
    this.type,
    this.createdAt,
    this.updatedAt,
  });

  factory MemberPivotCompetition.fromJson(Map<String, dynamic> json) {
    return MemberPivotCompetition(
      competitionId: json['competition_id'],
      memberId: json['member_id'],
      agree: json['agree'],
      type: json['type'],
      isAgree: json['is_agree'],
      isSigned: json['is_signed'],
      comment: json['comment'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
    );
  }
}