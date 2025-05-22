import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';


import 'dart:typed_data';
import 'package:flutter/rendering.dart';
import 'dart:ui' as ui;

class BarChartWidget extends StatelessWidget {
  final Map<String, double> data;
  final List<Color> colorList;

  BarChartWidget({required this.data, required this.colorList});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 500,
      height: 500,
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          maxY: data.values.reduce((a, b) => a > b ? a : b) + 10,
          barTouchData: BarTouchData(enabled: false),
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(
              sideTitles: SideTitles(showTitles: true),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  return Text(data.keys.elementAt(value.toInt()));
                },
              ),
            ),
          ),
          borderData: FlBorderData(show: false),
          barGroups: data.entries
              .map(
                (e) => BarChartGroupData(
              x: data.keys.toList().indexOf(e.key),
              barRods: [
                BarChartRodData(
                  toY: e.value,
                  color: colorList[data.keys.toList().indexOf(e.key) % colorList.length],
                )
              ],
            ),
          )
              .toList(),
        ),
      ),
    );
  }
}


Future<Uint8List> capturePngBar(GlobalKey globalKey) async {
  RenderRepaintBoundary boundary = globalKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
  ui.Image image = await boundary.toImage(pixelRatio: 3.0);
  ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
  return byteData!.buffer.asUint8List();
}


class CaptureChartWidgetBar extends StatefulWidget {
  final Map<String, double> data;
  final List<Color> colorList;

  CaptureChartWidgetBar({required this.data, required this.colorList});

  @override
  _CaptureChartWidgetBarState createState() => _CaptureChartWidgetBarState();
}

class _CaptureChartWidgetBarState extends State<CaptureChartWidgetBar> {
  GlobalKey globalKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: RepaintBoundary(
          key: globalKey,
          child: BarChartWidget(data: widget.data, colorList: widget.colorList),
        ),
      ),
    );
  }

  Future<Uint8List> captureChartImage() async {
    return await capturePngBar(globalKey);
  }
}