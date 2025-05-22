import 'package:logger/logger.dart';
import 'package:diligov_members/models/committee_model.dart';
import 'package:diligov_members/models/member.dart';
import '../models/board_model.dart';

class AttendanceTrackerService {
  final Logger log = Logger();

  /// Calculate attendance statistics for a member across all meetings
  Map<String, dynamic> calculateMemberAttendanceStats(Member member, {bool includeCommittees = true}) {
    int totalMeetings = 0;
    int attendedMeetings = 0;

    // Check board meeting attendance if member has board attendance data
    if (member.boardMeetingAttendances != null && member.boardMeetingAttendances!.isNotEmpty) {
      for (var meeting in member.boardMeetingAttendances!) {
        totalMeetings++;
        if (meeting.pivot?.isAttended == true) {
          attendedMeetings++;
        }
      }
    }

    // Check committee meeting attendance if includeCommittees is true
    if (includeCommittees && member.meetingAttendances != null && member.meetingAttendances!.isNotEmpty) {
      for (var meeting in member.meetingAttendances!) {
        totalMeetings++;
        if (meeting.pivot?.isAttended == true) {
          attendedMeetings++;
        }
      }
    }

    double attendanceRate = totalMeetings > 0 ? (attendedMeetings / totalMeetings) * 100 : 0;

    return {
      'totalMeetings': totalMeetings,
      'attended': attendedMeetings,
      'attendanceRate': attendanceRate,
    };
  }

  /// Calculate attendance for all members in a committee
  Map<int, int> calculateCommitteeMemberAttendance(Committee committee) {
    Map<int, int> attendance = {};

    if (committee.members == null || committee.meetings == null) return attendance;

    // Initialize attendance count for each member
    for (var member in committee.members!) {
      int memberId = member.memberId ?? 0;
      attendance[memberId] = 0;
    }

    // Count attendance by checking individual member's meeting attendances
    for (var member in committee.members!) {
      int memberId = member.memberId ?? 0;
      int attendedCount = 0;

      if (member.meetingAttendances != null) {
        for (var meeting in member.meetingAttendances!) {
          // Check if this meeting belongs to the current committee and if member attended
          if (meeting.committee?.id == committee.id &&
              meeting.pivot?.isAttended == true) {
            attendedCount++;
          }
        }
      }

      attendance[memberId] = attendedCount;
    }

    return attendance;
  }

  /// Calculate attendance for all members in a board
  Map<int, int> calculateBoardMemberAttendance(Board board) {
    Map<int, int> attendance = {};

    if (board.members == null || board.meetings == null) return attendance;

    // Initialize attendance count for each member
    for (var member in board.members!) {
      int memberId = member.memberId ?? 0;
      attendance[memberId] = 0;
    }

    // Count attendance by checking individual member's board meeting attendances
    for (var member in board.members!) {
      int memberId = member.memberId ?? 0;
      int attendedCount = 0;

      if (member.boardMeetingAttendances != null) {
        for (var meeting in member.boardMeetingAttendances!) {
          // Check if this meeting belongs to the current board and if member attended
          if (meeting.board?.boarId == board.boarId &&
              meeting.pivot?.isAttended == true) {
            attendedCount++;
          }
        }
      }

      attendance[memberId] = attendedCount;
    }

    return attendance;
  }

  /// Calculate remuneration for all members in a committee based on attendance
  Map<int, double> calculateCommitteeRemuneration(
      Committee committee,
      double membershipFee,
      double attendanceFee
      ) {
    Map<int, double> remuneration = {};

    if (committee.members == null) return remuneration;

    // Get attendance counts
    Map<int, int> attendance = calculateCommitteeMemberAttendance(committee);
    int totalMeetings = committee.meetings?.length ?? 0;

    // Calculate remuneration for each member
    for (var member in committee.members!) {
      int memberId = member.memberId ?? 0;
      int attendedCount = attendance[memberId] ?? 0;

      // Calculate prorated membership fee
      double proratedMembershipFee = 0;
      if (totalMeetings > 0) {
        proratedMembershipFee = (membershipFee / totalMeetings) * attendedCount;
      }

      // Calculate attendance fee
      double totalAttendanceFee = attendanceFee * attendedCount;

      // Calculate total remuneration
      double totalRemuneration = proratedMembershipFee + totalAttendanceFee;

      remuneration[memberId] = totalRemuneration;
    }

    return remuneration;
  }

  /// Calculate remuneration for all members in a board based on attendance
  Map<int, double> calculateBoardRemuneration(
      Board board,
      double membershipFee,
      double attendanceFee
      ) {
    Map<int, double> remuneration = {};

    if (board.members == null) return remuneration;

    // Get attendance counts
    Map<int, int> attendance = calculateBoardMemberAttendance(board);
    int totalMeetings = board.meetings?.length ?? 0;

    // Calculate remuneration for each member
    for (var member in board.members!) {
      int memberId = member.memberId ?? 0;
      int attendedCount = attendance[memberId] ?? 0;

      // Calculate prorated membership fee
      double proratedMembershipFee = 0;
      if (totalMeetings > 0) {
        proratedMembershipFee = (membershipFee / totalMeetings) * attendedCount;
      }

      // Calculate attendance fee
      double totalAttendanceFee = attendanceFee * attendedCount;

      // Calculate total remuneration
      double totalRemuneration = proratedMembershipFee + totalAttendanceFee;

      remuneration[memberId] = totalRemuneration;
    }

    return remuneration;
  }

  /// Get detailed remuneration breakdown for a specific member
  Map<String, dynamic> getMemberRemunerationBreakdown(
      int memberId,
      double membershipFee,
      double attendanceFee,
      int totalMeetings,
      int attendedMeetings
      ) {
    // Calculate prorated membership fee
    double proratedMembershipFee = 0;
    if (totalMeetings > 0) {
      proratedMembershipFee = (membershipFee / totalMeetings) * attendedMeetings;
    }

    // Calculate attendance fee
    double totalAttendanceFee = attendanceFee * attendedMeetings;

    // Calculate total remuneration
    double totalRemuneration = proratedMembershipFee + totalAttendanceFee;

    return {
      'memberId': memberId,
      'totalMeetings': totalMeetings,
      'attendedMeetings': attendedMeetings,
      'attendanceRate': totalMeetings > 0 ? (attendedMeetings / totalMeetings) * 100 : 0,
      'membershipFee': membershipFee,
      'proratedMembershipFee': proratedMembershipFee,
      'attendanceFeePerMeeting': attendanceFee,
      'totalAttendanceFee': totalAttendanceFee,
      'totalRemuneration': totalRemuneration,
    };
  }
}