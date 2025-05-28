import 'dart:convert';
import 'dart:io';

import 'package:diligov_members/models/agenda_model.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../NetworkHandler.dart';
import '../models/combined_collection_board_committee_model.dart';
import '../models/meeting_model.dart';
import '../models/preview_meeting_model.dart';
import '../models/user.dart';
class MeetingPageProvider extends ChangeNotifier{

  var log = Logger();
  User user = User();
  NetworkHandler networkHandler = NetworkHandler();

  Meetings? dataOfMeetings;
  CombinedCollectionBoardCommitteeData? collectionBoardCommitteeData;
  Agendas? listAgenda;
  PreviewMeetingModel? previewMeeting;
  String _yearSelected = '2024';

  bool _enableArabic = false;
  bool _enableEnglish = true;
  bool _enableArabicAndEnglish = false;
  bool get enableArabic => _enableArabic;
  bool get enableEnglish => _enableEnglish;
  bool get enableArabicAndEnglish => _enableArabicAndEnglish;

  void toggleEnableArabic() {
    _enableArabic = !_enableArabic;
    _enableEnglish = false;
    _enableArabicAndEnglish= false;
    log.i('arabic');
    notifyListeners();
  }

  void toggleEnableEnglish() {
    _enableEnglish = !_enableEnglish;
    _enableArabic = false;
    _enableArabicAndEnglish= false;
    log.i('english');
    notifyListeners();
  }

  void toggleEnableArabicAndEnglish() {
    _enableArabicAndEnglish = !_enableArabicAndEnglish;
    _enableEnglish = false;
    _enableArabic = false;
    log.i('dual');
    notifyListeners();
  }

  bool _isBack = false;
  bool get isBack => _isBack;
  void setIsBack(value) async {
    _isBack =  value;
    notifyListeners();
  }

  bool _loading = false;
  bool get loading => _loading;
  String get yearSelected => _yearSelected;

  void setLoading(value) async {
    _loading =  value;
    notifyListeners();
  }

  void setYearSelected(year) async {
    _yearSelected =  year;
    notifyListeners();
  }

  final TextEditingController meetingTitleController = TextEditingController();
  final TextEditingController meetingDescriptionController = TextEditingController();
  final TextEditingController startDateController = TextEditingController();
  final TextEditingController endDateController = TextEditingController();
  final TextEditingController moreInfoController = TextEditingController();
  final TextEditingController linkController = TextEditingController();

  late List<TextEditingController> titleControllers = [];
  late List<TextEditingController> descriptionControllers = [];
  late List<TextEditingController> timeControllers = [];
  late List<TextEditingController> userControllers = [];

  late List<TextEditingController> arabicTitleControllers = [];
  late List<TextEditingController> arabicDescriptionControllers = [];
  late List<TextEditingController> arabicTimeControllers = [];
  late List<TextEditingController> arabicUserControllers = [];

  late List<List<TextEditingController>> titleControllersList = [];
  late List<List<TextEditingController>> descriptionControllersList = [];
  late List<List<TextEditingController>> timeControllersList = [];
  late List<List<TextEditingController>> userControllersList = [];

  late List<List<TextEditingController>> arabicTitleControllersList = [];
  late List<List<TextEditingController>> arabicDescriptionControllersList = [];
  late List<List<TextEditingController>> arabicTimeControllersList = [];
  late List<List<TextEditingController>> arabicUserControllersList = [];

  int _currentStep = 0;
  List _membersListIds = [];
  List _selectedMembers = [];
  List _listOfMembersData = [];

  List _arabicMembersListIds = [];
  List _arabicSelectedMembers = [];
  List _arabicListOfMembersData = [];

  int? visibleActionIndex;

  List<List<String>> fileName = [];
  List<List<String>> fileContent = [];
  List<List<String>> fileBase64One = [];
  List<List<String>> filePath = [];

  List<List<String>> fileNameTwo = [];
  List<List<String>> fileContentTwo = [];
  List<List<String>> fileBase64Two = [];
  List<List<String>> filePathTwo = [];


  List<List<List<String>>> fileNameChild = [];
  List<List<List<String>>> fileContentChild = [];
  List<List<List<String>>> fileBase64OneChild = [];
  List<List<List<String?>>> filePathChild = [];


  List<List<List<String>>> fileNameTwoChild = [];
  List<List<List<String>>> fileContentTwoChild = [];
  List<List<List<String>>> fileBase64TwoChild = [];
  List<List<List<String>>> filePathTwoChild = [];


  List<List<Widget>> childItems = [];
  List<List<Widget>> arabicChildItems = [];

  Map<String, dynamic>? combined;
  int get currentStep => _currentStep;

  List get membersListIds => _membersListIds;
  List get selectedMembers => _selectedMembers;
  List get listOfMembersData => _listOfMembersData;

  List get arabicMembersListIds => _arabicMembersListIds;
  List get arabicSelectedMembers => _arabicSelectedMembers;
  List get arabicListOfMembersData => _arabicListOfMembersData;

  Meeting _meeting = Meeting();
  Meeting get meeting => _meeting;
  Map<int, bool> showActionsMap = {};
  String? selectedCombined;

  List<Meeting>? get meetings => dataOfMeetings?.meetings;

  int _currentPage = 0;
  int get currentPage => _currentPage;
  void updatePage(int page) {
    _currentPage = page;
    // log.i("_currentPage _currentPage is $_currentPage");
    notifyListeners();
  }

  Future<void> notifyPageChange(String fileId, int newPage, ) async {
   Map<String, dynamic> data = {'fileId': fileId,'page': newPage};
    final response = await networkHandler.post1('/page-change', data);

    if (response.statusCode != 200) {
      print('Failed to notify page change: ${response.body}');
    }else{
      print("Notified backend about page change to $newPage");
      // final data = json.decode(response.body);
      // _currentPage = data['pageNumber'];
      // print("data data $data");
      // var pageNumber = responseData['pageNumber'];
      updatePage(_currentPage);
      print('notifyPageChange  page change: ${_currentPage}');

      notifyListeners();
    }
  }


  bool _showMeetingForm = false;
  bool _showPublished = true;
  bool _showUnPublished = false;
  bool _showArchived = false;
  final int totalSteps = 2;
  bool get showPublished => _showPublished;
  bool get showArchived => _showArchived;
  bool get showUnPublished => _showUnPublished;
  bool get showMeetingForm => _showMeetingForm;

  bool _isAnyFileNameNull = false;
  bool get isAnyFileNameNull => _isAnyFileNameNull;

  DateTime _selectedDate  = DateTime.now();
  DateTime get selectedDate => _selectedDate;
  void setDate(DateTime date) => _selectedDate = date;
  List<Meeting> get eventsOfSelectedDate => dataOfMeetings!.meetings!;
  String? selectedMeetingId;

  List<String> agendaIds = [];
  late List<List<String>> childrenAgendaIds;
  String? _dropdownError;
  String? get dropdownError => _dropdownError;

  bool _waitingForOpeningFileOne = false;
  bool get waitingForOpeningFileOne => _waitingForOpeningFileOne;

  bool _waitingForOpeningFileChild = false;
  bool get waitingForOpeningFileChild => _waitingForOpeningFileChild;

  bool _arabicWaitingForOpeningFileOne = false;
  bool get arabicWaitingForOpeningFileOne => _arabicWaitingForOpeningFileOne;

  bool _arabicWaitingForOpeningFileChild = false;
  bool get arabicWaitingForOpeningFileChild => _arabicWaitingForOpeningFileChild;


  List<Map<String, int>> _agendaParentMaps = [];
  List<Map<String, int>> _agendaChildrenMaps = [];


  List<Map<String, int>> _agendaArabicParentMaps = [];
  List<Map<String, int>> _agendaArabicChildrenMaps = [];

  List<Map<String, int>> get agendaParentMaps => _agendaParentMaps;
  List<Map<String, int>> get agendaChildrenMaps => _agendaChildrenMaps;

  List<Map<String, int>> get agendaArabicParentMaps => _agendaArabicParentMaps;
  List<Map<String, int>> get agendaArabicChildrenMaps => _agendaArabicChildrenMaps;


  bool _isVisible = true;
  bool get isVisible => _isVisible;

  void toggleVisibility() {
    _isVisible = !_isVisible;
    notifyListeners();
  }



  void setWaitingForOpeningFileOne(bool value){
    _waitingForOpeningFileOne = value;
    notifyListeners();
  }

  void setWaitingForOpeningFileChild(bool value){
    _waitingForOpeningFileChild = value;
    notifyListeners();
  }

  void setArabicWaitingForOpeningFile(bool value){
    _arabicWaitingForOpeningFileOne   = value;
    notifyListeners();
  }

  void setArabicWaitingForOpeningFileChild(bool value){
    _arabicWaitingForOpeningFileChild   = value;
    notifyListeners();
  }

  void addAgendaParentIds(String value) {
    _agendaParentMaps.add({
      "remove_agenda_id": int.parse(value),
    });
    notifyListeners();
  }

  void addAgendaChildrenIds(String value) {
    _agendaChildrenMaps.add({
      "remove_agenda_children_id": int.parse(value),
    });
    notifyListeners();
  }

  void addArabicAgendaParentIds(String value) {
    _agendaArabicParentMaps.add({
      "remove_arabic_agenda_id": int.parse(value),
    });
    notifyListeners();
  }

  void addArabicAgendaChildrenIds(String value) {
    _agendaArabicChildrenMaps.add({
      "remove_arabic_agenda_children_id": int.parse(value),
    });
    notifyListeners();
  }

