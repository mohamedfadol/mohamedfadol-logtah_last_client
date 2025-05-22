import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/board_page_provider.dart';
import '../../widgets/custome_text.dart';
import '../../widgets/stand_text_form_field.dart';
import '../../widgets/date_format_text_form_field.dart';

class EditBoardForm extends StatelessWidget {
  final int boardId;

  const EditBoardForm({super.key, required this.boardId});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<BoardPageProvider>(context);
    final formKey = GlobalKey<FormState>();

    return FutureBuilder(
      future: provider.getBoardById(boardId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        return Dialog(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: formKey,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    CustomText(text: "Edit Board", fontSize: 20, fontWeight: FontWeight.bold),
                    const SizedBox(height: 15),
                    StandTextFormField(
                      controllerField: provider.boardNameController,
                      labelText: "Board Name",
                      icon: Icons.people,
                      color: Colors.redAccent,
                      valid: (val) => val!.isEmpty ? 'Required' : null,
                    ),
                    const SizedBox(height: 15),
                    DateFormatTextFormField(
                      dateinput: provider.termController,
                      labelText: "Start Term",
                      icon: Icons.calendar_today,
                      color: Colors.redAccent,
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
                    ),
                    const SizedBox(height: 15),
                    DropdownButton<String>(
                      value: provider.dropdownValue,
                      items: ['51', '66', '70'].map((value) => DropdownMenuItem(
                        value: value,
                        child: CustomText(text: '% $value'),
                      )).toList(),
                      onChanged: (val) {
                        if (val != null) {
                          provider.dropdownValue = val;
                          provider.notifyListeners();
                        }
                      },
                    ),
                    const SizedBox(height: 15),
                    DateFormatTextFormField(
                      dateinput: provider.fiscalYearController,
                      labelText: "Fiscal Year End",
                      icon: Icons.calendar_today,
                      color: Colors.redAccent,
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
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ElevatedButton(
                          onPressed: () async {
                            if (formKey.currentState!.validate()) {
                              final success = await provider.updateBoard(boardId);
                              if (success && context.mounted) {
                                Navigator.pop(context);
                              }
                            }
                          },
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                          child: CustomText(text: "Save Changes"),
                        ),
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: CustomText(text: "Cancel", color: Colors.red),
                        ),
                      ],
                    )
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
