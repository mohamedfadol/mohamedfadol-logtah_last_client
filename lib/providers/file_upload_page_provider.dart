import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';

class FileUploadPageProvider with ChangeNotifier {

  bool isLoading = false;
  String? errorMessage;

  PlatformFile? pickedFile;
  String? fileName;
  String? fileContent;
  String? oneFileBase64;


  List<PlatformFile> pickedFiles = [];
  List<String> fileNames = [];
  List<String> fileContents = [];
  List<String> fileBase64 = [];
  List<String> filePaths = [];

  Future<void> pickFiles(List<String> allowedExtensions) async {
    isLoading = true;
    notifyListeners();

    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        allowMultiple: false,
        type: FileType.custom,
        allowedExtensions: allowedExtensions,
      );

      if (result != null && result.files.isNotEmpty) {
        pickedFiles = result.files;

        // Clear previous base64 data
        fileBase64.clear();

        // Perform synchronous base64 encoding
        for (var file in result.files) {
          if (file.bytes != null) {
            fileBase64.add(base64.encode(file.bytes!));
          } else if (file.path != null) {
            // Optionally handle file read from disk if bytes are not available
            var fileData = File(file.path!).readAsBytesSync();
            filePaths.add(file.path!);
            fileBase64.add(base64.encode(fileData));
          }
        }
      } else {
        errorMessage = 'No file picked';
      }
    } catch (e) {
      errorMessage = 'Error picking files: $e';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }



  void clearFiles(int index) {
    if (index >= 0 && index < pickedFiles.length) {
      pickedFiles.removeAt(index);
      // fileNames.removeAt(index);
      // fileContents.removeAt(index);
      notifyListeners();
    }
  }

  void clearAllFiles() {
    pickedFiles.clear();
    fileNames.clear();
    fileContents.clear();
    notifyListeners();
  }



  Future<void> pickFile(List<String> allowedExtensions) async {
    isLoading = true;
    notifyListeners();

    try {
      // Allow picking a single file (allowMultiple: false)
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        allowMultiple: false,  // Only allow single file selection
        type: FileType.custom,
        allowedExtensions: allowedExtensions,
      );

      if (result != null && result.files.isNotEmpty) {
        var file = result.files.first; // Select the first file

        pickedFile = file;

        // Clear previous base64 data
        fileBase64.clear();

        if (file.bytes != null) {
          // If file data is available as bytes
          fileBase64.add(base64.encode(file.bytes!));
        } else if (file.path != null) {
          // Optionally handle file read from disk if bytes are not available
          var fileData = File(file.path!).readAsBytesSync();
          fileBase64.add(base64.encode(fileData));
        }
      } else {
        errorMessage = 'No file picked';
      }
    } catch (e) {
      errorMessage = 'Error picking file: $e';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  void clearFile() {
    pickedFile = null;        // Clear the picked file
    oneFileBase64 = null;    // Clear the Base64 data
    errorMessage = '';        // Clear any error messages if needed
    notifyListeners();        // Notify listeners to update UI
  }


}