  // Method to handle the first file at a given index
  void setFileAtIndex(int index, List<String> pickedFileName, List<String> pickedFileContent, List<String?> pickedFilePath) {
    // Ensure the lists are large enough to hold the value at the specified index
    if (fileName.length <= index) {
      // Extend the list to the required length
      fileName.addAll(List.generate(index - fileName.length + 1, (_) => []));
      fileBase64One.addAll(List.generate(index - fileBase64One.length + 1, (_) => []));
      filePath.addAll(List.generate(index - filePath.length + 1, (_) => []));
    }
    // Assign the file names and base64 content to the correct index

    // Ensure the inner list at the parent index is large enough for the child index
    while (filePath.length <= index) {
      filePath.add([]); // Add an empty list for the child index
    }
    fileName[index] = pickedFileName;
    fileBase64One[index] = pickedFileContent;
    // Insert pickedFilePath into the correct index of filePath
    // Convert pickedFilePath from List<String?> to List<String> by replacing null values
    List<String> nonNullableFilePath = pickedFilePath.map((e) => e ?? '').toList();
    filePath[index] = nonNullableFilePath;
    // Log the content for verification
    log.i(fileBase64One[index]);
    log.i(fileName[index]);
    log.i("filePath after insertion: ${filePath[index]}");
    notifyListeners(); // Notify listeners about the changes
  }

  // Method to handle the second file at a given index
  void setFileTwoAtIndex(int index, List<String> pickedFileName, List<String> pickedFileContent , List<String?> pickedFilePath) {
    // Ensure the lists are large enough to hold the value at the specified index
    if (fileNameTwo.length <= index) {
      // Extend the list to the required length
      fileNameTwo.addAll(List.generate(index - fileNameTwo.length + 1, (_) => []));
      fileBase64Two.addAll(List.generate(index - fileBase64Two.length + 1, (_) => []));
      filePathTwo.addAll(List.generate(index - filePathTwo.length + 1, (_) => []));
    }
    // Assign the second file names and base64 content to the correct index
    fileNameTwo[index] = pickedFileName;
    fileBase64Two[index] = pickedFileContent;
    List<String> nonNullableFilePath = pickedFilePath.map((e) => e ?? '').toList();

    // filePathTwo[index] = pickedFilePath! ;
    filePathTwo[index] = nonNullableFilePath; // Replace null with empty string
    log.i("filePathTwo filePathTwo filePathTwo filePathTwo ${filePathTwo}");
    log.i(fileBase64Two[index]);
    log.i( fileNameTwo[index]);
    notifyListeners(); // Notify listeners about the changes
  }

  // Method to handle the first file at a given index
  void setFileChildAtIndex(int parentIndex, int childIndex, List<String> pickedFileName, List<String> pickedFileContent, List<String?> pickedFilePath){
    // Ensure the outer list is large enough for the parent index
    while (fileNameChild.length <= parentIndex) {
      fileNameChild.add([]); // Add an empty list for new parent index
      fileBase64OneChild.add([]); // Add an empty list for fileBase64OneChild
      filePathChild.add([]); // Add an empty list for filePathChild
    }

    // Ensure the inner list at the specified parent index is large enough for the child index
    while (fileNameChild[parentIndex].length <= childIndex) {
      fileNameChild[parentIndex].add([]); // Add an empty list for new child index
      fileBase64OneChild[parentIndex].add([]); // Add an empty list for fileBase64OneChild
      filePathChild[parentIndex].add([]); // Add an empty list for filePathChild
    }

    while (filePathChild.length <= parentIndex) {
      filePathChild.add([]); // Add an empty list for new parent index
    }

    // Ensure the inner list at the parent index is large enough for the child index
    while (filePathChild[parentIndex].length <= childIndex) {
      filePathChild[parentIndex].add([]); // Add an empty list for the child index
    }
    // Assign the file names, base64 content, and non-nullable file path to the correct indices
    fileNameChild[parentIndex][childIndex] = pickedFileName;
    fileBase64OneChild[parentIndex][childIndex] = pickedFileContent;

    // Convert pickedFilePath from List<String?> to List<String> by replacing null values
    List<String> nonNullableFilePath = pickedFilePath.map((e) => e ?? '').toList();

    // Assign the file paths to the correct indices
    filePathChild[parentIndex][childIndex] = nonNullableFilePath;

    // Logging for debugging
    log.i('File Paths: ${filePathChild}');

    // Logging for debugging
    log.i('File Content: ${fileBase64OneChild[parentIndex][childIndex]}');
    log.i('File Names: ${fileNameChild[parentIndex][childIndex]}');
    log.i("File Paths: ${filePathChild[parentIndex][childIndex]}");

    // Notify listeners about the changes
    notifyListeners();
  }

  // Method to handle the first file at a given index
  void setFileChildTwoAtIndex(int parentIndex, int childIndex, List<String> pickedFileName, List<String> pickedFileContent , List<String?> pickedFilePath) {

    // Ensure the outer list is large enough for the parent index
    while (fileNameTwoChild.length <= parentIndex) {
      fileNameTwoChild.add([]); // Add an empty list for new parent index
      fileBase64TwoChild.add([]); // Add an empty list for fileBase64OneChild
      filePathTwoChild.add([]); // Add an empty list for filePathChild
    }

    // Ensure the inner list at the specified parent index is large enough for the child index
    while (fileNameTwoChild[parentIndex].length <= childIndex) {
      fileNameTwoChild[parentIndex].add([]); // Add an empty list for new child index
      fileBase64TwoChild[parentIndex].add([]); // Add an empty list for fileBase64OneChild
      filePathTwoChild[parentIndex].add([]); // Add an empty list for filePathChild
    }

    while (filePathTwoChild.length <= parentIndex) {
      filePathTwoChild.add([]); // Add an empty list for new parent index
    }

    // Ensure the inner list at the parent index is large enough for the child index
    while (filePathTwoChild[parentIndex].length <= childIndex) {
      filePathTwoChild[parentIndex].add([]); // Add an empty list for the child index
    }
    // Assign the file names, base64 content, and non-nullable file path to the correct indices
    fileNameTwoChild[parentIndex][childIndex] = pickedFileName;
    fileBase64TwoChild[parentIndex][childIndex] = pickedFileContent;

    // Convert pickedFilePath from List<String?> to List<String> by replacing null values
    List<String> nonNullableFilePath = pickedFilePath.map((e) => e ?? '').toList();

    // Assign the file paths to the correct indices
    filePathTwoChild[parentIndex][childIndex] = nonNullableFilePath;

    // Logging for debugging
    log.i('File Paths: ${filePathTwoChild}');

    // Logging for debugging
    log.i('File Content: ${fileBase64TwoChild[parentIndex][childIndex]}');
    log.i('File Names: ${fileNameTwoChild[parentIndex][childIndex]}');
    log.i("File Paths: ${filePathTwoChild[parentIndex][childIndex]}");

    // Notify listeners about the changes
    notifyListeners();
  }

  // Function to set the selected meeting
  void setSelectedMeetingId(String? id) {
    selectedMeetingId = id;
    notifyListeners();
  }

  void initializeControllers(int count) {
    titleControllers = List.generate(count, (i) => TextEditingController());
    descriptionControllers = List.generate(count, (i) => TextEditingController());
    timeControllers = List.generate(count, (i) => TextEditingController());
    userControllers = List.generate(count, (i) => TextEditingController());

    arabicTitleControllers = List.generate(count, (i) => TextEditingController());
    arabicDescriptionControllers = List.generate(count, (i) => TextEditingController());
    arabicTimeControllers = List.generate(count, (i) => TextEditingController());
    arabicUserControllers = List.generate(count, (i) => TextEditingController());
    // initialAndEnsureListCapacity(count);
  }

  void initializeFromEvent(Meeting event) {
    // Initialize main meeting fields
    meeting.meetingId = event.meetingId!;
    meetingTitleController.text = event.meetingTitle!;
    startDateController.text = event.meetingStart.toString();
    endDateController.text = event.meetingEnd.toString();
    meetingDescriptionController.text = event.meetingDescription!;
    moreInfoController.text = event.meetingMediaName ?? '';
    linkController.text = event.meetingBy ?? '';

    // Clear previous data
    agendaIds =[];
    childrenAgendaIds =[];
    arabicChildItems =[];
    childItems =[];

    // Initialize agenda items if they exist
    if (event.agendas?.isNotEmpty ?? false) {
      // Initialize the controllers based on the number of agendas
      initializeControllers(event.agendas!.length);
      childrenAgendaIds = List.generate(event.agendas!.length, (_) => []);
      childItems = List.generate(event.agendas!.length, (i) => []);
      arabicChildItems = List.generate(event.agendas!.length, (i) => []);

      for (int i = 0; i < event.agendas!.length; i++) {

        final agenda = event.agendas![i];
        agendaIds.add(agenda.agendaId.toString() ?? '') ;

        void ensure2DListCapacity(List<List<String>> list, int index) {
          while (list.length < index) {
            list.add(['']); // Add a new list for children of this parent
          }
        }

        // Check and initialize the file lists if they are null before assigning values
        ensure2DListCapacity(fileName, i);
        ensure2DListCapacity(fileBase64One, i);
        ensure2DListCapacity(fileNameTwo, i);
        ensure2DListCapacity(fileBase64Two, i);

        fileName.add(agenda.agendaFileOneName ?? []);
        fileBase64One.add(agenda.agendaFileOneName ?? []);

        fileBase64Two.add(agenda.agendaFileTwoName ?? []);
        fileNameTwo.add(agenda.agendaFileTwoName ?? []);

        titleControllers[i].text = agenda.agendaTitle ?? '';
        descriptionControllers[i].text = agenda.agendaDescription ?? '';
        timeControllers[i].text = agenda.agendaTime ?? '';
        userControllers[i].text = agenda.presenter.toString() ?? '';
        
        arabicTitleControllers[i].text = agenda.agendaTitleAr ?? '';
        arabicDescriptionControllers[i].text = agenda.agendaDescriptionAr ?? '';
        arabicTimeControllers[i].text = agenda.agendaTimeAr ?? '';
        arabicUserControllers[i].text = agenda.presenterAr.toString() ?? '';

        if (agenda.agendaChildren?.isNotEmpty ?? false) {
          final childCount = agenda.agendaChildren!.length;
          initializeChildControllers(i, childCount);
          childrenAgendaIds[i] = List.generate(childCount, (_) => '');

          for (int j = 0; j < childCount; j++) {
            addNewFormForEnglishChildren(i);
            addArabicChildItem(i);
            final childAgenda = agenda.agendaChildren![j];
            childrenAgendaIds[i][j] = childAgenda.childAgendaId.toString() ?? '';

            fileNameChild[i][j] =  childAgenda.childAgendaFileOneName ?? [];
            fileBase64OneChild[i][j] =  childAgenda.childAgendaFileOneName ?? [];

            fileNameTwoChild[i][j] =  childAgenda.childAgendaFileTwoName ?? [];
            fileBase64TwoChild[i][j] =  childAgenda.childAgendaFileTwoName ?? [];

            titleControllersList[i][j].text = childAgenda.childAgendaTitle ?? '';
            descriptionControllersList[i][j].text = childAgenda.childAgendaDescription ?? '';
            timeControllersList[i][j].text = childAgenda.childAgendaTime ?? '';
            userControllersList[i][j].text = childAgenda.childAgendaPresenter.toString();

            arabicTitleControllersList[i][j].text = childAgenda.childAgendaTitleAr ?? '';
            arabicDescriptionControllersList[i][j].text = childAgenda.childAgendaDescriptionAr ?? '';
            arabicTimeControllersList[i][j].text = childAgenda.childAgendaTimeAr ?? '';
            arabicUserControllersList[i][j].text = childAgenda.childAgendaPresenterAr.toString();
          }
        }else{
          childrenAgendaIds = [];
          childItems.add([]);
          arabicChildItems = [];
        }
      }
    } else {
      // Initialize childrenAgendaIds as an empty list if there are no agendas
      childrenAgendaIds = [];
      childItems.add([]);
      arabicChildItems = [];
    }

    // Notify listeners to update the UI
    Future.microtask(() => notifyListeners());
  }

