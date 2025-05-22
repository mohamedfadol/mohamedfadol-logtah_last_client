import 'package:diligov_members/models/annual_reports_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../colors.dart';
import '../../../models/annual_audit_report_model.dart';
import '../../../models/data/years_data.dart';
import '../../../providers/annual_audit_report_provider.dart';
import '../../../utility/pdf_annual_report_api.dart';
import '../../../utility/pdf_api.dart';
import '../../../widgets/appBar.dart';
import '../../../widgets/build_dynamic_data_cell.dart';
import '../../../widgets/custom_elevated_button.dart';
import '../../../widgets/custom_icon.dart';
import '../../../widgets/custom_message.dart';
import '../../../widgets/custome_text.dart';
import '../../../widgets/dropdown_string_list.dart';
import '../../../widgets/loading_sniper.dart';
import 'package:flutter_gen/gen_l10n/app_localization.dart';

import '../../committee_views/annual_audit_report/annual_audit_generate_dual_pdf_pag.dart';
import '../../committee_views/annual_audit_report/annual_audit_generate_for_arabic_pdf_pag.dart';
import '../../committee_views/annual_audit_report/annual_audit_generate_for_english_pdf_pag.dart';
import '../../committee_views/annual_audit_report/forms/build_annual_audit_report_form_card.dart';


class CommitteesAnnualAuditReportListView extends StatefulWidget {
  static const routeName = '/AnnualReportListView';
  const CommitteesAnnualAuditReportListView({super.key});

  @override
  State<CommitteesAnnualAuditReportListView> createState() => _CommitteesAnnualAuditReportListViewState();
}

