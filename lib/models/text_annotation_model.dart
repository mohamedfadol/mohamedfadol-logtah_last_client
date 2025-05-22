import 'package:diligov_members/models/agenda_model.dart';
import 'package:diligov_members/models/business_model.dart';
import 'package:diligov_members/models/user.dart';

class TextAnnotationList {
  List<TextAnnotationModel>? notes;
  TextAnnotationList.fromJson(Map<String, dynamic> json) {
    if (json['notes'] != null) {
      notes = <TextAnnotationModel>[];
      json['notes'].forEach((v) {
        notes!.add(TextAnnotationModel.fromJson(v));
      });
    }
  }
}

class TextAnnotationModel {
  int? textId;
  String? textNote;
  int? textAnnotationId;
  int? pageIndexTextAnnotation;
  double? positionDx;
  double? positionDy;
  int? isPrivate;
  User? user;
  Agenda? agenda;
  Business? business;
  String? fileEdited;
  String? createdAt;
  bool isClicked = false;

  TextAnnotationModel(
      {required this.textId,
      required this.textNote,
      required this.textAnnotationId,
        required this.pageIndexTextAnnotation,
        required this.positionDx,
        required this.positionDy,
      required this.user,
      required this.agenda,
      required this.business,
      required this.fileEdited,
      required this.isPrivate,
        required this.createdAt,});

  TextAnnotationModel.fromJson(Map<String, dynamic> json) {
    textId = json['id'];
    textAnnotationId = json['annotation_id'];
    textNote = json['note'];
    pageIndexTextAnnotation = json['page_index'];
    positionDx = json['positionDx'];
    positionDy = json['positionDy'];
    isPrivate = json['isPrivate'];
    fileEdited = json['file_edited'];
    createdAt = json['created_at'];
    business = json['business'] != null ? Business.fromJson(json['business']) : null;
    agenda = json['agenda'] != null ? Agenda.fromJson(json['agenda']) : null;
    user = json['user'] != null ? User.fromJson(json['user']) : null;
  }
}
