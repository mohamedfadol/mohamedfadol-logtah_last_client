import 'package:diligov_members/models/meeting_model.dart';

class PreviewMeetingModel{
  int? previewMeetingId;
  String? reviewMeetingFileName;
  String? filePath;
  Meeting? meeting;

  PreviewMeetingModel(
      {this.previewMeetingId,
        this.reviewMeetingFileName,
        this.filePath,
        this.meeting});

  PreviewMeetingModel.fromJson(Map<String, dynamic> json) {
    previewMeetingId = json['id'];
    reviewMeetingFileName = json['file_name'];
    filePath = json['file_path'];
    meeting = json['meeting'] != null ? Meeting?.fromJson(json['meeting']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data =  Map<String, dynamic>();
    data['id'] = previewMeetingId;
    data['file_name'] = reviewMeetingFileName;
    data['file_path'] = filePath;
    data['meeting'] = meeting;
    return data;
  }
}