  void initializeChildControllers(int parentIndex, int childCount) {
    // Ensure the parentIndex is valid and lists are initialized
    while (arabicTitleControllersList.length <= parentIndex) {
      titleControllersList.add([]);
      descriptionControllersList.add([]);
      timeControllersList.add([]);
      userControllersList.add([]);

      arabicTitleControllersList.add([]);
      arabicDescriptionControllersList.add([]);
      arabicTimeControllersList.add([]);
      arabicUserControllersList.add([]);

      while (fileNameChild.length <= parentIndex) {
        fileNameChild.add([]);
        fileContentChild.add([]);
        fileBase64OneChild.add([]);
        fileNameTwoChild.add([]);
        fileContentTwoChild.add([]);
        fileBase64TwoChild.add([]);
      }
    }

    // Initialize child controllers
    if (titleControllersList[parentIndex].length < childCount) {
      titleControllersList[parentIndex] = List.generate(childCount, (_) => TextEditingController());
    }

    if (descriptionControllersList[parentIndex].length < childCount) {
      descriptionControllersList[parentIndex] = List.generate(childCount, (_) => TextEditingController());
    }
    if (timeControllersList[parentIndex].length < childCount) {
      timeControllersList[parentIndex] = List.generate(childCount, (_) => TextEditingController());
    }
    if (userControllersList[parentIndex].length < childCount) {
      userControllersList[parentIndex] = List.generate(childCount, (_) => TextEditingController());
    }

    // Initialize Arabic child controllers
    if (arabicTitleControllersList[parentIndex].length < childCount) {
      arabicTitleControllersList[parentIndex] = List.generate(childCount, (_) => TextEditingController());
    }
    if (arabicDescriptionControllersList[parentIndex].length < childCount) {
      arabicDescriptionControllersList[parentIndex] = List.generate(childCount, (_) => TextEditingController());
    }
    if (arabicTimeControllersList[parentIndex].length < childCount) {
      arabicTimeControllersList[parentIndex] = List.generate(childCount, (_) => TextEditingController());
    }
    if (arabicUserControllersList[parentIndex].length < childCount) {
      arabicUserControllersList[parentIndex] = List.generate(childCount, (_) => TextEditingController());
    }
  }

  void addNewEnglishParentForm() {
    titleControllers.add(TextEditingController());
    descriptionControllers.add(TextEditingController());
    timeControllers.add(TextEditingController());
    userControllers.add(TextEditingController());
    childItems.add([]);
    titleControllersList.add([]);
    descriptionControllersList.add([]);
    timeControllersList.add([]);
    userControllersList.add([]);
    // Initialize lists for multiple files
    fileName.add(['']);
    fileContent.add(['']);
    fileBase64One.add(['']);
    filePath.add(['']);
    fileNameTwo.add(['']);
    fileContentTwo.add(['']);
    fileBase64Two.add(['']);

    // Initialize child file lists
    fileNameChild.add([]);
    fileContentChild.add([]);
    fileBase64OneChild.add([]);
    filePathChild = [];

    filePathTwoChild =[];
    fileNameTwoChild.add([]);
    fileContentTwoChild.add([]);
    fileBase64TwoChild.add([]);
    notifyListeners();
  }

  void removeButtonForEnglishParentFormFields(int index) {
    if (index < 0 || index >= titleControllers.length) {
      print("Index out of range: $index");
      return; // Guard clause to handle out-of-range index
    }

    log.i("Removing Index: $index");

    // Dispose and remove main field controllers
    titleControllers[index].dispose();
    descriptionControllers[index].dispose();
    timeControllers[index].dispose();
    userControllers[index].dispose();

    titleControllers.removeAt(index);
    descriptionControllers.removeAt(index);
    timeControllers.removeAt(index);
    userControllers.removeAt(index);

    // Safely remove from lists if the index is valid
    if (index < fileName.length) fileName.removeAt(index);
    if (index < fileContent.length) fileContent.removeAt(index);
    if (index < fileBase64One.length) fileBase64One.removeAt(index);

    if (index < fileNameTwo.length) fileNameTwo.removeAt(index);
    if (index < fileContentTwo.length) fileContentTwo.removeAt(index);
    if (index < fileBase64Two.length) fileBase64Two.removeAt(index);

    if (index < filePath.length) filePath.removeAt(index);
    if (index < filePathTwo.length) filePath.removeAt(index);

    // Remove corresponding child controllers and lists if they exist
    if (index < childItems.length) {
      // Remove child controllers
      // Ensure the parent index exists in the child lists
      if (index < titleControllersList.length) {
        for (int i = titleControllersList[index].length - 1; i >= 0; i--) {
          // Safely remove each child controller
          removeEnglishChildItem(index, i);
        }

        // Remove the child controller lists after clearing their contents
        titleControllersList.removeAt(index);
        descriptionControllersList.removeAt(index);
        timeControllersList.removeAt(index);
        userControllersList.removeAt(index);
      }

      childItems.removeAt(index);
      if (index < titleControllersList.length) titleControllersList.removeAt(index);
      if (index < descriptionControllersList.length) descriptionControllersList.removeAt(index);
      if (index < timeControllersList.length) timeControllersList.removeAt(index);
      if (index < userControllersList.length) userControllersList.removeAt(index);

      // Safely remove from child file lists if the index is valid
      if (index < fileNameChild.length) fileNameChild.removeAt(index);
      if (index < fileContentChild.length) fileContentChild.removeAt(index);
      if (index < fileBase64OneChild.length) fileBase64OneChild.removeAt(index);
      if (index < fileNameTwoChild.length) fileNameTwoChild.removeAt(index);
      if (index < filePathTwoChild.length) filePathTwoChild.removeAt(index);
      if (index < fileContentTwoChild.length) fileContentTwoChild.removeAt(index);
      if (index < filePathChild.length) filePathChild.removeAt(index);
    }

    notifyListeners(); // Notify listeners after state changes
  }

  void addNewFormForEnglishChildren(int parentIndex) {
    // Ensure the parent index is valid
    // Ensure the parent index is valid
    if (parentIndex >= 0) {

      // Helper function to ensure a list has enough capacity and initialize elements
      void ensureListCapacity<T>(List<List<T>> list, int index) {
        while (list.length <= index) {
          list.add([]); // Add an empty list of the correct type
        }
      }

      // Helper function to ensure a 3D list has enough capacity
      void ensure3DListCapacity(List<List<List<String>>> list, int index) {
        while (list.length <= index) {
          list.add([]); // Add a new list for children of this parent
        }
      }

      // Step 1: Ensure the parent list for child items exists (as a List<List<Widget>>)
      ensureListCapacity<Widget>(childItems, parentIndex);

      // Step 2: Ensure the controller lists exist
      ensureListCapacity<TextEditingController>(titleControllersList, parentIndex);
      ensureListCapacity<TextEditingController>(descriptionControllersList, parentIndex);
      ensureListCapacity<TextEditingController>(timeControllersList, parentIndex);
      ensureListCapacity<TextEditingController>(userControllersList, parentIndex);

      // Step 3: Add a new child widget to the parent's list
      childItems[parentIndex].add(
          Text('Child Item ${childItems[parentIndex].length + 1}') // Example widget
      );

      // Step 4: Add new controllers for each child field for this parent
      titleControllersList[parentIndex].add(TextEditingController());
      descriptionControllersList[parentIndex].add(TextEditingController());
      timeControllersList[parentIndex].add(TextEditingController());
      userControllersList[parentIndex].add(TextEditingController());

      // Step 5: Ensure the 3D file-related lists are initialized and add entries for the new child
      ensure3DListCapacity(fileNameChild, parentIndex);
      ensure3DListCapacity(fileContentChild, parentIndex);
      ensure3DListCapacity(fileBase64OneChild, parentIndex);
      ensure3DListCapacity(fileNameTwoChild, parentIndex);
      ensure3DListCapacity(fileContentTwoChild, parentIndex);
      ensure3DListCapacity(fileBase64TwoChild, parentIndex);

      // Now add new lists for the new child within the parent at the given index
      fileNameChild[parentIndex].add([]);
      fileContentChild[parentIndex].add([]);
      fileBase64OneChild[parentIndex].add([]);
      fileNameTwoChild[parentIndex].add([]);
      fileContentTwoChild[parentIndex].add([]);
      fileBase64TwoChild[parentIndex].add([]);

      // Optionally add initial values for the newly created file lists for this child
      fileNameChild[parentIndex].last.add('');  // Add an empty string as a placeholder for file name
      fileContentChild[parentIndex].last.add('');  // Add empty string for file content
      fileBase64OneChild[parentIndex].last.add('');  // Add empty string for base64 file data
      fileNameTwoChild[parentIndex].last.add('');  // Add an empty string for file name (second file set)
      fileContentTwoChild[parentIndex].last.add('');  // Add empty string for file content (second file set)
      fileBase64TwoChild[parentIndex].last.add('');  // Add empty string for base64 data (second file set)

      // Step 6: Notify listeners to update the UI
      notifyListeners();
    }
  }

