import 'package:diligov_members/models/minutes_model.dart';

class AttendanceDetails {
  int? attendanceBoardId;
  String? attendedName;
  String? attendedNameAr;
  String? position;
  AttendanceDetails({this.attendanceBoardId, this.attendedName,this.attendedNameAr, this.position});

  AttendanceDetails.fromJson(Map<String, dynamic> json) {
    attendanceBoardId= json['id'];
    attendedName= json['attended_name'];
    attendedNameAr= json['attended_name_ar'];
    position= json['position'];
  }
}