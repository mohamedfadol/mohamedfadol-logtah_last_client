
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
            icon: CustomIcon(icon: Icons.remove_red_eye_outlined),
            onPressed: () {},
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
          ),
          const SizedBox(width: 5),
          ElevatedButton.icon(
            label: CustomText(text: 'edit'),
            icon: CustomIcon(icon: Icons.edit, color: Colors.white),
            onPressed: () => openEditBoardDialog(context, board),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
          ),
          const SizedBox(width: 5),
          ElevatedButton.icon(
            label: CustomText(text: 'Delete'),
            icon: CustomIcon(icon: Icons.restore_from_trash_outlined, color: Colors.white),
            onPressed: () => _confirmDelete(context, board.boarId!),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
          ),
          const SizedBox(width: 5),
          ElevatedButton.icon(
            label: CustomText(text: 'Set Remuneration'),
            icon: CustomIcon(icon: Icons.add, color: Colors.white),
            onPressed: () {
              Navigator.of(context).push(MaterialPageRoute(builder: (context) => SetBoardRemunerationForm(board: board)));
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.white),
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

                  const SizedBox(
                    width: 5.0,
                  ),

                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                      color: Colour().buttonBackGroundRedColor,
                    ),
                    child: ElevatedButton.icon(
                      label: CustomText(text: 'Add Board'),
                      icon: CustomIcon(icon: Icons.add, color: Colors.white),
                      onPressed: () => openBoardCreateDialog(context),
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
          );
        }
    );
  }

  Future<void> openBoardCreateDialog(BuildContext context) async {
    final boardProvider = Provider.of<BoardPageProvider>(context, listen: false);
    final formKey = GlobalKey<FormState>();

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          insetPadding: const EdgeInsets.symmetric(horizontal: 100, vertical: 24),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: 600,
              maxHeight: MediaQuery.of(context).size.height * 0.8,
            ),
            child: Scaffold(
              backgroundColor: Colors.black12,
              body: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Form(
                  key: formKey,
                  child: SingleChildScrollView(
                    child: Consumer<BoardPageProvider>(
                      builder: (context, provider, _) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            CustomText(text:
                                "Add New Board",
                                fontWeight: FontWeight.bold,
                                color: Colors.red,
                            ),
                            const SizedBox(height: 15),
                            StandTextFormField(
                              color: Colors.redAccent,
                              icon: Icons.people,
                              labelText: "Board Name",
                              valid: (val) => val!.isNotEmpty ? null : 'Enter a valid Board Name',
                              controllerField: provider.boardNameController,
                            ),
                            const SizedBox(height: 15),
                            DateFormatTextFormField(
                              dateinput: provider.termController,
                              labelText: "Start Board Date",
                              onTap: () async {
                                final date = await showDatePicker(
                                  context: context,
                                  initialDate: DateTime.now(),
                                  firstDate: DateTime(2000),
                                  lastDate: DateTime(2100),
                                );
                                if (date != null) {
                                  provider.termController.text = DateFormat('yyyy-MM-dd').format(date);
                                }
                              },
                              icon: Icons.calendar_today,
                              color: Colors.redAccent,
                            ),
                            const SizedBox(height: 15),
                            CustomText(text: "Set Quorum (51% - 66% - 70%)"),
                            const SizedBox(height: 10),
                            DropdownButton<String>(
                              value: provider.dropdownValue,
                              dropdownColor: Colors.white,
                              icon: CustomIcon(icon: Icons.keyboard_arrow_down),
                              onChanged: (String? newValue) {
                                if (newValue != null) {
                                  provider.dropdownValue = newValue;
                                  provider.notifyListeners();
                                }
                              },
                              items: ['51', '66', '70'].map((String item) {
                                return DropdownMenuItem<String>(
                                  value: item,
                                  child: CustomText(text: "% $item"),
                                );
                              }).toList(),
                            ),
                            const SizedBox(height: 15),
                            DateFormatTextFormField(
                              dateinput: provider.fiscalYearController,
                              labelText: "Set Financial Year End",
                              onTap: () async {
                                final date = await showDatePicker(
                                  context: context,
                                  initialDate: DateTime.now(),
                                  firstDate: DateTime(2000),
                                  lastDate: DateTime(2100),
                                );
                                if (date != null) {
                                  provider.fiscalYearController.text = DateFormat('yyyy-MM-dd').format(date);
                                }
                              },
                              icon: Icons.calendar_today,
                              color: Colors.redAccent,
                            ),
                            const SizedBox(height: 15),
                            provider.fileName != null
                                ? CustomText(text: "📄 ${provider.fileName}")
                                : CustomText(text: "No file selected"),
                            const SizedBox(height: 10),
                            ElevatedButton.icon(
                              onPressed: () => provider.pickBoardFile(),
                              icon: CustomIcon(icon: Icons.upload_file, color: Colors.white),
                              label: CustomText(text: "Upload Charter"),
                              style: ElevatedButton.styleFrom(backgroundColor: Colors.grey),
                            ),
                            const SizedBox(height: 20),
                              Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                boardProvider.loading ? CircularProgressIndicator() : ElevatedButton.icon(
                                  onPressed: () async {
                                    if (formKey.currentState!.validate()) {
                                      final success = await boardProvider.createBoard();
                                      if (success) {
                                        boardProvider.clearForm();
                                        Navigator.pop(context);
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(
                                              backgroundColor: Colors.green,
                                              content: CustomText(text: "Board created successfully")
                                          ),
                                        );
                                      } else {

                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(
                                              backgroundColor: Colors.red,
                                              content: CustomText(text: "Failed to create board")
                                          ),
                                        );
                                      }
                                    }
                                  },
                                  icon: CustomIcon(icon: Icons.add),
                                  label: CustomText(text: "Add Board"),
                                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                                ),
                                boardProvider.loading ? CircularProgressIndicator() : TextButton(
                                  onPressed: () {
                                    boardProvider.clearForm();
                                    Navigator.pop(context);
                                  },
                                  child: CustomText(text: "Cancel", color: Colors.red),
                                ),
                              ],
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> openEditBoardDialog(BuildContext context, Board board) async {
    final boardProvider = Provider.of<BoardPageProvider>(context, listen: false);
    final formKey = GlobalKey<FormState>();

    // pre-fill fields
    boardProvider.boardNameController.text = board.boardName ?? '';
    boardProvider.termController.text = board.term ?? '';
    boardProvider.fiscalYearController.text = board.fiscalYear ?? '';
    boardProvider.dropdownValue = board.quorum ?? '51';
    boardProvider.fileName = board.charterBoard ?? null;

    await showDialog(
      context: context,
      builder: (context) => Dialog(
        insetPadding: const EdgeInsets.symmetric(horizontal: 100),
        child: Container(
          padding: const EdgeInsets.all(20),
          constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.9),
          color: Colors.black12,
          child: Form(
            key: formKey,
            child: Consumer<BoardPageProvider>(
              builder: (context, provider, _) => SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    CustomText(text: "Edit Board"),
                    const SizedBox(height: 15),
                    StandTextFormField(
                      color: Colors.redAccent,
                      icon: Icons.people,
                      labelText: "Board Name",
                      controllerField: provider.boardNameController,
                      valid: (val) => val!.isEmpty ? 'Enter valid board name' : null,
                    ),
                    const SizedBox(height: 15),
                    DateFormatTextFormField(
                      dateinput: provider.termController,
                      labelText: "Start Date",
                      onTap: () async {
                        final date = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime(2000),
                          lastDate: DateTime(2100),
                        );
                        if (date != null) provider.termController.text = DateFormat('yyyy-MM-dd').format(date);
                      },
                      icon: Icons.calendar_today,
                      color: Colors.redAccent,
                    ),
                    const SizedBox(height: 15),
                    CustomText(text: "Set Quorum"),
                    DropdownButton<String>(
                      value: provider.dropdownValue,
                      items: ['51', '66', '70'].map((val) => DropdownMenuItem(value: val, child: Text("% $val"))).toList(),
                      onChanged: (val) {
                        provider.dropdownValue = val!;
                        provider.notifyListeners();
                      },
                    ),
                    const SizedBox(height: 15),
                    DateFormatTextFormField(
                      dateinput: provider.fiscalYearController,
                      labelText: "Fiscal Year End",
                      onTap: () async {
                        final date = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime(2000),
                          lastDate: DateTime(2100),
                        );
                        if (date != null) provider.fiscalYearController.text = DateFormat('yyyy-MM-dd').format(date);
                      },
                      icon: Icons.calendar_today,
                      color: Colors.redAccent,
                    ),
                    const SizedBox(height: 15),
                    provider.fileName != null
                        ? CustomText(text: "📄 ${provider.fileName}")
                        : CustomText(text: "No file selected"),
                    const SizedBox(height: 10),
                    ElevatedButton.icon(
                      onPressed: () => provider.pickBoardFile(),
                      icon: CustomIcon(icon: Icons.upload_file, color: Colors.white),
                      label: CustomText(text: "Upload Charter"),
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.grey),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        boardProvider.loading ? CircularProgressIndicator() :  ElevatedButton.icon(
                          icon: CustomIcon(icon: Icons.save),
                          label:  CustomText(text: "Save Changes"),
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                          onPressed: () async {
                            if (formKey.currentState!.validate()) {
                              final success = await provider.updateBoard(board.boarId!);
                              if (success) {
                                provider.clearForm();
                                Navigator.pop(context);
                                ScaffoldMessenger.of(context).showSnackBar(
                                   SnackBar(
                                     backgroundColor: Colors.green,
                                       content: CustomText(text: "Board updated successfully")
                                   ),
                                );
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                   SnackBar(
                                     backgroundColor: Colors.red,
                                       content: CustomText(text: "Update failed")
                                   ),
                                );
                              }
                            }
                          },
                        ),
                        boardProvider.loading ? CircularProgressIndicator() :  TextButton(
                          onPressed: () {
                            provider.clearForm();
                            Navigator.pop(context);
                          },
                          child: CustomText(text: "Cancel"),
                        )
                      ],
                    )
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context, int boardId) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: CustomText(text: "Delete Board"),
        content:CustomText(text: "Are you sure you want to delete this board?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: CustomText(text: "Cancel"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              Navigator.of(ctx).pop(); // Close the dialog
              final provider = Provider.of<BoardPageProvider>(context, listen: false);
              final success = await provider.deleteBoard(boardId);
              if (success) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                      backgroundColor: Colors.green,
                      content: CustomText(text: "Board deleted successfully")
                  ),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                      backgroundColor: Colors.red,
                      content: CustomText(text: "Failed to delete board")
                  ),
                );
              }
            },
            child: CustomText(text: "Delete"),
          ),
        ],
      ),
    );
  }

  void onTapGetDate  (TextEditingController passDate) async {
    DateTime? pickedDate = await showDatePicker(
        context: context, initialDate: DateTime.now(),
        firstDate: DateTime(2000), //DateTime.now() - not to allow to choose before today.
        lastDate: DateTime(2101)
    );

    print(pickedDate);  //pickedDate output format => 2021-03-10 00:00:00.000
    String formattedDate = DateFormat('yyyy-MM-dd').format(pickedDate!);
    print(formattedDate); //formatted date output using intl package =>  2021-03-16
    //you can implement different kind of Date Format here according to your requirement

    setState(() {
      passDate.text = formattedDate; //set output date to TextField value.
    });
    }

  void openPDF(BuildContext context, String file,fileName) => Navigator.of(context).push(
    MaterialPageRoute(builder: (context) => PDFViewerPageSyncfusionPackage(file: file,fileName: fileName,)),
  );


}
