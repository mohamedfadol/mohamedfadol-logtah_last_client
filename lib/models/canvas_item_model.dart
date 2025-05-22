import 'package:diligov_members/src/stroke.dart';
import 'package:flutter/material.dart';

class CanvasItemModel {
  int? canvasId;
  int? canvasItemId;
  int? agendaId;
  Offset? positionDx;
  Offset? positionDy;
  List<Stroke>? strokes;

  CanvasItemModel({
    required this.canvasId,
    required this.agendaId,
    required this.canvasItemId,
    required this.positionDx,
    required this.positionDy,
    required this.strokes,
  });


   CanvasItemModel.fromJson(Map<String, dynamic> json) {
      canvasId= json['id'];
      agendaId = json['agenda_id'];
      canvasItemId= json['canva_id'];
      positionDx= json['position_dx']!= null ? Offset.fromDirection(json['position_dx'].toDouble(), 0) : null;
      positionDy= json['position_dy']!= null ? Offset.fromDirection(json['position_dy'].toDouble(), 0) : null;
      if (json['strokes'] != null) {
        strokes = <Stroke>[];
        json['strokes'].forEach((v) {
          strokes!.add(Stroke.fromMap(v));
        });
      }
   }

  // CanvasItemModel.fromJson(Map<String, dynamic> json) {
  //   canvasId = json['canvas_id'] as int?;
  //   agendaId = json['agenda_id'] as int?;
  //   canvasItemId = json['canvas_item_id'] as int?;
  //   positionDx = json['position_dx'] != null ? Offset.fromDirection(json['position_dx'].toDouble(), 0) : null;
  //   positionDy = json['position_dy'] != null ? Offset.fromDirection(json['position_dy'].toDouble(), 0) : null;
  //   strokes = json['strokes'] != null ? List<Stroke>.from(json['strokes'].map((v) => Stroke.fromMap(v))) : null;
  // }

  Map<String, dynamic> toMap() {
    return {
      'canvas_id': canvasId,
      'canvas_item_id': canvasItemId,
      'agenda_id': agendaId,
      'position_dx': positionDx != null ? positionDx!.dx : null,
      'position_dy': positionDy != null ? positionDy!.dy : null,
      'strokes': strokes?.map((stroke) => stroke.toMap()).toList(),
    };
  }

}