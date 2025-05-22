import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../NetworkHandler.dart';
import '../models/document_model.dart';
import '../models/user.dart';
class DocumentPageProvider extends ChangeNotifier {
  var log = Logger();
  User user = User();
  NetworkHandler networkHandler = NetworkHandler();
  DocumentData? documentData;
  Document _document = Document();
  Document get document => _document;
  List<int?> selectedDocumentId = [];
  List<int?> selectedChildDocumentId = [];
  List<int?> selectedArabicDocumentId = [];
  List<int?> selectedArabicChildDocumentId = [];

  // Map<int, int> selectedDocumentIndices = {};
  void setDocument(Document document) async {
    _document = document;
    notifyListeners();
  }

  bool _loading = false;
  bool get loading => _loading;

  void setLoading(value) async {
    _loading = value;
    notifyListeners();
  }

  bool _isBack = false;
  bool get isBack => _isBack;
  void setIsBack(value) async {
    _isBack = value;
    notifyListeners();
  }

  DocumentPageProvider() {
    // Fetch data when the provider is initialized
    getListOfDocuments();
  }

  void toggleDocumentSelection(int documentId) {
    final document = documentData?.documents?.firstWhere((doc) => doc.documentId == documentId);
    if (document != null) {
      document.selected = !document.selected;
      notifyListeners();
    }
  }

  void selectDocumentChild(int i, int j, int documentId) {
    while (selectedChildDocumentId.length <= i) {
      selectedChildDocumentId.add(null);
    }
    if (selectedChildDocumentId.length <= j) {
      selectedChildDocumentId.add(documentId);
    } else {
      selectedChildDocumentId[j] = documentId;
    }
    notifyListeners();
  }

  String? getSelectedChildDocumentName(int i, int j) {
    if (i < selectedChildDocumentId.length && j < selectedChildDocumentId.length) {
      int? docId = selectedChildDocumentId[j];
      if (docId != null) {
        return documentData?.documents?.firstWhere((doc) => doc.documentId == docId, orElse: () => Document()).documentName;
      }
    }
    return null;
  }

  void selectArabicDocumentChild(int i, int j, int documentId) {
    while (selectedArabicChildDocumentId.length <= i) {
      selectedArabicChildDocumentId.add(null);
    }
    if (selectedArabicChildDocumentId.length <= j) {
      selectedArabicChildDocumentId.add(documentId);
    } else {
      selectedArabicChildDocumentId[j] = documentId;
    }
    log.i("i ${i} -- j ${j} --  ${documentId} ${selectedArabicChildDocumentId}");
    notifyListeners();
  }

  String? getSelectedArabicChildDocumentName(int i, int j) {
    if (i < selectedArabicChildDocumentId.length && j < selectedArabicChildDocumentId.length) {
      int? docId = selectedArabicChildDocumentId[j];
      if (docId != null) {
        return documentData?.documents?.firstWhere((doc) => doc.documentId == docId, orElse: () => Document()).documentName;
      }
    }
    return null;
  }

  void selectDocument(int i , documentId) {
    selectedDocumentId[i] = documentId;
    notifyListeners();
  }

  String? getSelectedDocumentName(int i) {
    // Check if the index is within the bounds of the selectedDocumentId list
    if (i >= 0 && i < selectedDocumentId.length) {
      int? documentId = selectedDocumentId[i];
      // Ensure that there is a valid document ID at this index
      if (documentId != null) {
        // Find the document with this ID
        Document? document = documentData?.documents?.firstWhere(
                (doc) => doc.documentId == documentId// Correctly handle the case where no document is found
        );
        // If a document is found, return its name
        if (document != null) {
          return document.documentName;
        }
      }
    }
    // Return null if the index is out of bounds or no document is found
    return null;
  }

  void selectArabicDocument(int i , documentId) {
    selectedArabicDocumentId[i] = documentId;
    log.i("${i} -- ${documentId} ${selectedArabicDocumentId}");
    notifyListeners();
  }

