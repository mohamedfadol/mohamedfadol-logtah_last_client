class Attendance {
  int? AttendanceId;
  int? agendaId;
  String? name;
  String? position;
  String? nameAr;
  String? positionAr;

  Attendance({this.AttendanceId,this.name,this.agendaId, this.position, this.nameAr,this.positionAr});

  factory Attendance.fromJson(Map<String, dynamic> json) {
    return Attendance(
      AttendanceId: json['id'],
      agendaId: json['agenda_id'],
      name: json['attended_name'],
      position: json['position'],
      positionAr: json['position_ar'],
      nameAr: json['attended_name_ar'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data['attended_name'] = name;
    data['agenda_id'] = agendaId;
    data['position'] = position;
    data['position_ar'] = positionAr;
    data['attended_name_ar'] = nameAr;
    return data;
  }
}