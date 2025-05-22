import 'package:diligov_members/models/meeting_model.dart';
import 'package:diligov_members/models/member.dart';

class MeetingAttendancesData {

}

class MeetingAttendance {

  int? AttendanceId;
  Meeting? meeting;
  Member? member;
  MemberMeetingPivot? pivot;

  MeetingAttendance({this.AttendanceId,this.member,this.meeting , this.pivot});

  factory MeetingAttendance.fromJson(Map<String, dynamic> json) {
    return MeetingAttendance(
      AttendanceId: json['id'],
      meeting: json['agenda_id'],
      member: json['attended_name'],
    );
  }
}