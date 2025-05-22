import 'package:flutter/animation.dart';

import 'package:flutter/material.dart';

import '../models/agenda_model.dart';
import '../models/user.dart';

class TextAnnotationList {
  List<TextAnnotation>? notes;
  TextAnnotationList.fromJson(Map<String, dynamic> json) {
    if (json['notes'] != null) {
      notes = <TextAnnotation>[];
      json['notes'].forEach((v) {
        notes!.add(TextAnnotation.fromJson(v));
      });
    }
  }
}

class TextAnnotation {
  late final Offset position;
  String? text;
  int? id;
  Color? color;
  int? pageIndex;
  double? positionDx;
  double? positionDy;
  bool? isPrivate;
  User? user;
  Agenda? agenda;
  String? fileEdited;
  String? createdAt;
  bool isClicked = false;

  TextAnnotation({required this.position, required this.text, required this.id, required this.color, required this.pageIndex,this.positionDx,this.positionDy, required bool isPrivate,});

  TextAnnotation.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    text = json['note'];
    color = json['annotation_color'] != null ? Color(json['annotation_color']) : null;
    pageIndex = json['page_index'];
    positionDx = json['position_dx']?.toDouble();
    positionDy = json['position_dy']?.toDouble();
    // Check if positionDx and positionDy are not null before creating the Offset
    if (positionDx != null && positionDy != null) {
      position = Offset(positionDx!, positionDy!);
    } else {
      position = Offset.zero;
    }
    isPrivate = json['is_private'];
    fileEdited = json['file_edited'];
    createdAt = json['created_at'];
    agenda = json['agenda'] != null ? Agenda.fromJson(json['agenda']) : null;
    user = json['user'] != null ? User.fromJson(json['user']) : null;
  }

}
