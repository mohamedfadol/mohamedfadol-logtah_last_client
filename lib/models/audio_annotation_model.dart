import 'package:diligov_members/models/agenda_model.dart';
import 'package:diligov_members/models/business_model.dart';
import 'package:diligov_members/models/user.dart';

class AudioAnnotationList {
  List<AudioAnnotationModel>? audios;
  AudioAnnotationList.fromJson(Map<String, dynamic> json) {
    if (json['audio_notes'] != null) {
      audios = <AudioAnnotationModel>[];
      json['audio_notes'].forEach((v) {
        audios!.add(AudioAnnotationModel.fromJson(v));
      });
    }
  }
}

class AudioAnnotationModel {
  int? audioId;
  String? audioNoteName;
  String? audioNoteRandomName;
  int? audioAnnotationId;
  int? audioPageIndex;
  double? positionDx;
  double? positionDy;
  int? isPrivate;
  User? user;
  Agenda? agenda;
  Business? business;
  String? fileEdited;
  String? fileFullPath;
  int? businessId;
  bool isClicked = false;
  AudioAnnotationModel(
      {required this.audioId,
        required this.audioNoteName,
        required this.audioNoteRandomName,
        required this.audioAnnotationId,
        required this.fileFullPath,
        required this.audioPageIndex,
        required this.positionDx,
        required this.positionDy,
        required this.user,
        required this.agenda,
        required this.business,
        required this.fileEdited,
        required this.isPrivate,
        required this.businessId});

  AudioAnnotationModel.fromJson(Map<String, dynamic> json) {
    audioId = json['id'];
    audioAnnotationId = json['audio_id'];
    audioNoteName = json['audio_name'];
    audioNoteRandomName = json['audio_random_name'];
    audioPageIndex = json['page_index'];
    fileFullPath = json['file_full_path'];
    positionDx = json['position_dx'].toDouble();
    positionDy = json['position_dy'].toDouble();
    isPrivate = json['is_private'];
    fileEdited = json['file_edited'];
    businessId = json['business_id'];
    business = json['business'] != null ? Business.fromJson(json['business']) : null;
    agenda = json['agenda'] != null ? Agenda.fromJson(json['agenda']) : null;
    user = json['user'] != null ? User.fromJson(json['user']) : null;
  }
}
