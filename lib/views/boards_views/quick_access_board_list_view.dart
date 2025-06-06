
import 'package:diligov_members/widgets/custome_text.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localization.dart';

import 'package:intl/intl.dart';
import '../../colors.dart';
import '../../models/board_model.dart';
import '../../models/data/years_data.dart';
import '../../providers/board_page_provider.dart';
import '../../utility/pdf_viewer_page_asyncfusion.dart';
import '../../widgets/appBar.dart';
import '../../widgets/custom_icon.dart';
import '../../widgets/custom_message.dart';
import '../../widgets/date_format_text_form_field.dart';
import '../../widgets/dropdown_string_list.dart';
import '../../widgets/loading_sniper.dart';
import '../../widgets/stand_text_form_field.dart';

import '../modules/remuneration_policy/form/set_board_remuneration_form.dart';
class QuickAccessBoardListView extends StatefulWidget {
  const QuickAccessBoardListView({Key? key}) : super(key: key);
  static const routeName = '/QuickAccessBoardListView';

  @override
  State<QuickAccessBoardListView> createState() => _QuickAccessBoardListViewState();
}

class _QuickAccessBoardListViewState extends State<QuickAccessBoardListView> {

  buildEmptyMessage(String message) {
    return CustomMessage(
      text: message,
    );
  }

  buildLoadingSniper() {
    return const LoadingSniper();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: Header(context),
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 5.0, horizontal: 10.0),
        child: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              buildFullTopFilter(),
              Consumer<BoardPageProvider>(
                builder: (context, provider, _) {
                  if (provider.loading) return buildLoadingSniper();
                  if (provider.boardsData?.boards == null) {
                    provider.getListOfBoardsByFilterDate(provider.yearSelected);
                    return buildLoadingSniper();
                  }

                  if (provider.boardsData!.boards!.isEmpty) {
                    return buildEmptyMessage(AppLocalizations.of(context)!.no_data_to_show);
                  }

                  return SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: DataTable(
                      columnSpacing: 100,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colour().darkHeadingColumnDataTables),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      headingRowHeight: 60,
                      dividerThickness: 0.3,
                      headingRowColor: MaterialStateColor.resolveWith((states) => Colour().darkHeadingColumnDataTables),
                      columns: [
                        DataColumn(label: CustomText(text: "Board Name", fontWeight: FontWeight.bold, fontSize: 18.0, color: Colour().lightBackgroundColor)),
                        DataColumn(label: CustomText(text: "Fiscal Year", fontWeight: FontWeight.bold, fontSize: 18.0, color: Colour().lightBackgroundColor)),
                        DataColumn(label: CustomText(text: "Serial Number", fontWeight: FontWeight.bold, fontSize: 18.0, color: Colour().lightBackgroundColor)),
                        DataColumn(label: CustomText(text: "Term", fontWeight: FontWeight.bold, fontSize: 18.0, color: Colour().lightBackgroundColor)),
                        DataColumn(label: CustomText(text: "Actions", fontWeight: FontWeight.bold, fontSize: 18.0, color: Colour().lightBackgroundColor)),
                      ],
                      rows: provider.boardsData!.boards!.map((board) => DataRow(
                        cells: [
                          DataCell(CustomText(text: board.boardName ?? '')),
                          DataCell(CustomText(text: board.fiscalYear ?? '')),
                          DataCell(CustomText(text: board.serialNumber ?? '')),
                          DataCell(CustomText(text: board.term ?? '')),
                          DataCell(_buildActionButtons(board)),
                        ],
                      )).toList(),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),

    );
  }

  Widget _buildActionButtons(Board board) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          ElevatedButton.icon(
            label: CustomText(text: 'View'),
            icon: CustomIcon(icon: Icons.remove_red_eye_outlined, color: Colors.white),
            onPressed: () {},
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
          ),
          const SizedBox(width: 5),
          ElevatedButton.icon(
            label: CustomText(text: 'Set Remuneration'),
            icon: CustomIcon(icon: Icons.add, color: Colors.white),
            onPressed: () {
              Navigator.of(context).push(MaterialPageRoute(builder: (context) => SetBoardRemunerationForm(board: board)));
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
          ),

        ],
      ),
    );
  }

  Widget buildFullTopFilter() {
    return Consumer<BoardPageProvider>(
        builder: (BuildContext context, provider, _) {
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
                          text: "Boards",
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white
                      )),
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
                      hint: CustomText(
                          text: AppLocalizations.of(context)!.select_year),
                      selectedValue: provider.yearSelected,
                      dropdownItems: yearsData,
                      onChanged: (newValue) => provider.setYearSelected(newValue!),
                      color: Colors.grey,
                    ),
                  ),

                ],
              ),
            ),
          );
        }
    );
  }



  void openPDF(BuildContext context, String file,fileName) => Navigator.of(context).push(
    MaterialPageRoute(builder: (context) => PDFViewerPageSyncfusionPackage(file: file,fileName: fileName,)),
  );


}
