
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
class Stroke {
  List<Offset> points;
  // Paint paint;
  final Offset position;
  int pageIndex;
  int canvasId;
  Color strokeColor;
  double strokeWidth;
  StrokeCap strokeCap; // Added to manage stroke cap style
  Stroke({required this.points,required this.canvasId, required this.pageIndex,required this.position, required this.strokeColor, required this.strokeWidth,this.strokeCap = StrokeCap.round,});


// Convert a Stroke object into a Map object
  Map<String, dynamic> toMap() {
    return {
      'points': points.map((point) => {'dx': point.dx, 'dy': point.dy}).toList(),
      'position': {'dx': position.dx, 'dy': position.dy},
      'page_index': pageIndex,
      'stroke_color': strokeColor.value,
      'stroke_width': strokeWidth,
      'canva_id': canvasId,
      'stroke_cap': strokeCap.toString().split('.').last, // Serialize StrokeCap as a string
    };
  }

  static List<Map<String, dynamic>> strokesToJson(List<Stroke> strokes) {
    return strokes.map((stroke) => stroke.toMap()).toList();
  }
  // Construct a Stroke from a Map object
  factory Stroke.fromMap(Map<String, dynamic> map) {
    // Parse points from the map
    // List<Offset> points = [Offset((map['points']['dx']).toDouble(), (map['points']['dy']).toDouble())];
    List<Offset> points = (map['points'] as List).map((point) => Offset(point['dx'].toDouble(),point['dy'].toDouble(),)).toList();
    // Parse position from the map
    Offset position = Offset((map['position']['dx']).toDouble(), (map['position']['dy']).toDouble());
    return Stroke(
      canvasId: map['canvas_item_id'],
      points: points,
      position: position,
      pageIndex: map['page_index'],
      strokeColor:   Color(2147483649),//Color(map['stroke_color']), //2147483649
      strokeWidth: map['stroke_width'].toDouble(),
      strokeCap: StrokeCap.values.firstWhere(
            (e) => e.toString() == 'StrokeCap.' + map['stroke_cap'],
        orElse: () => StrokeCap.round, // Default value if not found
      ),
    );
  }




}