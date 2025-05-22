import 'dart:async';
import 'dart:convert';
import 'package:diligov_members/models/agenda_details.dart';
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_quill/quill_delta.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:logger/logger.dart';
import '../../../NetworkHandler.dart';
import '../models/agenda_model.dart';
import 'package:intl/intl.dart';

import '../models/detail_details_model.dart';
import '../models/minutes_model.dart';


class AgendaPageProvider extends ChangeNotifier {
  final log = Logger();
  final networkHandler = NetworkHandler();
  final storage = const FlutterSecureStorage();

  Minutes? minutesData;

  bool _enableArabic = false;
  bool _enableEnglish = true;
  bool _enableArabicAndEnglish = false;

  Agendas? listAgenda;
  bool get enableArabic => _enableArabic;
  bool get enableEnglish => _enableEnglish;
  bool get enableArabicAndEnglish => _enableArabicAndEnglish;

  Agenda _agenda = Agenda();
  Agenda get agenda => _agenda;

  AgendaDetails _agendaDetails = AgendaDetails();
  AgendaDetails get agendaDetails => _agendaDetails;

  bool _loading = false;
  bool get loading => _loading;

  bool _isBack = false;
  bool get isBack => _isBack;
  bool _isActive = true;
  bool get isActive => _isActive;

  final List<TextEditingController> descriptionControllers = [];
  final List<TextEditingController> reservationsControllers = [];

  final List<QuillController> descriptionControllerss = [];
  final List<QuillController> reservationsControllerss = [];

  final List<QuillController> arabicDescriptionControllerss = [];
  final List<QuillController> arabicReservationsControllerss = [];


  final List<TextEditingController> arabicDescriptionControllers = [];
  final List<TextEditingController> arabicReservationsControllers = [];

  List<TextEditingController> attendedNameControllers = [];
  List<TextEditingController> positionControllers = [];
  List<TextEditingController> arabicAttendedNameControllers = [];
  List<TextEditingController> arabicPositionControllers = [];

  List<Map<String, dynamic>> resolutions = [];
  List<Map<String, dynamic>> directions = [];
  List<Map<String, dynamic>> arabicResolutions = [];
  List<Map<String, dynamic>> arabicDirections = [];

  Map<int, TextEditingController> englishResolutionControllers = {};
  Map<int, TextEditingController> englishDirectionControllers = {};
  Map<int, TextEditingController> arabicResolutionControllers = {};
  Map<int, TextEditingController> arabicDirectionControllers = {};


  Map<int, QuillController> englishResolutionControllerss = {};
  Map<int, QuillController> englishDirectionControllerss = {};
  Map<int, QuillController> arabicResolutionControllerss = {};
  Map<int, QuillController> arabicDirectionControllerss = {};

  String agendaTitle = '';
  int currentIndex = 0;

  double _bottomPadding = 0.0; // Initial bottom padding
  double get bottomPadding => _bottomPadding;
  Map<int, int> agendaFilledFieldsCount = {};  // Track how many fields are filled for each agenda

  void setAgendaTitle(String title) {
    agendaTitle = title;
    notifyListeners();
  }

  Minute _minute = Minute();
  Minute get minute => _minute;
  void setMinute(Minute minute) async {
    _minute =  minute;
    notifyListeners();
  }

  TextEditingController getOrCreateController(Map<int, TextEditingController> controllersMap, int detailId, String? initialValue) {
    if (!controllersMap.containsKey(detailId) || controllersMap[detailId] == null) {
      // log.i('Initializing controller for detailId: $detailId');
      controllersMap[detailId] = TextEditingController(text: initialValue);
    } else {
      // log.i('Reusing existing controller for detailId: $detailId');
    }
    return controllersMap[detailId]!;
  }


  QuillController getOrCreateQuillController(Map<int, QuillController> controllersMap, int detailId, String? initialValue) {
    if (!controllersMap.containsKey(detailId) || controllersMap[detailId] == null) {
      // Convert initialValue to a Delta format for QuillController
      Delta delta = Delta()..insert((initialValue ?? '') + '\n');
      controllersMap[detailId] = QuillController(
        document: Document.fromDelta(delta),
        selection: const TextSelection.collapsed(offset: 0),
      );
    }
    return controllersMap[detailId]!;
  }


  void disposeControllers(List<QuillController> controllers) {
    for (var controller in controllers) {
      controller.dispose();  // Dispose each controller
    }
    controllers.clear();  // Then clear the list
  }

