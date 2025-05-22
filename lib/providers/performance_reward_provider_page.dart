import 'dart:convert';
import 'dart:io';
import 'package:image/image.dart' as img;
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:logger/logger.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../NetworkHandler.dart';
import '../core/domains/app_uri.dart';
import '../models/member.dart';
import '../models/performance_reward_model.dart';
import '../models/user.dart';

import 'package:http/http.dart' as http;
import 'package:pdf/widgets.dart' as pw;

class PerformanceRewardProviderPage extends ChangeNotifier{
  PerformanceRewardData? performanceRewardData;

  PerformanceRewardModel _performanceReward = PerformanceRewardModel();
  PerformanceRewardModel get performanceReward => _performanceReward;

  var log = Logger();
  User user = User();
  NetworkHandler networkHandler = NetworkHandler();

  bool _isBack = false;
  bool get isBack => _isBack;
  void setIsBack(value) async {
    _isBack =  value;
    notifyListeners();
  }

  bool _loading = false;
  bool get loading => _loading;
  void setLoading(value) async {
    _loading =  value;
    notifyListeners();
  }

  File? _pdfFile;
  File? get pdfFile => _pdfFile;
  String _yearSelected = '2025';

  String get yearSelected => _yearSelected;

  void setYearSelected(year) async {
    _yearSelected =  year;
    notifyListeners();
  }

  Map<String, File?> uploadedFiles = {}; // Store uploaded files per nominee
  Map<String, String> enteredNames = {}; // Store entered names per nominee
  Map<String, bool> fileValidationErrors = {}; // Track if file is required

