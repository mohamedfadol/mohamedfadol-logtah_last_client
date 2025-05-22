import 'package:diligov_members/models/audio_annotation_model.dart';
import 'package:diligov_members/models/board_model.dart';
import 'package:diligov_members/models/business_model.dart';
import 'package:diligov_members/models/committee_model.dart';
import 'package:diligov_members/models/member_sign_minutes.dart';
import 'package:diligov_members/models/user.dart';

import '../src/canvas_item.dart';
import '../src/stroke.dart';
import '../src/text_annotation.dart';
import 'agenda_model.dart';
import 'meeting_model.dart';

class Minutes{
  List<Minute>? minutes;

  Minutes.fromJson(Map<String, dynamic> json) {
    if (json['minutes'] != null) {
      minutes = <Minute>[];
      json['minutes'].forEach((v) {
        minutes!.add(Minute.fromJson(v));
      });
    }
  }
}

class Minute {
  int? minuteId;
  String? minuteName;
  String? minuteDecision;
  String? minuteDate;
  String? minuteNumbers;
  String? minuteStatus ;
  String? minuteFile ;
  int? addBy;
  int? businessId;
  Business? business;
  Committee? committee;
  Board? board;
  User? user;
  Meeting? meeting;
  List<MemberSignMinutes>? memberSignMinutes;
  List<TextAnnotation>? notes;
  List<AudioAnnotationModel>? audioNotes;
  List<Stroke>? strokes;
  List<CanvasItem>? canvasItems;

  Minute(
      {this.minuteId,
        this.minuteName,
        this.minuteDecision,
        this.minuteDate,
        this.minuteNumbers,
        this.minuteStatus,
        this.addBy,
        this.businessId,
        this.business,
        this.user,
        this.board,
        this.committee,
        this.meeting,
        this.memberSignMinutes,
        this.minuteFile,
        this.notes,
        this.strokes,
        this.audioNotes,
        this.canvasItems,
      });
  // create new converter
  Minute.fromJson(Map<String, dynamic> json) {
    minuteId = json['id'];
    minuteName = json['minute_name'];
    minuteDecision = json['minute_decision'];
    minuteDate = json['minute_date'];
    minuteNumbers = json['minute_numbers'];
    minuteStatus = json['minute_status'];
    addBy = json['add_by'];

    if (json['canvas_items'] != null) {
      canvasItems = <CanvasItem>[];
      json['canvas_items'].forEach((v) {
        canvasItems!.add(CanvasItem.fromJson(v));
      });
    }

    if (json['notes'] != null) {
      notes = <TextAnnotation>[];
      json['notes'].forEach((v) {
        notes!.add(TextAnnotation.fromJson(v));
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

    minuteFile = json['minute_file'];
    businessId = json['business_id'];
    business = json['business'] != null ? Business?.fromJson(json['business']) : null;
    user = json['user'] != null ? User?.fromJson(json['user']) : null;
    committee = json['committee'] != null ? Committee?.fromJson(json['committee']) : null;
    meeting = json['meeting'] != null ? Meeting.fromJson(json['meeting']) : null;
    board = json['board'] != null ? Board.fromJson(json['board']) : null;

    if (json['members_signatures'] != null) {
      memberSignMinutes = <MemberSignMinutes>[];
      json['members_signatures'].forEach((v) {
        memberSignMinutes!.add(MemberSignMinutes.fromJson(v));
      });
    }
  }


  Map<String, dynamic> toJson() {
    return {
      'id': minuteId,
      'minute_name': minuteName,
      'minute_decision': minuteDecision,
      'minute_date': minuteDate,
      'minute_numbers': minuteNumbers,
      'minute_status': minuteStatus,
      'minute_file': minuteFile,
      'add_by': addBy,
      'business_id': businessId,
      // 'business': business?.toJson(),
      'user': user?.toJson(),
      'board': board?.toJson(),
      'committee': committee?.toJson(),
      'meeting': meeting?.toJson(),
      // 'members_signatures': memberSignMinutes?.map((e) => e.toJson()).toList(),
      // 'notes': notes?.map((n) => n.toJson()).toList(),
      // 'audio_notes': audioNotes?.map((a) => a.toJson()).toList(),
      'strokes': strokes?.map((s) => s.toMap()).toList(), // Assuming `toMap()` is used for Stroke
      // 'canvas_items': canvasItems?.map((c) => c.toJson()).toList(),
    };
  }



  // Returns the total number of items to be paginated (e.g., all agenda items)
  int? getTotalItems() {
    return meeting?.agendas?.length;
  }

  // Returns a subset of items for the given range
  List<Agenda>? getItemsInRange(int start, int end) {
    return meeting?.agendas?.sublist(start, end.clamp(0, meeting!.agendas!.length));
  }
}