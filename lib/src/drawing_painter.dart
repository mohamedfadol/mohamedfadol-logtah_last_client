import 'package:diligov_members/src/stroke.dart';
import 'package:flutter/material.dart';
class DrawingPainter extends CustomPainter {
  List<Stroke> strokes;
  final int currentPageIndex;
  DrawingPainter({required this.strokes, required this.currentPageIndex});

  @override
  void paint(Canvas canvas, Size size) {
    final currentPageStrokes = strokes.where((stroke) => stroke.pageIndex == currentPageIndex).toList();

    for (Stroke stroke in currentPageStrokes) {
      Paint paint = Paint()
        ..color = stroke.strokeColor
        ..strokeCap = StrokeCap.round
        ..strokeWidth = stroke.strokeWidth
      // ..blendMode = BlendMode.clear
      ..strokeJoin = StrokeJoin.round
        ..isAntiAlias = true
        ..style = PaintingStyle.stroke;

      Path path = Path();
      if (stroke.points.isNotEmpty) {
        path.moveTo(stroke.points.first.dx, stroke.points.first.dy);
        stroke.points.skip(1).forEach((point) {
          path.lineTo(point.dx, point.dy);
        });
      }

      canvas.drawPath(path, paint);
    }

  }




  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    if (oldDelegate is DrawingPainter) {
      return oldDelegate.strokes != strokes || oldDelegate.currentPageIndex != currentPageIndex;
    }
    return true;
  }



}