  void clearAllControllers() {
    disposeControllers(descriptionControllerss);  // Dispose and clear arabic description controllers
    disposeControllers(reservationsControllerss); // Dispose and clear arabic reservations controllers
    // disposeControllers(arabicDescriptionControllerss);  // Dispose and clear arabic description controllers
    // disposeControllers(arabicReservationsControllerss); // Dispose and clear arabic reservations controllers
  }

  Delta _convertTextToDelta(String text) {
    return Delta()..insert(text + '\n');  // Adds a newline at the end
  }

  void setAgenda1(Agenda agenda) {
    _agenda = agenda;
    englishResolutionControllers.clear();
    englishDirectionControllers.clear();
    arabicResolutionControllers.clear();
    arabicDirectionControllers.clear();
    clearAllControllers();
    for (var detail in agenda.details!.detailDetails!) {
      log.i('Initializing ResolutionEn: ${detail.textResolutionEn}, DirectionEn: ${detail.textDirectionEn}');

      if (detail.serialNumberResolutionEn != null) {

        englishResolutionControllers[detail.detailId!] = TextEditingController(text: detail.textResolutionEn);
      }
      if (detail.serialNumberDirectionEn != null) {
        englishDirectionControllers[detail.detailId!] = TextEditingController(text: detail.textDirectionEn);
      }
      if (detail.serialNumberResolutionAr != null) {
        arabicResolutionControllers[detail.detailId!] = TextEditingController(text: detail.textResolutionAr);
      }
      if (detail.serialNumberDirectionAr != null) {
        arabicDirectionControllers[detail.detailId!] = TextEditingController(text: detail.textDirectionAr);
      }
    }
    notifyListeners();
  }

  void setAgenda(Agenda agenda) {
    _agenda = agenda;

    // Clear the existing text controllers and QuillControllers
    englishResolutionControllers.clear();
    englishDirectionControllers.clear();
    // arabicResolutionControllers.clear();
    // arabicDirectionControllers.clear();
    clearAllControllers();

    for (var detail in agenda.details!.detailDetails!) {
      log.i('Initializing ResolutionEn: ${detail.textResolutionEn}, DirectionEn: ${detail.textDirectionEn}');

      // English Resolutions
      if (detail.serialNumberResolutionEn != null) {
        var delta = _convertTextToDelta(detail.textResolutionEn ?? '');
        englishResolutionControllerss[detail.detailId!] = QuillController(
          document: Document.fromDelta(delta),
          selection: const TextSelection.collapsed(offset: 0),
        );
      }

      // English Directions
      if (detail.serialNumberDirectionEn != null) {
        var delta = _convertTextToDelta(detail.textDirectionEn ?? '');
        englishDirectionControllerss[detail.detailId!] = QuillController(
          document: Document.fromDelta(delta),
          selection: const TextSelection.collapsed(offset: 0),
        );
      }

      // Arabic Resolutions
      if (detail.serialNumberResolutionAr != null) {
        var delta = _convertTextToDelta(detail.textResolutionAr ?? '');
        arabicResolutionControllerss[detail.detailId!] = QuillController(
          document: Document.fromDelta(delta),
          selection: const TextSelection.collapsed(offset: 0),
        );
      }

      // Arabic Directions
      if (detail.serialNumberDirectionAr != null) {
        var delta = _convertTextToDelta(detail.textDirectionAr ?? '');
        arabicDirectionControllerss[detail.detailId!] = QuillController(
          document: Document.fromDelta(delta),
          selection: const TextSelection.collapsed(offset: 0),
        );
      }
    }

    notifyListeners();
  }



  void setAgendaDetails(AgendaDetails agendaDetails) {
    _agendaDetails = agendaDetails;
    notifyListeners();
  }

  void setLoading(bool value) {
    _loading = value;
    notifyListeners();
  }

  void setIsBack(bool value) {
    _isBack = value;
    notifyListeners();
  }

  void toggleEnableArabic() {
    _enableArabic = !_enableArabic;
    _enableEnglish = false;
    _enableArabicAndEnglish= false;
    notifyListeners();
  }

  void toggleEnableEnglish() {
    _enableEnglish = !_enableEnglish;
    _enableArabic = false;
    _enableArabicAndEnglish= false;
    notifyListeners();
  }

  void toggleEnableArabicAndEnglish() {
    _enableArabicAndEnglish = !_enableArabicAndEnglish;
    _enableEnglish = false;
    _enableArabic = false;
    notifyListeners();
  }