  void initialAndEnsureListCapacity(int parentIndex) {
    // Ensure the parent index is valid
    // Ensure the parent index is valid
    if (parentIndex >= 0) {

      // Helper function to ensure a list has enough capacity and initialize elements
      void ensureListCapacity<T>(List<List<T>> list, int index) {
        while (list.length <= index) {
          list.add([]); // Add an empty list of the correct type
        }
      }

      // Helper function to ensure a 3D list has enough capacity
      void ensure2DListCapacity(List<List<String>> list, int index) {
        while (list.length <= index) {
          list.add([]); // Add a new list for children of this parent
        }
      }

      void ensure3DListCapacity(List<List<List<String>>> list, int index) {
        while (list.length <= index) {
          list.add([]); // Add a new list for children of this parent
        }
      }

      // Step 1: Ensure the parent list for child items exists (as a List<List<Widget>>)
      ensureListCapacity<Widget>(childItems, parentIndex);

      // Step 3: Add a new child widget to the parent's list
      childItems[parentIndex].add(
          Text('Child Item ${childItems[parentIndex].length + 1}') // Example widget
      );

      // Step 5: Ensure the 3D file-related lists are initialized and add entries for the new child
      ensure3DListCapacity(fileNameChild, parentIndex);
      ensure3DListCapacity(fileContentChild, parentIndex);
      ensure3DListCapacity(fileBase64OneChild, parentIndex);
      ensure3DListCapacity(fileNameTwoChild, parentIndex);
      ensure3DListCapacity(fileContentTwoChild, parentIndex);
      ensure3DListCapacity(fileBase64TwoChild, parentIndex);

      ensure2DListCapacity(fileName, parentIndex);
      ensure2DListCapacity(fileContent, parentIndex);
      ensure2DListCapacity(fileBase64One, parentIndex);
      ensure2DListCapacity(fileNameTwo, parentIndex);
      ensure2DListCapacity(fileContentTwo, parentIndex);
      ensure2DListCapacity(fileBase64Two, parentIndex);

      // Now add new lists for the new child within the parent at the given index
      fileNameChild[parentIndex].add([]);
      fileContentChild[parentIndex].add([]);
      fileBase64OneChild[parentIndex].add([]);
      fileNameTwoChild[parentIndex].add([]);
      fileContentTwoChild[parentIndex].add([]);
      fileBase64TwoChild[parentIndex].add([]);

      // Optionally add initial values for the newly created file lists for this child
      fileNameChild[parentIndex].last.add('');  // Add an empty string as a placeholder for file name
      fileContentChild[parentIndex].last.add('');  // Add empty string for file content
      fileBase64OneChild[parentIndex].last.add('');  // Add empty string for base64 file data
      fileNameTwoChild[parentIndex].last.add('');  // Add an empty string for file name (second file set)
      fileContentTwoChild[parentIndex].last.add('');  // Add empty string for file content (second file set)
      fileBase64TwoChild[parentIndex].last.add('');  // Add empty string for base64 data (second file set)

      fileName.add(['']);
      fileContent.add(['']);
      fileBase64One.add(['']);
      filePath = [];
      fileNameTwo.add(['']);
      fileContentTwo.add(['']);
      fileBase64Two.add(['']);


    }
  }

  void removeEnglishChildItem(int parentIndex, int childIndex) {
    if (parentIndex < 0 || parentIndex >= childItems.length ||
        childIndex < 0 || childIndex >= childItems[parentIndex].length) {
      return; // Guard clause to prevent out-of-range access
    }

    if (parentIndex >= titleControllersList.length || childIndex >= titleControllersList[parentIndex].length) {
      print("Child index out of range for parent: $parentIndex, child: $childIndex");
      return; // Avoid accessing invalid indices
    }
    // Dispose child controllers
    titleControllersList[parentIndex][childIndex].dispose();
    descriptionControllersList[parentIndex][childIndex].dispose();
    timeControllersList[parentIndex][childIndex].dispose();
    userControllersList[parentIndex][childIndex].dispose();

    // Remove controllers from their respective lists
    titleControllersList[parentIndex].removeAt(childIndex);
    descriptionControllersList[parentIndex].removeAt(childIndex);
    timeControllersList[parentIndex].removeAt(childIndex);
    userControllersList[parentIndex].removeAt(childIndex);

    // Safely remove the child files if they exist
    if (parentIndex < fileNameChild.length && childIndex < fileNameChild[parentIndex].length) {
      fileNameChild[parentIndex].removeAt(childIndex);
      fileContentChild[parentIndex].removeAt(childIndex);
      fileBase64OneChild[parentIndex].removeAt(childIndex);
      fileNameTwoChild[parentIndex].removeAt(childIndex);
      fileContentTwoChild[parentIndex].removeAt(childIndex);
      fileBase64TwoChild[parentIndex].removeAt(childIndex);
    }

    // Remove child item widgets
    childItems[parentIndex].removeAt(childIndex);

    if (parentIndex < filePathTwoChild.length && filePathTwoChild[parentIndex].length > childIndex) {
      filePathTwoChild[parentIndex].removeAt(childIndex);
    }
    notifyListeners(); // Notify listeners after state changes
  }

  void addNewArabicParentForm() {
    arabicTitleControllers.add(TextEditingController());
    arabicDescriptionControllers.add(TextEditingController());
    arabicTimeControllers.add(TextEditingController());
    arabicUserControllers.add(TextEditingController());
    arabicChildItems.add([]);  // Empty list for children
    arabicTitleControllersList.add([]);
    arabicDescriptionControllersList.add([]);
    arabicTimeControllersList.add([]);
    arabicUserControllersList.add([]);

    // Initialize lists for multiple files
    fileName.add([]);
    fileContent.add([]);
    fileBase64One.add([]);

    fileNameTwo.add([]);
    fileContentTwo.add([]);
    fileBase64Two.add([]);
    filePath.add([]);
    // Initialize child file lists
    fileNameChild.add([]);
    fileContentChild.add([]);
    fileBase64OneChild.add([]);

    fileNameTwoChild.add([]);
    fileContentTwoChild.add([]);
    fileBase64TwoChild.add([]);
    notifyListeners();
  }

  void addArabicChildItem(int parentIndex) {
    // Ensure the parent index is valid
    if (parentIndex >= 0) {

      // Helper function to ensure a list has enough capacity and initialize elements
      void ensureListCapacity<T>(List<List<T>> list, int index) {
        while (list.length <= index) {
          list.add([]); // Add an empty list of the correct type
        }
      }

      // Helper function to ensure a 3D list has enough capacity
      void ensure3DListCapacity(List<List<List<String>>> list, int index) {
        while (list.length <= index) {
          list.add([]); // Add a new list for children of this parent
        }
      }

      // Step 1: Ensure the parent list for child items exists (as a List<List<Widget>>)
      ensureListCapacity<Widget>(arabicChildItems, parentIndex);

      // Step 2: Ensure the controller lists exist
      ensureListCapacity<TextEditingController>(arabicTitleControllersList, parentIndex);
      ensureListCapacity<TextEditingController>(arabicDescriptionControllersList, parentIndex);
      ensureListCapacity<TextEditingController>(arabicTimeControllersList, parentIndex);
      ensureListCapacity<TextEditingController>(arabicUserControllersList, parentIndex);

      // Step 3: Add a new child widget to the parent's list
      arabicChildItems[parentIndex].add(
          Text('Child Item ${arabicChildItems[parentIndex].length + 1}') // Example widget
      );

      // Step 4: Add new controllers for each child field for this parent
      arabicTitleControllersList[parentIndex].add(TextEditingController());
      arabicDescriptionControllersList[parentIndex].add(TextEditingController());
      arabicTimeControllersList[parentIndex].add(TextEditingController());
      arabicUserControllersList[parentIndex].add(TextEditingController());

      // Step 5: Ensure the 3D file-related lists are initialized and add entries for the new child
      ensure3DListCapacity(fileNameChild, parentIndex);
      ensure3DListCapacity(fileContentChild, parentIndex);
      ensure3DListCapacity(fileBase64OneChild, parentIndex);
      ensure3DListCapacity(fileNameTwoChild, parentIndex);
      ensure3DListCapacity(fileContentTwoChild, parentIndex);
      ensure3DListCapacity(fileBase64TwoChild, parentIndex);

      // Now add new lists for the new child within the parent at the given index
      fileNameChild[parentIndex].add([]);
      fileContentChild[parentIndex].add([]);
      fileBase64OneChild[parentIndex].add([]);
      fileNameTwoChild[parentIndex].add([]);
      fileContentTwoChild[parentIndex].add([]);
      fileBase64TwoChild[parentIndex].add([]);

      // Optionally add initial values for the newly created file lists for this child
      fileNameChild[parentIndex].last.add('');  // Add an empty string as a placeholder for file name
      fileContentChild[parentIndex].last.add('');  // Add empty string for file content
      fileBase64OneChild[parentIndex].last.add('');  // Add empty string for base64 file data
      fileNameTwoChild[parentIndex].last.add('');  // Add an empty string for file name (second file set)
      fileContentTwoChild[parentIndex].last.add('');  // Add empty string for file content (second file set)
      fileBase64TwoChild[parentIndex].last.add('');  // Add empty string for base64 data (second file set)

      // Step 6: Notify listeners to update the UI
      notifyListeners();
    }
  }

