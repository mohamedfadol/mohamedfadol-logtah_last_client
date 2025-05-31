import 'dart:convert';

import 'package:diligov_members/models/financial_model.dart';
import 'package:diligov_members/widgets/appBar.dart';
import 'package:diligov_members/widgets/custom_icon.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../colors.dart';
import '../../../core/domains/app_uri.dart';
import '../../../models/data/years_data.dart';
import '../../../models/meeting_model.dart';
import '../../../models/user.dart';
import '../../../providers/financial_page_provider.dart';
import '../../../providers/meeting_page_provider.dart';
import '../../../utility/custome_pdf_viewr.dart';
import '../../../utility/pdf_api.dart';
import '../../../utility/pdf_financial_api.dart';
import '../../../utility/utils.dart';
import '../../../widgets/build_dynamic_data_cell.dart';
import '../../../widgets/custom_elevated_button.dart';
import '../../../widgets/custom_message.dart';
import '../../../widgets/loading_sniper.dart';
import 'package:flutter_gen/gen_l10n/app_localization.dart';
import '../meetings/show_meeting.dart';
import '../../../widgets/custome_text.dart';
import '../../../widgets/dropdown_string_list.dart';
import 'forms/create_financial_form.dart';

class FinancialListViews extends StatefulWidget {
  const FinancialListViews({super.key});
  static const routeName = '/FinancialListViews';
  @override
  State<FinancialListViews> createState() => _FinancialListViewsState();
}

class _FinancialListViewsState extends State<FinancialListViews> {

  User user = User();




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

    final Map<String, dynamic>? args =
    ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>?;

    // Extract `committeeId` safely
    String committeeId = args?['committeeId'] ?? "No ID Provided";

