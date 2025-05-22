import 'package:diligov_members/models/business_model.dart';
import 'package:diligov_members/models/committee_model.dart';
import 'package:diligov_members/models/member.dart';
import 'package:diligov_members/models/board_model.dart';

class Remunerations {
  List<Remuneration>? remunerations;

  Remunerations({this.remunerations});

  Remunerations.fromJson(Map<String, dynamic> json) {
    if (json['remunerations'] != null) {
      remunerations = <Remuneration>[];
      json['remunerations'].forEach((v) {
        remunerations!.add(Remuneration.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (remunerations != null) {
      data['remunerations'] = remunerations!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Remuneration {
  int? remunerationId;
  String? quarter;
  String? membershipFees;
  String? attendanceFees;
  Business? business;
  Committee? committee;
  Board? board;  // Added board field
  String? createdAt;
  String? updatedAt;
  String? entityType;  // 'committee' or 'board'

  Remuneration({
    this.remunerationId,
    this.quarter,
    this.membershipFees,
    this.attendanceFees,
    this.business,
    this.committee,
    this.board,
    this.createdAt,
    this.updatedAt,
    this.entityType,
  });

  Remuneration.fromJson(Map<String, dynamic> json) {
    remunerationId = json['id'];
    quarter = json['quarter'];
    membershipFees = json['membership_fees'];
    attendanceFees = json['attendance_fees'];

    // Fix for business parsing
    business = json['business'] != null ? Business.fromJson(json['business']) : null;

    // Fix for committee parsing
    if (json['committee'] != null) {
      committee = Committee.fromJson(json['committee']);
      entityType = 'committee';
    }

    // Fix for board parsing
    if (json['board'] != null) {
      board = Board.fromJson(json['board']);
      entityType = 'board';
    }

    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = remunerationId;
    data['quarter'] = quarter;
    data['membership_fees'] = membershipFees;
    data['attendance_fees'] = attendanceFees;
    data['entity_type'] = entityType;

    // if (business != null) {
    //   data['business'] = business!.toJson();
    // }

    if (committee != null) {
      data['committee'] = committee!.toJson();
    }

    if (board != null) {
      data['board'] = board!.toJson();
    }

    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    return data;
  }

  // Get total meetings in the entity (committee or board)
  int get totalMeetings {
    if (entityType == 'committee') {
      return committee?.meetings?.length ?? 0;
    } else if (entityType == 'board') {
      return board?.meetings?.length ?? 0;
    }
    return 0;
  }

  // Get attended meetings for all members in the entity
  Map<int, int> get memberAttendance {
    Map<int, int> attendance = {};

    if (entityType == 'committee' && committee?.members != null) {
      for (var member in committee!.members!) {
        int memberId = member.memberId ?? 0;
        int attendedCount = 0;

        // Check the member's attendance from their meetingAttendances list
        if (member.meetingAttendances != null) {
          for (var meetingAttendance in member.meetingAttendances!) {
            // Check if this meeting belongs to the current committee and if member attended
            if (meetingAttendance.committee?.id == committee?.id &&
                meetingAttendance.pivot?.isAttended == true) {
              attendedCount++;
            }
          }
        }

        attendance[memberId] = attendedCount;
      }
    } else if (entityType == 'board' && board?.members != null) {
      for (var member in board!.members!) {
        int memberId = member.memberId ?? 0;
        int attendedCount = 0;

        // Check the member's attendance from their boardMeetingAttendances list
        if (member.boardMeetingAttendances != null) {
          for (var boardMeetingAttendance in member.boardMeetingAttendances!) {
            // Check if this meeting belongs to the current board and if member attended
            if (boardMeetingAttendance.board?.boarId == board?.boarId &&
                boardMeetingAttendance.pivot?.isAttended == true) {
              attendedCount++;
            }
          }
        }

        attendance[memberId] = attendedCount;
      }
    }

    return attendance;
  }

  // Calculate pro-rated membership fee for a specific member
  double getProRatedMembershipFee(int memberId) {
    if (totalMeetings == 0) return 0;

    double annualFee = double.tryParse(membershipFees ?? '0') ?? 0;
    double perMeetingFee = annualFee / totalMeetings;
    int attended = memberAttendance[memberId] ?? 0;

    return perMeetingFee * attended;
  }

  // Calculate attendance fee for a specific member
  double getAttendanceFee(int memberId) {
    double feePerMeeting = double.tryParse(attendanceFees ?? '0') ?? 0;
    int attended = memberAttendance[memberId] ?? 0;

    return feePerMeeting * attended;
  }

  // Calculate total remuneration for a specific member
  double getTotalRemuneration(int memberId) {
    return getProRatedMembershipFee(memberId) + getAttendanceFee(memberId);
  }

  // Get entity name (committee or board name)
  String get entityName {
    if (entityType == 'committee') {
      return committee?.committeeName ?? 'Unknown Committee';
    } else if (entityType == 'board') {
      return board?.boardName ?? 'Unknown Board';
    }
    return 'Unknown Entity';
  }

  // Get entity members
  List<Member> get members {
    if (entityType == 'committee' && committee?.members != null) {
      return committee!.members!;
    } else if (entityType == 'board' && board?.members != null) {
      return board!.members!;
    }
    return [];
  }
}