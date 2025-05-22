
import 'package:diligov_members/models/member_signed_model.dart';

class AgendaChildrenData {
  List<AgendaChildrenModel>? agendaChildren;
  AgendaChildrenData.fromJson(Map<String, dynamic> json) {
    if (json['agendaChildren'] != null) {
      agendaChildren = <AgendaChildrenModel>[];
      json['agendaChildren'].forEach((v) {
        agendaChildren!.add(AgendaChildrenModel.fromJson(v));
      });
    }
  }
}

class AgendaChildrenModel {
  int? childAgendaId;
  String? childAgendaTitle;
  String? childAgendaDescription;
  String? childAgendaTime;
  int? childAgendaPresenter;
  List<String>? childAgendaFileOneName;
  List<String>? childAgendaFileTwoName;

  String? childAgendaTitleAr;
  String? childAgendaDescriptionAr;
  String? childAgendaTimeAr;
  int? childAgendaPresenterAr;
  List<String>? childAgendaFileOneNameAr;
  List<String>? childAgendaFileTwoNameAr;
  int? documentIdsAr;
  List<MemberSignedModel>? membersSigned;

  int? parentId;
  int? documentId;

  // Agenda? agenda;

  AgendaChildrenModel(
      {this.childAgendaId,
      this.childAgendaTitle,
      this.childAgendaDescription,
      this.childAgendaTime,
      this.childAgendaPresenter,
      this.childAgendaFileOneName,
      this.childAgendaFileTwoName,
      this.documentId,
      this.childAgendaTitleAr,
      this.childAgendaDescriptionAr,
      this.childAgendaTimeAr,
      this.childAgendaPresenterAr,
      this.childAgendaFileOneNameAr,
      this.childAgendaFileTwoNameAr,
        this.documentIdsAr,
        this.membersSigned
      // this.agenda
      });

  AgendaChildrenModel.fromJson(Map<String, dynamic> json) {
    childAgendaId = json['id'];
    childAgendaTitle = json['child_agenda_title'];
    childAgendaDescription = json['child_agenda_description'];
    childAgendaTime = json['child_agenda_time'];
    childAgendaPresenter = json['child_agenda_presenter'];
    childAgendaFileOneName = json['child_agenda_file_one_name'].cast<String>();
    childAgendaFileTwoName = json['child_agenda_file_two_name'].cast<String>();

    childAgendaTitleAr = json['child_agenda_title_ar'];
    childAgendaDescriptionAr = json['child_agenda_description_ar'];
    childAgendaTimeAr = json['child_agenda_time_ar'];
    childAgendaPresenterAr = json['child_presenter_ar'];
    childAgendaFileOneName = json['child_agenda_file_one_name'].cast<String>();
    childAgendaFileTwoName = json['child_agenda_file_two_name'].cast<String>();

    if (json['member_signeds'] != null) {
      membersSigned = <MemberSignedModel>[];
      json['member_signeds'].forEach((v) {
        membersSigned!.add(MemberSignedModel.fromJson(v));
      });
    }

    parentId = json['parent_id'];
    documentId = json['document_id'];
    documentIdsAr = json['documentIds_ar'];
  }


  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['child_agenda_title'] = this.childAgendaTitle;
    data['child_agenda_description'] = this.childAgendaDescription;
    data['child_agenda_time'] = this.childAgendaTime;
    data['child_agenda_presenter'] = this.childAgendaPresenter;
    data['child_agenda_file_one_name'] = this.childAgendaFileOneName;
    data['child_agenda_file_two_name'] = this.childAgendaFileTwoName;
    data['parent_id'] = this.parentId;
    data['document_id'] = this.documentId;
    return data;
  }
}