  /// Pick and upload file
  Future<void> pickFile(String nomineeName) async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );

    if (result != null) {
      File file = File(result.files.single.path!);
      uploadedFiles[nomineeName] = file;
      fileValidationErrors[nomineeName] = false; // Remove validation error when file is picked
      notifyListeners();
    }
  }

  /// Save entered name
  void saveEnteredName(String nomineeName, String newName) {
    enteredNames[nomineeName] = newName;
    notifyListeners();
  }

  /// Get uploaded file name
  String? getUploadedFileName(String nomineeName) {
    return uploadedFiles[nomineeName]?.path.split('/').last;
  }

  /// Get entered name
  String getEnteredName(String nomineeName) {
    return enteredNames[nomineeName] ?? "";
  }

  /// Convert file to Base64
  Future<String?> getFileAsBase64(String nomineeName) async {
    File? file = uploadedFiles[nomineeName];
    if (file != null) {
      List<int> fileBytes = await file.readAsBytes();
      return base64Encode(fileBytes);
    }
    return null;
  }

  /// Validate file (returns true if valid, false if missing)
  bool validateFile(String nomineeName) {
    if (uploadedFiles[nomineeName] == null) {
      fileValidationErrors[nomineeName] = true;
      notifyListeners();
      return false;
    }
    return true;
  }

  void clearUploadedFile(String bonusScheme) {
    uploadedFiles.remove(bonusScheme);
    fileValidationErrors.remove(bonusScheme);
    notifyListeners();
  }

  void setPerformanceRewardModel(PerformanceRewardModel performanceReward) async {
    _performanceReward =  performanceReward;
    notifyListeners();
  }

  Future getListOfPerformanceRewards(_yearSelected) async{
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    user =  User.fromJson(json.decode(prefs.getString("user")!)) ;
    final Map<String, String>  queryParams = {
      'business_id': user.businessId.toString(),
      'yearSelected': _yearSelected,
    };
    log.d("get-list-performanceRewards_yearSelected $_yearSelected");
    var response = await networkHandler.post1('/get-list-performance_rewards-by-filter-date',queryParams);
    if (response.statusCode == 200 || response.statusCode == 201) {
      log.d("get-list-performanceRewards form provider response statusCode == 200");
      var responseData = json.decode(response.body) ;
      var responsePerformanceRewardData = responseData['data'];
      log.d(responsePerformanceRewardData);
      performanceRewardData = PerformanceRewardData.fromJson(responsePerformanceRewardData);
      log.d(performanceRewardData!.performanceRewards!.length);
      notifyListeners();
    } else {
      log.d("get-list-performanceRewards form provider response statusCode unknown");
      log.d(response.statusCode);
      log.d(json.decode(response.body)['message']);
    }
  }

  Future<void> insertNewPerformanceRewardData(Map<String, dynamic> data)async{
    setLoading(true);
    var response = await networkHandler.post1('/insert-new-performance', data);
    if (response.statusCode == 200 || response.statusCode == 201) {
      log.d("insert new performance response statusCode == 200");
      var responseData = json.decode(response.body) ;
      var responsePerformanceRewardData = responseData['data'];
      _performanceReward = PerformanceRewardModel.fromJson(responsePerformanceRewardData['performance_reward']);
      setPerformanceRewardModel(_performanceReward);
      performanceRewardData!.performanceRewards!.add(_performanceReward);
      log.d(performanceRewardData!.performanceRewards!.length);
      setLoading(false);
    } else {
      setLoading(false);
      log.d("insert new performance response statusCode unknown");
      log.d(response.statusCode);
      print(json.decode(response.body)['message']);
    }
  }

  Future<void> getMemberPerformanceForSigningOrder(PerformanceRewardModel performance)async{
    // setLoading(true);
    Map<String, dynamic> data = {"performance_id": performance.performanceId};
    var response = await networkHandler.post1('/get-members-performance-for-signing-order', data);
    if (response.statusCode == 200 || response.statusCode == 201) {
      log.d("insert new performance response statusCode == 200");
      var responseData = json.decode(response.body) ;
      var responsePerformanceRewardData = responseData['data'];
      _performanceReward = PerformanceRewardModel.fromJson(responsePerformanceRewardData['performance_members']);
      setPerformanceRewardModel(_performanceReward);
      // performanceRewardData!.performanceRewards!.add(_performanceReward);
      // log.d(performanceRewardData!.performanceRewards!.length);
      // setLoading(false);
    } else {
      // setLoading(false);
      log.d("insert new performance response statusCode unknown");
      log.d(response.statusCode);
      print(json.decode(response.body)['message']);
    }
  }


  Future<void> removePerformance(PerformanceRewardModel deletePerformance)async{
    setLoading(true);
    final index = performanceRewardData!.performanceRewards!.indexOf(deletePerformance);
    PerformanceRewardModel performance = performanceRewardData!.performanceRewards![index];
    String performanceId =  performance.performanceId.toString();
    Map<String, dynamic> data = {"performance_id": performanceId};

    var response = await networkHandler.post1('/delete-performance-by-id', data);
    if (response.statusCode == 200 || response.statusCode == 201) {
      log.d("deleted performance response statusCode == 200");
      performanceRewardData!.performanceRewards!.remove(performance);
      log.d(performanceRewardData!.performanceRewards!.length);
      setIsBack(true);
      setLoading(false);
    } else {
      setLoading(false);
      setIsBack(false);
      log.d(json.decode(response.body)['message']);
      log.d(response.statusCode);
    }
  }

  Future<void> processPdfWorkflow(PerformanceRewardModel performance,String url, int pageCount, String uploadUrl) async {
    try {
      setLoading(true);
      print("📥 Downloading PDF...");
      final downloadedFile = await _downloadPdf(url);
      if (downloadedFile == null) throw Exception("Failed to download PDF");

      print("🔄 Merging PDF with new pages...");
      final mergedFile = await _mergePdfWithNewPages(downloadedFile, pageCount, performance);
      if (mergedFile == null) throw Exception("Failed to merge PDF");

      print("🚀 Uploading merged PDF...");
      await _uploadPdf(performance.performanceId.toString(), mergedFile, uploadUrl);

      print("✅ Process completed successfully!");
    } catch (e) {
      print("❌ Error: $e");
    } finally {
      setLoading(false);
    }
  }

  Future<File?> _downloadPdf(String url) async {
    try {
      var response = await http.get(Uri.parse(url));
      final fileCreateTime = DateTime.now().millisecondsSinceEpoch;
      if (response.statusCode == 200) {
        Directory tempDir = await getApplicationDocumentsDirectory();
        String tempPath = '${tempDir.path}/$fileCreateTime.pdf';

        File file = File(tempPath);
        await file.writeAsBytes(response.bodyBytes);
        _pdfFile = file;
        return file;
      } else {
        print("❌ Error downloading PDF: ${response.statusCode}");
        return null;
      }
    } catch (e) {
      print("❌ Error downloading PDF: $e");
      return null;
    }
  }

  // 📌 2️⃣ Get Page Theme
  Future<pw.PageTheme> _myPageTheme(PdfPageFormat format) async {
    final form = await rootBundle.load('assets/fonts/Al-Mohanad-Regular.ttf');
    final ttf = await rootBundle.load('assets/fonts/Al-Mohanad-Bold.ttf');
    final theme = pw.ThemeData.withFont(
      base: pw.Font.ttf(form),
      bold: pw.Font.ttf(ttf),
    );

    return pw.PageTheme(
      theme: theme,
      margin: const pw.EdgeInsets.symmetric(
        horizontal: 1 * PdfPageFormat.cm,
        vertical: 0.5 * PdfPageFormat.cm,
      ),
      orientation: pw.PageOrientation.portrait,
    );
  }

  pw.Widget _buildFooter(pw.Context context) {
    return pw.Column(
        children: [
          pw.Container(
            alignment: pw.Alignment.centerRight,
            child: pw.Text('Page ${context.pageNumber} of ${context.pagesCount}', style: pw.TextStyle(fontSize: 8)),
          ),
          pw.Divider(thickness: 1.0,),
        ]
    );
  }

  // 📌 2️⃣ Merge PDF (Preserve Original Pages)
  Future<File?> _mergePdfWithNewPages(File file, int pageCount, PerformanceRewardModel performance) async {
    try {
      final pdf = pw.Document();
      final existingPdfBytes = await file.readAsBytes();
      final pageTheme = await _myPageTheme(PdfPageFormat.a4);

      // Extract committee members
      List<Member> members = performance.committee?.members ?? [];

      // Fetch member images from network
      List<pw.MemoryImage> memberImages = [];
      for (var member in members) {
        try {
          var response = await http.get(Uri.parse("${AppUri.profileImages}/${member.businessId}/${member.memberProfileImage}"));
          if (response.statusCode == 200) {
            memberImages.add(pw.MemoryImage(response.bodyBytes));
          } else {
            memberImages.add(pw.MemoryImage((await rootBundle.load('assets/images/default_avatar.png')).buffer.asUint8List())); // Fallback image
          }
        } catch (e) {
          print("❌ Error loading image for ${member.memberFirstName}: $e");
          memberImages.add(pw.MemoryImage((await rootBundle.load('assets/images/default_avatar.png')).buffer.asUint8List())); // Fallback image
        }
      }

      log.i('memberNames memberNames memberNames $members');
      // Add Original PDF Pages
      final existingPages = await Printing.raster(existingPdfBytes).toList();
      for (var page in existingPages) {
        final imageBytes = await page.toPng();
        pdf.addPage(
          pw.Page(
            pageTheme: pageTheme,
            build: (context) {
              return pw.Image(pw.MemoryImage(imageBytes));
            },
          ),
        );
      }

      // Add Themed New Pages
      for (int i = 1; i <= pageCount; i++) {
        pdf.addPage(
          pw.MultiPage(
            pageTheme: pageTheme,
            footer: (context) => _buildFooter(context),
            build: (context) => [
              // Member Table with Images
              pw.Table(
                border: pw.TableBorder.all(width: 1),
                children: [
                  // Table Header
                  pw.TableRow(
                    children: [
                      pw.Container(
                        padding: const pw.EdgeInsets.all(8),
                        child: pw.Text("Member Image", style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                      ),
                      pw.Container(
                        padding: const pw.EdgeInsets.all(8),
                        child: pw.Text("Member First Name", style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                      ),
                    ],
                  ),
                  // Table Rows (Images + Names)
                  for (int index = 0; index > members.length; index++)
                    pw.TableRow(
                      children: [
                        pw.Container(
                          padding: const pw.EdgeInsets.all(5),
                          child: pw.Image(memberImages[index], width: 40, height: 40, fit: pw.BoxFit.cover),
                        ),
                        pw.Container(
                          padding: const pw.EdgeInsets.all(5),
                          child: pw.Text(
                              '${members[index].memberFirstName} ${members[index].memberMiddleName}' ?? "Unknown"),
                        ),
                      ],
                    ),
                ],
              ),
            ],
          ),
        );
      }

      final fileCreateTime = DateTime.now().millisecondsSinceEpoch;
      Directory tempDir = await getApplicationDocumentsDirectory();
      String newPdfPath = '${tempDir.path}/$fileCreateTime.pdf';
      File newPdfFile = File(newPdfPath);
      await newPdfFile.writeAsBytes(await pdf.save());

      _pdfFile = newPdfFile;
      return newPdfFile;
    } catch (e) {
      print("❌ Error merging PDFs: $e");
      return null;
    }
  }

// 📌 4️⃣ Upload Final PDF and Refresh Data
  Future<void> _uploadPdf(String performanceId,File file, String uploadUrl) async {
    try {
      setLoading(true);
      notifyListeners();
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      user =  User.fromJson(json.decode(prefs.getString("user")!)) ;

      // Read file as bytes and encode to Base64
      List<int> pdfBytes = await file.readAsBytes();
      String base64Pdf = base64Encode(pdfBytes);

      // Generate a unique filename
      String fileName = "performance_${DateTime.now().millisecondsSinceEpoch}.pdf";

      // Prepare data for upload
      Map<String, dynamic> data = {
        "performance_id": performanceId,
        "bonus_scheme_file": base64Pdf,
        "fileName": fileName,
        "business_id": user.businessId.toString(),
        // "committee_id": committeeId,
      };

      // Send the request
      var response = await networkHandler.post1('/publish-performance-bonus_scheme_file', data);

      if (response.statusCode == 200 || response.statusCode == 201) {
        print("✅ PDF uploaded successfully!");

        // Refresh performance reward data after successful upload
        await _refreshPerformanceRewards();
        setLoading(false);

      } else {
        print("❌ PDF upload failed: ${response.body}");
      }
    } catch (e) {
      print("❌ Error uploading PDF: $e");
    } finally {
      setLoading(false);
      notifyListeners();
    }
  }

// 📌 Refresh Performance Rewards Data After Upload
  Future<void> _refreshPerformanceRewards() async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      user = User.fromJson(json.decode(prefs.getString("user")!));

      final Map<String, String> queryParams = {
        'business_id': user.businessId.toString(),
        'yearSelected': _yearSelected,
      };

      log.d("Refreshing performance rewards for year $_yearSelected");

      var response = await networkHandler.post1('/get-list-performance_rewards-by-filter-date', queryParams);

      if (response.statusCode == 200 || response.statusCode == 201) {
        var responseData = json.decode(response.body);
        var responsePerformanceRewardData = responseData['data'];

        performanceRewardData = PerformanceRewardData.fromJson(responsePerformanceRewardData);
        log.d("Updated Performance Rewards Count: ${performanceRewardData!.performanceRewards!.length}");

        notifyListeners();
      } else {
        log.d("Error refreshing performance rewards: ${response.statusCode}");
      }
    } catch (e) {
      log.d("❌ Error refreshing performance rewards: $e");
    }
  }

}