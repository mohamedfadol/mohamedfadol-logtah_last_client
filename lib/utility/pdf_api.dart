
import 'dart:async';
import 'dart:convert';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path/path.dart' as path;
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';
import 'package:pdf/widgets.dart';
import 'package:http/http.dart' as http;
import 'package:permission_handler/permission_handler.dart';
import 'dart:io';

import '../../../models/minutes_model.dart';
import '../../../widgets/custome_text.dart';
import 'package:flutter/material.dart' as mat;

import 'upload_local_file_processing.dart';






Future<void> downloadPdfFile(BuildContext context, Uint8List pdfBytes, String fileName) async {
  try {
    // Request storage permission for Android
    if (Platform.isAndroid) {
      var status = await Permission.storage.request();
      if (!status.isGranted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: mat.Text("Storage permission denied")),
        );
        return;
      }
    }

    // Determine directory for saving the file
    Directory? directory;
    if (Platform.isAndroid) {
      directory = await getExternalStorageDirectory();
      directory = Directory('${directory!.path}/Documents');
    } else {
      directory = await getApplicationDocumentsDirectory();
    }

    // Ensure the directory exists
    if (!await directory.exists()) {
      await directory.create(recursive: true);
    }

    // Define the complete file path
    final filePath = '${directory.path}/$fileName';
    final file = File(filePath);

    // Write the PDF file to the specified path
    await file.writeAsBytes(pdfBytes);

    // Notify user of successful download and open file
    if (await file.exists()) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: mat.Text("PDF saved to ${directory.path}")),
      );
      await OpenFile.open(filePath);
    } else {
      throw Exception("Failed to save PDF file");
    }
  } catch (e) {
    print("Error saving file: $e");
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: mat.Text("Failed to save PDF: $e")),
    );
  }
}




class PDFApi {

