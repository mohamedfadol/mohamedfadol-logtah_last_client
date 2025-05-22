 import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../../colors.dart';
import '../../../../../models/competition_model.dart';
import '../../../../../models/data/years_data.dart';
import '../../../../../models/meeting_model.dart';
import '../../../../../models/member.dart';
 import 'package:flutter_gen/gen_l10n/app_localization.dart';

import '../../../../../models/user.dart';
import '../../../../../providers/competition_provider_page.dart';
import '../../../../../utility/utils.dart';
import '../../../../../widgets/appBar.dart';
import '../../../../../widgets/build_dynamic_data_cell.dart';
import '../../../../../widgets/custom_elevated_button.dart';
import '../../../../../widgets/custom_icon.dart';
import '../../../../../widgets/custom_message.dart';
import '../../../../../widgets/custome_text.dart';
import '../../../../../widgets/dropdown_string_list.dart';
import '../../../../../widgets/loading_sniper.dart';
import '../../../../dashboard/setting.dart';
import '../../../meetings/show_meeting.dart';
import '../../competitions/pdf_services/PdfDownloadButton.dart';
import '../../competitions/pdf_services/competion_with_members_questions_pdf_views.dart';

class ViewCompetitionWithRelatedParties extends StatefulWidget {
  final Member member;
  final String type;
  const ViewCompetitionWithRelatedParties({super.key, required this.member, required this.type});

  @override
  State<ViewCompetitionWithRelatedParties> createState() => _ViewCompetitionWithRelatedPartiesState();
}

