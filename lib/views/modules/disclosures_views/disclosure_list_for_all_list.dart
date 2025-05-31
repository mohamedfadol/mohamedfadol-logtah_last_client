import 'package:diligov_members/models/disclosure_model.dart';
import 'package:diligov_members/providers/disclosure_page_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../colors.dart';
import '../../../models/data/years_data.dart';
import '../../../utility/pdf_api.dart';
import '../../../utility/pdf_disclosure_api.dart';
import '../../../widgets/appBar.dart';
import '../../../widgets/build_dynamic_data_cell.dart';
import '../../../widgets/custom_elevated_button.dart';
import '../../../widgets/custom_icon.dart';
import '../../../widgets/custom_message.dart';
import '../../../widgets/custome_text.dart';
import '../../../widgets/dropdown_string_list.dart';
import 'package:flutter_gen/gen_l10n/app_localization.dart';

import '../../../widgets/loading_sniper.dart';
import 'disclosures_list_view.dart';


class DisclosureListForAllList extends StatefulWidget {
  const DisclosureListForAllList({super.key});
  static const routeName = '/DisclosureListForAllList';

  @override
  State<DisclosureListForAllList> createState() => _DisclosureListForAllListState();
}

class _DisclosureListForAllListState extends State<DisclosureListForAllList> {