  static Future<File?> pickFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );

    if (result == null) return null;
    return File(result.paths!.first!);
  }

  static Future openFile(File? file) async {
    if(await requestPermission()){
      final url = file!.path;
      await OpenFile.open(url);
    }
    final url = file!.path;
    await OpenFile.open(url);
  }

  static Future<File> saveDocument(
      {required String name, required Document pdf}) async {
    final bytes = await pdf.save();
    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/$name');
    await file.writeAsBytes(bytes);
    return file;
  }

  // static Future<File> saveDocumentAsyncFusion(
  //     {required String name, required PdfDocument pdf}) async {
  //   final bytes = await pdf.save();
  //   final dir = await getApplicationDocumentsDirectory();
  //   final file = File('${dir.path}/$name');
  //   await file.writeAsBytes(bytes);
  //   return file;
  // }


  static Future<void> saveFileToDirectoryPath(String fileName, String folderName, String data) async {
    try {
      // Get the application's documents directory.
      final Directory docsDirectory = await getApplicationDocumentsDirectory();
      // Path to the folder where the file will be saved.
      final String folderPath = path.join(docsDirectory.path, folderName);

      // Create the folder if it doesn't already exist.
      final Directory folder = Directory(folderPath);
      if (!await folder.exists()) {
        await folder.create(recursive: true);
      }

      // Path for the file to be saved.
      final String filePath = path.join(folderPath, fileName);
      // Create the file.
      final File file = File(filePath);

      // Write data to the file (assuming `data` is a String).
      await file.writeAsString(data);
      print("File saved: $filePath");
    } catch (e) {
      print("Error saving file: $e");
    }
  }

  // Method to retrieve a file from local storage
  static Future<File?> retrieveFile(BuildContext context,String fileName, Minute minute) async {
    try {
      Directory? directory;
      if (Platform.isAndroid) {
        directory = await getExternalStorageDirectory();
        directory = Directory('${directory!.path}/Documents');
      } else {
        directory = await getApplicationDocumentsDirectory();
      }

      final filePath = '${directory.path}/$fileName';
      final file = File(filePath);
      print("filefilefilefilefilefilefile $filePath");

      // Check if the file exists
      if (await file.exists()) {
        Navigator.of(context).push(MaterialPageRoute(builder: (context) => UploadLocalFileProcessing(path: filePath, minute: minute!,)));

        // return file;
      } else {
        throw Exception("File not found");
      }
    } catch (e) {
      print("Error retrieving file: $e");
      return null;
    }
  }




  static Future<bool> requestPermission() async {
    if (Platform.isAndroid) {
      try {
        final status = await Permission.storage.request();
        return status.isGranted;
      } on Exception catch (e) {
        print('permission error---------$e');
        return false;
      }
    } else {
      return false;
    }
  }

   Future<void> downloadFileToStorage2(File pdfFile) async {
    print('PDF path to: ${pdfFile.path}');
    // Get external storage directory
    final storageDirectory = await getExternalStorageDirectory();
    print('storageDirectory: ${storageDirectory?.path}');
    // Create the file path
    String filePath = '';
    final isRealDevice = !Platform.isAndroid && !Platform.isIOS;
    final isEmulator = Platform.isAndroid || Platform.isIOS;
    if (!isEmulator) {
      filePath = '${storageDirectory?.path}/${pdfFile.path.split('/').last}';
    } else {
      filePath = '/storage/emulated/0/Download/${pdfFile.path.split('/').last}';
    }
    print('PDF file saved to: $filePath');
    // Write the PDF file to the external storage
    final File file = File(filePath);
    //for a directory: await Directory(savePath).exists();
    if (await file.exists()) {
      print("File exists");
    } else {
      print("File don't exists");
    }
    await file.writeAsBytes(pdfFile.readAsBytesSync());
  }

  static Future<String?> getFileAsBase64(String filePath) async {
    try {
      // Check if the file exists at the specified path
      final file = File(filePath);
      if (!await file.exists()) {
        print('File does not exist at the specified path.');
        return null;
      }
      // Read the file as bytes
      final bytes = await file.readAsBytes();
      // Convert the file bytes to a Base64 string
      final base64String = base64Encode(bytes);
      // Return the Base64 string
      return base64String;
    } catch (e) {
      print('Error reading and encoding file: $e');
      return null;
    }
  }

  static Future<void> uploadFile(String filePath) async {
    try {
      // Check if the file exists at the specified path
      final file = File(filePath);
      if (!await file.exists()) {
        print('File does not exist at the specified path.');
        return;
      }

      // Prepare the multipart request
      final uri = Uri.parse("https://your-server.com/upload");  // Replace with your server's URL
      final request = http.MultipartRequest('POST', uri);

      // Attach the file to the request
      request.files.add(
        http.MultipartFile(
          'file',                       // Name for the file field on the server
          file.readAsBytes().asStream(), // Stream the file content
          file.lengthSync(),             // File length
          filename: basename(file.path), // File name
        ),
      );

      // Send the request
      final response = await request.send();

      // Check the response
      if (response.statusCode == 200) {
        print('File uploaded successfully!');
      } else {
        print('Failed to upload file. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error uploading file: $e');
    }
  }

  static Future<void> downloadFileToStorage(File pdfFile) async {
    print('PDF path to: ${pdfFile.path}');
    // Get external storage directory
    final storageDirectory = await getExternalStorageDirectory();
    print('storageDirectory: ${storageDirectory?.path}');
    // Create the file path
    String filePath = '';
    final isRealDevice = !Platform.isAndroid && !Platform.isIOS;
    final isEmulator = Platform.isAndroid || Platform.isIOS;
    if (!isEmulator) {
      filePath = '${storageDirectory?.path}/${pdfFile.path.split('/').last}';
    } else {
      filePath = '/storage/emulated/0/Download/${pdfFile.path.split('/').last}';
    }
    print('PDF file saved to: $filePath');
    // Write the PDF file to the external storage
    final File file = File(filePath);
    //for a directory: await Directory(savePath).exists();
    if (await file.exists()) {
      print("File exists");
    } else {
      print("File don't exists");
    }
    await file.writeAsBytes(pdfFile.readAsBytesSync());
  }

  static Future<File> loadAsset(String path) async {
    final data = await rootBundle.load(path);
    final bytes = data.buffer.asUint8List();
    return _storeFile(path, bytes);
  }

  // static Future<File> loadNetwork(String url) async {
  //
  //   final response = await http.get(
  //     Uri.parse(url),
  //     headers: {"Connection": "Keep-Alive"},
  //   ).timeout(Duration(seconds: 60));
  //   print('loadNetwork function response: ${response.statusCode.toString()}');
  //   // Handle successful download
  //   final bytes = response.bodyBytes;
  //   return _storeFileFromPath(url, bytes);
  //
  // }

  // Download network file with unique name based on URL
  static Future<File> loadNetwork(String url) async {
    // Clean the URL of any whitespace or newlines
    final cleanUrl = url.trim();

    // Create a unique filename based on the URL hash to prevent overwriting
    final urlHash = cleanUrl.hashCode.toString();
    // Extract original filename from URL if possible
    final originalFilename = basename(cleanUrl);
    // Create a unique filename that preserves the original name
    final filename = '${urlHash}_$originalFilename';

    // Log the URLs for debugging
    print('Original URL: $cleanUrl');
    print('Generated unique filename: $filename');

    final response = await http.get(Uri.parse(cleanUrl));
    final bytes = response.bodyBytes;

    // Store file with unique name
    return _storeFileWithUniqueFilename(filename, bytes);
  }

  // Store file with unique filename to prevent overwriting
  static Future<File> _storeFileWithUniqueFilename(String filename, List<int> bytes) async {
    // Use application document directory for temporary storage
    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/$filename');

    // Log the storage path for debugging
    print('Storing file at: ${file.path}');

    // Write the file
    await file.writeAsBytes(bytes, flush: true);
    return file;
  }

  // Clean up temporary files when no longer needed
  static Future<void> cleanupTempFiles() async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      // Optional: Delete temporary PDF files to free up space
      final files = dir.listSync().whereType<File>().where(
              (file) => file.path.toLowerCase().endsWith('.pdf'));

      for (final file in files) {
        await file.delete();
      }
    } catch (e) {
      print('Error cleaning up temp files: $e');
    }
  }

  static Future<File> loadNetworkFromLocalPath(String url) async {

    final response = await http.get(
      Uri.parse(url),
      headers: {"Connection": "Keep-Alive"},
    ).timeout(Duration(seconds: 60));
    print('loadNetwork function response: ${response.statusCode.toString()}');
    // Handle successful download
    final bytes = response.bodyBytes;
    return _storeFileFromPath(url, bytes);

  }

  static Future<File> _storeFileFromPath(String url, List<int> bytes) async {
    final cleanUrl = url.trim();
    final filename = basename(cleanUrl);
    print("filename filename  ${filename}");
    // Check and request storage permissions
    if (await Permission.storage.request().isGranted) {
      // Save to external storage directory
      final externalDir = Directory('/storage/emulated/0/Android/data/com.diligov.doc/files/Documents');
      if (!await externalDir.exists()) {
        await externalDir.create(recursive: true);
      }

      final file = File('${externalDir.path}/$filename');

      print("file from _storeFileFromPath ${file}");
      await file.writeAsBytes(bytes, flush: true);
      return file;
    } else {
      throw Exception('Storage permission not granted');
    }
  }

  static Future<File> _storeFile(String url, List<int> bytes) async {
    final filename = basename(url);
    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/$filename');

    await file.writeAsBytes(bytes, flush: true);
    return file;
  }

  static Future<void> ensureDirectoryExists(String filePath) async {
    final directory = Directory(filePath);
    if (!await directory.exists()) {
      await directory.create(recursive: true);
    }
  }

  // Method to download and open the file
  static Future<void> downloadAndOpenFile(String url, BuildContext context) async {
    try {
      // Get the temporary directory to save the file
      Directory tempDir = await getTemporaryDirectory();
      String fileName = url.split('/').last;  // Extract the file name from the URL
      String filePath = "${tempDir.path}/$fileName";

      // Download the file using http package
      var response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        // Save the downloaded file to the local storage
        File file = File(filePath);
        await file.writeAsBytes(response.bodyBytes);

        // Open the file using open_filex
        OpenResult result = await OpenFile.open(filePath);

        // Handle the result of the file opening
        if (result.type != ResultType.done) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: CustomText(text: 'Error: ${result.message}',color: Colors.white)),
          );
        }
      } else {
        // Show error if the download failed
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content:CustomText(text:'Download failed with status: ${response.statusCode}',color: Colors.white)),
        );
      }
    } catch (e) {
      // Handle any exceptions that occur during download or file open
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: CustomText(text:'Error: $e',color: Colors.white)),
      );
    }
  }
}
