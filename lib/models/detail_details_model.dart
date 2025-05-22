import 'package:flutter/material.dart';

// class DetailDetails {
//   int? detailId;
//   int? primaryDetailId;
//   String? groupSerial;
//   int? agendaDetailId;
//   String? serialNumberResolutionAr;
//   String? textResolutionAr;
//   String? serialNumberDirectionAr;
//   String? serialNumberDirectionEn;
//   String? textDirectionAr;
//   String? textDirectionEn;
//   String? serialNumberResolutionEn;
//   String? textResolutionEn;
//   TextEditingController textResolutionEnController;
//   TextEditingController textDirectionEnController;
//   TextEditingController textResolutionArController;
//   TextEditingController textDirectionArController;
//
//   DetailDetails({
//     this.agendaDetailId,
//     this.primaryDetailId,
//     this.groupSerial,
//     this.serialNumberResolutionAr,
//     this.textResolutionAr,
//     this.serialNumberDirectionAr,
//     this.serialNumberDirectionEn,
//     this.detailId,
//     this.textDirectionAr,
//     this.textDirectionEn,
//     this.serialNumberResolutionEn,
//     this.textResolutionEn,
//     TextEditingController? textResolutionEnController,
//     TextEditingController? textDirectionEnController,
//     TextEditingController? textResolutionArController,
//     TextEditingController? textDirectionArController,
//   })  : textResolutionEnController =
//             TextEditingController(text: textResolutionEn),
//         textDirectionEnController =
//             TextEditingController(text: textDirectionEn),
//         textResolutionArController =
//             TextEditingController(text: textResolutionAr),
//         textDirectionArController =
//             TextEditingController(text: textDirectionAr);
//
//   // To save the data back from the controller to the model
//   void saveData() {
//     textResolutionEn = textResolutionEnController.text;
//     textDirectionEn = textDirectionEnController.text;
//     textResolutionAr = textResolutionArController.text;
//     textDirectionAr = textDirectionArController.text;
//   }
//
//   // Optional: Implement disposal to clean up the controllers if needed
//   void dispose() {
//     textResolutionEnController.dispose();
//     textDirectionEnController.dispose();
//     textResolutionArController.dispose();
//     textDirectionArController.dispose();
//   }
//
//   factory DetailDetails.fromJson(Map<String, dynamic> json) {
//     return DetailDetails(
//         detailId: json['id'],
//         primaryDetailId: json['id'],
//         serialNumberResolutionAr: json['serial_number_resolution_ar'],
//         textResolutionAr: json['text_resolution_ar'],
//         serialNumberDirectionAr: json['serial_number_direction_ar'],
//         textDirectionAr: json['text_direction_ar'],
//         serialNumberDirectionEn: json['serial_number_direction_en'],
//         textDirectionEn: json['text_direction_en'],
//         serialNumberResolutionEn: json['serial_number_resolution_en'],
//         textResolutionEn: json['text_resolution_en'],
//         agendaDetailId: json['agenda_detail_id']);
//   }
//
//   Map<String, dynamic> toJson() {
//     return {
//       'detailId': detailId,
//       'primaryDetailId': primaryDetailId,
//       'agenda_detail_id': agendaDetailId,
//       'serialNumberResolutionEn': serialNumberResolutionEn,
//       'textResolutionEn': textResolutionEn,
//       'serialNumberDirectionEn': serialNumberDirectionEn,
//       'textDirectionEn': textDirectionEn,
//       'serialNumberResolutionAr': serialNumberResolutionAr,
//       'textResolutionAr': textResolutionAr,
//       'serialNumberDirectionAr': serialNumberDirectionAr,
//       'textDirectionAr': textDirectionAr,
//     };
//   }
// }
//





//
//
import 'package:flutter_quill/flutter_quill.dart'; // Make sure to import Quill

class DetailDetails {
  int? detailId;
  int? primaryDetailId;
  String? groupSerial;
  int? agendaDetailId;
  String? serialNumberResolutionAr;
  String? textResolutionAr;
  String? serialNumberDirectionAr;
  String? serialNumberDirectionEn;
  String? textDirectionAr;
  String? textDirectionEn;
  String? serialNumberResolutionEn;
  String? textResolutionEn;

  // Use QuillController for rich text editing
  QuillController textResolutionEnController;
  QuillController textDirectionEnController;
  QuillController textResolutionArController;
  QuillController textDirectionArController;

  DetailDetails({
    this.agendaDetailId,
    this.primaryDetailId,
    this.groupSerial,
    this.serialNumberResolutionAr,
    this.textResolutionAr,
    this.serialNumberDirectionAr,
    this.serialNumberDirectionEn,
    this.detailId,
    this.textDirectionAr,
    this.textDirectionEn,
    this.serialNumberResolutionEn,
    this.textResolutionEn,
    QuillController? textResolutionEnController,
    QuillController? textDirectionEnController,
    QuillController? textResolutionArController,
    QuillController? textDirectionArController,
  })  : textResolutionEnController = textResolutionEnController ??
      QuillController.basic(),
        textDirectionEnController = textDirectionEnController ??
            QuillController.basic(),
        textResolutionArController = textResolutionArController ??
            QuillController.basic(),
        textDirectionArController = textDirectionArController ??
            QuillController.basic();

  // To save the data back from the controller to the model
  void saveData() {
    textResolutionEn = textResolutionEnController.document.toPlainText();
    textDirectionEn = textDirectionEnController.document.toPlainText();
    textResolutionAr = textResolutionArController.document.toPlainText();
    textDirectionAr = textDirectionArController.document.toPlainText();
  }

  // Optional: Implement disposal to clean up the controllers if needed
  void dispose() {
    textResolutionEnController.dispose();
    textDirectionEnController.dispose();
    textResolutionArController.dispose();
    textDirectionArController.dispose();
  }

  factory DetailDetails.fromJson(Map<String, dynamic> json) {
    return DetailDetails(
      detailId: json['id'],
      primaryDetailId: json['id'],
      serialNumberResolutionAr: json['serial_number_resolution_ar'],
      textResolutionAr: json['text_resolution_ar'],
      serialNumberDirectionAr: json['serial_number_direction_ar'],
      textDirectionAr: json['text_direction_ar'],
      serialNumberDirectionEn: json['serial_number_direction_en'],
      textDirectionEn: json['text_direction_en'],
      serialNumberResolutionEn: json['serial_number_resolution_en'],
      textResolutionEn: json['text_resolution_en'],
      agendaDetailId: json['agenda_detail_id'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'detailId': detailId,
      'primaryDetailId': primaryDetailId,
      'agenda_detail_id': agendaDetailId,
      'serialNumberResolutionEn': serialNumberResolutionEn,
      'textResolutionEn': textResolutionEn,
      'serialNumberDirectionEn': serialNumberDirectionEn,
      'textDirectionEn': textDirectionEn,
      'serialNumberResolutionAr': serialNumberResolutionAr,
      'textResolutionAr': textResolutionAr,
      'serialNumberDirectionAr': serialNumberDirectionAr,
      'textDirectionAr': textDirectionAr,
    };
  }
}
