import 'dart:convert';

import 'package:diligov_members/views/modules/disclosures_views/competitions/forms/competitions_with_company_form.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../../colors.dart';
import '../../../../../models/competition_model.dart';
import '../../../../../models/data/years_data.dart';
import '../../../../../models/user.dart';
import '../../../../../providers/competition_provider_page.dart';
import '../../../../../widgets/appBar.dart';
import '../../../../../widgets/build_dynamic_data_cell.dart';
import '../../../../../widgets/custom_icon.dart';
import '../../../../../widgets/custom_message.dart';
import '../../../../../widgets/custome_text.dart';
import '../../../../../widgets/dropdown_string_list.dart';
import '../../../../../widgets/loading_sniper.dart';
import '../views/competitions_questions_with_company_list_views.dart';
import 'package:flutter_gen/gen_l10n/app_localization.dart';

class EditCompetitionForm extends StatefulWidget {
  final String committeeId;
  const EditCompetitionForm({super.key, required this.committeeId});
  static const routeName = '/EditCompetitionForm';
  @override
  State<EditCompetitionForm> createState() => _EditCompetitionFormState();
}

class _EditCompetitionFormState extends State<EditCompetitionForm> {
  @override
  Widget build(BuildContext context) {

    final formKey = GlobalKey<FormState>();
    final englishNameController = TextEditingController();
    final arabicNameController = TextEditingController();
    bool isEnglishActive = true;
    bool isArabicActive = true;

    return Scaffold(
      appBar: Header(context),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          Navigator.push(context, MaterialPageRoute(builder: (context) => CompetitionsWithCompanyForm(committeeId: this.widget.committeeId,)));
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
          child: Column(
            children: [
              buildFullTopFilter(widget.committeeId),

              // Add form section above the table
              Card(
                elevation: 4,
                margin: EdgeInsets.symmetric(vertical: 16),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Form(
                    key: formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CustomText(
                          text: "Add New Competition Entry",
                          fontWeight: FontWeight.bold,
                          fontSize: 18.0,
                        ),
                        SizedBox(height: 16),

                        // English section
                        Row(
                          children: [
                            Expanded(
                              flex: 4,
                              child: TextFormField(
                                controller: englishNameController,
                                decoration: InputDecoration(
                                  labelText: "English Name",
                                  border: OutlineInputBorder(),
                                  hintText: "Enter competition name in English",
                                ),
                                validator: (value) {
                                  if (isEnglishActive && (value == null || value.isEmpty)) {
                                    return 'Please enter English name';
                                  }
                                  return null;
                                },
                              ),
                            ),
                            SizedBox(width: 16),
                            Expanded(
                              flex: 1,
                              child: Row(
                                children: [
                                  Checkbox(
                                    value: isEnglishActive,
                                    onChanged: (value) {
                                      setState(() {
                                        isEnglishActive = value!;
                                      });
                                    },
                                  ),
                                  CustomText(text: "Active"),
                                ],
                              ),
                            ),
                          ],
                        ),

                        SizedBox(height: 16),

                        // Arabic section
                        Row(
                          children: [
                            Expanded(
                              flex: 4,
                              child: TextFormField(
                                controller: arabicNameController,
                                decoration: InputDecoration(
                                  labelText: "Arabic Name",
                                  border: OutlineInputBorder(),
                                  hintText: "Enter competition name in Arabic",
                                  alignLabelWithHint: true,
                                ),
                                textAlign: TextAlign.right,
                                textDirection: TextDirection.rtl,
                                validator: (value) {
                                  if (isArabicActive && (value == null || value.isEmpty)) {
                                    return 'Please enter Arabic name';
                                  }
                                  return null;
                                },
                              ),
                            ),
                            SizedBox(width: 16),
                            Expanded(
                              flex: 1,
                              child: Row(
                                children: [
                                  Checkbox(
                                    value: isArabicActive,
                                    onChanged: (value) {
                                      setState(() {
                                        isArabicActive = value!;
                                      });
                                    },
                                  ),
                                  CustomText(text: "Active"),
                                ],
                              ),
                            ),
                          ],
                        ),

                        SizedBox(height: 20),

                        // Submit button
                        Center(
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colour().buttonBackGroundRedColor,
                              padding: EdgeInsets.symmetric(horizontal: 50, vertical: 12),
                            ),
                            onPressed: () async {
                              if (formKey.currentState!.validate()) {
                                // Submit the form data
                                final provider = Provider.of<CompetitionProviderPage>(context, listen: false);

                                // Create data structure for API call
                                List<Map<String, dynamic>> formData = [];
                                if (isEnglishActive && englishNameController.text.isNotEmpty) {
                                  formData.add({
                                    'category_en': englishNameController.text,
                                    'category_ar': isArabicActive ? arabicNameController.text : '',
                                  });
                                } else if (isArabicActive && arabicNameController.text.isNotEmpty) {
                                  formData.add({
                                    'category_en': '',
                                    'category_ar': arabicNameController.text,
                                  });
                                }
                                final SharedPreferences prefs = await SharedPreferences.getInstance();
                                var user = User.fromJson(json.decode(prefs.getString("user")!));

                                if (formData.isNotEmpty) {
                                  Map<String, dynamic> data = {
                                    "listOfCategory": formData,
                                    "created_by": user.userId,
                                    "business_id": user.businessId,
                                    "committee_id": widget.committeeId, // Fixed value as requested
                                  };

                                  // Call the API method
                                  provider.insertNewCompetitionsForCompany(data).then((success) {
                                    if (success) {
                                      // Reset form on success
                                      englishNameController.clear();
                                      arabicNameController.clear();

                                      // Refresh the data
                                      provider.getListOfCompetitionsQuestionnaireForCompany(provider.yearSelected, widget.committeeId);

                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(content: Text('Competition added successfully')),
                                      );
                                    } else {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: Text(provider.errorMessage ?? 'Failed to add competition'),
                                          backgroundColor: Colors.red,
                                        ),
                                      );
                                    }
                                  });
                                }
                              }
                            },
                            child: CustomText(
                              text: "Add Competition",
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // Original data table
              Expanded(
                child: Consumer<CompetitionProviderPage>(
                  builder: (context, provider, child) {
                    if (provider.competitionsData?.competitions == null) {
                      provider.getListOfCompetitionsQuestionnaireForCompany(provider.yearSelected, widget.committeeId);
                      return buildLoadingSniper();
                    }
                    return provider.competitionsData!.competitions!.isEmpty
                        ? buildEmptyMessage(AppLocalizations.of(context)!.no_data_to_show)
                        : Container(
                      padding: EdgeInsets.only(left: 10.0),
                      width: MediaQuery.of(context).size.width,
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: SingleChildScrollView(
                          child: DataTable(
                            columnSpacing: 100,
                            decoration: BoxDecoration(
                              border: Border.all(color: Colour().darkHeadingColumnDataTables),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            headingRowHeight: 60,
                            dividerThickness: 0.3,
                            headingRowColor: WidgetStateColor.resolveWith(
                                    (states) => Colour().darkHeadingColumnDataTables
                            ),
                            columns: <DataColumn>[
                              DataColumn(
                                  label: CustomText(
                                    text: "Name English",
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18.0,
                                    color: Colour().lightBackgroundColor,
                                  ),
                                  tooltip: "show name"
                              ),
                              DataColumn(
                                  label: CustomText(
                                    text: "Name Arabic",
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18.0,
                                    color: Colour().lightBackgroundColor,
                                  ),
                                  tooltip: "show name"
                              ),
                              DataColumn(
                                label: CustomText(
                                  text: "Actions",
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18.0,
                                  color: Colour().lightBackgroundColor,
                                ),
                              ),
                            ],
                            rows: provider.competitionsData!.competitions!
                                .map((CompetitionModel competition) => DataRow(
                                cells: [
                                  BuildDynamicDataCell(
                                    child: CustomText(
                                      text: competition?.competitionEnName ?? 'N/A',
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14.0,
                                      softWrap: false,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  BuildDynamicDataCell(
                                    child: CustomText(
                                      text: competition?.competitionArName ?? 'N/A',
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14.0,
                                      softWrap: false,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  BuildDynamicDataCell(
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        IconButton(
                                          icon: Icon(Icons.edit, color: Colors.blue),
                                          onPressed: () {
                                            // Set text controllers with existing data
                                            englishNameController.text = competition?.competitionEnName ?? '';
                                            arabicNameController.text = competition?.competitionArName ?? '';

                                            // TODO: Implement edit functionality
                                          },
                                        ),
                                        IconButton(
                                          icon: Icon(Icons.delete, color: Colors.red),
                                          onPressed: () {
                                            // TODO: Implement delete functionality
                                            showDialog(
                                              context: context,
                                              builder: (BuildContext context) {
                                                return AlertDialog(
                                                  title: Text("Delete Competition"),
                                                  content: Text("Are you sure you want to delete this competition?"),
                                                  actions: [
                                                    TextButton(
                                                      child: Text("Cancel"),
                                                      onPressed: () {
                                                        Navigator.of(context).pop();
                                                      },
                                                    ),
                                                    TextButton(
                                                      child: Text("Delete"),
                                                      onPressed: () {
                                                        // TODO: Call API to delete
                                                        Navigator.of(context).pop();
                                                      },
                                                    ),
                                                  ],
                                                );
                                              },
                                            );
                                          },
                                        ),
                                      ],
                                    ),
                                  ),
                                ]
                            )).toList(),
                          ),
                        ),
                      ),
                    );
                  },
                ),
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
            child: Row(
              children: [
                Container(
                    padding: const EdgeInsets.symmetric(
                        vertical: 7.0, horizontal: 15.0),
                    decoration: BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(0)),
                      color: Colour().buttonBackGroundRedColor,
                    ),
                    child: CustomText(
                        text: 'Edit Competitions',
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
                      await provider.getListOfCompetitionsQuestionnaireForCompany(provider.yearSelected,committeeId);
                    },
                    color: Colors.grey,
                  ),
                ),

                const SizedBox(width: 5.0),

                Container(
                    padding: const EdgeInsets.symmetric(vertical: 0.0, horizontal: 10.0),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(0)),
                      color: Colour().buttonBackGroundRedColor,
                    ),
                    child: TextButton(
                      onPressed: () {
                        Navigator.pushReplacementNamed(context, CompetitionsQuestionsWithCompanyListViews.routeName, arguments: {"committeeId": committeeId});
                      },
                      child: CustomText(
                        text: 'Back',
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    )
                ),
              ],
            ),
          );
        }
    );
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



class CompetitionListScreen extends StatefulWidget {
  static const routeName = '/CompetitionListScreen';

