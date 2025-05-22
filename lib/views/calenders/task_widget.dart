import 'package:diligov_members/views/calenders/event_viewing_page.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import '../../models/events_data_source.dart';
import '../../providers/meeting_page_provider.dart';
import '../../widgets/custome_text.dart';
class TaskWidget extends StatefulWidget {
  const TaskWidget({Key? key}) : super(key: key);

  @override
  State<TaskWidget> createState() => _TaskWidgetState();
}

class _TaskWidgetState extends State<TaskWidget> {
  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<MeetingPageProvider>(context,listen: false);
    final selectedEvents = provider.eventsOfSelectedDate;
    if(selectedEvents.isEmpty){
      return  Center(
        child: CustomText(text:"No Events Found!",fontSize: 20,),
      );
    }
    return SfCalendar(
      view: CalendarView.timelineDay,
      dataSource: EventsDataSource(provider.dataOfMeetings!.meetings!),
      headerHeight: 0,
      todayHighlightColor: Colors.black,
      selectionDecoration: BoxDecoration(
        color: Colors.red.withOpacity(0.5),
      ),
      initialDisplayDate: provider.selectedDate,
      appointmentBuilder: appointmentBuilder,
      onTap: (details){
        if(details.appointments == null) return;
        final event = details.appointments!.first;
        Navigator.of(context).push(MaterialPageRoute(
            builder: (context) => EventViewingPage(event: event),
        ));
      },
    );
  }

  Widget appointmentBuilder(
      BuildContext context,
      CalendarAppointmentDetails details,
      ){
    final event = details.appointments!.first;
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(15)
      ),
      width: details.bounds.width,
      height: details.bounds.height,
      child: Center(
        child: CustomText(text: event.meetingTitle.toString(),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,


            fontSize: 16,
            fontWeight: FontWeight.bold

        ),
      ),
    );
  }
}
