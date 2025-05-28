import 'dart:io';

import 'package:diligov_members/providers/agenda_page_provider.dart';
import 'package:diligov_members/providers/meeting_page_provider.dart';
import 'package:diligov_members/views/modules/minutes_meeting_views/agenda_details_with_minutes.dart';
import 'package:diligov_members/views/modules/minutes_meeting_views/page_pdf.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import 'package:logger/logger.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../colors.dart';
import '../../../models/meeting_model.dart';
import '../../../models/minutes_model.dart';
import '../../../models/user.dart';
import '../../../providers/minutes_provider_page.dart';
import '../../../utility/edit_laboratory_local_file_processing.dart';
import '../../../utility/pdf_api.dart';
import '../../../utility/pdf_minutes_meeting_api.dart';
import '../../../models/data/years_data.dart';
import '../../../widgets/custom_elevated_button.dart';
import '../../../widgets/custom_icon.dart';
import '../../../widgets/custom_message.dart';
import '../../../widgets/custome_text.dart';
import '../../../widgets/appBar.dart';
import '../../../widgets/dropdown_string_list.dart';
import '../../../widgets/loading_sniper.dart';
import 'package:flutter_gen/gen_l10n/app_localization.dart';
import '../meetings/show_meeting.dart';
import 'edit_minutes.dart';

class MinutesMeetingList extends StatefulWidget {
  const MinutesMeetingList({Key? key}) : super(key: key);
  static const routeName = '/MinutesMeetingList';

  @override
  State<MinutesMeetingList> createState() => _MinutesMeetingListState();
}