  @override
  _CompetitionListScreenState createState() => _CompetitionListScreenState();
}

class _CompetitionListScreenState extends State<CompetitionListScreen> {
  final formKey = GlobalKey<FormState>();
  final englishNameController = TextEditingController();
  final arabicNameController = TextEditingController();
  bool isEnglishActive = true;
  bool isArabicActive = true;
  bool isSubmitting = false;

  @override
  void dispose() {
    englishNameController.dispose();
    arabicNameController.dispose();
    super.dispose();
  }


  Widget buildFullTopFilter(String committeeId) {
    return Consumer<CompetitionProviderPage>(
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
                        text: 'Competitions',
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
              ],
            ),
          );
        }
    );
  }

  buildEmptyMessage(String message) {
    return CustomMessage(
      text: message,
    );
  }

  buildLoadingSniper() {
    return const LoadingSniper();
  }

  void _submitForm(String committeeId) async {
    if (!formKey.currentState!.validate()) {
      return;
    }

    // Validate that at least one field is filled
    if (englishNameController.text.isEmpty && arabicNameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter at least one name'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      isSubmitting = true;
    });

    try {
      final provider = Provider.of<CompetitionProviderPage>(context, listen: false);

      // Create data structure for API call
      List<Map<String, dynamic>> formData = [];

      // Only add non-empty fields based on active status
      if (isEnglishActive && englishNameController.text.isNotEmpty) {
        formData.add({
          'category_en': englishNameController.text,
          'category_ar': isArabicActive ? arabicNameController.text : '',
        });
      } else if (isArabicActive && arabicNameController.text.isNotEmpty) {
        formData.add({
          'category_en': '',
          'category_ar': arabicNameController.text,
        });
      }

      Map<String, dynamic> data = {
        "listOfCategory": formData,
        "business_id": 1, // Fixed value as requested
        "created_by": 1, // Fixed value as requested
        "committee_id": committeeId, // Use committeeId or default to 16
        "type": 'competition_with_company',
      };

      bool success = await provider.insertNewCompetitionsForCompany(data);

      if (success) {
        // Reset form
        englishNameController.clear();
        arabicNameController.clear();

        // Refresh data list
        provider.getListOfCompetitionsQuestionnaireForCompany(provider.yearSelected, committeeId);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Competition added successfully'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(provider.errorMessage ?? 'Failed to add competition'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        isSubmitting = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final Map<String, dynamic>? args =
    ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>?;

    // Extract `committeeId` safely
    String committeeId = args?['committeeId'] ?? "No ID Provided";

    return Scaffold(
      appBar: Header(context),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          Navigator.push(context, MaterialPageRoute(builder: (context) => CompetitionsWithCompanyForm(committeeId: committeeId,)));
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
          child: Column(
            children: [
              buildFullTopFilter(committeeId),

              // Add form section
              Card(
                elevation: 4,
                margin: EdgeInsets.symmetric(vertical: 16),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Form(
                    key: formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CustomText(
                          text: "Add New Competition Entry",
                          fontWeight: FontWeight.bold,
                          fontSize: 18.0,
                        ),
                        SizedBox(height: 16),

                        // English section
                        Row(
                          children: [
                            Expanded(
                              flex: 4,
                              child: TextFormField(
                                controller: englishNameController,
                                decoration: InputDecoration(
                                  labelText: "English Name",
                                  border: OutlineInputBorder(),
                                  hintText: "Enter competition name in English",
                                ),
                                validator: (value) {
                                  if (isEnglishActive && (value == null || value.isEmpty)) {
                                    return 'Please enter English name';
                                  }
                                  return null;
                                },
                                enabled: isEnglishActive,
                              ),
                            ),
                            SizedBox(width: 16),
                            Expanded(
                              flex: 1,
                              child: Row(
                                children: [
                                  Checkbox(
                                    value: isEnglishActive,
                                    onChanged: (value) {
                                      setState(() {
                                        isEnglishActive = value!;
                                      });
                                    },
                                  ),
                                  CustomText(text: "Active"),
                                ],
                              ),
                            ),
                          ],
                        ),

                        SizedBox(height: 16),

                        // Arabic section
                        Row(
                          children: [
                            Expanded(
                              flex: 4,
                              child: TextFormField(
                                controller: arabicNameController,
                                decoration: InputDecoration(
                                  labelText: "Arabic Name",
                                  border: OutlineInputBorder(),
                                  hintText: "Enter competition name in Arabic",
                                  alignLabelWithHint: true,
                                ),
                                textAlign: TextAlign.right,
                                textDirection: TextDirection.rtl,
                                validator: (value) {
                                  if (isArabicActive && (value == null || value.isEmpty)) {
                                    return 'Please enter Arabic name';
                                  }
                                  return null;
                                },
                                enabled: isArabicActive,
                              ),
                            ),
                            SizedBox(width: 16),
                            Expanded(
                              flex: 1,
                              child: Row(
                                children: [
                                  Checkbox(
                                    value: isArabicActive,
                                    onChanged: (value) {
                                      setState(() {
                                        isArabicActive = value!;
                                      });
                                    },
                                  ),
                                  CustomText(text: "Active"),
                                ],
                              ),
                            ),
                          ],
                        ),

                        SizedBox(height: 20),

                        // Submit button
                        Center(
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colour().buttonBackGroundRedColor,
                              padding: EdgeInsets.symmetric(horizontal: 50, vertical: 12),
                            ),
                            onPressed: isSubmitting ? null : () => _submitForm(committeeId),
                            child: isSubmitting
                                ? CircularProgressIndicator(color: Colors.white)
                                : CustomText(
                              text: "Add Competition",
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // Data table
              Expanded(
                child: Consumer<CompetitionProviderPage>(
                  builder: (context, provider, child) {
                    if (provider.competitionsData?.competitions == null) {
                      provider.getListOfCompetitionsQuestionnaireForCompany(provider.yearSelected, committeeId);
                      return buildLoadingSniper();
                    }
                    return provider.competitionsData!.competitions!.isEmpty
                        ? buildEmptyMessage(AppLocalizations.of(context)!.no_data_to_show)
                        : Container(
                      padding: EdgeInsets.only(left: 10.0),
                      width: MediaQuery.of(context).size.width,
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: SingleChildScrollView(
                          child: DataTable(
                            columnSpacing: 100,
                            decoration: BoxDecoration(
                              border: Border.all(color: Colour().darkHeadingColumnDataTables),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            headingRowHeight: 60,
                            dividerThickness: 0.3,
                            headingRowColor: WidgetStateColor.resolveWith(
                                    (states) => Colour().darkHeadingColumnDataTables
                            ),
                            columns: <DataColumn>[
                              DataColumn(
                                  label: CustomText(
                                    text: "Name English",
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18.0,
                                    color: Colour().lightBackgroundColor,
                                  ),
                                  tooltip: "show name"
                              ),
                              DataColumn(
                                  label: CustomText(
                                    text: "Name Arabic",
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18.0,
                                    color: Colour().lightBackgroundColor,
                                  ),
                                  tooltip: "show name"
                              ),
                              DataColumn(
                                label: CustomText(
                                  text: "Actions",
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18.0,
                                  color: Colour().lightBackgroundColor,
                                ),
                              ),
                            ],
                            rows: provider.competitionsData!.competitions!
                                .map((CompetitionModel competition) => DataRow(
                                cells: [
                                  BuildDynamicDataCell(
                                    child: CustomText(
                                      text: competition?.competitionEnName ?? 'N/A',
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14.0,
                                      softWrap: false,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  BuildDynamicDataCell(
                                    child: CustomText(
                                      text: competition?.competitionArName ?? 'N/A',
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14.0,
                                      softWrap: false,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  BuildDynamicDataCell(
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        IconButton(
                                          icon: Icon(Icons.edit, color: Colors.blue),
                                          onPressed: () {
                                            // Fill the form with existing data for editing
                                            setState(() {
                                              englishNameController.text = competition?.competitionEnName ?? '';
                                              arabicNameController.text = competition?.competitionArName ?? '';
                                              isEnglishActive = englishNameController.text.isNotEmpty;
                                              isArabicActive = arabicNameController.text.isNotEmpty;
                                            });
                                          },
                                        ),
                                        IconButton(
                                          icon: Icon(Icons.delete, color: Colors.red),
                                          onPressed: () {
                                            // Show delete confirmation
                                            showDialog(
                                              context: context,
                                              builder: (BuildContext context) {
                                                return AlertDialog(
                                                  title: Text("Delete Competition"),
                                                  content: Text("Are you sure you want to delete this competition?"),
                                                  actions: [
                                                    TextButton(
                                                      child: Text("Cancel"),
                                                      onPressed: () {
                                                        Navigator.of(context).pop();
                                                      },
                                                    ),
                                                    TextButton(
                                                      child: Text("Delete"),
                                                      onPressed: () {
                                                        // TODO: Call API to delete
                                                        Navigator.of(context).pop();
                                                      },
                                                    ),
                                                  ],
                                                );
                                              },
                                            );
                                          },
                                        ),
                                      ],
                                    ),
                                  ),
                                ]
                            )).toList(),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}