  void removeArabicChildItem(int parentIndex, int childIndex) {
    log.i(arabicChildItems.length);
    // Check if the parent index is valid and within bounds
    if (parentIndex >= 0 && parentIndex < arabicChildItems.length) {

      // Check if the child index is valid for the parent list
      if (childIndex >= 0 && childIndex < arabicChildItems[parentIndex].length) {

        // Remove the child widget
        arabicChildItems[parentIndex].removeAt(childIndex);

        // Remove the corresponding controllers for this child
        arabicTitleControllersList[parentIndex].removeAt(childIndex);
        arabicDescriptionControllersList[parentIndex].removeAt(childIndex);
        arabicTimeControllersList[parentIndex].removeAt(childIndex);
        arabicUserControllersList[parentIndex].removeAt(childIndex);

        // Remove file-related data for this child
        fileNameChild[parentIndex].removeAt(childIndex);
        fileContentChild[parentIndex].removeAt(childIndex);
        fileBase64OneChild[parentIndex].removeAt(childIndex);
        filePathChild[parentIndex].removeAt(childIndex);

        fileNameTwoChild[parentIndex].removeAt(childIndex);
        fileContentTwoChild[parentIndex].removeAt(childIndex);
        fileBase64TwoChild[parentIndex].removeAt(childIndex);
        filePathTwoChild[parentIndex].removeAt(childIndex);
        // Notify listeners to update the UI
        notifyListeners();
      } else {
        // Handle case where the child index is out of bounds
        print("Invalid child index: $childIndex for parent index: $parentIndex");
      }
    } else {
      // Handle case where the parent index is out of bounds
      print("Invalid parent index: $parentIndex");
    }
  }

  void removeArabicFormParentFields(int index) {
    if (index < 0 || index >= arabicTitleControllers.length) {
      return; // Guard clause to handle out-of-range index
    }
    // Dispose and remove the main controllers
    arabicTitleControllers[index].dispose();
    arabicDescriptionControllers[index].dispose();
    arabicTimeControllers[index].dispose();
    arabicUserControllers[index].dispose();

    arabicTitleControllers.removeAt(index);
    arabicDescriptionControllers.removeAt(index);
    arabicTimeControllers.removeAt(index);
    arabicUserControllers.removeAt(index);

    // Check if there are child items and remove them
    if (index < arabicChildItems.length) {
      for (var child in arabicChildItems[index]) {
        int childIndex = arabicChildItems[index].indexOf(child);
        arabicTitleControllersList[index][childIndex].dispose();
        arabicDescriptionControllersList[index][childIndex].dispose();
        arabicTimeControllersList[index][childIndex].dispose();
        arabicUserControllersList[index][childIndex].dispose();
      }

      // Clear the lists after disposing of the controllers
      arabicTitleControllersList[index].clear();
      arabicDescriptionControllersList[index].clear();
      arabicTimeControllersList[index].clear();
      arabicUserControllersList[index].clear();

      arabicChildItems.removeAt(index);
      arabicTitleControllersList.removeAt(index);
      arabicDescriptionControllersList.removeAt(index);
      arabicTimeControllersList.removeAt(index);
      arabicUserControllersList.removeAt(index);
    }

    notifyListeners();
  }

  void removeFiles(int index) {
    if (index >= 0 && index < fileName.length) {
      fileName[index] = [''];
      fileBase64One[index] = [''];
      notifyListeners();
    }

    if (index >= 0 && index < filePath.length) {
      filePath[index] = [''];
      notifyListeners();
    }

  }

  void removeFilesChild(int parentIndex , int childIndex){
    // Safely remove the child files if they exist
    if (parentIndex < fileNameChild.length && childIndex < fileNameChild[parentIndex].length) {
      fileNameChild[parentIndex][childIndex] = [''];
      fileBase64OneChild[parentIndex][childIndex] = [''];
      fileNameTwoChild[parentIndex][childIndex] = [''];
      fileBase64TwoChild[parentIndex][childIndex] = [''];
    }

    if (parentIndex < filePathTwoChild.length && filePathTwoChild[parentIndex].length > childIndex) {
      filePathTwoChild[parentIndex][childIndex] = [''];
    }
    notifyListeners();
  }

  // Method to clear all controllers
  void clearAllControllers() {
    meetingTitleController.clear();
    meetingDescriptionController.clear();
    startDateController.clear();
    endDateController.clear();
    moreInfoController.clear();
    linkController.clear();

    for (var controller in titleControllers) {
      controller.clear();
    }
    for (var controller in descriptionControllers) {
      controller.clear();
    }
    for (var controller in timeControllers) {
      controller.clear();
    }
    for (var controller in userControllers) {
      controller.clear();
    }

    for (var controller in arabicTitleControllers) {
      controller.clear();
    }
    for (var controller in arabicDescriptionControllers) {
      controller.clear();
    }
    for (var controller in arabicTimeControllers) {
      controller.clear();
    }
    for (var controller in arabicUserControllers) {
      controller.clear();
    }

    for (var controllerList in titleControllersList) {
      for (var controller in controllerList) {
        controller.clear();
      }
    }
    for (var controllerList in descriptionControllersList) {
      for (var controller in controllerList) {
        controller.clear();
      }
    }
    for (var controllerList in timeControllersList) {
      for (var controller in controllerList) {
        controller.clear();
      }
    }
    for (var controllerList in userControllersList) {
      for (var controller in controllerList) {
        controller.clear();
      }
    }

    for (var controllerList in arabicTitleControllersList) {
      for (var controller in controllerList) {
        controller.clear();
      }
    }
    for (var controllerList in arabicDescriptionControllersList) {
      for (var controller in controllerList) {
        controller.clear();
      }
    }
    for (var controllerList in arabicTimeControllersList) {
      for (var controller in controllerList) {
        controller.clear();
      }
    }
    for (var controllerList in arabicUserControllersList) {
      for (var controller in controllerList) {
        controller.clear();
      }
    }

    // Clear file data
    fileName.clear();
    fileContent.clear();
    fileBase64One.clear();
    fileNameTwo.clear();
    fileContentTwo.clear();
    fileBase64Two.clear();
    fileNameChild.clear();
    fileContentChild.clear();
    fileBase64OneChild.clear();
    fileNameTwoChild.clear();
    fileContentTwoChild.clear();
    fileBase64TwoChild.clear();
    // Clear child items
    childItems.clear();
    arabicChildItems.clear();

    notifyListeners();
  }

  void reorderChildItems(int parentIndex, int oldIndex, int newIndex) {
    if (newIndex >oldIndex) {
      newIndex -= 1;
    }
    notifyListeners();
  }

  void reorderArabicChildItems(int parentIndex, int oldIndex, int newIndex) {
    if (newIndex >oldIndex) {
      newIndex -= 1;
    }
    notifyListeners();
  }

  void setSelectedMembers(List members) {
    _selectedMembers = members;
    _membersListIds = _selectedMembers.map((e) => e['id']).toList();
    notifyListeners();
  }

  void onStepContinue() {
    if (_currentStep < totalSteps - 1) {
      _currentStep++;
      notifyListeners();
    } else {
      // Handle form submission
    }
  }

  void onStepCancel() {
    if (_currentStep > 0) {
      _currentStep--;
      notifyListeners();
    }
  }

  void setCurrentStep(int step) {
    _currentStep = step;
    notifyListeners();
  }

  void toggleActions(int index) {
    // If the current visible action index is the same as the one clicked, hide it.
    if (visibleActionIndex == index) {
      visibleActionIndex = null; // Hide the menu
    } else {
      visibleActionIndex = index; // Show the menu for the clicked item
    }

    // Clear all other items' action menus.
    showActionsMap.clear();

    // Set the specific item to show its action menu.
    if (visibleActionIndex != null) {
      showActionsMap[visibleActionIndex!] = true;
    }

    notifyListeners(); // Notify the UI to rebuild with the updated state.
  }

  void setMeeting(Meeting meeting) async {
    _meeting =  meeting;
    notifyListeners();
  }

  Future<void> getListMembers(User user, NetworkHandler networkHandler, Logger log) async {
    var response = await networkHandler.get('/get-list-members/${user.businessId.toString()}');
    if (response.statusCode == 200 || response.statusCode == 201) {
      var responseData = json.decode(response.body);
      var membersData = responseData['data'];
      _listOfMembersData = membersData['members'];
      notifyListeners();
    } else {
      log.d("get-list-members response statusCode unknown");
      print(json.decode(response.body)['message']);
    }
  }

  void toggleShowMeetingForm() {
    _showMeetingForm = !_showMeetingForm;
    // log.i(combined);
    notifyListeners();
  }

  void togglePublished() {
    _showPublished = !_showPublished;
    _showArchived = false;
    _showUnPublished = false;
    showActionsMap.clear();
    visibleActionIndex = null;
    notifyListeners();
    fetchMeetings(_showPublished, false, false, _yearSelected,combined);
  }

  void toggleArchived() {
    _showArchived = !_showArchived;
    _showPublished = false;
    _showUnPublished = false;
    showActionsMap.clear();
    visibleActionIndex = null;
    notifyListeners();
    fetchMeetings(false, false, _showArchived, _yearSelected,combined);
  }

  void toggleUnPublished() {
    _showUnPublished = !_showUnPublished;
    _showPublished = false;
    _showArchived = false;
    showActionsMap.clear();
    visibleActionIndex = null;
    notifyListeners();
    fetchMeetings(false, _showUnPublished, false, _yearSelected,combined);
  }

