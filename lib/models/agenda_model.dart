
import 'package:diligov_members/models/Attendance.dart';
import 'package:diligov_members/models/agenda_children_model.dart';
import 'package:diligov_members/models/agenda_details.dart';
import 'package:diligov_members/models/member_signed_model.dart';
import 'package:diligov_members/src/stroke.dart';

import '../src/canvas_item.dart';
import '../src/text_annotation.dart';
import 'audio_annotation_model.dart';

class Agendas {
  List<Agenda>? agendas;
  Agendas.fromJson(Map<String, dynamic> json) {
    if (json['agendas'] != null) {
      agendas = <Agenda>[];
      json['agendas'].forEach((v) {
        agendas!.add(Agenda.fromJson(v));
      });
    }
  }

}

class Agenda{
  int? agendaId;
  String? agendaTitle;
  String? agendaDescription;
  String? agendaTime;
  String? presenter;
  String? agendaFile;
  String?  agendaFileName;

  String? agendaTitleAr;
  String? agendaDescriptionAr;
  String? agendaTimeAr;
  String? presenterAr;
  List<String>? agendaFileAr;
  List<String>? agendaFileNameAr;
  List<String>? agendaFileOneName;
  List<String>? agendaFileTwoName;
  int? documentIdsAr;
  int? documentId;
  String? agendaFileFullPath;
  bool? isExpanded = false;
  bool isClicked = false;
  List<AgendaDetails>? agendaDetails;
  AgendaDetails? details;
  List<TextAnnotation>? notes;
  List<AudioAnnotationModel>? audioNotes;
  List<Stroke>? strokes;
  List<CanvasItem>? canvasItems;
  List<Attendance>? attendanceDetails;
  List<AgendaChildrenModel>? agendaChildren;
  List<MemberSignedModel>? membersSigned;


  Agenda({
        this.agendaId,
        this.agendaTitle,
        this.agendaDescription,
        this.agendaTime,
        this.presenter,
        this.agendaDetails,
        this.agendaFile,
        this.agendaFileOneName,
        this.agendaFileTwoName,
        this.agendaFileFullPath,
        this.agendaFileName,
        this.agendaTitleAr,
        this.agendaDescriptionAr,
        this.agendaTimeAr,
        this.presenterAr,
        this.agendaFileAr,
        this.agendaFileNameAr,
        this.documentIdsAr,
        this.documentId,
        this.details,
        this.notes,
        this.strokes,
        this.audioNotes,
        this.canvasItems,
        this.agendaChildren,
        this.attendanceDetails,
        this.membersSigned
      });

  Map<String, dynamic> toJson() {
    return {
      'id': agendaId,
      'agenda_title': agendaTitle,
      'agenda_description': agendaDescription,
      'agenda_time': agendaTime,
      'agenda_presenter': presenter,
      'agenda_details': agendaDetails?.map((e) => e.toJson()).toList(),
    };
  }

   Agenda.fromJson(Map<String, dynamic> json) {
     // var details = json['agenda_details'] as List;
     // List<AgendaDetails> agendaDetailsList = details.map((i) => AgendaDetails.fromJson(i)).toList();
      // agendaDetails = agendaDetailsList;
        agendaId= json['id'];
        agendaTitle= json['agenda_title'];
        agendaDescription= json['agenda_description'];
        agendaTime= json['agenda_time'];
        presenter =json['agenda_presenter'];
        agendaFile =json['agenda_file'];
        agendaFileFullPath =json['file_full_path'];
        agendaFileName = json['file_name'];
        // Safely cast agendaFileOneName and agendaFileTwoName
        agendaFileOneName = (json['agenda_file_one_name'] != null) ? List<String>.from(json['agenda_file_one_name']) : [];

        agendaFileTwoName = (json['agenda_file_two_name'] != null) ? List<String>.from(json['agenda_file_two_name']) : [];
        documentId = json['document_id'];
        documentIdsAr = json['documentIds_ar'];
        agendaTitleAr= json['agenda_title_ar'];
        agendaDescriptionAr= json['agenda_description_ar'];
        agendaTimeAr= json['agenda_time_ar'];
        presenterAr= json['presenter_ar'];
        agendaFileAr = (json['file_name_ar'] != null) ? List<String>.from(json['file_name_ar']) : [];
        agendaFileNameAr = (json['file_name_two_ar'] != null) ? List<String>.from(json['file_name_two_ar']) : [];
        details = json['details'] != null ? AgendaDetails.fromJson(json['details']) : null;

        if (json['attendance_details'] != null) {
          attendanceDetails = <Attendance>[];
          json['attendance_details'].forEach((v) {
            attendanceDetails!.add(Attendance.fromJson(v));
          });
        }

        if (json['member_signeds'] != null) {
          membersSigned = <MemberSignedModel>[];
          json['member_signeds'].forEach((v) {
            membersSigned!.add(MemberSignedModel.fromJson(v));
          });
        }

        if (json['canvas_items'] != null) {
         canvasItems = <CanvasItem>[];
         json['canvas_items'].forEach((v) {
           canvasItems!.add(CanvasItem.fromJson(v));
         });
       }

        if (json['agenda_details'] != null) {
          agendaDetails = <AgendaDetails>[];
          json['agenda_details'].forEach((v) {
            agendaDetails!.add(AgendaDetails.fromJson(v));
          });
        }

        if (json['notes'] != null) {
          notes = <TextAnnotation>[];
          json['notes'].forEach((v) {
            notes!.add(TextAnnotation.fromJson(v));
          });
        }

        if (json['agenda_childrens'] != null) {
          agendaChildren = <AgendaChildrenModel>[];
          json['agenda_childrens'].forEach((v) {
            agendaChildren!.add(AgendaChildrenModel.fromJson(v));
          });
        }

        if (json['audio_notes'] != null) {
          audioNotes = <AudioAnnotationModel>[];
          json['audio_notes'].forEach((v) {
            audioNotes!.add(AudioAnnotationModel.fromJson(v));
          });
        }

        if (json['strokes'] != null) {
        strokes = <Stroke>[];
        json['strokes'].forEach((v) {
          strokes!.add(Stroke.fromMap(v));
        });
      }
  }



}