  void updateStatusProvider(bool value) {
    _isActive = value;
      notifyListeners();
  }

  void safeNotifyListeners() {
    if (_isActive) {
      notifyListeners();
    }
  }

  void updateBottomPadding(double padding) {
    _bottomPadding = padding;
    notifyListeners(); // Notify listeners to update the UI
  }

// In your AgendaPageProvider
  void updateAgendaProgress(int agendaId, {
    String? descriptionEn,
    String? descriptionAr,
    String? reservationsEn,
    String? reservationsAr,
  }) {
    int filledFields = 0;

    // Dual Language Mode: Check all 4 fields
    if (_enableArabicAndEnglish) {
      if (descriptionEn != null && descriptionEn.isNotEmpty) filledFields++;
      if (descriptionAr != null && descriptionAr.isNotEmpty) filledFields++;
      if (reservationsEn != null && reservationsEn.isNotEmpty) filledFields++;
      if (reservationsAr != null && reservationsAr.isNotEmpty) filledFields++;
    }
    // Single Language Mode (either English or Arabic)
    else if (_enableEnglish || _enableArabic) {
      if (_enableEnglish) {
        if (descriptionEn != null && descriptionEn.isNotEmpty) filledFields++;
        if (reservationsEn != null && reservationsEn.isNotEmpty) filledFields++;
      }
      if (_enableArabic) {
        if (descriptionAr != null && descriptionAr.isNotEmpty) filledFields++;
        if (reservationsAr != null && reservationsAr.isNotEmpty) filledFields++;
      }
    }

    // Update the count of filled fields for the agenda
    agendaFilledFieldsCount[agendaId] = filledFields;

    // Notify listeners to update UI after progress changes
    notifyListeners();
  }

// Use this method to calculate total fields based on language mode
  int getTotalFieldsCount() {
    if (_enableArabicAndEnglish) {
      return 4;  // 4 fields in Dual Language mode
    }
    return 2;  // 2 fields in Single Language mode
  }

  // Helper to get the filled fields count for a specific agenda
  int getFilledFieldsCount(int agendaId) {
    return agendaFilledFieldsCount[agendaId] ?? 0;
  }

  final Map<int, double> _agendaProgress = {}; // Store agenda progress by agendaId

  // Getter to access the agenda progress
  double getAgendaProgress(int agendaId) {
    return _agendaProgress[agendaId] ?? 0.0; // Return 0.0 if not yet calculated
  }

  // void calculateProgressForAgenda(int agendaId) {
  //   int filledFields = getFilledFieldsCount(agendaId);
  //   int totalFields = getTotalFieldsCount();
  //
  //   double progress = filledFields / totalFields;
  //
  //   _agendaProgress[agendaId] = progress; // Store the progress
  //
  //   notifyListeners(); // Notify listeners that progress has updated
  // }

  //
  // void calculateProgressForAgenda(int agendaId) {
  //   int filledFields = getFilledFieldsCount(agendaId);
  //   int totalFields = getTotalFieldsCount();
  //
  //   double progress = filledFields / totalFields;
  //
  //   // Optionally store this in a map or use it for UI updates
  //   _agendaProgress[agendaId] = progress;
  //
  //   notifyListeners();
  // }
  //
  // int getFilledFieldsCount(int agendaId) {
  //   // Add more fields if necessary
  //   int count = 0;
  //
  //   if (_isQuillNotEmpty(descriptionControllerss[agendaId])) count++;
  //   if (_isQuillNotEmpty(reservationsControllerss[agendaId])) count++;
  //   if (_isQuillNotEmpty(arabicDescriptionControllerss[agendaId])) count++;
  //   if (_isQuillNotEmpty(arabicReservationsControllerss[agendaId])) count++;
  //
  //   return count;
  // }



  void calculateProgressForAgenda(int agendaId) {
    int filledFields = getFilledFieldsCount(agendaId);
    int totalFields = getTotalFieldsCount();

    double progress = filledFields / totalFields;

    _agendaProgress[agendaId] = progress; // Store the progress

    notifyListeners(); // Notify listeners that progress has updated
  }

  bool _isQuillNotEmpty(QuillController controller) {
    return controller.document.toPlainText().trim().isNotEmpty;
  }


