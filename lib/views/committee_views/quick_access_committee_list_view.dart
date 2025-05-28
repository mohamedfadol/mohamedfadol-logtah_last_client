import 'package:diligov_members/providers/board_page_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:convert';
import 'dart:io';

import 'package:another_flushbar/flushbar.dart';
import 'package:file_picker/file_picker.dart';
import 'package:logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../NetworkHandler.dart';
import '../../colors.dart';

import '../../models/committee_model.dart';
import '../../models/data/years_data.dart';
import '../../models/user.dart';
import '../../providers/committee_provider_page.dart';
import '../../utility/pdf_viewer_page_asyncfusion.dart';
import '../../widgets/appBar.dart';
import '../../widgets/custom_icon.dart';
import '../../widgets/custom_message.dart';
import '../../widgets/custome_text.dart';
import '../../widgets/dropdown_string_list.dart';
import '../../widgets/loading_sniper.dart';
import '../../widgets/stand_text_form_field.dart';
import 'package:flutter_gen/gen_l10n/app_localization.dart';

import '../modules/remuneration_policy/form/set_committee_remuneration_form.dart';

class QuickAccessCommitteeListView extends StatefulWidget {
  const QuickAccessCommitteeListView({Key? key}) : super(key: key);
  static const routeName = '/QuickAccessCommitteeListView';

  @override
  State<QuickAccessCommitteeListView> createState() => _QuickAccessCommitteeListViewState();
}

class _QuickAccessCommitteeListViewState extends State<QuickAccessCommitteeListView> {

  Widget buildFullTopFilter() {
    return Consumer<CommitteeProviderPage>(
        builder: (BuildContext context, provider, child){
          return Padding(
            padding: const EdgeInsets.only(top: 3.0, left: 0.0, right: 8.0, bottom: 8.0),
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
                        text: 'Committees',
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold)),
                const SizedBox(
                  width: 5.0,
                ),
                Container(
                  width: 200,
                  padding: const EdgeInsets.symmetric(vertical: 7.0, horizontal: 15.0),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                    color: Colour().buttonBackGroundRedColor,
                  ),
                  child: DropdownStringList(
                    boxDecoration: Colors.white,
                    hint: CustomText(text: AppLocalizations.of(context)!.select_year,color: Colour().mainWhiteTextColor),
                    selectedValue: provider.yearSelected,
                    dropdownItems: yearsData,
                    onChanged: (String? newValue) async {
                      provider.setYearSelected(newValue!.toString());
                      await provider.getListOfMeetingsCommitteesByFilter(provider.yearSelected);
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

  buildLoadingSniper() {
    return const LoadingSniper();
  }
  buildEmptyMessage(String message) {
    return CustomMessage(
      text: message,
    );
  }

  Widget buildCommitteeActions(Committee committee) {
    return Row(
      children: [
        ElevatedButton.icon(
          label: CustomText(text: 'Set Remuneration'),
          icon: CustomIcon(icon: Icons.add),
          onPressed: () {
            Navigator.of(context).push(MaterialPageRoute(builder: (context) => SetCommitteeRemunerationForm(committee: committee)));
            },
          style: ElevatedButton.styleFrom(backgroundColor: Colors.grey),
        ),

      ],
    );
  }

  Widget buildCommitteeTable() {
    return Consumer<CommitteeProviderPage>(
      builder: (context, provider, child) {
        if (provider.committeesData?.committees == null) {

          provider.getListOfMeetingsCommitteesByFilter(provider.yearSelected);
          return buildLoadingSniper();
        }
        return provider.committeesData!.committees!.isEmpty
            ? buildEmptyMessage(AppLocalizations.of(context)!.no_data_to_show)
            : SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: SizedBox(
            width: MediaQuery.of(context).size.width,
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
              headingRowColor:
              MaterialStateColor.resolveWith((states) =>
              Colour().darkHeadingColumnDataTables),
              columns: [
                DataColumn(label: CustomText(text: "Committee Name",  fontWeight: FontWeight.bold,
                  fontSize: 18.0,
                  color: Colour().lightBackgroundColor,
                  softWrap: true,)),
                DataColumn(label: CustomText(text: "Committee Board",  fontWeight: FontWeight.bold,
                  fontSize: 18.0,
                  color: Colour().lightBackgroundColor,
                  softWrap: true,)),
                DataColumn(label: CustomText(text: "Actions",  fontWeight: FontWeight.bold,
                  fontSize: 18.0,
                  color: Colour().lightBackgroundColor,
                  softWrap: true,)),
              ],
              rows: provider.committeesData!.committees!.map((committee) {
                return DataRow(
                  cells: [
                    DataCell(CustomText(text: committee.committeeName ?? '', fontWeight: FontWeight.bold, fontSize: 14.0)),
                    DataCell(CustomText(text: committee.board?.boardName ?? '', fontWeight: FontWeight.bold, fontSize: 14.0)),
                    DataCell(buildCommitteeActions(committee)),
                  ],
                );
              }).toList(),
            ),
          ),
        );
      },
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: Header(context),
      body: Center(
        child: Padding(
      padding: const EdgeInsets.symmetric(vertical: 5.0, horizontal: 10.0),
      child: Column(
        children: [
          buildFullTopFilter(),
          Expanded(child: buildCommitteeTable()),
        ],
      ),
    ),
      ),
    );
  }


}