  late DisclosurePageProvider providerDisclosure;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    Future.delayed(Duration.zero, () {
      providerDisclosure = Provider.of<DisclosurePageProvider>(context,listen: false);
      PdfDisclosureApi.getLocale(context);
      PdfDisclosureApi.getTextDirection(context);
      PdfDisclosureApi.getTextAlign(context);
      PdfDisclosureApi.getLocale(context);
      // PdfDisclosureApi.getLang(context);
    });
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: Header(context),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 5.0, horizontal: 10.0),
          child: ListView(
            scrollDirection: Axis.vertical,
            children: [
              buildFullTopFilter( ),
              Center(
                child: Consumer<DisclosurePageProvider>(
                    builder: (context, provider, child) {
                      if (provider.disclosuresData?.disclosures == null) {
                        provider.getListOfAllDisclosures(provider.yearSelected);
                        return buildLoadingSniper();
                      }
                      return provider.disclosuresData!.disclosures!.isEmpty
                          ? buildEmptyMessage(
                          AppLocalizations.of(context)!.no_data_to_show)
                          : SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: SingleChildScrollView(
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
                                    text: AppLocalizations.of(context)!
                                        .name,
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
                                    text: AppLocalizations.of(context)!.file,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18.0,
                                    color: Colour().lightBackgroundColor,
                                  ),
                                  tooltip: "file"),
                              DataColumn(
                                  label: CustomText(
                                    text: AppLocalizations.of(context)!
                                        .type,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18.0,
                                    color: Colour().lightBackgroundColor,
                                  ),
                                  tooltip: "meeting name"),
                              DataColumn(
                                  label: CustomText(
                                    text:
                                    AppLocalizations.of(context)!.owner,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18.0,
                                    color: Colour().lightBackgroundColor,
                                  ),
                                  tooltip: "signed"),
                              DataColumn(
                                  label: CustomText(
                                    text: AppLocalizations.of(context)!.signed,
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
                            rows: provider!.disclosuresData!.disclosures!
                                .map((DisclosureModel disclosure) =>
                                DataRow(cells: [
                                  BuildDynamicDataCell(
                                    child: CustomText(text:disclosure!.disclosureName!,
                                      fontWeight: FontWeight.bold,fontSize: 14.0,softWrap: false,
                                      maxLines: 1,overflow: TextOverflow.ellipsis,
                                    ),
                                  ),

                                  BuildDynamicDataCell(
                                    child: CustomText(text:disclosure!.disclosureDate!,
                                      fontWeight: FontWeight.bold,fontSize: 14.0,softWrap: false,
                                      maxLines: 1,overflow: TextOverflow.ellipsis,
                                    ),
                                  ),

                                  BuildDynamicDataCell(
                                    child: CustomText(text:disclosure!.disclosureFile!,
                                      fontWeight: FontWeight.bold,fontSize: 14.0,softWrap: false,
                                      maxLines: 1,overflow: TextOverflow.ellipsis,
                                    ),
                                  ),

                                  BuildDynamicDataCell(
                                    child: CustomText(text:disclosure!.disclosureType!,
                                      fontWeight: FontWeight.bold,fontSize: 14.0,softWrap: false,
                                      maxLines: 1,overflow: TextOverflow.ellipsis,
                                    ),
                                  ),

                                  BuildDynamicDataCell(
                                    child: CustomText(text: disclosure?.user?.name.toString() ?? 'Loading...',
                                      fontWeight: FontWeight.bold,fontSize: 14.0,softWrap: false,
                                      maxLines: 1,overflow: TextOverflow.ellipsis,
                                    ),
                                  ),

                                  BuildDynamicDataCell(
                                    child: CustomText(text: 'status not yet',
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
                                        itemBuilder: (context) => [
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
                                                    final pdfFile = await PdfDisclosureApi.generate(disclosure,context);
                                                    print(pdfFile);
                                                    PDFApi.openFile(pdfFile);
                                                  })),
                                          PopupMenuItem<int>(
                                              value: 1,
                                              child: CustomElevatedButton(
                                                  verticalPadding:
                                                  0.0,
                                                  text:
                                                  AppLocalizations.of(
                                                      context)!
                                                      .export,
                                                  icon: Icons
                                                      .import_export_outlined,
                                                  textColor:
                                                  Colors.white,
                                                  buttonBackgroundColor:
                                                  Colors.red,
                                                  horizontalPadding:
                                                  10.0,
                                                  callFunction:
                                                      () async {
                                                    await dialogDownloadDisclosure(disclosure);
                                                  })),
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
                                                  callFunction:() {
                                                    dialogToMakeSignDisclosure(disclosure);
                                                  })),
                                        ]),
                                  ),
                                ]))
                                .toList(),
                          ),
                        ),
                      );
                    }),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildFullTopFilter() {
    return Consumer<DisclosurePageProvider>(
        builder: (BuildContext context, provider, _) {
          return Padding(
            padding:
            const EdgeInsets.only(top: 3.0, left: 15.0, right: 15.0, bottom: 8.0),
            child: Row(
              children: [
                Container(
                  padding:const EdgeInsets.symmetric(vertical: 15.0, horizontal: 15.0),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                    color: Colour().buttonBackGroundRedColor,
                  ),
                  child: CustomText(text: "All Disclosures", color: Colors.white,fontWeight: FontWeight.bold,),
                ),
                const SizedBox(
                  width: 5.0,
                ),
                Container(
                  width: 200,
                  padding: const EdgeInsets.symmetric(
                      vertical: 7.0, horizontal: 15.0),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                    color: Colour().buttonBackGroundRedColor,
                  ),
                  child: DropdownStringList(
                    boxDecoration: Colors.white,
                    hint: CustomText(
                        text: AppLocalizations.of(context)!.select_year),
                    selectedValue: provider.yearSelected,
                    dropdownItems: yearsData,
                    onChanged: (String? newValue) async {
                      provider.setYearSelected(newValue!.toString());
                      await provider.getListOfAllDisclosures(provider.yearSelected);
                    },
                    color: Colors.grey,
                  ),
                ),


              ],
            ),
          );
        }
    );
  }


  Future dialogToMakeSignDisclosure(DisclosureModel disclosure) => showDialog(
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
                        "${AppLocalizations.of(context)!.are_you_sure} ${disclosure.disclosureName!} ${AppLocalizations.of(context)!.to_sign}",
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
                                makeSignOnDisclosure(disclosure);
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

  void makeSignOnDisclosure(DisclosureModel disclosure) async {
    Map<String, dynamic> data = {"disclosure_id": disclosure.disclosureId!,"member_id": 7};
    final Future<Map<String, dynamic>> response = providerDisclosure.makeSignedDisclosure(data);
    response.then((response) {
      if (response['status']) {
        providerDisclosure.setIsBack(true);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Column(
              children: [
                CustomText(text: AppLocalizations.of(context)!.signed_successfully),
                const SizedBox(height: 10.0,),
                CustomText(text: response['message'])
              ],
            ),
            backgroundColor: Colors.greenAccent,
            duration: const Duration(seconds: 6),
          ),
        );
        Navigator.of(context).pop();
      } else {
        providerDisclosure.setIsBack(false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Column(
              children: [
                CustomText(text: AppLocalizations.of(context)!.signed_failed),
                const SizedBox(height: 10.0,),
                CustomText(text: response['message'])
              ],
            ),
            backgroundColor: Colors.redAccent,
            duration: const Duration(seconds: 6),
          ),
        );
        Navigator.of(context).pop();
      }
    });
  }

  Future dialogDownloadDisclosure(DisclosureModel disclosure) => showDialog(
    // barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return AlertDialog(
                backgroundColor: Colors.white,
                insetPadding: const EdgeInsets.symmetric(horizontal: 100),
                title: Center(
                    child: CustomText(text: "${AppLocalizations.of(context)!.yes_sure_download} ${disclosure.disclosureName!} ?",
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
                                downloadDisclosure(disclosure);
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

  Future<void> downloadDisclosure(DisclosureModel disclosure) async {
    final pdfFile = await PdfDisclosureApi.generate(disclosure, context);
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

// void openPDF(BuildContext context, String file,fileName) => Navigator.of(context).push(
//   MaterialPageRoute(builder: (context) => PDFViewerPageAsyncfusion(file: file,fileName: fileName,)),
// );


}