  void _addDetail(Agenda agenda, String type, String language, String field) {
    // Initialize the detailDetails list if null
    agenda.details!.detailDetails ??= [];

    // Filter the details based on the type and language
    final filteredDetails = agenda.details!.detailDetails!
        .where((detail) => language == 'en'
        ? (type == 'R' ? detail.serialNumberResolutionEn != null : detail.serialNumberDirectionEn != null)
        : (type == 'R' ? detail.serialNumberResolutionAr != null : detail.serialNumberDirectionAr != null))
        .toList();

    // Generate the new serial number
    final newSerial = _generateSerial(type, agenda.agendaTitle ?? '', filteredDetails, field);

    final newDetailId = DateTime.now().millisecondsSinceEpoch;
    // Create a new DetailDetails object
    final newDetail = DetailDetails(
      detailId: newDetailId,
      agendaDetailId: agenda.details!.detailsId,
      serialNumberResolutionEn: type == 'R' && language == 'en' ? newSerial : null,
      serialNumberDirectionEn: type == 'D' && language == 'en' ? newSerial : null,
      serialNumberResolutionAr: type == 'R' && language == 'ar' ? newSerial : null,
      serialNumberDirectionAr: type == 'D' && language == 'ar' ? newSerial : null,
      textResolutionEnController: type == 'R' && language == 'en' ? QuillController.basic() : null,
      textDirectionEnController: type == 'D' && language == 'en' ? QuillController.basic() : null,
      textResolutionArController: type == 'R' && language == 'ar' ? QuillController.basic() : null,
      textDirectionArController: type == 'D' && language == 'ar' ? QuillController.basic() : null,
    );
  log.i(newDetail);
    // Add the new detail to the list
    agenda.details!.detailDetails!.add(newDetail);

    // Add the controller to the corresponding map
    if (type == 'R' && language == 'en' && newDetail.textResolutionEnController != null) {
      englishResolutionControllerss[newDetailId] = newDetail.textResolutionEnController!;
    }
    if (type == 'D' && language == 'en' && newDetail.textDirectionEnController != null) {
      englishDirectionControllerss[newDetailId] = newDetail.textDirectionEnController!;
    }
    if (type == 'R' && language == 'ar' && newDetail.textResolutionArController != null) {
      arabicResolutionControllerss[newDetailId] = newDetail.textResolutionArController!;
    }
    if (type == 'D' && language == 'ar' && newDetail.textDirectionArController != null) {
      arabicDirectionControllerss[newDetailId] = newDetail.textDirectionArController!;
    }
    notifyListeners();
  }

  void _addDetail2(Agenda agenda, String type, String language, String field) {
    // Initialize the detailDetails list if null
    agenda.details ??= AgendaDetails();
    agenda.details!.detailDetails ??= [];

    List<DetailDetails> details = agenda.details!.detailDetails!;

    // Generate the new serial number
    final newSerial = _generateSerial(type, agenda.agendaTitle ?? '', details, field);

    // Create a new DetailDetails object
    final newDetailId = DateTime.now().millisecondsSinceEpoch;
    final newDetail = DetailDetails(
      detailId: newDetailId,
      agendaDetailId: agenda.agendaId,
      serialNumberResolutionEn: type == 'R' && language == 'en' ? newSerial : null,
      serialNumberDirectionEn: type == 'D' && language == 'en' ? newSerial : null,
      serialNumberResolutionAr: type == 'R' && language == 'ar' ? newSerial : null,
      serialNumberDirectionAr: type == 'D' && language == 'ar' ? newSerial : null,
      textResolutionEnController: type == 'R' && language == 'en' ? QuillController.basic() : null,
      textDirectionEnController: type == 'D' && language == 'en' ? QuillController.basic() : null,
      textResolutionArController: type == 'R' && language == 'ar' ? QuillController.basic() : null,
      textDirectionArController: type == 'D' && language == 'ar' ? QuillController.basic() : null,
    );

    // Add the new detail to the list
    details.add(newDetail);

    // Add the controller to the corresponding map
    if (type == 'R' && language == 'en' && newDetail.textResolutionEnController != null) {
      englishResolutionControllerss[newDetailId] = newDetail.textResolutionEnController!;
    }
    if (type == 'D' && language == 'en' && newDetail.textDirectionEnController != null) {
      englishDirectionControllerss[newDetailId] = newDetail.textDirectionEnController!;
    }
    if (type == 'R' && language == 'ar' && newDetail.textResolutionArController != null) {
      arabicResolutionControllerss[newDetailId] = newDetail.textResolutionArController!;
    }
    if (type == 'D' && language == 'ar' && newDetail.textDirectionArController != null) {
      arabicDirectionControllerss[newDetailId] = newDetail.textDirectionArController!;
    }

    log.i('Detail added with ID: $newDetailId');
    notifyListeners();
  }