  void selectCombinedCollectionBoardCommittee(String? combinedModel) {
    if (combinedModel != null) {
      List<String> parts = combinedModel.split('-');
      if (parts.length == 2) {
        String name = parts[0];
        int? id = int.tryParse(parts[1]);
        combined = {"id": id, "type": name};
        log.i(combined);
        selectedCombined = name.toString();
        _dropdownError = null;
        notifyListeners();
      }
    }
  }

  void setCombinedCollectionBoardCommittee(String? combinedModel) {
    if (combinedModel != null) {
      List<String> parts = combinedModel.split('-');
      if (parts.length == 2) {
        String name = parts[0];
        int? id = int.tryParse(parts[1]);
        combined = {"id": id, "type": name};
        log.i(combined);
        selectedCombined = name.toString();
        _dropdownError = null;
        fetchMeetings(false, _showUnPublished, false, _yearSelected,combined);
        notifyListeners();
      }
    }
  }

  // Method to validate the dropdown selection
  void validateDropdown() {
    if (selectedCombined == null || selectedCombined!.isEmpty) {
      _dropdownError = "Please select an item";
    } else {
      _dropdownError = null;
    }
    notifyListeners();
  }

  Future getListAgendas(String meetingId) async{
    Map<String,String> data = {"meeting_id": meetingId};
    var response = await networkHandler.get('/get-list-agenda-by-meetingId/${data["meeting_id"]}');
    if (response.statusCode == 200 || response.statusCode == 201) {
      log.d("get-list-agendas response statusCode == 200");
      var responseData = json.decode(response.body);
      var agendasData = responseData['data'];
      listAgenda = Agendas.fromJson(agendasData);
      notifyListeners();
    } else {
      log.d("get-list-agendas response statusCode unknown");
      print(json.decode(response.body)['message']);
    }
    //
  }

  void addAgendaDetails(Agenda agenda){
    final element = listAgenda!.agendas!.firstWhere((ag) => ag.agendaId==agenda.agendaId);
    final indexOfAgenda = listAgenda!.agendas!.indexOf(element);
  listAgenda!.agendas![indexOfAgenda] = agenda;
    print('add success---------------------------------------');
    notifyListeners();
  }

  Future getListOfMeetings(context)async{
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    user =  User.fromJson(json.decode(prefs.getString("user")!)) ;
    var response = await networkHandler.get('/get-list-meetings/${user.businessId.toString()}');
    print('/get-list-meetings/${user.businessId.toString()}');
    if (response.statusCode == 200 || response.statusCode == 201) {
      log.d("get-list-meetings response statusCode == 200");
      var responseData = json.decode(response.body);
      var meetingsData = responseData['data'];
      print("meetingsData $meetingsData");
      dataOfMeetings = Meetings.fromJson(meetingsData);
      print(dataOfMeetings!.meetings!.length);
      notifyListeners();
    } else {
      log.d("get-list-meetings response statusCode unknown");
      log.d(response.statusCode);
      print(json.decode(response.body)['message']);
    }
  }

  Future getListOfPublishedMeetingsThatNotHasMinutes()async{
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    user =  User.fromJson(json.decode(prefs.getString("user")!)) ;
    var response = await networkHandler.get('/get-list-of-published-meetings-that-not-has-minutes/${user.businessId.toString()}');
    if (response.statusCode == 200 || response.statusCode == 201) {
      log.d("get-list-of-published-meetings-that-not-has-minutes response statusCode == 200");
      var responseData = json.decode(response.body);
      var meetingsData = responseData['data'];
      dataOfMeetings = Meetings.fromJson(meetingsData);
      print(dataOfMeetings!.meetings!.length);
      notifyListeners();
    } else {
      log.d("get-list-of-published-meetings-that-not-has-minutes response statusCode unknown");
      log.d(response.statusCode);
      print(json.decode(response.body)['message']);
    }
  }

  Future getListOfMeetingsBoards(context)async{
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    user =  User.fromJson(json.decode(prefs.getString("user")!)) ;
    var response = await networkHandler.post1('/get-list-meetings-belongsTo-board',context);
    if (response.statusCode == 200 || response.statusCode == 201) {
      log.d("get-list-meetings response statusCode == 200");
      var responseData = json.decode(response.body);
      log.d(responseData);
      var meetingsData = responseData['data'];
      dataOfMeetings = Meetings.fromJson(meetingsData);
      print(dataOfMeetings!.meetings!.length);
      notifyListeners();

    } else {
      log.d("get-list-meetings response statusCode unknown");
      log.d(response.statusCode);
      print(json.decode(response.body)['message']);
    }
  }

  Future getListOfMeetingsCommittees(context)async{
    log.d(context);
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    user =  User.fromJson(json.decode(prefs.getString("user")!)) ;
    var response = await networkHandler.post1('/get-list-meetings-belongsTo-committee',context);
    if (response.statusCode == 200 || response.statusCode == 201) {
      log.d("get-list-meetings response statusCode == 200");
      var responseData = json.decode(response.body);
      print(responseData);
      var meetingsData = responseData['data'];
      dataOfMeetings = Meetings.fromJson(meetingsData);
      print(dataOfMeetings!.meetings!.length);
      notifyListeners();

    } else {
      log.d("get-list-meetings response statusCode unknown");
      log.d(response.statusCode);
      print(json.decode(response.body)['message']);
    }
  }

  Future<void> fetchMeetings(bool published, bool unpublished, bool archived, String? yearSelected, Map<String, dynamic>? combined) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    user =  User.fromJson(json.decode(prefs.getString("user")!)) ;
    final Map<String, String>  queryParams = {
      if (published) 'published': 'true',
      if (unpublished) 'unpublished': 'true',
      if (archived) 'archived': 'true',
      if (yearSelected != null) 'yearSelected': yearSelected,
    };

    // Check if combined map is not null or empty and add its entries to queryParams
    if (combined != null && combined.isNotEmpty) {
      combined.forEach((key, value) {
        queryParams[key] = value.toString();
      });
    }

