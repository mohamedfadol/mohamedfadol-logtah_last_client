import 'package:flutter/material.dart';
import '../../widgets/appBar.dart';
import '../../widgets/calendar_widget.dart';
class CalendarPage extends StatefulWidget {
  const CalendarPage({Key? key}) : super(key: key);
  static const routeName = '/CalendarPage';


  @override
  State<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: Header(context),
    body: const CalendarWidget(),
  );
}