  void initializeControllers() {
    if (listAgenda?.agendas != null && listAgenda!.agendas!.isNotEmpty) {
      for (var agenda in listAgenda!.agendas!) {
        if (agenda.details?.detailDetails != null && agenda.details!.detailDetails!.isNotEmpty) {
          for (var detail in agenda.details!.detailDetails!) {
            if (detail.serialNumberResolutionEn != null && !englishResolutionControllerss.containsKey(detail.detailId!)) {
              englishResolutionControllerss[detail.detailId!] = QuillController(
                document: Document.fromDelta(_convertTextToDelta(detail.textResolutionEn ?? '')),
                selection: const TextSelection.collapsed(offset: 0),
              );
            }
            if (detail.serialNumberDirectionEn != null && !englishDirectionControllerss.containsKey(detail.detailId!)) {
              englishDirectionControllerss[detail.detailId!] = QuillController(
                document: Document.fromDelta(_convertTextToDelta(detail.textDirectionEn ?? '')),
                selection: const TextSelection.collapsed(offset: 0),
              );
            }
            if (detail.serialNumberResolutionAr != null && !arabicResolutionControllerss.containsKey(detail.detailId!)) {
              arabicResolutionControllerss[detail.detailId!] = QuillController(
                document: Document.fromDelta(_convertTextToDelta(detail.textResolutionAr ?? '')),
                selection: const TextSelection.collapsed(offset: 0),
              );
            }
            if (detail.serialNumberDirectionAr != null && !arabicDirectionControllerss.containsKey(detail.detailId!)) {
              arabicDirectionControllerss[detail.detailId!] = QuillController(
                document: Document.fromDelta(_convertTextToDelta(detail.textDirectionAr ?? '')),
                selection: const TextSelection.collapsed(offset: 0),
              );
            }
          }
        }
      }
    } else {
      log.d("Agendas or details are empty.");
    }
  }


  Map<String, dynamic> collectFormData(AgendaPageProvider provider) {
    List<Map<String, dynamic>> agendasData = [];

    if (provider.listAgenda != null && provider.listAgenda!.agendas != null) {
      for (var agenda in provider.listAgenda!.agendas!) {
        List<Map<String, dynamic>> detailDetailsData = [];

        if (agenda.details != null && agenda.details!.detailDetails != null) {
          for (var detail in agenda.details!.detailDetails!) {
            // Collect the text from the controllers
            String? resolutionEn = provider.englishResolutionControllers[detail.detailId!]?.text;
            String? directionEn = provider.englishDirectionControllers[detail.detailId!]?.text;
            String? resolutionAr = provider.arabicResolutionControllers[detail.detailId!]?.text;
            String? directionAr = provider.arabicDirectionControllers[detail.detailId!]?.text;

            detailDetailsData.add({
              'detail_id': detail.detailId,
              'serial_enR': detail.serialNumberResolutionEn,
              'text_enR': resolutionEn,
              'serial_enD': detail.serialNumberDirectionEn,
              'text_enD': directionEn,
              'serial_arR': detail.serialNumberResolutionAr,
              'text_arR': resolutionAr,
              'serial_arD': detail.serialNumberDirectionAr,
              'text_arD': directionAr,
            });
          }
        }

        agendasData.add({
          'agendaId': agenda.agendaId,
          'agendaTitle': agenda.agendaTitle,
          'agendaDetails': detailDetailsData,
          // Add other relevant fields if necessary
        });
      }
    }

    // Collect other form data if necessary
    return {
      // 'meeting_id': provider.agenda.meetingId,  // example: assuming you have a meeting ID in your Agenda model
      'agendas': agendasData,
      // Add any additional data that your backend API requires
    };
  }

