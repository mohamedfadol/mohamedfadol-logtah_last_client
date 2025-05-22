import 'package:diligov_members/src/stroke.dart';
import 'package:flutter/material.dart';

class CanvasItem {
  late final int? id;
  Offset? position;
  List<Stroke>? strokes;
  double? penWidth;
  double? canvasWidth;
  double? canvasHeight;
  Color? color;
  int? pageIndex;
  late bool? isDraggable;

  CanvasItem({
    required this.id,
    required this.position,
    required this.strokes,
    required this.penWidth,
    required this.canvasWidth,
    required this.canvasHeight,
    required this.color,
    this.pageIndex = 0,
    this.isDraggable = true,
  });

  Map<String, dynamic> toMap() {
    return {
      'canva_id': id,
      'position_dx': position!.dx != null ? position!.dx : null,
      'position_dy': position != null ? position!.dy : null,
      'canvas_width': canvasWidth,
      'canvas_height': canvasHeight,
      'page_index': pageIndex,
      'strokes': strokes?.map((stroke) => stroke.toMap()).toList(),
    };
  }

  CanvasItem.fromJson(Map<String, dynamic> json) {
    List<Stroke> strokesList = (json['strokes'] as List).map((strokeMap) => Stroke.fromMap(strokeMap)).toList();
      id = json['canva_id'];
      position = Offset(json['position_dx'].toDouble(), json['position_dy'].toDouble());
      strokes = strokesList;
      canvasWidth = json['canvas_width'].toDouble();
      canvasHeight = json['canvas_height'].toDouble();
      pageIndex = json['page_index'] ?? 0;
      isDraggable = json['is_draggable'] ?? true;

  }


  void updateWidthScale(double scale) {
    canvasWidth = scale;
  }

  void updateHeightScale(double scale) {
    canvasHeight = scale;
  }

  // Method to clear all strokes from this canvas item
  // void clearStrokes() {
  //   strokes!.clear();
  // }

  // void undoLastStroke() {
  //   if (strokes!.isNotEmpty) {
  //     if (strokes!.last.points.isNotEmpty) {
  //       strokes!.last.points.removeLast();
  //       if (strokes!.last.points.isEmpty) {
  //         strokes!.removeLast();
  //       }
  //     } else {
  //       strokes!.removeLast();
  //     }
  //   }
  // }

  // void toggleDraggable() {
  //   isDraggable = !isDraggable;
  // }

}