class _MinutesMeetingListState extends State<MinutesMeetingList> {
  var log = Logger();
  User user = User();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    Future.delayed(Duration.zero, () async {
      final ag = Provider.of<AgendaPageProvider>(context, listen: false);
      if (ag.isActive) {
        ag.updateStatusProvider(false);
        log.i(ag.isActive);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
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
            padding:
                const EdgeInsets.symmetric(vertical: 5.0, horizontal: 10.0),
            child: ListView(
              scrollDirection: Axis.vertical,
              children: [
                buildFullTopFilter(),
                Center(
                  child: Consumer<MinutesProviderPage>(
                      builder: (context, provider, child) {
                    if (provider.minutesData?.minutes == null) {
                      provider.getListOfMinutes(provider.yearSelected);
                      return buildLoadingSniper();
                    }
                    return provider.minutesData!.minutes!.isEmpty
                        ? buildEmptyMessage(
                            AppLocalizations.of(context)!.no_data_to_show)
                        : Container(
                            padding: EdgeInsets.only(left: 10.0),
                            height: MediaQuery.of(context).size.height,
                            width: MediaQuery.of(context).size.width,
                            child: SizedBox.expand(
                              child: SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
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
                                  headingRowColor: WidgetStateColor.resolveWith(
                                      (states) =>
                                          Colour().darkHeadingColumnDataTables),
                                  // dataRowColor: MaterialStateColor.resolveWith((states) => Colour().lightBackgroundColor),
                                  columns: <DataColumn>[
                                    DataColumn(
                                        label: CustomText(
                                          text: AppLocalizations.of(context)!
                                              .minute_name,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 18.0,
                                          color: Colour().lightBackgroundColor,
                                          softWrap: true,
                                        ),
                                        tooltip: "show minute name"),
                                    DataColumn(
                                        label: CustomText(
                                          text: AppLocalizations.of(context)!
                                              .date,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 18.0,
                                          color: Colour().lightBackgroundColor,
                                        ),
                                        tooltip: "show minute Date"),
                                    DataColumn(
                                        label: CustomText(
                                          text: AppLocalizations.of(context)!
                                              .file,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 18.0,
                                          color: Colour().lightBackgroundColor,
                                        ),
                                        tooltip: "file"),
                                    DataColumn(
                                        label: CustomText(
                                          text: AppLocalizations.of(context)!
                                              .meeting_agenda,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 18.0,
                                          color: Colour().lightBackgroundColor,
                                        ),
                                        tooltip: "meeting name"),
                                    DataColumn(
                                        label: CustomText(
                                          text: AppLocalizations.of(context)!
                                              .signature,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 18.0,
                                          color: Colour().lightBackgroundColor,
                                        ),
                                        tooltip: "signature"),
                                    // DataColumn(
                                    //     label: CustomText(
                                    //       text: AppLocalizations.of(context)!
                                    //           .owner,
                                    //       fontWeight: FontWeight.bold,
                                    //       fontSize: 18.0,
                                    //       color: Colour().lightBackgroundColor,
                                    //     ),
                                    //     tooltip: "owner that add by"),
                                    DataColumn(
                                        label: CustomText(
                                          text: AppLocalizations.of(context)!
                                              .actions,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 18.0,
                                          color: Colour().lightBackgroundColor,
                                        ),
                                        tooltip:
                                            "show buttons for functionality members"),
                                  ],
                                  rows: provider!.minutesData!.minutes!
                                      .map((Minute minute) => DataRow(cells: [
                                            DataCell(CustomText(
                                              text: minute.minuteName!,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 14.0,
                                              softWrap: true,
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            )),
                                            DataCell(CustomText(
                                              text: minute.minuteDate!,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 14.0,
                                              softWrap: false,
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            )),
                                            DataCell(
                                              TextButton(
                                                  onPressed: () async {
                                                    final pdfFile =
                                                        await PdfMinutesMeetingApi
                                                            .generate(minute,
                                                                context);
                                                    PDFApi.openFile(pdfFile);
                                                  },
                                                  child: CustomText(
                                                    text: minute.meeting
                                                            ?.meetingFile ??
                                                        'Show File',
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 14.0,
                                                    softWrap: false,
                                                    maxLines: 1,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  )),
                                            ),
                                            DataCell(
                                              TextButton(
                                                  onPressed: () async {
                                                    Navigator.of(context).push(
                                                        MaterialPageRoute(
                                                            builder:
                                                                (context) =>
                                                                    ShowMeeting(
                                                                      meeting:
                                                                          minute
                                                                              .meeting!,
                                                                    )));
                                                  },
                                                  child: CustomText(
                                                    text: minute.meeting
                                                            ?.meetingTitle ??
                                                        'Circular',
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 14.0,
                                                  )),
                                            ),
                                            DataCell(CustomText(
                                              text: minute.minuteStatus!,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 14.0,
                                            )),
                                            // DataCell(CustomText(text:
                                            //   minute?.user?.firstName ??
                                            //       "loading ...",
                                            //
                                            //     fontWeight: FontWeight.bold,
                                            //     fontSize: 14.0,
                                            //
                                            //   softWrap: false,
                                            //   maxLines: 1,
                                            //   overflow: TextOverflow.ellipsis,
                                            // )),
                                            DataCell(
                                              PopupMenuButton<int>(
                                                  padding: EdgeInsets.only(
                                                      bottom: 5.0),
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
                                                                        Colour()
                                                                            .buttonBackGroundRedColor,
                                                                    horizontalPadding:
                                                                        10.0,
                                                                    callFunction:
                                                                        () async {
                                                                      Navigator.of(
                                                                              context)
                                                                          .push(
                                                                        MaterialPageRoute(
                                                                            builder: (context) =>
                                                                                PagePdf(minute: minute)),
                                                                      );
                                                                    })),
                                                        // minute.minuteFile !=
                                                        //         null
                                                        //     ? PopupMenuItem<
                                                        //             int>(
                                                        //         value: 0,
                                                        //         child:
                                                        //             CustomElevatedButton(
                                                        //                 verticalPadding:
                                                        //                     0.0,
                                                        //                 text: AppLocalizations.of(context)!
                                                        //                     .notes,
                                                        //                 icon: Icons
                                                        //                     .remove_red_eye_outlined,
                                                        //                 textColor:
                                                        //                     Colors
                                                        //                         .white,
                                                        //                 buttonBackgroundColor:
                                                        //                     Colour()
                                                        //                         .buttonBackGroundRedColor,
                                                        //                 horizontalPadding:
                                                        //                     10.0,
                                                        //                 callFunction:
                                                        //                     () async {
                                                        //                   Navigator.of(context)
                                                        //                       .push(
                                                        //                     MaterialPageRoute(builder: (context) => EditLaboratoryLocalFileProcessing(minute: minute)),
                                                        //                   );
                                                        //                 }))
                                                        //     : PopupMenuItem<
                                                        //         int>(
                                                        //         value: 0,
                                                        //         child: null,
                                                        //       ),
                                                        PopupMenuItem<int>(
                                                            value: 1,
                                                            child:
                                                                CustomElevatedButton(
                                                                    verticalPadding:
                                                                        0.0,
                                                                    text: AppLocalizations
                                                                            .of(
                                                                                context)!
                                                                        .export,
                                                                    icon: Icons
                                                                        .import_export_outlined,
                                                                    textColor:
                                                                        Colors
                                                                            .white,
                                                                    buttonBackgroundColor:
                                                                        Colour()
                                                                            .buttonBackGroundRedColor,
                                                                    horizontalPadding:
                                                                        10.0,
                                                                    callFunction:
                                                                        () async {
                                                                      await dialogDownloadMinute(
                                                                          minute);
                                                                    })),
                                                        PopupMenuItem<int>(
                                                            value: 2,
                                                            child: CustomElevatedButton(
                                                                verticalPadding:
                                                                    0.0,
                                                                text: AppLocalizations
                                                                        .of(
                                                                            context)!
                                                                    .signed,
                                                                icon: Icons
                                                                    .checklist_outlined,
                                                                textColor: Colors
                                                                    .white,
                                                                buttonBackgroundColor:
                                                                    Colour()
                                                                        .buttonBackGroundRedColor,
                                                                horizontalPadding:
                                                                    10.0,
                                                                callFunction: () =>
                                                                    dialogToMakeSignMinute(minute)
                                                            )
                                                        ),
                                                        // PopupMenuItem<int>(
                                                        //   value: 3,
                                                        //   child:
                                                        //       CustomElevatedButton(
                                                        //     verticalPadding:
                                                        //         0.0,
                                                        //     text: AppLocalizations
                                                        //             .of(context)!
                                                        //         .edit_minute,
                                                        //     icon: Icons
                                                        //         .check_box_outlined,
                                                        //     textColor:
                                                        //         Colors.white,
                                                        //     buttonBackgroundColor:
                                                        //         Colour()
                                                        //             .buttonBackGroundRedColor,
                                                        //     horizontalPadding:
                                                        //         10.0,
                                                        //     callFunction: () =>
                                                        //         {
                                                        //       Navigator.of(
                                                        //               context)
                                                        //           .push(
                                                        //         MaterialPageRoute(
                                                        //             builder:
                                                        //                 (context) =>
                                                        //                     EditMinutes(
                                                        //                       minute: minute,
                                                        //                     )),
                                                        //       ),
                                                        //     },
                                                        //   ),
                                                        // ),
                                                        // PopupMenuItem<int>(
                                                        //     value: 4,
                                                        //     child:
                                                        //         CustomElevatedButton(
                                                        //       verticalPadding:
                                                        //           0.0,
                                                        //       text: AppLocalizations
                                                        //               .of(context)!
                                                        //           .delete,
                                                        //       icon: Icons
                                                        //           .restore_from_trash_outlined,
                                                        //       textColor:
                                                        //           Colors.white,
                                                        //       buttonBackgroundColor:
                                                        //           Colour()
                                                        //               .buttonBackGroundRedColor,
                                                        //       horizontalPadding:
                                                        //           10.0,
                                                        //       callFunction: () =>
                                                        //           dialogDeleteMinute(
                                                        //               minute),
                                                        //     )),
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
    return Consumer<MinutesProviderPage>(
        builder: (BuildContext context, provider, child) {
      return Padding(
        padding:
            const EdgeInsets.only(top: 3.0, left: 0.0, right: 8.0, bottom: 8.0),
        child: Row(
          children: [
            Container(
                padding: const EdgeInsets.symmetric(
                    vertical: 12.0, horizontal: 15.0),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(20)),
                  color: Colour().buttonBackGroundMainColor,
                ),
                child: CustomText(
                    text: AppLocalizations.of(context)!.minutes_list,
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold)),
            const SizedBox(
              width: 5.0,
            ),
            Container(
              width: 200,
              padding:
                  const EdgeInsets.symmetric(vertical: 7.0, horizontal: 15.0),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(10)),
                color: Colour().buttonBackGroundRedColor,
              ),
              child: DropdownStringList(
                boxDecoration: Colors.white,
                hint: CustomText(
                    text: AppLocalizations.of(context)!.select_year,
                    color: Colour().mainWhiteTextColor),
                selectedValue: provider.yearSelected,
                dropdownItems: yearsData,
                onChanged: (String? newValue) async {
                  provider.setYearSelected(newValue!.toString());
                  await provider.getListOfMinutes(provider.yearSelected);
                },
                color: Colors.grey,
              ),
            ),
            // const SizedBox(
            //   width: 5.0,
            // ),
            // Container(
            //   padding: const EdgeInsets.symmetric(horizontal: 15.0),
            //   decoration: BoxDecoration(
            //     borderRadius: BorderRadius.all(Radius.circular(20)),
            //     color: Colour().buttonBackGroundMainColor,
            //   ),
            //   child: Center(
            //     child: IconButton(
            //         onPressed: () {
            //           openMinutesCreateDialog();
            //         },
            //         icon: const Icon(
            //           Icons.add,
            //           color: Colors.white,
            //           size: 30.0,
            //         )),
            //   ),
            // ),
            // Spacer(),
            // Container(
            //   decoration: BoxDecoration(
            //     borderRadius: BorderRadius.all(Radius.circular(20)),
            //     color: Colour().buttonBackGroundMainColor,
            //   ),
            //   padding: const EdgeInsets.symmetric(horizontal: 15.0),
            //   child: TextButton(
            //       onPressed: () {},
            //       child: Row(
            //         children: [
            //           CustomText(
            //             text: AppLocalizations.of(context)!.remind_to_signing,
            //             color: Colors.white,
            //             fontSize: 20,
            //             fontWeight: FontWeight.bold,
            //           ),
            //           SizedBox(
            //             width: 5.0,
            //           ),
            //           Icon(
            //             Icons.notifications_active_outlined,
            //             color: Colors.white,
            //             size: 30.0,
            //           )
            //         ],
            //       )),
            // )
          ],
        ),
      );
    });
  }

  Future openMinutesCreateDialog() => showDialog(
      // barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
          return AlertDialog(
            backgroundColor: Colors.white,
            insetPadding: const EdgeInsets.symmetric(horizontal: 100),
            title: CustomText(
                text: AppLocalizations.of(context)!.select_meeting_name,
                color: Colors.red,
                fontSize: 20,
                fontWeight: FontWeight.bold),
            content: SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: Container(
                  color: Colors.black12,
                  width: MediaQuery.of(context).size.width * 0.45,
                  child: Column(
                    children: [
                      const SizedBox(height: 15),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10.0),
                        child: buildMeetingAndMinutesDropDownList(),
                      ),
                      const SizedBox(height: 15),
                    ],
                  )),
            ),
          );
        });
      });

  Widget buildMeetingAndMinutesDropDownList() {
    return Consumer<MeetingPageProvider>(
      builder: (BuildContext context, Mprovider, widget) {
        if (Mprovider.dataOfMeetings?.meetings == null) {
          Mprovider.getListOfPublishedMeetingsThatNotHasMinutes();
          return buildLoadingSniper();
        }

        if (Mprovider.dataOfMeetings!.meetings!.isEmpty) {
          return buildEmptyMessage(
              AppLocalizations.of(context)!.no_data_to_show);
        }

        List<DropdownMenuItem<String>> dropdownItems = [
          DropdownMenuItem<String>(
            value: "",
            child: CustomText(
                text: AppLocalizations.of(context)!.select_meeting_name,
                color: Colors.white),
          )
        ];

        dropdownItems
            .addAll(Mprovider.dataOfMeetings!.meetings!.map((Meeting meeting) {
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
              boxShadow: const [BoxShadow(blurRadius: 2.0, spreadRadius: 0.4)]),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              isExpanded: true,
              isDense: true,
              menuMaxHeight: 300,
              style: Theme.of(context).textTheme.titleLarge,
              // Dynamic hint based on whether an item is selected
              hint: Mprovider.selectedMeetingId == null ||
                      Mprovider.selectedMeetingId == ""
                  ? CustomText(
                      text: AppLocalizations.of(context)!.select_meeting_name,
                      color: Colors.white)
                  : CustomText(
                      text: Mprovider.dataOfMeetings!.meetings!
                          .firstWhere(
                              (meeting) =>
                                  meeting.meetingId.toString() ==
                                  Mprovider.selectedMeetingId,
                              orElse: () =>
                                  Meeting(meetingTitle: 'No meeting found'))
                          .meetingTitle!,
                      color: Colors.black),
              value: Mprovider.selectedMeetingId == ""
                  ? null
                  : Mprovider.selectedMeetingId,
              icon: const Icon(Icons.keyboard_arrow_down,
                  size: 20, color: Colors.white),
              dropdownColor: Colors.white60,
              focusColor: Colors.redAccent[300],
              items: dropdownItems,
              onChanged: (String? newValue) {
                Mprovider.setSelectedMeetingId(newValue);
                Navigator.of(context).pop();
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => ChangeNotifierProvider(
                      create: (_) =>
                          AgendaPageProvider(), // Creating a new instance here
                      child: AgendaDetailsWithMinutes(
                        meetingId: Provider.of<MeetingPageProvider>(context,
                                listen: false)
                            .selectedMeetingId!,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }

  Future dialogDownloadMinute(Minute minute) => showDialog(
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
                        "${AppLocalizations.of(context)!.yes_sure_download} ${minute.minuteName!} ?",
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
                            await downloadMinute(minute);
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

  Future<void> downloadMinute(Minute minute) async {
    final pdfFile = await PdfMinutesMeetingApi.generate(minute, context);
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

  Future dialogDeleteMinute(Minute minute) => showDialog(
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
                        "${AppLocalizations.of(context)!.are_you_sure_to_delete} ${minute.minuteName!} ?",
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
                            removeMinute(minute);
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

  void removeMinute(Minute minute) {
    final provider = Provider.of<MinutesProviderPage>(context, listen: false);
    Future.delayed(Duration.zero, () {
      provider.removeMinute(minute);
      provider.setIsBack(true);
    });
    if (provider.isBack == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: CustomText(
              text: AppLocalizations.of(context)!.remove_minute_done),
          backgroundColor: Colors.greenAccent,
        ),
      );
      Future.delayed(const Duration(seconds: 5), () {
        Navigator.of(context).pop();
      });
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

  buildEmptyMessage(String message) {
    return CustomMessage(
      text: message,
    );
  }

  buildLoadingSniper() {
    return const LoadingSniper();
  }

  Future dialogToMakeSignMinute(Minute minute) => showDialog(
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
                        "${AppLocalizations.of(context)!.are_you_sure} ${minute.minuteName!} ${AppLocalizations.of(context)!.to_sign}",
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
                            makeSignOnMinute(minute);
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

  void makeSignOnMinute(Minute minute) async {
    final providerMakeMinuteSign =
        Provider.of<MinutesProviderPage>(context, listen: false);
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    user = User.fromJson(json.decode(prefs.getString("user")!));
    Map<String, dynamic> data = {
      "minute_id": minute.minuteId!,
      "member_id": user.userId
    };
    final Future<Map<String, dynamic>> response =
        providerMakeMinuteSign.makeSignedMinute(data);
    response.then((response) {
      if (response['status']) {
        providerMakeMinuteSign.setIsBack(true);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Column(
              children: [
                CustomText(
                    text: AppLocalizations.of(context)!.signed_successfully),
                const SizedBox(
                  height: 10.0,
                ),
                CustomText(text: response['message'])
              ],
            ),
            backgroundColor: Colors.greenAccent,
            duration: const Duration(seconds: 6),
          ),
        );
        Navigator.of(context).pop();
      } else {
        providerMakeMinuteSign.setIsBack(false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Column(
              children: [
                CustomText(text: AppLocalizations.of(context)!.signed_failed),
                const SizedBox(
                  height: 10.0,
                ),
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
}