  void saveDetails(Agenda agenda) {
    if (agenda.details != null) {
      for (var detail in agenda.details!.detailDetails!) {

        // Ensure the controller is not null and update the model
        if (detail.serialNumberResolutionEn != null && englishResolutionControllerss.containsKey(detail.detailId!)) {
          detail.textResolutionEn = englishResolutionControllerss[detail.detailId!]!.document.toPlainText().trim();
        }

        if (detail.serialNumberDirectionEn != null && englishDirectionControllerss.containsKey(detail.detailId!)) {
          detail.textDirectionEn = englishDirectionControllerss[detail.detailId!]!.document.toPlainText().trim();
        }

        if (detail.serialNumberResolutionAr != null && arabicResolutionControllerss.containsKey(detail.detailId!)) {
          detail.textResolutionAr = arabicResolutionControllerss[detail.detailId!]!.document.toPlainText().trim();
        }

        if (detail.serialNumberDirectionAr != null && arabicDirectionControllerss.containsKey(detail.detailId!)) {
          detail.textDirectionAr = arabicDirectionControllerss[detail.detailId!]!.document.toPlainText().trim();
        }

        log.i('After Saving - ResolutionEn: ${detail}');
      }
    }
  }


  void disposeControllers1() {
    englishResolutionControllers.values.forEach((controller) => controller.dispose());
    englishDirectionControllers.values.forEach((controller) => controller.dispose());
    arabicResolutionControllers.values.forEach((controller) => controller.dispose());
    arabicDirectionControllers.values.forEach((controller) => controller.dispose());
  }

  void addResolution(Agenda agenda) {
      if(_enableArabicAndEnglish == true){
        _addDetail(agenda, 'D', 'en', 'serialNumberDirectionEn');
        _addDetail(agenda, 'R', 'en', 'serialNumberResolutionEn');
        _addDetail(agenda, 'D', 'ar', 'serialNumberDirectionAr');
        _addDetail(agenda, 'R', 'ar', 'serialNumberResolutionAr');
      }else{
        _addDetail(agenda, 'D', 'en', 'serialNumberDirectionEn');
        _addDetail(agenda, 'R', 'en', 'serialNumberResolutionEn');
      }
  }

  void addResolution2(Agenda agenda) {
    if(_enableArabicAndEnglish == true){
      // _addDetail2(agenda, 'D', 'en', 'serialNumberDirectionEn');
      _addDetail2(agenda, 'R', 'en', 'serialNumberResolutionEn');
      // _addDetail2(agenda, 'D', 'ar', 'serialNumberDirectionAr');
      _addDetail2(agenda, 'R', 'ar', 'serialNumberResolutionAr');
    }else{
      _addDetail2(agenda, 'D', 'en', 'serialNumberDirectionEn');
      _addDetail2(agenda, 'R', 'en', 'serialNumberResolutionEn');
    }
  }

  void addArResolution(Agenda agenda) {
    if(_enableArabicAndEnglish == true){
      // _addDetail(agenda, 'D', 'ar', 'serialNumberDirectionAr');
      _addDetail(agenda, 'R', 'ar', 'serialNumberResolutionAr');
      _addDetail(agenda, 'R', 'en', 'serialNumberResolutionEn');
      // _addDetail(agenda, 'D', 'en', 'serialNumberDirectionEn');
    }else{
      _addDetail(agenda, 'D', 'ar', 'serialNumberDirectionAr');
      _addDetail(agenda, 'R', 'ar', 'serialNumberResolutionAr');
    }
  }

  void addDirection2(Agenda agenda) {
    if(_enableArabicAndEnglish == true){
      _addDetail2(agenda, 'R', 'en', 'serialNumberResolutionEn');
      _addDetail2(agenda, 'D', 'en', 'serialNumberDirectionEn');
      _addDetail2(agenda, 'D', 'ar', 'serialNumberDirectionAr');
      _addDetail2(agenda, 'R', 'ar', 'serialNumberResolutionAr');
    }else{
      _addDetail2(agenda, 'R', 'en', 'serialNumberResolutionEn');
      _addDetail2(agenda, 'D', 'en', 'serialNumberDirectionEn');
    }
  }

  void addDirection(Agenda agenda) {
    if(_enableArabicAndEnglish == true){
      _addDetail(agenda, 'R', 'en', 'serialNumberResolutionEn');
      _addDetail(agenda, 'D', 'en', 'serialNumberDirectionEn');
      _addDetail(agenda, 'D', 'ar', 'serialNumberDirectionAr');
      _addDetail(agenda, 'R', 'ar', 'serialNumberResolutionAr');
    }else{
      _addDetail(agenda, 'R', 'en', 'serialNumberResolutionEn');
      _addDetail(agenda, 'D', 'en', 'serialNumberDirectionEn');
    }
  }

