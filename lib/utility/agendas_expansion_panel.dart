import 'package:diligov_members/models/agenda_model.dart';
import 'package:flutter/material.dart';

import '../../../widgets/custome_text.dart';
import 'notes_expansion_panel.dart';
class AgendasExpansionPanel extends StatefulWidget {
  final List<Agenda> agendas;
  const AgendasExpansionPanel({super.key, required this.agendas});

  @override
  State<AgendasExpansionPanel> createState() => _AgendasExpansionPanelState();
}

class _AgendasExpansionPanelState extends State<AgendasExpansionPanel> {
  @override
  Widget build(BuildContext context) {
    return ExpansionPanelList.radio(
      materialGapSize: 10.0,
      dividerColor: Colors.white60,
      elevation: 3.0,
      expandedHeaderPadding : EdgeInsets.only(top: 5.0, bottom: 5.0),
      children: widget.agendas!.map<ExpansionPanelRadio>((Agenda agenda) {
        return ExpansionPanelRadio(
          canTapOnHeader: true,
          backgroundColor:  Colors.white70 ,
          value: agenda.agendaId.toString(),
          headerBuilder: (BuildContext context, bool isExpanded) {
            return Padding(
              padding: const EdgeInsets.only(left: 15.0),
              child: ListTile(
                leading: Icon(Icons.picture_as_pdf_outlined,),
                title: CustomText(
                  text: '${agenda.agendaTitle!}',
                  fontWeight: FontWeight.w500,
                  fontSize: 18.0,
                ),
              ),
            );
          },
          body: NotesExpansionPanel(agenda: agenda ),
        );
      }).toList(),
    );
  }
}
