class MeetingAttendancePivot {
  bool? isAttended;

  MeetingAttendancePivot({this.isAttended});

  MeetingAttendancePivot.fromJson(Map<String, dynamic> json) {
    // Handles both boolean and integer values (1/0)
    isAttended = json['is_attended'] == 1 || json['is_attended'] == true;
  }
}