class _CommitteesAnnualAuditReportListViewState extends State<CommitteesAnnualAuditReportListView> {

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();

  }

  @override
  Widget build(BuildContext context) {

    // Retrieve the arguments passed from navigation
    final Map<String, dynamic>? args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>?;

    // Extract committeeId safely
    String committeeId = args?['committeeId'] ?? "No ID Provided";

    print("committeeId _CommitteesAnnualAuditReportListViewState $committeeId");
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);

    return WillPopScope(
      onWillPop: () async {
        // Reset to default orientation when leaving the screen
        SystemChrome.setPreferredOrientations(DeviceOrientation.values);
        return true;
      },
      child: Scaffold(
        appBar: Header(context),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 5.0, horizontal: 10.0),
            child: ListView(
              scrollDirection: Axis.vertical,
              children: [
                buildFullTopFilter(),
                Center(
                  child: Consumer<AnnualAuditReportProvider>(
                      builder: (context, provider, child) {
                        if (provider.annual_audit_reports_data?.annual_audit_reports_data == null) {
                          provider.getListOfAnnualAuditReports(provider.yearSelected);
                          return buildLoadingSniper();
                        }
                        return provider.annual_audit_reports_data!.annual_audit_reports_data!.isEmpty
                            ? buildEmptyMessage(
                            AppLocalizations.of(context)!.no_data_to_show)
                            : SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: SingleChildScrollView(
                            child: SizedBox(
                              width: MediaQuery.of(context).size.width,
                              child: DataTable(
                                showBottomBorder: true,
                                dividerThickness: 5.0,
                                headingRowColor: MaterialStateColor.resolveWith(
                                        (states) =>
                                    Colour().darkHeadingColumnDataTables),
                                // dataRowColor: MaterialStateColor.resolveWith((states) => Colour().lightBackgroundColor),
                                columns: <DataColumn>[
                                  DataColumn(
                                      label: CustomText(
                                        text: "Annual Audit title",
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18.0,
                                        color: Colour().lightBackgroundColor,
                                      ),
                                      tooltip: "show minute name"),
                                  DataColumn(
                                      label: CustomText(
                                        text: AppLocalizations.of(context)!.date,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18.0,
                                        color: Colour().lightBackgroundColor,
                                      ),
                                      tooltip: "show minute Date"),
                                  DataColumn(
                                      label: CustomText(
                                        text: 'Committee Name',
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18.0,
                                        color: Colour().lightBackgroundColor,
                                      ),
                                      tooltip: "Committee name"),
                                  DataColumn(
                                      label: CustomText(
                                        text: AppLocalizations.of(context)!.owner,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18.0,
                                        color: Colour().lightBackgroundColor,
                                      ),
                                      tooltip: "owner that add by"),
                                  DataColumn(
                                      label: CustomText(
                                        text:
                                        AppLocalizations.of(context)!.actions,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18.0,
                                        color: Colour().lightBackgroundColor,
                                      ),
                                      tooltip:
                                      "show buttons for functionality members"),
                                ],
                                rows: provider!.annual_audit_reports_data!.annual_audit_reports_data!
                                    .map((annual_report) =>
                                    DataRow(cells: [
                                      BuildDynamicDataCell(
                                        child: CustomText(text:annual_report!.annualAuditReportTitleEn!,
                                            fontWeight: FontWeight.bold,fontSize: 14.0,softWrap: false,
                                            maxLines: 1,overflow: TextOverflow.ellipsis,
                                        ),
                                      ),

                                      BuildDynamicDataCell(
                                        child: CustomText(text:annual_report!.annualAuditReportTitleAr?? '',
                                          fontWeight: FontWeight.bold,fontSize: 14.0,softWrap: false,
                                          maxLines: 1,overflow: TextOverflow.ellipsis,
                                        ),
                                      ),


                                      BuildDynamicDataCell(
                                        child: CustomText(text: annual_report.committee!.committeeName! ,
                                          fontWeight: FontWeight.bold,fontSize: 14.0,softWrap: false,
                                          maxLines: 1,overflow: TextOverflow.ellipsis,
                                        ),
                                      ),


                                      BuildDynamicDataCell(
                                        child: CustomText(text: annual_report?.user?.firstName ??
                                            "loading ...",
                                          fontWeight: FontWeight.bold,fontSize: 14.0,softWrap: false,
                                          maxLines: 1,overflow: TextOverflow.ellipsis,
                                        ),
                                      ),

                                      DataCell(
                                        PopupMenuButton<int>(
                                            padding:
                                            EdgeInsets.only(bottom: 5.0),
                                            icon: CustomIcon(
                                              icon: Icons.settings,
                                              size: 30.0,
                                            ),
                                            onSelected: (value) => 0,
                                            itemBuilder: (context) =>
                                            [
                                              PopupMenuItem<int>(
                                                  value: 0,
                                                  child:
                                                  CustomElevatedButton(
                                                      verticalPadding:
                                                      0.0,
                                                      text: AppLocalizations
                                                          .of(
                                                          context)!
                                                          .view,
                                                      icon: Icons
                                                          .remove_red_eye_outlined,
                                                      textColor:
                                                      Colors
                                                          .white,
                                                      buttonBackgroundColor:
                                                      Colors.red,
                                                      horizontalPadding:
                                                      10.0,
                                                      callFunction:
                                                          () async {
                                                        print('View done');
                                                        // final pdfFile = await PdfAnnualReportApi.generate(annual_report, context);
                                                        // print(pdfFile);
                                                        // PDFApi.openFile(pdfFile);
                                                      })),
                                              PopupMenuItem<int>(
                                                value: 1,
                                                child: ExpansionTile(
                                                  title: CustomText(
                                                    text: AppLocalizations.of(context)!.export,
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 16.0,
                                                  ),
                                                  leading: Icon(Icons.import_export_outlined, color: Colors.red),
                                                  children: [
                                                    ListTile(
                                                      leading: Icon(Icons.language, color: Colors.green),
                                                      title: CustomText(text: "Export to Arabic"),
                                                      onTap: () async{
                                                        Navigator.of(context).push(MaterialPageRoute(
                                                            builder: (context) => AnnualAuditGenerateForArabicPdfPag(annual_report: annual_report)
                                                        ),
                                                        );
                                                      },
                                                    ),
                                                    ListTile(
                                                      leading: Icon(Icons.language, color: Colors.blue),
                                                      title: CustomText(text: "Export to English"),
                                                      onTap: () async{
                                                        Navigator.of(context).push(MaterialPageRoute(
                                                            builder: (context) => AnnualAuditGenerateForEnglishPdfPag(annual_report: annual_report)
                                                        ),
                                                        );
                                                      },
                                                    ),
                                                    ListTile(
                                                      leading: Icon(Icons.public, color: Colors.orange),
                                                      title: CustomText(text: "Export to Dual (Arabic & English)"),
                                                      onTap: () async {
                                                        Navigator.of(context).push(MaterialPageRoute(
                                                            builder: (context) => AnnualAuditGenerateForDualPdfPag(annual_report: annual_report)
                                                        ),
                                                        );
                                                      },
                                                    ),
                                                  ],
                                                ),
                                              ),

                                              PopupMenuItem<int>(
                                                  value: 2,
                                                  child: CustomElevatedButton(
                                                      verticalPadding:
                                                      0.0,
                                                      text:
                                                      AppLocalizations.of(
                                                          context)!
                                                          .signed,
                                                      icon: Icons
                                                          .checklist_outlined,
                                                      textColor:
                                                      Colors.white,
                                                      buttonBackgroundColor:
                                                      Colors.red,
                                                      horizontalPadding:
                                                      10.0,
                                                      callFunction: () {
                                                        // dialogToMakeSignAnnualReport(annual_report);
                                                      })),
                                              PopupMenuItem<int>(
                                                  value: 4,
                                                  child:
                                                  CustomElevatedButton(
                                                    verticalPadding: 0.0,
                                                    text: AppLocalizations
                                                        .of(context)!
                                                        .delete,
                                                    icon: Icons
                                                        .restore_from_trash_outlined,
                                                    textColor:
                                                    Colors.white,
                                                    buttonBackgroundColor:
                                                    Colors.red,
                                                    horizontalPadding:
                                                    10.0,
                                                    callFunction: () {
                                                      // dialogDeleteAnnualReport(annual_report);
                                                    },
                                                  )),
                                            ]),
                                      ),
                                    ]))
                                    .toList(),
                              ),
                            ),
                          ),
                        );
                      }),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget buildFullTopFilter() {
    return Consumer<AnnualAuditReportProvider>(
        builder: (BuildContext context, provider, child){
          return Padding(
            padding:
            const EdgeInsets.only(top: 3.0, left: 0.0, right: 8.0, bottom: 8.0),
            child: Row(
              children: [
                Container(
                    padding:const EdgeInsets.symmetric(vertical: 7.0, horizontal: 15.0),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                      color: Colour().buttonBackGroundRedColor,
                    ),
                    child: CustomText(
                        text: AppLocalizations.of(context)!.annual_report_list,
                        fontSize: 20,
                        fontWeight: FontWeight.bold)),
                const SizedBox(
                  width: 5.0,
                ),

                Container(
                  width: 200,
                  padding:const EdgeInsets.symmetric(vertical: 7.0, horizontal: 15.0),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                    color: Colour().buttonBackGroundRedColor,
                  ),
                  child: DropdownStringList(
                    boxDecoration: Colors.white,
                    hint: CustomText(text: AppLocalizations.of(context)!.select_year),
                    selectedValue: provider.yearSelected,
                    dropdownItems: yearsData,
                    onChanged: (String? newValue) async {
                      provider.setYearSelected(newValue!.toString());
                      await  provider.getListOfAnnualAuditReports(provider.yearSelected);
                    },
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(
                  width: 5.0,
                ),
                Container(
                  padding:const EdgeInsets.symmetric(vertical: 2.0, horizontal: 15.0),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                    color: Colour().buttonBackGroundRedColor,
                  ),
                  child: TextButton(
                    onPressed: () async {
                      Navigator.of(context).pushReplacementNamed(BuildAnnualAuditReportFormCard.routeName);
                    }, child: CustomText(text: 'Add New',fontSize: 20,
                      fontWeight: FontWeight.bold),
                  ),
                )
              ],
            ),
          );
        }
    );
  }

  Future dialogDeleteAnnualReport(AnnualAuditReportModel annualReport) => showDialog(
    // barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return AlertDialog(
                backgroundColor: Colors.white,
                insetPadding: const EdgeInsets.symmetric(horizontal: 100),
                title: Center(
                    child: CustomText(text:"${AppLocalizations.of(context)!.are_you_sure_to_delete} ${annualReport.annualAuditReportTitleEn!} ?",
                        color: Colors.red,
                        fontSize: 20,
                        fontWeight: FontWeight.bold)),
                content: SingleChildScrollView(
                  scrollDirection: Axis.vertical,
                  child: Container(
                      color: Colors.white,
                      width: MediaQuery.of(context).size.width * 0.35,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10.0, vertical: 10.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            ElevatedButton.icon(
                              label: CustomText(
                                text: AppLocalizations.of(context)!.yes_delete,
                                color: Colors.white,
                              ),
                              icon: const Icon(Icons.check, color: Colors.white),
                              onPressed: () {
                                removeAnnualReport(annualReport);
                              },
                              style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red,
                                  padding:
                                  const EdgeInsets.symmetric(horizontal: 10.0)),
                            ),
                            ElevatedButton.icon(
                              label: CustomText(
                                text: AppLocalizations.of(context)!.no_cancel,
                                color: Colors.white,
                              ),
                              icon: const Icon(Icons.clear, color: Colors.white),
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                              style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red,
                                  padding:
                                  const EdgeInsets.symmetric(horizontal: 10.0)),
                            )
                          ],
                        ),
                      )),
                ),
              );
            });
      });

  void removeAnnualReport(AnnualAuditReportModel annualReport)async {
    final providerAnnualReports = Provider.of<AnnualAuditReportProvider>(context, listen: false);
    await providerAnnualReports.removeAnnualAuditReport(annualReport);
    if (providerAnnualReports.isBack == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: CustomText(text: AppLocalizations.of(context)!.remove_minute_done),
          backgroundColor: Colors.greenAccent,
        ),
      );
      Navigator.of(context).pop();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: CustomText(
              text: AppLocalizations.of(context)!.remove_minute_failed),
          backgroundColor: Colors.redAccent,
        ),
      );
      Navigator.of(context).pop();
    }
  }

  Future dialogToMakeSignAnnualReport(AnnualReportsModel annualReport) => showDialog(
    // barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return AlertDialog(
                backgroundColor: Colors.white,
                insetPadding: const EdgeInsets.symmetric(horizontal: 100),
                title: Center(
                    child: CustomText(
                        text:
                        "${AppLocalizations.of(context)!.are_you_sure} ${annualReport.annualReportName!} ${AppLocalizations.of(context)!.to_sign}",
                        color: Colors.green,
                        fontSize: 20,
                        fontWeight: FontWeight.bold)),
                content: SingleChildScrollView(
                  scrollDirection: Axis.vertical,
                  child: Container(
                      color: Colors.white,
                      width: MediaQuery.of(context).size.width * 0.35,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10.0, vertical: 10.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            ElevatedButton.icon(
                              label: CustomText(
                                text: AppLocalizations.of(context)!.yes_sure,
                                color: Colors.white,
                              ),
                              icon: const Icon(Icons.check, color: Colors.white),
                              onPressed: () {
                                makeSignOnAnnualReport(annualReport);
                              },
                              style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.green,
                                  padding:
                                  const EdgeInsets.symmetric(horizontal: 10.0)),
                            ),
                            ElevatedButton.icon(
                              label: CustomText(
                                text: AppLocalizations.of(context)!.no_cancel,
                                color: Colors.white,
                              ),
                              icon: const Icon(Icons.clear, color: Colors.white),
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                              style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red,
                                  padding:
                                  const EdgeInsets.symmetric(horizontal: 10.0)),
                            )
                          ],
                        ),
                      )),
                ),
              );
            });
      });

  void makeSignOnAnnualReport(AnnualReportsModel annualReport) async {
    // Map<String, dynamic> data = {"annual_report_id": annualReport.annualReportId!,"member_id": 7};
    // final Future<Map<String, dynamic>> response = providerAnnualReports.makeSignedAnnualReport(data);
    // response.then((response) {
    //   if (response['status']) {
    //     providerAnnualReports.setIsBack(true);
    //     ScaffoldMessenger.of(context).showSnackBar(
    //       SnackBar(
    //         content: Column(
    //           children: [
    //             CustomText(text: AppLocalizations.of(context)!.signed_successfully),
    //             const SizedBox(height: 10.0,),
    //             CustomText(text: response['message'])
    //           ],
    //         ),
    //         backgroundColor: Colors.greenAccent,
    //         duration: const Duration(seconds: 6),
    //       ),
    //     );
    //     Navigator.of(context).pop();
    //   } else {
    //     providerAnnualReports.setIsBack(false);
    //     ScaffoldMessenger.of(context).showSnackBar(
    //       SnackBar(
    //         content: Column(
    //           children: [
    //             CustomText(text: AppLocalizations.of(context)!.signed_failed),
    //             const SizedBox(height: 10.0,),
    //             CustomText(text: response['message'])
    //           ],
    //         ),
    //         backgroundColor: Colors.redAccent,
    //         duration: const Duration(seconds: 6),
    //       ),
    //     );
    //     Navigator.of(context).pop();
    //   }
    // });
  }

  Future dialogDownloadAnnualReport(AnnualReportsModel annualReport) => showDialog(
    // barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return AlertDialog(
                backgroundColor: Colors.white,
                insetPadding: const EdgeInsets.symmetric(horizontal: 100),
                title: Center(
                    child: CustomText(text: "${AppLocalizations.of(context)!.yes_sure_download} ${annualReport.annualReportName!} ?",
                        color: Colors.green,
                        fontSize: 20,
                        fontWeight: FontWeight.bold)),
                content: SingleChildScrollView(
                  scrollDirection: Axis.vertical,
                  child: Container(
                      color: Colors.white,
                      width: MediaQuery.of(context).size.width * 0.35,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10.0, vertical: 10.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            ElevatedButton.icon(
                              label: CustomText(
                                text: AppLocalizations.of(context)!.yes_download,
                                color: Colors.white,
                              ),
                              icon: const Icon(Icons.download, color: Colors.white),
                              onPressed: () async {
                                print('no function yet in download');
                                downloadAnnualReport(annualReport);
                              },
                              style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.green,
                                  padding:
                                  const EdgeInsets.symmetric(horizontal: 10.0)),
                            ),
                            ElevatedButton.icon(
                              label: CustomText(
                                text: AppLocalizations.of(context)!.no_cancel,
                                color: Colors.white,
                              ),
                              icon: const Icon(Icons.clear, color: Colors.white),
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                              style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red,
                                  padding:
                                  const EdgeInsets.symmetric(horizontal: 10.0)),
                            )
                          ],
                        ),
                      )),
                ),
              );
            });
      });

  Future<void> downloadAnnualReport(AnnualReportsModel annualReport) async {
    final pdfFile = await PdfAnnualReportApi.generate(annualReport, context);
    if (await PDFApi.requestPermission()) {
      await PDFApi.downloadFileToStorage(pdfFile);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: CustomText(
              text: AppLocalizations.of(context)!.download_file_is_done),
          backgroundColor: Colors.greenAccent,
        ),
      );
      Future.delayed(const Duration(seconds: 5), () {
        Navigator.of(context).pop();
      });
    } else {
      print('permission error--------------');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: CustomText(
              text: AppLocalizations.of(context)!.download_file_is_failed),
          backgroundColor: Colors.redAccent,
        ),
      );
      Navigator.of(context).pop();
    }
  }

  buildEmptyMessage(String message) {
    return CustomMessage(
      text: message,
    );
  }

  buildLoadingSniper() {
    return const LoadingSniper();
  }

}