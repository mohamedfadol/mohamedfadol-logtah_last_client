import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../canvas_item.dart';
import '../drawing_painter.dart';

class ShowDraggableCanvas extends StatefulWidget {
  final CanvasItem item;
  final int canvasPageIndex;

  const ShowDraggableCanvas(
      {Key? key,
      required this.item,
      required this.canvasPageIndex
      })
      : super(key: key);

  @override
  _ShowDraggableCanvasState createState() => _ShowDraggableCanvasState();
}

class _ShowDraggableCanvasState extends State<ShowDraggableCanvas> {

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: widget.item.position!.dx,
      top: widget.item.position!.dy,
      child: AnimatedContainer(
        width: 200 * widget.item.canvasWidth!,
        height: 200 * widget.item.canvasHeight!,
        duration: Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        decoration: BoxDecoration(
          // border: Border.all(color: Colors.black, width: 0.5),
        ),
        child: ClipRect(
          child: CustomPaint(
            painter: DrawingPainter(
                strokes: widget.item.strokes!,
                currentPageIndex: widget.item.pageIndex!),
          ),
        ),
      ),
    );
  }

}