  void addArDirection(Agenda agenda) {
    if(_enableArabicAndEnglish == true){
      _addDetail(agenda, 'D', 'ar', 'serialNumberDirectionAr');
      _addDetail(agenda, 'R', 'ar', 'serialNumberResolutionAr');
      _addDetail(agenda, 'R', 'en', 'serialNumberResolutionEn');
      _addDetail(agenda, 'D', 'en', 'serialNumberDirectionEn');
    }else{
      _addDetail(agenda, 'D', 'ar', 'serialNumberDirectionAr');
      _addDetail(agenda, 'R', 'ar', 'serialNumberResolutionAr');
    }
  }

  void removeResolution(Agenda agenda, int detailId) {
    // Check if the detail list is not null
    if (agenda.details?.detailDetails != null) {
      // Remove the resolution with the matching detailId
      agenda.details!.detailDetails!.removeWhere((detail) => detail.detailId == detailId && detail.serialNumberResolutionEn != null);
      // Remove the associated controller from the provider (if exists)
      if (englishResolutionControllers.containsKey(detailId)) {
        englishResolutionControllers[detailId]!.dispose();
        englishResolutionControllers.remove(detailId);
      }
      notifyListeners(); // Update UI after removing the resolution
    }
  }

  void removeDirection(Agenda agenda, int detailId) {
    // Check if the detail list is not null
    if (agenda.details?.detailDetails != null) {
      // Remove the direction with the matching detailId
      agenda.details!.detailDetails!.removeWhere((detail) => detail.detailId == detailId && detail.serialNumberDirectionEn != null);

      // Remove the associated controller from the provider (if exists)
      if (englishDirectionControllers.containsKey(detailId)) {
        englishDirectionControllers[detailId]!.dispose();
        englishDirectionControllers.remove(detailId);
      }

      notifyListeners(); // Update UI after removing the direction
    }
  }

  void removeArabicResolution(Agenda agenda, int id) {
    // Remove the Arabic resolution based on the specific field
    agenda.details!.detailDetails!.removeWhere((detail) =>
    detail.detailId == id && detail.serialNumberResolutionAr != null);
    notifyListeners();
  }

  void removeArabicDirection(Agenda agenda, int id) {
    // Remove the Arabic direction based on the specific field
    agenda.details!.detailDetails!.removeWhere((detail) =>
    detail.detailId == id && detail.serialNumberDirectionAr != null);
    notifyListeners();
  }

  // Modified _generateSerial to handle null or empty lists
  String _generateSerial(String type, String agendaTitle, List<DetailDetails> details, String serialField) {
    final now = DateTime.now();
    final dateString = DateFormat('yyyy-MM-dd').format(now);
    final firstChar = agendaTitle.isNotEmpty ? agendaTitle[0] : 'X';

    int count = 1;

    if (details.isNotEmpty) {
      final lastDetail = details.last;
      String? lastSerial;

      // Determine which serial field to use
      if (serialField == 'serialNumberResolutionEn') {
        lastSerial = lastDetail.serialNumberResolutionEn;
      } else if (serialField == 'serialNumberDirectionEn') {
        lastSerial = lastDetail.serialNumberDirectionEn;
      } else if (serialField == 'serialNumberResolutionAr') {
        lastSerial = lastDetail.serialNumberResolutionAr;
      } else if (serialField == 'serialNumberDirectionAr') {
        lastSerial = lastDetail.serialNumberDirectionAr;
      }

      if (lastSerial != null) {
        final regex = RegExp(r'(\d+)$');
        final match = regex.firstMatch(lastSerial);
        if (match != null) {
          count = int.parse(match.group(1)!) + 1;
        }
      }
    }

    return '$dateString-$firstChar/$type${count.toString().padLeft(2, '0')}';
  }

  @override
  void dispose() {
    for (var controller in attendedNameControllers) {
      controller.dispose();
    }
    for (var controller in positionControllers) {
      controller.dispose();
    }
    for (var controller in  arabicAttendedNameControllers) {
      controller.dispose();
    }
    for (var controller in  arabicPositionControllers) {
      controller.dispose();
    }

    for (var controller in englishResolutionControllers.values) {
      controller.dispose();
    }
    for (var controller in englishDirectionControllers.values) {
      controller.dispose();
    }
    for (var controller in arabicResolutionControllers.values) {
      controller.dispose();
    }
    for (var controller in arabicDirectionControllers.values) {
      controller.dispose();
    }

    print("Disposing AgendaPageProvider");
    _isActive = false;
    super.dispose();
}

