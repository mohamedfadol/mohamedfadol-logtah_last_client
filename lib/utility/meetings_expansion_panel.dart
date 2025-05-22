
import 'package:flutter/material.dart';

import '../../../models/meeting_model.dart';
import '../../../widgets/custome_text.dart';
import 'agendas_expansion_panel.dart';
class MeetingsExpansionPanel extends StatefulWidget {
  final List<Meeting>? meetings;

  MeetingsExpansionPanel({super.key, required this.meetings});

  @override
  State<MeetingsExpansionPanel> createState() => _MeetingsExpansionPanelState();
}

class _MeetingsExpansionPanelState extends State<MeetingsExpansionPanel> {

  String? localPath = '';
  String? baseUri;

  @override
  Widget build(BuildContext context) {

    return SingleChildScrollView(
      physics: BouncingScrollPhysics(),
      scrollDirection: Axis.vertical,
      child: ExpansionPanelList.radio(
        materialGapSize: 10.0,
        dividerColor: Colors.grey[100],
        elevation: 3.0,
        expandedHeaderPadding : EdgeInsets.only(top: 5.0, bottom: 5.0),
        children: widget.meetings!.map<ExpansionPanelRadio>((Meeting meeting) {
          return ExpansionPanelRadio(
            canTapOnHeader: true,
            backgroundColor: meeting.isExpanded! ? Colors.grey  : Colors.blueGrey[200],
            value: meeting.meetingId.toString(),
            headerBuilder: (BuildContext context, bool isExpanded) {
              return Padding(
                padding: const EdgeInsets.only(left: 10.0),
                child: ListTile(
                  title: CustomText(
                    text: '- ${meeting.meetingTitle!} -- ${meeting.meetingSerialNumber!}',
                    fontWeight: FontWeight.w500,
                    fontSize: 18.0,
                  ),
                ),
              );
            },
            body: AgendasExpansionPanel(agendas: meeting.agendas!,),
          );
        }).toList(),
      ),
    );
  }


}