    log.d("queryParams is ${queryParams}");
    final response = await networkHandler.post('/get-list-meetings-by-filter',queryParams);
    showActionsMap.clear();
    visibleActionIndex = null;
    if (response.statusCode == 200 || response.statusCode == 201) {
      log.d("get-list-meetings response statusCode == 200");
      var responseData = json.decode(response.body);
      var meetingsData = responseData['data'];
      dataOfMeetings = Meetings.fromJson(meetingsData);
      log.i(meetingsData);
      notifyListeners();
    } else {
      // throw Exception('Failed to load meetings');
      log.d("get-list-meetings response statusCode unknown");
      log.d(response.statusCode);
      print(json.decode(response.body)['message']);
    }
  }

  Future<void> insertMeeting(Map<String, dynamic> data)async{
    setLoading(true);
    var response = await networkHandler.post1('/insert-new-meeting', data);
    if (response.statusCode == 200 || response.statusCode == 201) {
      log.d("insert new meeting response statusCode == 200");
      var responseData = json.decode(response.body) ;
      var meetingsData = responseData['data'];
      _meeting = Meeting.fromJson(meetingsData['meeting']);
      log.d(_meeting);
      dataOfMeetings!.meetings!.add(_meeting);
      setMeeting(_meeting);
      clearAllControllers();
      setLoading(false);
      setIsBack(false);
    } else {
      setLoading(false);
      setIsBack(false);
      notifyListeners();
      log.d("insert new meeting response statusCode unknown");
      log.d(response.statusCode);
      print(json.decode(response.body)['message']);
    }
  }

  Future<void> insertNewMeeting(Map<String, dynamic> data)async{
    setLoading(true);
    notifyListeners();
    var response = await networkHandler.post1('/insert-meeting', data);
    if (response.statusCode == 200 || response.statusCode == 201) {
      log.d("insert new meeting response statusCode == 200");
      var responseData = json.decode(response.body) ;
      var meetingsData = responseData['data'];
      _meeting = Meeting.fromJson(meetingsData['meeting']);
      // log.d(_meeting);
      setMeeting(_meeting);
      dataOfMeetings!.meetings?.add(_meeting);

      // _showMeetingForm = !_showMeetingForm;

      setIsBack(true);
      setLoading(false);
      clearAllControllers(); // Clear controllers after successful insert
      fetchMeetings(false, _showUnPublished, false, _yearSelected,combined);
      notifyListeners();
    } else {
      setLoading(false);
      setIsBack(false);
      notifyListeners();
      log.d("insert new meeting response statusCode unknown");
      log.d(response.statusCode);
      print(json.decode(response.body)['message']);
    }
  }

  Future<void> editingMeeting(Map<String, dynamic> data, Meeting oldMeeting)async{
    setLoading(true);
    notifyListeners();
    // final index = dataOfMeetings!.meetings!.indexOf(oldMeeting);
    // Meeting meeting = dataOfMeetings!.meetings![index];
    // String meetingId =  meeting.meetingId.toString();

    final SharedPreferences prefs = await SharedPreferences.getInstance();
    user =  User.fromJson(json.decode(prefs.getString("user")!)) ;
    var response = await networkHandler.post1('/update-meeting-by-id', data);
    if (response.statusCode == 200 || response.statusCode == 201) {

      log.d("update-meeting-by-id response statusCode == 200");
      var responseData = json.decode(response.body) ;
      var membersData = responseData['data'];
      // dataOfMeetings!.meetings![index] = Meeting.fromJson(membersData['meeting']);
      // setMeeting(_meeting);
      // showActionsMap[index] = false;
      visibleActionIndex = null;
      setIsBack(true);
      setLoading(false);
      clearAllControllers(); // Clear controllers after successful insert
      fetchMeetings(false, _showUnPublished, false, _yearSelected,combined);
      notifyListeners();
    } else {
      setLoading(false);
      setIsBack(false);
      notifyListeners();
      log.d("update-meeting-by-id meeting response statusCode unknown");
      log.d(response.statusCode);
      print(json.decode(response.body)['message']);
    }
  }

  Future<bool> checkIfMeetingHasAgendas(Meeting meeting) async {
    // This function checks if the meeting has associated agendas
    Map<String, dynamic> data = {"meeting_published": "archived", "meeting_id": meeting.meetingId};
    var response = await networkHandler.post1('/check-meeting-agendas/${meeting.meetingId}', data);

    if (response.statusCode == 200) {
      var data = json.decode(response.body);
      log.d("hasAgendas hasAgendas hasAgendas hasAgendas data ${data}");
      return data['hasAgendas'] == true; // Returns true if agendas exist
    }

    return false; // No agendas
  }

  Future<String> deleteMeeting(Meeting oldMeeting) async {
    final index = dataOfMeetings!.meetings!.indexOf(oldMeeting);
    if (index == -1) return 'Meeting not found.';

    Meeting meeting = dataOfMeetings!.meetings![index];
    String meetingId = meeting.meetingId.toString();
    setLoading(true);
    notifyListeners();

    bool hasAgendas = await checkIfMeetingHasAgendas(meeting);

    if (hasAgendas) {
      log.d("hasAgendas hasAgendas hasAgendas hasAgendas ${hasAgendas}");
      // If there are agendas, notify the widget to ask for confirmation
      setLoading(false);
      return 'This meeting has associated agendas. Please confirm deletion.';
    }

    Map<String, dynamic> data = {"meeting_published": "archived", "meeting_id": meetingId};
    var response = await networkHandler.post1('/delete-meeting-by-id/$meetingId', data);

    if (response.statusCode == 200 || response.statusCode == 201) {

      log.d("delete-meeting-by-id response statusCode == 200");
      dataOfMeetings!.meetings!.removeAt(index);
      setIsBack(true);
      setLoading(false); // Changed from true to false as loading should be stopped.
      showActionsMap[index] = false;
      visibleActionIndex = null;
      notifyListeners();
      return 'Meeting deleted successfully.';
    } else {
      setLoading(false);
      setIsBack(false);
      notifyListeners();
      log.d("delete-meeting-by-id meeting response statusCode unknown");
      log.d(response.statusCode);
      String errorMessage = json.decode(response.body)['message'] ?? 'Unknown error occurred.';
      print(errorMessage);
      return errorMessage;
    }
  }

  Future<String> deleteMeetingWithAgendas(Meeting oldMeeting) async {
    final index = dataOfMeetings!.meetings!.indexOf(oldMeeting);
    if (index == -1) return 'Meeting not found.';

    Meeting meeting = dataOfMeetings!.meetings![index];
    String meetingId = meeting.meetingId.toString();
    setLoading(true);
    notifyListeners();

    Map<String, dynamic> data = {"meeting_published": "archived", "meeting_id": meetingId};
    var response = await networkHandler.post1('/delete-meeting-by-id/$meetingId', data);

    if (response.statusCode == 200 || response.statusCode == 201) {
      log.d("delete-meeting-by-id response statusCode == 200");
      dataOfMeetings!.meetings!.removeAt(index);
      setIsBack(true);
      setLoading(false); // Changed from true to false as loading should be stopped.
      showActionsMap[index] = false;
      visibleActionIndex = null;
      notifyListeners();
      return 'Meeting with agendas deleted successfully.';
    } else {
      setLoading(false);
      String errorMessage = json.decode(response.body)['message'] ?? 'Unknown error occurred.';
      return errorMessage;
    }
  }

  Future<bool> checkIfAgendaHasChildren(Map<String, dynamic> data) async {
    // This function checks if the meeting has associated agendas
    var response = await networkHandler.post1('/check-agenda-has-children', data);
    if (response.statusCode == 200) {
      var data = json.decode(response.body);
      log.d("hasChildren hasChildren hasChildren hasChildren data ${data}");
      return data['hasChildren'] == true; // Returns true if agendas exist
    }
    return false; // No agendas
  }

  Future<String> deleteAgenda(Map<String, dynamic> dataA) async {
    setLoading(true);
    notifyListeners();
    bool hasAgendas = await checkIfAgendaHasChildren(dataA);
    if (hasAgendas) {
      log.d("hasChildren hasChildren hasChildren hasChildren ${hasAgendas}");
      // If there are agendas, notify the widget to ask for confirmation
      setLoading(false);
      return 'This meeting has associated agendas. Please confirm deletion.';
    }

    var response = await networkHandler.post1('/delete-agenda-by-id', dataA);

    if (response.statusCode == 200 || response.statusCode == 201) {

      log.d("delete-meeting-by-id response statusCode == 200");
      // dataOfMeetings!.meetings!.removeAt(index);
      setIsBack(true);
      setLoading(false); // Changed from true to false as loading should be stopped.
      // showActionsMap[index] = false;
      visibleActionIndex = null;
      fetchMeetings(true, false, false, _yearSelected, combined);
      notifyListeners();
      return 'Meeting deleted successfully.';
    } else {
      setLoading(false);
      setIsBack(false);
      notifyListeners();
      log.d("delete-meeting-by-id meeting response statusCode unknown");
      log.d(response.statusCode);
      String errorMessage = json.decode(response.body)['message'] ?? 'Unknown error occurred.';
      print(errorMessage);
      return errorMessage;
    }
  }

  Future<String> deleteAgendaWithChildren(Map<String, dynamic> data) async {
    setLoading(true);
    notifyListeners();
    var response = await networkHandler.post1('/delete-agenda-by-id', data);
    if (response.statusCode == 200 || response.statusCode == 201) {
      log.d("delete-meeting-by-id response statusCode == 200");
      // dataOfMeetings!.meetings!.removeAt(index);
      setIsBack(true);
      setLoading(false); // Changed from true to false as loading should be stopped.
      // showActionsMap[index] = false;
      visibleActionIndex = null;
      fetchMeetings(true, false, false, _yearSelected, combined);
      notifyListeners();
      return 'Meeting with agendas deleted successfully.';
    } else {
      setLoading(false);
      String errorMessage = json.decode(response.body)['message'] ?? 'Unknown error occurred.';
      return errorMessage;
    }
  }

  Future<String> deleteAgendaChild(Map<String, dynamic> dataA) async {
    setLoading(true);
    notifyListeners();
    var response = await networkHandler.post1('/delete-agenda-child-by-id', dataA);
    if (response.statusCode == 200 || response.statusCode == 201) {
      log.d("delete-meeting-by-id response statusCode == 200");
      setIsBack(true);
      setLoading(false);
      visibleActionIndex = null;
      fetchMeetings(true, false, false, _yearSelected, combined);
      notifyListeners();
      return 'Meeting deleted successfully.';
    } else {
      setLoading(false);
      setIsBack(false);
      notifyListeners();
      log.d("delete-meeting-by-id meeting response statusCode unknown");
      log.d(response.statusCode);
      String errorMessage = json.decode(response.body)['message'] ?? 'Unknown error occurred.';
      print(errorMessage);
      return errorMessage;
    }
  }

  Future<String> archiveMeeting(Meeting oldMeeting)async{
    final index = dataOfMeetings!.meetings!.indexOf(oldMeeting);
    Meeting meeting = dataOfMeetings!.meetings![index];
    String meetingId =  meeting.meetingId.toString();
    setLoading(true);
    notifyListeners();
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    user =  User.fromJson(json.decode(prefs.getString("user")!)) ;
    log.i(meetingId);
    Map<String, dynamic> data = {"meeting_published": "archived","meeting_id": meetingId};
    var response = await networkHandler.post1('/archive-meeting-by-id/$meetingId', data);
    if (response.statusCode == 200 || response.statusCode == 201) {

      log.d("archive-meeting-by-id response statusCode == 200");
      var responseData = json.decode(response.body) ;
      var membersData = responseData['data'];

      _meeting = Meeting.fromJson(membersData['meeting']);
      log.d(membersData);
      setMeeting(_meeting);
      // dataOfMeetings!.meetings!.removeAt(index);
      // _showArchived = !_showArchived;
      fetchMeetings(false, false, true, _yearSelected, combined);
      setIsBack(true);
      setLoading(false);
      showActionsMap[index] = false;
      visibleActionIndex = null;
      notifyListeners();
      return 'Meeting archived successfully.';
    } else {
      setLoading(false);
      setIsBack(false);
      notifyListeners();
      log.d("archive-meeting-by-id meeting response statusCode unknown");
      log.d(response.statusCode);
      String errorMessage = json.decode(response.body)['message'] ?? 'Unknown error occurred.';
      print(errorMessage);
      return errorMessage;
    }
  }

  Future<String> publishedMeeting(Meeting oldMeeting)async{
    final index = dataOfMeetings!.meetings!.indexOf(oldMeeting);
    Meeting meeting = dataOfMeetings!.meetings![index];
    String meetingId =  meeting.meetingId.toString();
    setLoading(true);
    notifyListeners();
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    user =  User.fromJson(json.decode(prefs.getString("user")!)) ;
    log.i(meetingId);
    Map<String, dynamic> data = {"meeting_published": "published","meeting_id": meetingId};
    var response = await networkHandler.post1('/published-meeting-by-id/$meetingId', data);
    if (response.statusCode == 200 || response.statusCode == 201) {

      log.d("published-meeting-by-id response statusCode == 200");
      var responseData = json.decode(response.body) ;
      var membersData = responseData['data'];
      dataOfMeetings!.meetings![index] = Meeting.fromJson(membersData['meeting']);
      setMeeting(_meeting);
      fetchMeetings(true, false, false, _yearSelected, combined);
      // dataOfMeetings!.meetings!.add(_meeting);
      setIsBack(true);
      setLoading(false);
      showActionsMap[index] = false;
      visibleActionIndex = null;
      notifyListeners();
      return 'Meeting published successfully.';
    } else {
      setLoading(false);
      setIsBack(false);
      notifyListeners();
      log.d("published-meeting-by-id meeting response statusCode unknown");
      log.d(response.statusCode);
      String errorMessage = json.decode(response.body)['message'] ?? 'Unknown error occurred.';
      print(errorMessage);
      return errorMessage;
    }
  }

  Future<String> unPublishedMeeting(Meeting oldMeeting)async {
    final index = dataOfMeetings!.meetings!.indexOf(oldMeeting);
    Meeting meeting = dataOfMeetings!.meetings![index];
    String meetingId = meeting.meetingId.toString();
    setLoading(true);
    notifyListeners();
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    user = User.fromJson(json.decode(prefs.getString("user")!));
    log.i(meetingId);
    Map<String, dynamic> data = {
      "meeting_unPublished": "unPublished",
      "meeting_id": meetingId
    };
    var response = await networkHandler.post1(
        '/unpublished-meeting-by-id/$meetingId', data);
    if (response.statusCode == 200 || response.statusCode == 201) {

      log.d("unpublished-meeting-by-id response statusCode == 200");
      var responseData = json.decode(response.body);
      var membersData = responseData['data'];
      _meeting = Meeting.fromJson(membersData['meeting']);
      setMeeting(_meeting);
      fetchMeetings(false , true, false, _yearSelected, combined);
      // dataOfMeetings!.meetings!.removeAt(index);
      // fetchMeetings(false, _showUnPublished, false, _yearSelected, combined);

      setIsBack(true);
      setLoading(false);
      showActionsMap[index] = false;
      visibleActionIndex = null;
      notifyListeners();
      return 'Meeting unPublished successfully.';
    } else {
      setLoading(false);
      setIsBack(false);
      notifyListeners();
      log.d("unPublished-meeting-by-id meeting response statusCode unknown");
      log.d(response.statusCode);
      String errorMessage = json.decode(response.body)['message'] ??
          'Unknown error occurred.';
      print(errorMessage);
      return errorMessage;
    }
  }

  Future<String> notifyMeeting(Meeting oldMeeting)async {
    final index = dataOfMeetings!.meetings!.indexOf(oldMeeting);
    Meeting meeting = dataOfMeetings!.meetings![index];
    String meetingId = meeting.meetingId.toString();
    setLoading(true);
    notifyListeners();
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    user = User.fromJson(json.decode(prefs.getString("user")!));
    log.i(meetingId);
    Map<String, dynamic> data = {"meeting_id": meetingId};
    var response = await networkHandler.post1('/notify-meeting-by-id/$meetingId', data);
    if (response.statusCode == 200 || response.statusCode == 201) {

      log.d("unpublished-meeting-by-id response statusCode == 200");
      var responseData = json.decode(response.body);
      var membersData = responseData['data'];
      _meeting = Meeting.fromJson(membersData['meeting']);
      setMeeting(_meeting);
      dataOfMeetings!.meetings!.removeAt(index);
      fetchMeetings(false, _showUnPublished, false, _yearSelected, combined);
      setIsBack(true);
      setLoading(false); // Changed from true to false as loading should be stopped.
      showActionsMap[index] = false;
      visibleActionIndex = null;
      notifyListeners();
      return 'Meeting notify successfully.';
    } else {
      setLoading(false);
      setIsBack(false);
      notifyListeners();
      log.d("unPublished-meeting-by-id meeting response statusCode unknown");
      log.d(response.statusCode);
      String errorMessage = json.decode(response.body)['message'] ?? 'Unknown error occurred.';
      print(errorMessage);
      return errorMessage;
    }
  }

  Future getListOfCombinedCollectionBoardAndCommittee()async{
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    user =  User.fromJson(json.decode(prefs.getString("user")!)) ;
    var businessId = user.businessId;
    Map<String, dynamic> data = {"business_id": businessId};
    var response = await networkHandler.post1('/combined-collection-board-and-committees',data);
    if (response.statusCode == 200 || response.statusCode == 201) {
      log.d("get-list-meetings response statusCode == 200");
      var responseData = json.decode(response.body);
      log.d(responseData);
      var meetingsData = responseData['data'];
      collectionBoardCommitteeData = CombinedCollectionBoardCommitteeData.fromJson(meetingsData);
      print(collectionBoardCommitteeData!.combinedCollectionBoardCommitteeData!.length);
      notifyListeners();

    } else {
      log.d("get-list-meetings response statusCode unknown");
      log.d(response.statusCode);
      print(json.decode(response.body)['message']);
    }
  }


  Future getListOfMembersDependingOnCombinedCollectionBoardAndCommittee()async{
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    user =  User.fromJson(json.decode(prefs.getString("user")!)) ;
    var businessId = user.businessId;
    Map<String, dynamic> data = {"business_id": businessId};
    var response = await networkHandler.post1('/combined-collection-board-and-committees',data);
    if (response.statusCode == 200 || response.statusCode == 201) {
      log.d("get-list-meetings response statusCode == 200");
      var responseData = json.decode(response.body);
      log.d(responseData);
      var meetingsData = responseData['data'];
      collectionBoardCommitteeData = CombinedCollectionBoardCommitteeData.fromJson(meetingsData);
      print(collectionBoardCommitteeData!.combinedCollectionBoardCommitteeData!.length);
      notifyListeners();

    } else {
      log.d("get-list-meetings response statusCode unknown");
      log.d(response.statusCode);
      print(json.decode(response.body)['message']);
    }
  }

  Future<Meeting?> findMeetingById(String meetingId) async {
    try {
      setLoading(true);
      notifyListeners();
      log.d("Meeting fetched: ${meetingId}");
      Map<String, dynamic> data = {"meeting_id": meetingId};
      var response = await networkHandler.post1('/find-meeting-by-id/$meetingId', data);
      // var response = await networkHandler.get('/find-meeting-by-id/$meetingId');
      if (response.statusCode == 200 || response.statusCode == 201) {
        log.d("find-meeting-by-id response statusCode == 200");
        var responseData = json.decode(response.body);
        var meetingData = responseData['data'];
        Meeting fetchedMeeting = Meeting.fromJson(meetingData['meeting']);
        setMeeting(fetchedMeeting);
        log.i(fetchedMeeting);
        setIsBack(true);
        setLoading(false);
        notifyListeners();
        return fetchedMeeting;
      } else {
        throw Exception("Failed to fetch meeting: ${response.statusCode} ${response.body}");
      }
    } catch (e) {
      log.e("Error fetching meeting: $e");
      setLoading(false);
      setIsBack(false);
      notifyListeners();
      return null;
    }
  }

  Future<void> uploadAgendasAndChildrenAfterView(String filePath, String meetingId) async {
    try {
      setLoading(true);
      notifyListeners();
      // Step 1: Read the file
      final File file = File(filePath);

      if (!await file.exists()) {
        throw Exception("File does not exist: $filePath");
      }

      final List<int> fileBytes = await file.readAsBytes();
      final String base64File = base64Encode(fileBytes);

      // Step 3: Prepare the HTTP request
      final Map<String, dynamic> requestBody = {
        "file": base64File, // Base64 string of the file
        "fileName": file.uri.pathSegments.last, // Extract file name from the path
        "meeting_id": meetingId
      };
      var response = await networkHandler.post1('/upload-agendas-and-children-after-view', requestBody);

      if (response.statusCode == 200 || response.statusCode == 201) {
        log.d("find-meeting-by-id response statusCode == 200");
        var responseData = json.decode(response.body);
        log.d("find-meeting-by-id response statusCode == 200 $responseData");
        var meetingData = responseData['data'];
        previewMeeting = PreviewMeetingModel.fromJson(meetingData['preview_meeting']);
        print("File uploaded successfully.");
        print("Server Response: ${meetingData['preview_meeting']}");
        setIsBack(true);
        setLoading(false);
        notifyListeners();
      } else {
        setIsBack(false);
        setLoading(false);
        throw Exception("Failed to fetch meeting: ${response.statusCode} ${response.body}");
      }


    } catch (e) {
      setIsBack(false);
      setLoading(false);
      print("Error uploading file: $e");
    }
  }

  Future<void> fetchUpComingMeetings() async {
    setLoading(true);
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    user =  User.fromJson(json.decode(prefs.getString("user")!)) ;
    final response = await networkHandler.get('/get-list-of-upcoming-meetings-for-member/${user.userId}');
    if (response.statusCode == 200 || response.statusCode == 201) {
      log.d("get-list-meetings response statusCode == 200");
      var responseData = json.decode(response.body);
      var meetingsData = responseData['data'];
      log.i(meetingsData);
      dataOfMeetings = Meetings.fromJson(meetingsData);
      log.i(meetingsData);
      setLoading(false);
    } else {
      // throw Exception('Failed to load meetings');
      log.d("get-list-meetings response statusCode unknown");
      log.d(response.statusCode);
      print(json.decode(response.body)['message']);
    }
  }

  Future<void> sendAttendanceStatus({
    required Meeting? oldMeeting,
    required bool isAttending,
    String? reason,
  }) async {
    final index = dataOfMeetings!.meetings!.indexOf(oldMeeting!);
    Meeting meeting = dataOfMeetings!.meetings![index];
    print(meeting.meetingId);
    String meetingId = meeting.meetingId.toString();
    setLoading(true);
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    user = User.fromJson(json.decode(prefs.getString("user")!));
    log.i(meetingId);

    final data = {
      "member_id": user.userId,
      "meeting_id": meetingId,
      "is_attended": isAttending,
      if (reason != null && reason.isNotEmpty) "reason": reason,
    };

    try {
      final response = await networkHandler.post1('/submit-attendance', data);

      if (response.statusCode == 200) {
        var responseData = json.decode(response.body);
        var membersData = responseData['data'];
        _meeting = Meeting.fromJson(membersData['meeting']);
        setMeeting(_meeting);
        setIsBack(true);
        setLoading(false);
      } else {
        log.e('Failed to update attendance: ${response.body}');
      }
    } catch (e) {
      log.e('Error sending attendance: $e');
    }

    notifyListeners(); // Optional UI refresh
  }






}

