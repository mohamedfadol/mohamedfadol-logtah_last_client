import 'package:diligov_members/models/detail_details_model.dart';

import 'agenda_model.dart';

class AgendaDetails{
  int? agendaId;
  int? index;
  int? detailsId;
  String? description;
  String? reservations;
  String? arabicDescription;
  String? arabicReservations;
  List<DetailDetails>? detailDetails;
  Agenda? agenda;

  AgendaDetails({this.index,this.detailsId,this.description, this.reservations,this.agendaId,this.arabicDescription,this.arabicReservations,this.agenda, this.detailDetails});

   AgendaDetails.fromJson(Map<String, dynamic> json) {

      agendaId= json['agenda_id'];
      detailsId= json['id'];
      description= json['description'];
      agenda= json['agenda'] != null ? Agenda.fromJson(json['agenda']) : null;
      arabicDescription= json['arabic_description'];
      arabicReservations= json['arabic_reservations'];
      reservations= json['reservations'];

      if (json['detail_details'] != null) {
        detailDetails = <DetailDetails>[];
        json['detail_details'].forEach((v) {
          detailDetails!.add(DetailDetails.fromJson(v));
        });
      }



  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data['agenda_id'] = agendaId;
    data['description'] = description;
    data['reservations'] = reservations;
    data['arabic_description'] = arabicDescription;
    data['arabic_reservations'] = arabicReservations;
    // data['detail_details'] = detailDetails?.map((detail) => detail.toJson()).toList();
    return data;
  }

  AgendaDetails copyWith({
    int? agendaId,
    String? missions,
    String? tasks,
    String? reservations,
  }) {
    return AgendaDetails(
      agendaId: agendaId ?? this.agendaId,
      description: description ?? this.description,
      reservations: reservations ?? this.reservations,
      detailDetails: detailDetails,
      arabicDescription: arabicDescription,
      arabicReservations: arabicReservations,
      agenda: agenda,
    );
  }
}