  String? getSelectedArabicDocumentName(int i) {
    // Check if the index is within the bounds of the selectedDocumentId list
    if (i >= 0 && i < selectedArabicDocumentId.length) {
      int? documentId = selectedArabicDocumentId[i];
      // Ensure that there is a valid document ID at this index
      if (documentId != null) {
        // Find the document with this ID
        Document? document = documentData?.documents?.firstWhere(
                (doc) => doc.documentId == documentId// Correctly handle the case where no document is found
        );
        // If a document is found, return its name
        if (document != null) {
          return document.documentName;
        }
      }
    }
    // Return null if the index is out of bounds or no document is found
    return null;
  }

  Future getListOfDocuments() async {
    var response = await networkHandler.get('/get-list-documents');
    log.d(response.statusCode);
    if (response.statusCode == 200 || response.statusCode == 201) {
      log.d("get-list-documents form provider response statusCode == 200");
      var responseData = json.decode(response.body);
      var responseDocumentData = responseData['data'];
      // log.d(responseActionTrackerData);
      documentData = DocumentData.fromJson(responseDocumentData);
      log.d(documentData!.documents!.length);
      notifyListeners();
    } else {
      log.d("get-list-documents form provider response statusCode unknown");
      log.d(response.statusCode);
      log.d(json.decode(response.body)['message']);
    }
  }

  // New validation function for file upload
  bool validateFileUpload(
      int index, {
        required List<int?> selectedDocumentId,
        required List<List<String>> fileName,
        required List<List<String>> fileBase64One,
        required List<List<List<String>>> fileNameChild,
        required List<int?> selectedChildDocumentId,
        required String errorMessage,
      }) {

    // Check if there’s a file uploaded at the given index for parent form
    if ((fileName[index].isNotEmpty || fileBase64One[index].isNotEmpty) &&
        (selectedDocumentId.length <= index || selectedDocumentId[index] == null)) {
      // If file is uploaded but no document selected
      print('Error: $errorMessage for index $index');
      return false;
    }

    // Check child forms for the same index
    for (int j = 0; j < fileNameChild[index].length; j++) {
      if (fileNameChild[index][j].isNotEmpty &&
          (selectedChildDocumentId.length <= j || selectedChildDocumentId[j] == null)) {
        // If file is uploaded for a child form but no document selected
        print('Error: $errorMessage for child form $index-$j');
        return false;
      }
    }

    // All validations passed
    return true;
  }

  // Validate English files
  bool validateEnglishFiles(int index, List<List<String>> fileName, List<List<String>> fileBase64One, List<List<List<String>>> fileNameChild) {
    return validateFileUpload(
      index,
      selectedDocumentId: selectedDocumentId, // English document selection
      fileName: fileName,
      fileBase64One: fileBase64One,
      fileNameChild: fileNameChild,
      selectedChildDocumentId: selectedChildDocumentId,
      errorMessage: 'No document selected for English file',
    );
  }

  // Validate Arabic files
  bool validateArabicFiles(int index, List<List<String>> arabicFileName, List<List<String>> arabicFileBase64One, List<List<List<String>>> arabicFileNameChild) {
    return validateFileUpload(
      index,
      selectedDocumentId: selectedArabicDocumentId, // Arabic document selection
      fileName: arabicFileName,
      fileBase64One: arabicFileBase64One,
      fileNameChild: arabicFileNameChild,
      selectedChildDocumentId: selectedArabicChildDocumentId,
      errorMessage: 'No document selected for Arabic file',
    );
  }

  // Use this during the form submission
  void submitForm(
      List<List<String>> fileName, List<List<String>> fileBase64One, List<List<List<String>>> fileNameChild,
      List<List<String>> arabicFileName, List<List<String>> arabicFileBase64One, List<List<List<String>>> arabicFileNameChild) {

    bool isEnglishValid = true;
    bool isArabicValid = true;

    // Validate all indices for both English and Arabic files
    for (int i = 0; i < fileName.length; i++) {
      isEnglishValid = validateEnglishFiles(i, fileName, fileBase64One, fileNameChild);
      isArabicValid = validateArabicFiles(i, arabicFileName, arabicFileBase64One, arabicFileNameChild);

      // If validation fails, stop the process
      if (!isEnglishValid || !isArabicValid) {
        print('Form submission halted due to missing documents.');
        return;
      }
    }

    // Proceed with the form submission
    print('Form submitted successfully!');
  }
}