class _ViewCompetitionWithRelatedPartiesState extends State<ViewCompetitionWithRelatedParties> {
  bool isLoading = false;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    // Call the fetch method when the page is initialized
    _fetchMemberCompetitions();
  }

  // Function to fetch competitions for the specific member
  Future<void> _fetchMemberCompetitions() async {
    try {
      // Get the CompetitionProviderPage instance
      final provider =
      Provider.of<CompetitionProviderPage>(context, listen: false);

      // Call the method to fetch competitions for this member
      await provider.getMemberCompetitions(provider.yearSelected, widget.member.memberId.toString(), widget.type);
    } catch (e) {
      print("Error fetching member competitions: $e");
      setState(() {
        errorMessage = "Failed to load competitions. Please try again.";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    print("object CompetitionWithMemberCompany ${widget.member.memberId}");
    return Scaffold(
      appBar: Header(context),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 15.0, horizontal: 15.0),
          child: ListView(
            scrollDirection: Axis.vertical,
            children: [
              buildFullTopFilter(widget.member, widget.type),
              Center(
                child: Consumer<CompetitionProviderPage>(
                    builder: (context, provider, child) {
                      // Show loading indicator if data is being fetched
                      if (provider.loading) {
                        return buildLoadingSniper();
                      }

                      // Show error message if there was an error
                      if (provider.errorMessage != null) {
                        return CustomMessage(
                          text: provider.errorMessage!,
                        );
                      }

                      if (provider.competitionsRelatedPartiesData?.competitions == null) {
                        provider.getMemberCompetitions(provider.yearSelected,
                            widget.member.memberId.toString(), widget.type);
                        return buildLoadingSniper();
                      }
                      return provider.competitionsRelatedPartiesData!.competitions!.isEmpty
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
                                headingRowColor: WidgetStateColor.resolveWith(
                                        (states) =>
                                    Colour().darkHeadingColumnDataTables),
                                columns: <DataColumn>[
                                  DataColumn(
                                      label: CustomText(
                                        text: "Name English",
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18.0,
                                        color: Colour().lightBackgroundColor,
                                      ),
                                      tooltip: "show name"),
                                  DataColumn(
                                      label: CustomText(
                                        text: "Name Arabic",
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18.0,
                                        color: Colour().lightBackgroundColor,
                                      ),
                                      tooltip: "show name"),
                                  DataColumn(
                                      label: CustomText(
                                        text: AppLocalizations.of(context)!
                                            .date,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18.0,
                                        color: Colour().lightBackgroundColor,
                                      ),
                                      tooltip: "show Date"),
                                  DataColumn(
                                      label: CustomText(
                                        text: "File",
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18.0,
                                        color: Colour().lightBackgroundColor,
                                      ),
                                      tooltip: "show file"),
                                  DataColumn(
                                      label: CustomText(
                                        text: AppLocalizations.of(context)!
                                            .meeting_agenda,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18.0,
                                        color: Colour().lightBackgroundColor,
                                      ),
                                      tooltip: "meeting agenda"),
                                  DataColumn(
                                      label: CustomText(
                                        text: AppLocalizations.of(context)!
                                            .owner,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18.0,
                                        color: Colour().lightBackgroundColor,
                                      ),
                                      tooltip: "owner that add by"),
                                  DataColumn(
                                      label: CustomText(
                                        text: 'Status',
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18.0,
                                        color: Colour().lightBackgroundColor,
                                      ),
                                      tooltip: "owner that add by"),
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
                                rows:
                                provider!.competitionsRelatedPartiesData!.competitions!
                                    .map((CompetitionRelatedPartiesModel competition) =>
                                    DataRow(cells: [
                                      BuildDynamicDataCell(
                                        child: CustomText(
                                          text: competition
                                              ?.competitionEnName ??
                                              'N/A',
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14.0,
                                          softWrap: false,
                                          maxLines: 1,
                                          overflow:
                                          TextOverflow.ellipsis,
                                        ),
                                      ),
                                      BuildDynamicDataCell(
                                        child: CustomText(
                                          text: competition
                                              ?.competitionArName ??
                                              'N/A',
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14.0,
                                          softWrap: false,
                                          maxLines: 1,
                                          overflow:
                                          TextOverflow.ellipsis,
                                        ),
                                      ),
                                      BuildDynamicDataCell(
                                        child: CustomText(
                                          text:
                                          "${Utils.convertStringToDateFunction(competition!.competitionCreateAt!)}",
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14.0,
                                          softWrap: false,
                                          maxLines: 1,
                                          overflow:
                                          TextOverflow.ellipsis,
                                        ),
                                      ),
                                      BuildDynamicDataCell(
                                        child: CustomText(
                                          text: ' link to PDF',
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14.0,
                                          softWrap: false,
                                          maxLines: 1,
                                          overflow:
                                          TextOverflow.ellipsis,
                                        ),
                                      ),
                                      BuildDynamicDataCell(
                                        child: TextButton(
                                            onPressed: () {
                                              final Meeting? meeting = (competition
                                                  .committee
                                                  ?.meetings !=
                                                  null &&
                                                  competition
                                                      .committee!
                                                      .meetings!
                                                      .isNotEmpty)
                                                  ? competition
                                                  .committee!
                                                  .meetings![0]
                                                  : null;

                                              if (meeting != null) {
                                                Navigator.of(context).push(
                                                    MaterialPageRoute(
                                                        builder: (context) =>
                                                            ShowMeeting(
                                                                meeting:
                                                                meeting)));
                                              } else {
                                                // Show a message when no meetings are available
                                                ScaffoldMessenger.of(
                                                    context)
                                                    .showSnackBar(SnackBar(
                                                    content: Text(
                                                        'No meetings available')));
                                              }
                                            },
                                            child: CustomText(
                                              text: 'Link to Agenda',
                                              fontWeight:
                                              FontWeight.bold,
                                              fontSize: 14.0,
                                              softWrap: false,
                                              maxLines: 1,
                                              overflow: TextOverflow
                                                  .ellipsis,
                                            )),
                                      ),
                                      BuildDynamicDataCell(
                                        child: CustomText(
                                          text: competition
                                              ?.user?.firstName ??
                                              "loading ...",
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14.0,
                                          softWrap: false,
                                          maxLines: 1,
                                          overflow:
                                          TextOverflow.ellipsis,
                                        ),
                                      ),
                                      BuildDynamicDataCell(
                                        child: Builder(
                                          builder: (context) {
                                            // Now we can safely access pivot data
                                            final bool isAgreed =
                                                competition.agree ==
                                                    1;
                                            final String comment =
                                                competition.comment ??
                                                    'No comment';

                                            return Column(
                                              crossAxisAlignment:
                                              CrossAxisAlignment
                                                  .start,
                                              mainAxisSize:
                                              MainAxisSize.min,
                                              children: [
                                                CustomText(
                                                  text: isAgreed
                                                      ? "Agrees"
                                                      : "Disagrees",
                                                  fontWeight:
                                                  FontWeight.bold,
                                                  fontSize: 14.0,
                                                  color: isAgreed
                                                      ? Colors.green
                                                      : Colors.red,
                                                ),
                                                SizedBox(height: 2),
                                                CustomText(
                                                  text: comment,
                                                  fontSize: 12.0,
                                                  softWrap: false,
                                                  maxLines: 1,
                                                  overflow:
                                                  TextOverflow
                                                      .ellipsis,
                                                ),
                                              ],
                                            );
                                          },
                                        ),
                                      ),
                                      DataCell(
                                        PopupMenuButton<int>(
                                            padding: EdgeInsets.only(
                                                bottom: 5.0),
                                            icon: CustomIcon(
                                              icon: Icons.settings,
                                              size: 30.0,
                                            ),
                                            onSelected: (value) => 0,
                                            itemBuilder:
                                                (context) => [
                                              PopupMenuItem<
                                                  int>(
                                                  value: 0,
                                                  child: CustomElevatedButton(
                                                      verticalPadding: 0.0,
                                                      text: AppLocalizations.of(context)!.view,
                                                      icon: Icons.remove_red_eye_outlined,
                                                      textColor: Colors.white,
                                                      buttonBackgroundColor: Colors.red,
                                                      horizontalPadding: 10.0,
                                                      callFunction: () {
                                                        Navigator.of(context)
                                                            .push(
                                                          MaterialPageRoute(builder: (context) => CompetitionWithMembersQuestionsPdfViews(member: widget.member, type: widget.type, )),
                                                        );
                                                      })),
                                              PopupMenuItem<
                                                  int>(
                                                  value: 0,
                                                  child: CustomElevatedButton(
                                                      verticalPadding:
                                                      0.0,
                                                      text: AppLocalizations.of(
                                                          context)!
                                                          .export,
                                                      icon:
                                                      Icons
                                                          .import_export_outlined,
                                                      textColor:
                                                      Colors
                                                          .white,
                                                      buttonBackgroundColor:
                                                      Colors
                                                          .red,
                                                      horizontalPadding:
                                                      10.0,
                                                      callFunction:
                                                          () async {
                                                        ScaffoldMessenger.of(context).showSnackBar(
                                                          const SnackBar(content: Text("Preparing PDF download...")),
                                                        );

                                                        // Call the static method directly
                                                        await PdfDownloadButton.downloadPdf(
                                                            context,
                                                            widget.member,
                                                            widget.type
                                                        );

                                                      })),
                                              PopupMenuItem<
                                                  int>(
                                                  value: 0,
                                                  child: CustomElevatedButton(
                                                      verticalPadding: 0.0,
                                                      text: AppLocalizations.of(context)!.signed,
                                                      icon: Icons.checklist_outlined,
                                                      textColor: Colors.white,
                                                      buttonBackgroundColor: Colors.red,
                                                      horizontalPadding: 10.0,
                                                      callFunction: () async {
                                                        dialogToMakeSignByCompetitionType(
                                                            widget.member,
                                                            widget.type
                                                        );
                                                      }
                                                  )
                                              ),
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

  Future dialogToMakeSignByCompetitionType(Member member, String type) => showDialog(
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
                        "${AppLocalizations.of(context)!.are_you_sure} ${type} ${AppLocalizations.of(context)!.to_sign}",
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
                                makeSignOnCompetitionType(member, type);
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

  void makeSignOnCompetitionType(Member member, String type) async {
    User user = User();
    final providerCompetition = Provider.of<CompetitionProviderPage>(context, listen: false);

    final SharedPreferences prefs = await SharedPreferences.getInstance();
    user = User.fromJson(json.decode(prefs.getString("user")!));
    Map<String, dynamic> data = {
      "member_id": member.memberId!,
      "type": type,
      "business_id": user.businessId
    };
    final Future<Map<String, dynamic>> response =
    providerCompetition.memberMakeSignedCompetition(data);
    response.then((response) {
      if (response['status']) {
        providerCompetition.setIsBack(true);
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
        providerCompetition.setIsBack(false);
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

  Future dialogDownloadCompetition(Member member, String type) => showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          insetPadding: const EdgeInsets.symmetric(horizontal: 100),
          title: Center(
              child: CustomText(
                  text: "${AppLocalizations.of(context)!.yes_sure_download} ${member.memberFirstName!} ?",
                  color: Colors.green,
                  fontSize: 20,
                  fontWeight: FontWeight.bold
              )
          ),
          content: SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: Container(
                color: Colors.white,
                width: MediaQuery.of(context).size.width * 0.35,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 10.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Use proper PdfDownloadButton here
                      PdfDownloadButton(
                        member: member,
                        type: type,
                        label: AppLocalizations.of(context)!.yes_download,
                        icon: Icons.download,
                        textColor: Colors.white,
                        backgroundColor: Colors.green,
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
                            padding: const EdgeInsets.symmetric(horizontal: 10.0)
                        ),
                      )
                    ],
                  ),
                )
            ),
          ),
        );
      }
  );

  Widget buildFullTopFilter(Member member, String type) {
    return Consumer<CompetitionProviderPage>(
        builder: (BuildContext context, provider, child) {
          return Padding(
            padding:
            const EdgeInsets.only(top: 3.0, left: 0.0, right: 8.0, bottom: 8.0),
            child: Row(
              children: [
                Container(
                    padding:
                    const EdgeInsets.symmetric(vertical: 7.0, horizontal: 15.0),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(0)),
                      color: Colour().buttonBackGroundRedColor,
                    ),
                    child: CustomText(
                        text:
                        'Competition with related parties for ${member.memberFirstName}',
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white)),
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
                    hint:
                    CustomText(text: AppLocalizations.of(context)!.select_year),
                    selectedValue: provider.yearSelected,
                    dropdownItems: yearsData,
                    onChanged: (String? newValue) async {
                      provider.setYearSelected(newValue!.toString());
                      await provider.getMemberCompetitions(
                          provider.yearSelected, member.memberId.toString(), type);
                    },
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(
                  width: 5.0,
                ),
                Container(
                    padding:
                    const EdgeInsets.symmetric(vertical: 0.0, horizontal: 15.0),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                      color: Colour().buttonBackGroundRedColor,
                    ),
                    child: TextButton(
                      onPressed: () {
                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute(
                            builder: (context) => Setting(initialTabIndex: 5),
                          ),
                        );
                      },
                      child: CustomText(
                        text: 'Back',
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    )),
              ],
            ),
          );
        });
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
