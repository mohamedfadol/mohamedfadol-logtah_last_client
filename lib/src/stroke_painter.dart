// import 'package:diligov/src/stroke.dart';
// import 'package:flutter/material.dart';
//
// class StrokePainter extends CustomPainter {
//   final List<Stroke> strokes;
//   Color selectedColor;
//   double currentPenWidth;
//   final int currentPageIndex;
//   StrokePainter({required this.strokes, required this.selectedColor, required this.currentPenWidth, required this.currentPageIndex});
//
//   @override
//   void paint(Canvas canvas, Size size) {
//     final currentPageStrokes = strokes.where((stroke) => stroke.pageIndex == currentPageIndex).toList();
//     // print(currentPageStrokes);
//     for (final stroke in currentPageStrokes) {
//       var paint = Paint()
//         ..color = selectedColor
//         ..strokeWidth = currentPenWidth
//          ..style = PaintingStyle.stroke;
//
//       var path = Path();
//       if (stroke.points.isNotEmpty) {
//         path.moveTo(stroke.points.first.dx, stroke.points.first.dy);
//         for (var point in stroke.points) {
//           path.lineTo(point.dx, point.dy);
//         }
//       }
//       canvas.drawPath(path, paint);
//     }
//   }
//
//   @override
//   bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
// }
