import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localization.dart';
import 'package:provider/provider.dart';

import '../../../../../colors.dart';
import '../../../../../models/competition_model.dart';
import '../../../../../models/data/years_data.dart';
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
import '../../disclosures_how_menus.dart';
import '../forms/competition_member_questionnaire_screen.dart';
import '../forms/competitions_with_company_form.dart';
import '../forms/edit_competition_form.dart';
import 'competition_member_with_company_list_views.dart';

class CompetitionsQuestionsWithCompanyListViews extends StatefulWidget {
  static const routeName = '/CompetitionsQuestionsWithCompanyListViews';
  const CompetitionsQuestionsWithCompanyListViews({super.key});

  @override
  State<CompetitionsQuestionsWithCompanyListViews> createState() => _CompetitionsQuestionsWithCompanyListViewsState();
}

class _CompetitionsQuestionsWithCompanyListViewsState extends State<CompetitionsQuestionsWithCompanyListViews> {
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

    final Map<String, dynamic>? args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>?;
    // Extract `committeeId` safely
    String committeeId = args?['committeeId'];

    print("CompetitionsQuestionsWithCompanyListViews $committeeId");
    return Scaffold(
      appBar: Header(context),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          Navigator.push(context, MaterialPageRoute(builder: (context) => CompetitionsWithCompanyForm(committeeId: committeeId)));
        },
        child: CustomIcon(
          icon: Icons.add,
          size: 30.0,
          color: Colors.white,
        ),
        backgroundColor: Colour().buttonBackGroundRedColor,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 15.0, horizontal: 15.0),
          child: ListView(
            scrollDirection: Axis.vertical,
            children: [
              buildFullTopFilter(committeeId),
              Center(
                child: Consumer<CompetitionProviderPage>(
                    builder: (context, provider, child) {
                      if (provider.competitionsData?.competitions == null) {
                        provider.getListOfCompetitionsQuestionnaireForCompany(provider.yearSelected, committeeId);
                        return buildLoadingSniper();
                      }
                      return provider.competitionsData!.competitions!.isEmpty
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
                                        text: AppLocalizations.of(context)!.date,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18.0,
                                        color: Colour().lightBackgroundColor,
                                      ),
                                      tooltip: "show Date"),

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
                                rows: provider!.competitionsData!.competitions!
                                    .map((CompetitionModel competition) =>
                                    DataRow(cells: [

                                      BuildDynamicDataCell(
                                        child: CustomText(text: competition?.competitionEnName ?? 'N/A',
                                          fontWeight: FontWeight.bold,fontSize: 14.0,softWrap: false,
                                          maxLines: 1,overflow: TextOverflow.ellipsis,
                                        ),
                                      ),


                                      BuildDynamicDataCell(
                                        child: CustomText(text: competition?.competitionArName ?? 'N/A',
                                          fontWeight: FontWeight.bold,fontSize: 14.0,softWrap: false,
                                          maxLines: 1,overflow: TextOverflow.ellipsis,
                                        ),
                                      ),


                                      BuildDynamicDataCell(
                                        child: CustomText(text: "${Utils.convertStringToDateFunction(competition!.competitionCreateAt!)}" ,
                                          fontWeight: FontWeight.bold,fontSize: 14.0,softWrap: false,
                                          maxLines: 1,overflow: TextOverflow.ellipsis,
                                        ),
                                      ),


                                      BuildDynamicDataCell(
                                        child: CustomText(text:competition?.user?.firstName ??"loading ...",
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
                                                          .edit,
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
                                                          () {
                                                        Navigator.of(context).push(MaterialPageRoute(builder: (context) => EditCompetitionForm(committeeId: competition.committee!.id.toString())));
                                                      }
                                                  )
                                              ),
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
                                                      dialogDeleteCompetition(competition);
                                                    },
                                                  )),
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


  Widget buildFullTopFilter(String committeeId) {
    return Consumer<CompetitionProviderPage>(
        builder: (BuildContext context, provider, child) {
          return Padding(
            padding:
            const EdgeInsets.only(top: 3.0, left: 0.0, right: 8.0, bottom: 8.0),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  Container(
                      padding: const EdgeInsets.symmetric(
                          vertical: 7.0, horizontal: 15.0),
                      decoration: BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(0)),
                        color: Colour().buttonBackGroundRedColor,
                      ),
                      child: CustomText(
                          text: 'Competition Questions For Company',
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
                        await provider.getListOfCompetitionsQuestionnaireForCompany(provider.yearSelected, committeeId);
                      },
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(
                    width: 5.0,
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        vertical: 0.0, horizontal: 15.0),
                    decoration: BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(0)),
                      color: Colour().buttonBackGroundRedColor,
                    ),
                    child: TextButton(
                      onPressed: () {
                        Navigator.of(context).push(MaterialPageRoute(builder: (context) => CompetitionMemberQuestionnaireScreen(committeeId: committeeId)));
                      },
                      child: CustomText(
                        text: 'Competition Questionnaire For Member Company',
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                  const SizedBox(
                    width: 5.0,
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        vertical: 0.0, horizontal: 15.0),
                    decoration: BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(0)),
                      color: Colour().buttonBackGroundRedColor,
                    ),
                    child: TextButton(
                      onPressed: () {
                        Navigator.pushNamed(context, DisclosuresHowMenus.routeName, arguments: {
                          'committeeId': committeeId,
                        });
                      },
                      child: CustomText(
                        text: 'Disclosures Menu',
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                  const SizedBox(
                    width: 5.0,
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        vertical: 0.0, horizontal: 15.0),
                    decoration: BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(0)),
                      color: Colour().buttonBackGroundRedColor,
                    ),
                    child: TextButton(
                      onPressed: () {
                        Navigator.of(context).push(MaterialPageRoute(builder: (context) => CompetitionMemberWithCompanyListViews(committeeId: committeeId)));
                      },
                      child: CustomText(
                        text: 'Competition Members With Company',
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        }
    );
  }



  Future dialogDeleteCompetition(CompetitionModel competition) => showDialog(
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
                        "${AppLocalizations.of(context)!.are_you_sure_to_delete} ${competition?.competitionEnName ?? competition?.competitionArName ?? 'N/A'} ?",
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
                              onPressed: () => removeCompetition(competition),
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
      }
  );


  void removeCompetition(CompetitionModel competition)async {
    final providerCompetition = Provider.of<CompetitionProviderPage>(context, listen: false);
    await providerCompetition.removeCompetition(competition);
    if (providerCompetition.isBack == true) {
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

  buildEmptyMessage(String message) {
    return CustomMessage(
      text: message,
    );
  }

  buildLoadingSniper() {
    return const LoadingSniper();
  }
}