  // Function to collect data (example)
  Map<String, dynamic> _collectData(Agenda agenda) {
    // Collect resolutions and directions data
    List<Map<String, dynamic>> collectedResolutions = [];
    List<Map<String, dynamic>> collectedDirections = [];

    for (var resolution in agenda.details!.detailDetails!
        .where((detail) => detail.serialNumberResolutionEn != null)) {
      collectedResolutions.add({
        'serial': resolution.serialNumberResolutionEn,
      });
    }

    for (var direction in agenda.details!.detailDetails!
        .where((detail) => detail.serialNumberDirectionEn != null)) {
      collectedDirections.add({
        'serial': direction.serialNumberDirectionEn,
      });
    }

    return {
      'resolutions': collectedResolutions,
      'directions': collectedDirections,
      // Add any additional fields your backend expects
    };
  }

// Method to submit the data
  Future<void> submitAgendaDetails(Map<String, dynamic> data) async {
    setLoading(true);
    log.i(data);
    final response = await networkHandler.post1('/insert-agenda-details', data);

    if (response.statusCode == 200 || response.statusCode == 201) {
      // log.d('Data submitted successfully');
      log.d(response.body);
      var responseData = json.decode(response.body);

      var responseMinuteData = responseData['data'];
      _minute = Minute.fromJson(responseMinuteData['minute']);
      log.d(_minute);
      minutesData!.minutes!.add(_minute);
      log.d(responseData['data']);
      setLoading(true);
      notifyListeners();
      if (_isActive) {
        notifyListeners();
      }
    } else {
      setLoading(false);
      setIsBack(false);
      log.d('Failed to submit data');
      log.d(response.body);
    }
    setLoading(false);
    notifyListeners();
  }


  Future<void> submitUpdateMinuteAgendaDetails(Map<String, dynamic> data) async {
    // setLoading(true);
    log.i(data);
    final response = await networkHandler.post1('/update-minute-agenda-details', data);
  //
    if (response.statusCode == 200 || response.statusCode == 201) {
      log.d('Data submitted successfully');

      setLoading(false);
      notifyListeners();
      if (_isActive) {
        notifyListeners();
      }
    } else {
      setLoading(false);
      setIsBack(false);
      log.d('Failed to submit data');
      log.d(response.body);
    }
    setLoading(false);
    notifyListeners();
  }

  Future getListAgendas(String meetingId) async {
    if (!_isActive) return; // Exit if provider is disposed
    try {
    final response = await networkHandler.get('/get-list-agenda-by-meetingId/$meetingId');
    if (!_isActive) return;
    if (response.statusCode == 200 || response.statusCode == 201) {
      log.d("get-list-agendas response statusCode == 200");
      final responseData = json.decode(response.body);
      final agendasData = responseData['data'];
      log.d(agendasData);
      listAgenda = Agendas.fromJson(agendasData);
      initializeControllers();
      if (_isActive) {
        notifyListeners();
      }
    } else {
      log.d("get-list-agendas response statusCode unknown");
      log.d(response.statusCode);
      log.d(json.decode(response.body)['message']);
      if (_isActive) {
        notifyListeners();
      }
    }
    } catch (error) {
      log.d("get-list-agendas response statusCode unknown $error");
      if (_isActive) {
        notifyListeners();
      }
    }
  }

  void addField() {
    arabicAttendedNameControllers.add(TextEditingController());
    arabicPositionControllers.add(TextEditingController());
    attendedNameControllers.add(TextEditingController());
    positionControllers.add(TextEditingController());
    notifyListeners();
  }

  void removeField(int index) {
    arabicAttendedNameControllers[index].dispose();
    arabicPositionControllers[index].dispose();
    attendedNameControllers[index].dispose();
    positionControllers[index].dispose();
    attendedNameControllers.removeAt(index);
    positionControllers.removeAt(index);
    arabicAttendedNameControllers.removeAt(index);
    arabicPositionControllers.removeAt(index);
    notifyListeners();
  }

  void setStepIndex(int index) {
    currentIndex = index;
    notifyListeners();
  }

  void onStepContinue() {
    if (currentIndex <= 0) {
      setStepIndex(currentIndex + 1);
    }
  }

  void onStepCancel() {
    if (currentIndex > 0) {
      setStepIndex(currentIndex - 1);
    }
  }
}
