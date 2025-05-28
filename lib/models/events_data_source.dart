import 'dart:ui';

import 'package:diligov_members/models/meeting_model.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';

class EventsDataSource extends CalendarDataSource{

  EventsDataSource(List<Meeting> appointments){
    this.appointments = appointments;
  }

  Meeting getMeeting(int index) => appointments![index] as Meeting;

  @override
  DateTime getStartTime(int index) => getMeeting(index).meetingStart!;

  @override
  DateTime getEndTime(int index) => getMeeting(index).meetingEnd!;

  @override
  String getSubject(int index) {
    final fullTitle = getMeeting(index).meetingTitle ?? '';
    return fullTitle.length > 20 ? '${fullTitle.substring(0, 20)}…' : fullTitle;
  }


  // @override
  Color getColor(int index) => getMeeting(index).backGroundColor!;

  @override
  bool isAllDays(int index) => getMeeting(index).isAllDays;

  @override
  bool isActive(int index) => getMeeting(index).isActive;

  @override
  String? getMeetingDescription(int index) => getMeeting(index).meetingDescription;
}