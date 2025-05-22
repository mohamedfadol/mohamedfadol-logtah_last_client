
import 'package:diligov_members/views/modules/disclosures_views/related_parties/views/competition_member_with_related_parties_list_views.dart';
import 'package:diligov_members/views/modules/disclosures_views/related_parties/views/competitions_questions_with_related_parties_list_views.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../colors.dart';
import '../../../models/data/years_data.dart';
import '../../../providers/disclosure_page_provider.dart';
import '../../../widgets/appBar.dart';
import '../../../widgets/custome_text.dart';
import '../../../widgets/dropdown_string_list.dart';
import 'package:flutter_gen/gen_l10n/app_localization.dart';

import 'competitions/views/competitions_questions_with_company_list_views.dart';
import 'confirmation_of_independence/views/competitions_questions_with_confirmation_of_independence_list_views.dart';


class DisclosuresHowMenus extends StatefulWidget {
  const DisclosuresHowMenus({super.key});
  static const routeName = '/DisclosuresHowMenus';
  @override
  State<DisclosuresHowMenus> createState() => _DisclosuresHowMenusState();
}

class _DisclosuresHowMenusState extends State<DisclosuresHowMenus> {
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
    String committeeId = args?['committeeId'] ?? "No ID Provided";

    return Scaffold(
      appBar: Header(context),
      body: Column(
        children: [
          buildFullTopFilter(committeeId),
          Expanded(
            child: Center(
              child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 15.0, horizontal: 15.0),
                  child: Consumer<DisclosurePageProvider>(
                      builder: (context, provider, child) {
                        return Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                // CEO KPI Upload Button
                                _buildUploadButton(
                                    context: context,
                                    provider: provider,
                                    committeeId: committeeId,
                                    buttonText: "Related Party Transaction",
                                    screenRoute: CompetitionsQuestionsWithRelatedPartiesListViews.routeName
                                ),

                                SizedBox(width: 20),

                                // Long Term Incentive Plan Upload Button
                                _buildUploadButton(
                                    context: context,
                                    provider: provider,
                                  committeeId: committeeId,
                                    buttonText: "Confirmation of Independence",
                                  screenRoute: CompetitionsQuestionsWithConfirmationOfIndependenceListViews.routeName,
                                ),

                                SizedBox(width: 20),

                                // Short Term Incentive Plan Upload Button
                                _buildUploadButton(
                                    context: context,
                                    provider: provider,
                                    committeeId: committeeId,
                                    buttonText: "Competing with Company",
                                    screenRoute: CompetitionsQuestionsWithCompanyListViews.routeName
                                ),
                              ],
                            ),


                          ],
                        );
                      }
                  )
              ),
            ),
          ),
        ],
      ),
    );
  }


  Widget _buildUploadButton({
    required BuildContext context,
    required DisclosurePageProvider provider,
    required String buttonText,
    required String screenRoute, required String committeeId,
  }) {

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(vertical: 7.0, horizontal: 15.0),
          width: 380,
          height: 300,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(10)),
            color: Colors.grey[400],
          ),
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(0),
              ),
            ),
            onPressed: () {
              // Navigate to different screens based on the fileType
              Navigator.of(context).pushNamed(
                  screenRoute,
                  arguments: {
                    'committeeId': committeeId,
                    // 'fileType': fileType,
                  }
              );
            },
            child: CustomText(text: buttonText, fontWeight: FontWeight.bold, fontSize: 20,color: Colors.grey,),
          ),
        ),

      ],
    );
  }


  Widget buildFullTopFilter(String committeeId) {
    return Consumer<DisclosurePageProvider>(
        builder: (BuildContext context, provider, child) {
          return Padding(
            padding:
            const EdgeInsets.only(top: 3.0, left: 15.0, right: 15.0, bottom: 8.0),
            child: Row(
              children: [
                Container(
                    padding: const EdgeInsets.symmetric(
                        vertical: 7.0, horizontal: 15.0),
                    decoration: BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(0)),
                      color: Colour().buttonBackGroundRedColor,
                    ),
                    child: CustomText(
                        text: "Disclosures",
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
                      await provider.getListOfDisclosures(provider.yearSelected, committeeId);
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

}
