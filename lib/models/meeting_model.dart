import 'package:diligov_members/models/board_model.dart';
import 'package:diligov_members/models/committee_model.dart';
import 'package:diligov_members/models/member.dart';
import 'package:diligov_members/models/minutes_model.dart';
import 'package:diligov_members/models/user.dart';
import 'package:flutter/material.dart';

import 'agenda_model.dart';

class Meetings {
  List<Meeting>? meetings;
  Meetings.fromJson(Map<String, dynamic> json) {
    if (json['meetings'] != null) {
      meetings = <Meeting>[];
      json['meetings'].forEach((v) {
        meetings!.add(Meeting.fromJson(v));
      });
    }
  }

}

class Meeting {
  int? meetingId;
  String? meetingTitle;
  String? meetingDescription;
  DateTime? meetingStart;
  DateTime? meetingEnd;
  String? meetingBy;
  String? meetingMediaName;
  String? meetingStatus;
  String? meetingPublishedStatus;
  String? meetingSerialNumber;
  String? meetingFile;
  bool isActive = false;
  bool isAllDays = false;
  int? createdBy;
  bool? hasNextMeeting;
  bool? isVisible;
  int? previousMeetingId;
  Color backGroundColor   = Colors.blue;
  Board? board;
  User? user;
  bool? isExpanded = false;
  bool isClicked = false;
  int? isAttended ;
  Committee? committee;
  List<Agenda>? agendas;
  List<Minute>? minutes;
  String? meetingStartDate;
  String? meetingEndDate;
  List<Member>? attendances;
  MemberMeetingPivot? pivot;

  Meeting(
      {this.meetingId,
        this.meetingStartDate,
        this.meetingEndDate,
        this.meetingTitle,
        this.attendances,
        this.meetingDescription,
        this.meetingStart,
        this.meetingEnd,
        this.meetingBy,
        this.meetingMediaName,
        this.meetingStatus,
        this.meetingPublishedStatus,
        this.meetingSerialNumber,
        this.meetingFile,
        this.createdBy,
        this.board,
        this.committee,
        this.agendas,
        this.user,
        this.hasNextMeeting,
        this.isVisible,
        this.pivot,
        this.minutes,
        this.isAttended,
        this.previousMeetingId});

  Meeting.fromJson(Map<String, dynamic> json) {
    meetingId = json['id'];
    meetingTitle = json['meeting_title'];
    meetingDescription = json['meeting_description'];
    meetingStart =  DateTime.tryParse(json['meeting_start']) ;
    meetingEnd = DateTime.tryParse(json['meeting_end']);
    meetingStartDate = json['meeting_start_date'];
    meetingEndDate = json['meeting_end_date'];
    meetingBy = json['meeting_by'];
    meetingMediaName = json['meeting_media_name'];
    isVisible = json['is_visible'];
    isAttended = json['is_attended'];
    meetingStatus = json['meeting_status'];
    meetingPublishedStatus = json['meeting_published'];
    meetingSerialNumber = json['meeting_serial_number'];
    meetingFile = json['meeting_file'];
    isAllDays = json['is_all_days']  = false;
    isActive = json['is_active'] = false;
    if (json['attendances'] != null) {
      attendances = <Member>[];
      json['attendances'].forEach((v) {
        attendances!.add(Member.fromJson(v));
      });
    }

    createdBy = json['created_by'];
    hasNextMeeting = json['hasNextMeeting'];
    previousMeetingId = json['previous_meeting_id'];
    board = json['board'] != null ? Board.fromJson(json['board']) : null;
    committee = json['committee'] != null ? Committee.fromJson(json['committee']) : null;
    user = json['user'] != null ? User.fromJson(json['user']) : null;
    if (json['agendas'] != null) {
      agendas = <Agenda>[];
      json['agendas'].forEach((v) {
        agendas!.add(Agenda.fromJson(v));
      });
    }
    if (json['pivot'] != null) {
      pivot = MemberMeetingPivot.fromJson(json['pivot']);
    }

    if (json['attendances'] != null) {
      attendances = <Member>[];
      json['attendances'].forEach((v) {
        attendances!.add(Member.fromJson(v));
      });
    }

  }


  Map<String, dynamic> toJson() {
    return {
      'id': meetingId,
      'meeting_title': meetingTitle,
      'meeting_description': meetingDescription,
      'meeting_start': meetingStart?.toIso8601String(),
      'meeting_end': meetingEnd?.toIso8601String(),
      'meeting_start_date': meetingStartDate,
      'meeting_end_date': meetingEndDate,
      'meeting_by': meetingBy,
      'meeting_media_name': meetingMediaName,
      'meeting_status': meetingStatus,
      'meeting_puplished': meetingPublishedStatus,
      'meeting_serial_number': meetingSerialNumber,
      'meeting_file': meetingFile,
      'is_active': isActive,
      'is_all_days': isAllDays,
      'created_by': createdBy,
      'hasNextMeeting': hasNextMeeting,
      'is_visible': isVisible,
      'previous_meeting_id': previousMeetingId,
      'board': board?.toJson(),
      'committee': committee?.toJson(),
      'user': user?.toJson(),
      'agendas': agendas?.map((a) => a.toJson()).toList(),
      'minutes': minutes?.map((m) => m.toJson()).toList(),
      'attendances' : attendances!.map((v) => v.toJson()).toList(),
      // 'pivot' : pivot!.toJson()
    };
  }

}

// Add missing MemberMeetingPivot class if not imported
class MemberMeetingPivot {
  int? meetingId;
  int? memberId;
  bool? isAttended;
  String? createdAt;
  String? updatedAt;

  MemberMeetingPivot({
    this.meetingId,
    this.memberId,
    this.isAttended,
    this.createdAt,
    this.updatedAt,
  });

  factory MemberMeetingPivot.fromJson(Map<String, dynamic> json) {
    return MemberMeetingPivot(
      meetingId: json['meeting_id'],
      memberId: json['member_id'],
      isAttended: json['is_attended'] == 1 || json['is_attended'] == true,
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'meeting_id': meetingId,
      'member_id': memberId,
      'is_attended': isAttended,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }
}
