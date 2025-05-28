import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';

import '../colors.dart';
import '../models/events_data_source.dart';
import '../providers/meeting_page_provider.dart';
import '../views/calenders/task_widget.dart';
import 'custom_message.dart';
import 'custome_text.dart';
import 'loading_sniper.dart';
import 'package:flutter_gen/gen_l10n/app_localization.dart';

class MiniCalendarWidget extends StatefulWidget {
  const MiniCalendarWidget({super.key});

  @override
  State<MiniCalendarWidget> createState() => _MiniCalendarWidgetState();
}

class _MiniCalendarWidgetState extends State<MiniCalendarWidget> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();

  }
  CalendarController calendarController = CalendarController();
  CalendarView calendarView = CalendarView.month;

  buildEmptyMessage(String message) {
    return CustomMessage(
      text: message,
    );
  }

  buildLoadingSniper() {
    return const LoadingSniper();
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final containerColor = isDarkMode ? Colour().darkContainerColor : Colour().lightContainerColor ;

    return Scaffold(
      backgroundColor: const Color(0xFFEAEAEA),
      body: Consumer<MeetingPageProvider>(
          builder: (context, provider, child) {
            if (provider.dataOfMeetings?.meetings == null) {
              provider.getListOfMeetings(context);
              return buildLoadingSniper();
            }

            return
              Padding(
                padding: const EdgeInsets.only(bottom: 10.0),
                child: SfCalendar(
                  headerStyle:  CalendarHeaderStyle(
                    textAlign: TextAlign.center,
                    textStyle: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: containerColor,
                    ),
                  ),
                  controller: calendarController,
                  view: calendarView,
                  dataSource: provider.dataOfMeetings?.meetings == null ? null : EventsDataSource(provider.dataOfMeetings!.meetings!),
                  todayHighlightColor: Colour().buttonBackGroundRedColor,todayTextStyle: TextStyle(color: Colour().mainWhiteTextColor),
                  monthViewSettings: MonthViewSettings(appointmentDisplayMode: MonthAppointmentDisplayMode.indicator, showAgenda: false, appointmentDisplayCount: 2),

                  initialSelectedDate: DateTime.now(),
                  backgroundColor: containerColor,
                  // showNavigationArrow: true,
                  onLongPress: (details) {
                    provider.setDate(details.date!);
                    showModalBottomSheet(context: context,builder: (context) => const TaskWidget(),
                    );
                  },
                ),
              );
          }),
    );
  }
}