    return Scaffold(
      appBar: Header(context),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 15.0, horizontal: 15.0),
          child: ListView(
            scrollDirection: Axis.vertical,
            children: [
              buildFullTopFilter(),
              Center(
                child: Consumer<FinancialPageProvider>(
                    builder: (context, provider, child) {
                  if (provider.financialData?.financials == null) {
                    provider.getListOfFinancials(provider.yearSelected);
                    return buildLoadingSniper();
                  }
                  return provider.financialData!.financials!.isEmpty
                      ? buildEmptyMessage(
                          AppLocalizations.of(context)!.no_data_to_show)
                      : Container(
                    padding: EdgeInsets.only(left: 10.0),
                    height: MediaQuery.of(context).size.height,
                    width: MediaQuery.of(context).size.width,
                      child: SizedBox.expand(
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: SingleChildScrollView(
                            child: DataTable(
                              columnSpacing: 100,
                              decoration: BoxDecoration(
                                border: Border.all(
                                    color: Colour()
                                        .darkHeadingColumnDataTables),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              // showBottomBorder: true,
                              headingRowHeight: 60,
                              dividerThickness: 0.3,
                              headingRowColor: WidgetStateColor.resolveWith((states) => Colour().darkHeadingColumnDataTables),
                              columns: <DataColumn>[
                                DataColumn(
                                    label: CustomText(
                                      text: "Name",
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18.0,
                                      color: Colour().lightBackgroundColor,
                                    ),
                                    tooltip: "show name"),
                                DataColumn(
                                    label: CustomText(
                                      text: AppLocalizations.of(context)!.date,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18.0,
                                      color: Colour().lightBackgroundColor,
                                    ),
                                    tooltip: "show Date"),
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
                                          .meeting_name,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18.0,
                                      color: Colour().lightBackgroundColor,
                                    ),
                                    tooltip: "meeting name"),
                                DataColumn(
                                    label: CustomText(
                                      text:
                                      AppLocalizations.of(context)!.signed,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18.0,
                                      color: Colour().lightBackgroundColor,
                                    ),
                                    tooltip: "signed"),
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
                              rows: provider!.financialData!.financials!
                                  .map((FinancialModel financial) =>
                                  DataRow(cells: [
                                    BuildDynamicDataCell(
                                      child: CustomText(text: financial?.financialEnglishName ?? financial?.financialArabicName ?? 'N/A',
                                        fontWeight: FontWeight.bold,fontSize: 14.0,softWrap: false,
                                        maxLines: 1,overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    BuildDynamicDataCell(
                                      child: CustomText(text: "${Utils.convertStringToDateFunction(financial!.financialDate!)}" ,
                                        fontWeight: FontWeight.bold,fontSize: 14.0,softWrap: false,
                                        maxLines: 1,overflow: TextOverflow.ellipsis,
                                      ),
                                    ),

                                    BuildDynamicDataCell(
                                      child: TextButton(
                                          onPressed: () async {
                                            provider.setLoading(true);
                                            String fullUrl = "${AppUri.baseUntilPublicDirectoryMeetings}/${financial!.financialFile}";
                                            // openPDF(context,url,charterName);
                                            Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                    builder:
                                                        (context) =>
                                                        CustomPdfView(path: fullUrl)));
                                            provider.setLoading(false);
                                          },
                                          child: CustomText(text:'Show File', fontWeight: FontWeight.bold,fontSize: 14.0,softWrap: false,maxLines: 1,overflow: TextOverflow.ellipsis,
                                          )
                                      ),
                                    ),

                                    BuildDynamicDataCell(
                                      child: financial.meeting == null
                                          ? CustomText(text:'Meeting not found',fontWeight: FontWeight.bold,fontSize: 14.0,)
                                          : TextButton(
                                          onPressed: () async {
                                            Navigator.of(context).push(MaterialPageRoute(builder: (context) => ShowMeeting(meeting: financial.meeting!,)));
                                          },
                                          child: CustomText(text:financial?.meeting?.meetingTitle ??'Circular',fontWeight: FontWeight.bold,fontSize: 14.0,)
                                      ),
                                    ),
                                    BuildDynamicDataCell(
                                      child: CustomText(text: financial?.financialEnglishName ?? financial?.financialArabicName ?? 'N/A',
                                        fontWeight: FontWeight.bold,fontSize: 14.0,softWrap: false,
                                        maxLines: 1,overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    BuildDynamicDataCell(
                                      child: CustomText(text:financial?.user?.firstName ??"loading ...",
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
                                                          String fullUrl = "${AppUri.baseUntilPublicDirectoryMeetings}/${financial!.financialFile}";
                                                          print(fullUrl);
                                                          // openPDF(context,url,charterName);
                                                          Navigator.push(
                                                              context,
                                                              MaterialPageRoute(
                                                                  builder:
                                                                      (context) =>
                                                                      CustomPdfView(path: fullUrl)));
                                                          provider.setLoading(false);
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
                                                      await dialogDownloadFinancial(financial);
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
                                                    callFunction:() { dialogToMakeSignFinancial(financial);})),

                                          ]),
                                    ),
                                  ]))
                                  .toList(),
                            ),
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
    );
  }


  Widget buildFullTopFilter() {
    return Consumer<FinancialPageProvider>(
        builder: (BuildContext context, provider, child) {
          return Padding(
            padding:
            const EdgeInsets.only(top: 3.0, left: 0.0, right: 8.0, bottom: 8.0),
            child: Row(
              children: [
                Container(
                    padding: const EdgeInsets.symmetric(
                        vertical: 7.0, horizontal: 15.0),
                    decoration: BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(0)),
                      color: Colour().buttonBackGroundRedColor,
                    ),
                    child: CustomText(
                        text: AppLocalizations.of(context)!.financial_list,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white
                    )
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
                      await provider.getListOfFinancials(provider.yearSelected);
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


  Widget buildMeetingAndMinutesDropDownList() {
    return Consumer<MeetingPageProvider>(
      builder: (BuildContext context, Mprovider, widget) {
        if (Mprovider.dataOfMeetings?.meetings == null) {
          Mprovider.getListOfPublishedMeetingsThatNotHasMinutes();
          return buildLoadingSniper();
        }

        if (Mprovider.dataOfMeetings!.meetings!.isEmpty) {
          return buildEmptyMessage(AppLocalizations.of(context)!.no_data_to_show);
        }

        List<DropdownMenuItem<String>> dropdownItems = [
          DropdownMenuItem<String>(
            value: "",
            child: CustomText(
                text: AppLocalizations.of(context)!.select_meeting_name,
                color: Colors.white),
          )
        ];

        dropdownItems.addAll(Mprovider.dataOfMeetings!.meetings!.map((Meeting meeting) {
          return DropdownMenuItem<String>(
            value: meeting.meetingId.toString(),
            child: CustomText(text: meeting.meetingTitle!, color: Colors.black),
          );
        }).toList());

        return Container(
          constraints: const BoxConstraints(minHeight: 30.0),
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10.0),
              color: Colors.red,
              boxShadow: const [
                BoxShadow(blurRadius: 2.0, spreadRadius: 0.4)
              ]),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              isExpanded: true,
              isDense: true,
              menuMaxHeight: 300,
              style: Theme.of(context).textTheme.titleLarge,
              // Dynamic hint based on whether an item is selected
              hint: Mprovider.selectedMeetingId == null || Mprovider.selectedMeetingId == ""
                  ? CustomText(
                  text: AppLocalizations.of(context)!.select_meeting_name,
                  color: Colors.white)
                  : CustomText(
                  text: Mprovider.dataOfMeetings!.meetings!.firstWhere(
                          (meeting) => meeting.meetingId.toString() == Mprovider.selectedMeetingId,
                      orElse: () => Meeting(meetingTitle: 'No meeting found')).meetingTitle!,
                  color: Colors.black),
              value: Mprovider.selectedMeetingId == "" ? null : Mprovider.selectedMeetingId,
              icon: const Icon(Icons.keyboard_arrow_down, size: 20, color: Colors.white),
              dropdownColor: Colors.white60,
              focusColor: Colors.redAccent[300],
              items: dropdownItems,
              onChanged: (String? newValue) {
                Mprovider.setSelectedMeetingId(newValue);
                Provider.of<MeetingPageProvider>(context, listen: false).selectedMeetingId;

              },
            ),
          ),
        );
      },
    );
  }


  Future dialogToMakeSignFinancial(FinancialModel financial) => showDialog(
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
                        "${AppLocalizations.of(context)!.are_you_sure} ${financial?.financialEnglishName ?? financial?.financialArabicName ?? 'N/A'} ${AppLocalizations.of(context)!.to_sign}",
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
                                makeSignOnFinancial(financial);
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

  void makeSignOnFinancial(FinancialModel financial) async {
    final providerFinancial = Provider.of<FinancialPageProvider>(context, listen: false);
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    user = User.fromJson(json.decode(prefs.getString("user")!));
    Map<String, dynamic> data = {"financial_id": financial.financialId!,"member_id": 7};
    final Future<Map<String, dynamic>> response = providerFinancial.makeSignedFinancial(data);
    response.then((response) {
      if (response['status']) {
        providerFinancial.setIsBack(true);
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
        providerFinancial.setIsBack(false);
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

  Future dialogDownloadFinancial(FinancialModel financial) => showDialog(
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
                        "${AppLocalizations.of(context)!.yes_sure_download} ${financial?.financialEnglishName ?? financial?.financialArabicName ?? 'N/A'} ?",
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
                                downloadFinancial(financial);
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

  Future<void> downloadFinancial(FinancialModel financial) async {
    final pdfFile = await PdfFinancialApi.generate(financial, context);
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

