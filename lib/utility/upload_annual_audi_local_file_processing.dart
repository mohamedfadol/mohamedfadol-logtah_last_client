import 'dart:convert';

import 'package:diligov_members/models/annual_audit_report_model.dart';
import 'package:diligov_members/utility/pdf_api.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_gen/gen_l10n/app_localization.dart';
import '../models/user.dart';
import '../providers/annual_audit_report_provider.dart';
import '../providers/note_page_provider.dart';
import '../widgets/custom_icon.dart';
import '../widgets/custome_text.dart';

class UploadAnnualAudiLocalFileProcessing extends StatefulWidget {
  final String path;
  final AnnualAuditReportModel annual_audit;
  const UploadAnnualAudiLocalFileProcessing({super.key, required this.path, required this.annual_audit});

  @override
  State<UploadAnnualAudiLocalFileProcessing> createState() => _UploadAnnualAudiLocalFileProcessingState();
}

class _UploadAnnualAudiLocalFileProcessingState extends State<UploadAnnualAudiLocalFileProcessing> {
  User user = User();
  String localPath = "";

  @override
  void initState() {
    // Enforce portraitUp and portraitDown orientations
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    preparePdfFileFromNetwork();
    super.initState();
  }

  @override
  void dispose() {
    // Allow all orientations when the widget is disposed
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    super.dispose();
  }


  Future<void> preparePdfFileFromNetwork() async {
    try {
      if(await PDFApi.requestPermission()){
        setState(() { localPath = widget.path!;});
      } else {
        print("Lacking permissions to access the file in preparePdfFileFromNetwork function");
        return;
      }
    } catch (e) { print("Error preparePdfFileFromNetwork function PDF: $e"); }
  }

  Future<void> takeScreenshot() async {
    final provider = Provider.of<AnnualAuditReportProvider>(context,listen: false);
    try {
      if(await PDFApi.requestPermission()){

        provider.setLoading(true);
        final SharedPreferences prefs = await SharedPreferences.getInstance();
        user =  User.fromJson(json.decode(prefs.getString("user")!));
        final filePath = widget.path;
        final base64File = await PDFApi.getFileAsBase64(filePath);

        if (base64File != null) {
          print('File as Base64: ${widget.path}');
        } else {
          print('Failed to convert file to Base64.');
        }

        Map<String, dynamic> data = {
          "file_edited": base64File,
          "business_id": user.businessId,
          "add_by": user.userId,
          "annual_audit_id": widget.annual_audit.annualAuditReportId,
        };

        Future.delayed(Duration.zero, () {
          provider.insertAnnualAuditReportFile(data);

        });
        if(provider.loading == true) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: CustomText(text: AppLocalizations.of(context)!.agenda_add_successfully ),
              backgroundColor: Colors.greenAccent,
            ),
          );
          Future.delayed(const Duration(seconds: 10), () {
            // Navigator.of(context).push(MaterialPageRoute(builder: (context) => LaboratoryLocalFileProcessing(minute: widget.minute!,)));
            // Navigator.pushReplacementNamed(context, EditLaboratoryLocalFileProcessing.routeName);
          });
        }else{
          provider.setLoading(false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: CustomText(text: AppLocalizations.of(context)!.agenda_add_failed ),
              backgroundColor: Colors.redAccent,
            ),
          );
        }
        print('done to open download file');
      } else {
        provider.setLoading(false);
        print("Lacking permissions to access the file.");
        return;
      }
    } catch (e) {
      provider.setLoading(false);
      print("Error catch taking screenshot function: $e");
    }
  }


  @override
  Widget build(BuildContext context) {

    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(),
      body: Consumer<AnnualAuditReportProvider>(
        builder: (BuildContext context, provider, child) {
          return  localPath.isNotEmpty
              ? SafeArea(
            child: Stack(
              children: [
                PDFView(
                  fitEachPage: true,
                  filePath: localPath,
                  autoSpacing: false,
                  enableSwipe: true,
                  pageSnap: true,
                  swipeHorizontal: false,
                  nightMode: false,
                ),
              ],
            ),
          )
              : const Center(child: CircularProgressIndicator())   ;
        },

      ),
      floatingActionButton: Consumer<AnnualAuditReportProvider>(
          builder: (context, provider, child){
            return provider.loading == true ?  CircularProgressIndicator(color: Colors.green,) : FloatingActionButton(
              onPressed: () async{
                Future.delayed(const Duration(milliseconds: 500), () async {
                  takeScreenshot();
                });
              },
              tooltip: 'Save File',
              child: CustomIcon(icon:Icons.upload_file),
            );
          }
      ),
    );
  }


}
