import 'package:flutter/material.dart';
import 'package:pie_chart/pie_chart.dart';

import 'dart:typed_data';
import 'package:flutter/rendering.dart';
import 'dart:ui' as ui;

import '../../../models/action_tracker_model.dart';


class PieChartWidget extends StatelessWidget {
final Map<String, double> data;
final double chartRadius;

PieChartWidget({required this.data, this.chartRadius = 150.0});

@override
Widget build(BuildContext context) {
  return Container(
    width: chartRadius * 2, // Width is double the radius
    height: chartRadius * 2, // Height is double the radius
    child: PieChart(
      dataMap: data,
      chartType: ChartType.disc,

      ringStrokeWidth: 32,
      colorList: statusColors.values.toList(),
      chartLegendSpacing: 32,
      // chartRadius: MediaQuery.of(context).size.width / 3.2,
      legendOptions: LegendOptions(
          showLegends: true,

      ),
      chartValuesOptions: ChartValuesOptions(
          showChartValuesInPercentage: true,
        showChartValueBackground: true,
        showChartValues: true,

      ),
    ),
  );
}
}


Map<String, double> prepareChartData(Map<String, Map<String, dynamic>> statusCounts) {
  const double minNonZeroValue = 1.0; // Use a value small enough to not distort the chart
  Map<String, double> chartData = {};
  statusLabels.forEach((status) {
    double count = (statusCounts[status]?['count'] ?? 0.0).toDouble();
    chartData[status] = count > 0 ? count : minNonZeroValue;
  });
  return chartData;
}


 Future<Uint8List> capturePng(GlobalKey key) async {
try {
RenderRepaintBoundary boundary = key.currentContext!.findRenderObject() as RenderRepaintBoundary;
ui.Image image = await boundary.toImage(pixelRatio: 3.0);
ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
return byteData!.buffer.asUint8List();
} catch (e) {
print(e);
throw Exception('Error capturing image: $e');
}
}



class CaptureChartWidget extends StatefulWidget {
final Map<String, double> data;
final List<Color> colorList;

CaptureChartWidget({required this.data, required this.colorList});

@override
_CaptureChartWidgetState createState() => _CaptureChartWidgetState();
}

class _CaptureChartWidgetState extends State<CaptureChartWidget> {
  GlobalKey globalKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      key: globalKey,
      child: PieChartWidget(data: widget.data),
    );
  }

  Future<Uint8List> captureChartImage() async {
    return await capturePng(globalKey);
  }
}