import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../../models/user.dart';
import '../../../../../providers/competition_provider_page.dart';
import '../../../../../providers/meeting_page_provider.dart';
import '../../../../../widgets/appBar.dart';
import '../../../../../widgets/custom_message.dart';
import '../../../../../widgets/custome_text.dart';
import '../../../../../widgets/header_language_widget.dart';
import '../../../../../widgets/loading_sniper.dart';
import '../views/competitions_questions_with_confirmation_of_independence_list_views.dart';

class CompetitionsWithConfirmationOfIndependenceForm extends StatefulWidget {
  const CompetitionsWithConfirmationOfIndependenceForm({super.key, required this.committeeId});
  final String committeeId;
  static const routeName = '/CompetitionsWithConfirmationOfIndependenceForm';
  @override
  State<CompetitionsWithConfirmationOfIndependenceForm> createState() => _CompetitionsWithConfirmationOfIndependenceFormState();
}

class _CompetitionsWithConfirmationOfIndependenceFormState extends State<CompetitionsWithConfirmationOfIndependenceForm> {
  final _formKey = GlobalKey<FormState>();
  User user = User();

  @override
  void initState() {
    super.initState();

    final provider = Provider.of<CompetitionProviderPage>(context, listen: false);

    // Build the _categoryQuestions map
    if (provider.competitionsConfirmationOfIndependenceData != null && provider.competitionsConfirmationOfIndependenceData!.competitions != null) {
      final Map<int, List<int>> categoryQuestionsMap = {};
      provider.setCategoryQuestions(categoryQuestionsMap);
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

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
    final Map<String, dynamic>? args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>?;
    // Extract `committeeId` safely
    String committeeId = args?['committeeId'] ?? "No ID Provided";

    return Scaffold(
      appBar: Header(context),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 15.0, horizontal: 15),
          child: Consumer<CompetitionProviderPage>(
              builder: (BuildContext context, provider, widget) {
                final enableArabic = context.watch<MeetingPageProvider>().enableArabic;
                final enableEnglish = context.watch<MeetingPageProvider>().enableEnglish;
                final enableArabicAndEnglish = context.watch<MeetingPageProvider>().enableArabicAndEnglish;

                return Form(
                    key: _formKey,
                    child: CustomScrollView(
                      slivers: [
                        // Sticky Header
                        SliverPersistentHeader(
                          pinned: true,
                          floating: false,
                          delegate: _StickyHeaderDelegate(
                            child: Container(
                              padding: EdgeInsets.only(left: 15, right: 15, top: 15),
                              margin: EdgeInsets.only(left: 10, right: 10),
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: Colors.grey,
                                  width: 0.3,
                                ),
                                borderRadius: BorderRadius.circular(3),
                              ),
                              child: Column(
                                children: [
                                  buildHeaderButtons(committeeId),
                                ],
                              ),
                            ),
                            headerHeight: 70.0,
                          ),
                        ),
                        // Scrollable Content
                        SliverList(
                          delegate: SliverChildListDelegate(
                            [
                              const SizedBox(height: 10),
                              LanguageWidget(
                                  enableEnglish: enableEnglish,
                                  enableArabicAndEnglish: enableArabicAndEnglish,
                                  enableArabic: enableArabic),
                              const SizedBox(height: 10),

                              // English Only Forms
                              if(enableEnglish && !enableArabicAndEnglish)
                                ...buildEnglishForms(provider),

                              // Arabic Only Forms
                              if(enableArabic && !enableArabicAndEnglish)
                                ...buildArabicForms(provider),

                              // Dual Language Forms
                              if(enableArabicAndEnglish)
                                ...buildDualLanguageForms(provider),
                            ],
                          ),
                        ),
                      ],
                    )
                );
              }),
        ),
      ),
    );
  }

  // English Forms Builder
  List<Widget> buildEnglishForms(CompetitionProviderPage provider) {
    return [
      for (int i = 0; i < provider.categoryControllersEn.length; i++)
        Column(
          children: [
            SizedBox(height: 20.0),
            buildFormItem(i, provider.categoryControllersEn[i], provider),
          ],
        ),
      SizedBox(height: 20),
    ];
  }

  // Arabic Forms Builder
  List<Widget> buildArabicForms(CompetitionProviderPage provider) {
    return [
      for (int i = 0; i < provider.categoryControllersAr.length; i++)
        Column(
          children: [
            SizedBox(height: 20.0),
            buildFormItem(i, provider.categoryControllersAr[i], provider),
          ],
        ),
      SizedBox(height: 20),
    ];
  }

  // Dual Language Forms Builder
  List<Widget> buildDualLanguageForms(CompetitionProviderPage provider) {
    // Make sure the lists have the same length
    final int itemCount = provider.categoryControllersEn.length;

    return [
      for (int i = 0; i < itemCount; i++)
        Padding(
          padding: const EdgeInsets.only(bottom: 20.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // English form
              Expanded(
                child: buildFormItem(i, provider.categoryControllersEn[i], provider, showRemoveButton: false),
              ),
              SizedBox(width: 20),
              // Arabic form
              Expanded(
                child: buildFormItem(i, provider.categoryControllersAr[i], provider),
              ),
            ],
          ),
        ),
      SizedBox(height: 20),
    ];
  }

  // Common Form Item Builder
  Widget buildFormItem(int index, TextEditingController controller, CompetitionProviderPage provider, {bool showRemoveButton = true}) {
    return Container(
      padding: EdgeInsets.all(5.0),
      decoration: BoxDecoration(
        border: Border(
          right: BorderSide(width: 0.1),
          left: BorderSide(width: 0.1),
          bottom: BorderSide(width: 0.1),
        ),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey,
            offset: Offset(0.0, 1.0),
            blurRadius: 6.0,
          ),
        ],
        borderRadius: BorderRadius.circular(3),
      ),
      child: Row(
        children: [
          Container(
              padding: const EdgeInsets.only(right: 5.0),
              color: Colors.white10,
              child: Text('${index + 1}')
          ),
          const SizedBox(width: 10),
          Flexible(
            flex: 9,
            child: SizedBox(
              height: 100,
              child: buildCustomTextFormField(
                controller: controller,
                hint: 'Enter Question',
                validatorMessage: 'please enter criteria Question',
              ),
            ),
          ),
          if (showRemoveButton)
            Expanded(
                child: InkWell(
                  child: const Icon(
                    Icons.remove_circle_outline,
                    color: Colors.red,
                    size: 40,
                  ),
                  onTap: () {
                    provider.removeParentForm(index);
                  },
                )
            ),
        ],
      ),
    );
  }

  Widget buildHeaderButtons(String committeeId) => Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Container(
          decoration: BoxDecoration(
            color: Colors.red,
            borderRadius: BorderRadius.circular(20),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 0.0),
          child: TextButton(
            onPressed: () {

              Navigator.pushNamed(context, CompetitionsQuestionsWithConfirmationOfIndependenceListViews.routeName, arguments: {'committeeId': widget.committeeId});

            },
            child: CustomText(
              text: 'Back',
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          )
      ),
      Container(
          decoration: BoxDecoration(
            color: Colors.red,
            borderRadius: BorderRadius.circular(20),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 25.0, vertical: 5.0),
          child: buildAddButton()
      ),
      buildEditingActions(committeeId)
    ],
  );

  Widget buildEditingActions(String committeeId) => ElevatedButton.icon(
    style: ElevatedButton.styleFrom(
      backgroundColor: Colors.red,
      shadowColor: Colors.transparent,
    ),
    onPressed: () => saveForm(committeeId),
    icon: const Icon(Icons.done),
    label: const Text('Save'),
  );

  Future saveForm(String committeeId) async {
    final provider = Provider.of<CompetitionProviderPage>(context, listen: false);
    final meetingProvider = Provider.of<MeetingPageProvider>(context, listen: false);

    // Check which language mode is active
    bool enableEnglish = meetingProvider.enableEnglish;
    bool enableArabic = meetingProvider.enableArabic;
    bool enableBoth = meetingProvider.enableArabicAndEnglish;

    // Validate form
    final isValid = _formKey.currentState!.validate();
    if (!isValid) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill all required fields'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Show loading indicator
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Center(
          child: CircularProgressIndicator(),
        );
      },
    );

    try {
      // Collect all form data
      List<Map<String, dynamic>> formData = provider.collectFormData();

      if (formData.isEmpty) {
        // Close loading dialog
        if (Navigator.canPop(context)) {
          Navigator.of(context, rootNavigator: true).pop();
        }

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please add at least one question'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      // Prepare data for backend
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      user = User.fromJson(json.decode(prefs.getString("user")!));

      Map<String, dynamic> data = {
        "listOfCategory": formData,
        "created_by": user.userId,
        "business_id": user.businessId,
        "type": 'competition_with_confirmation_of_independence',
        "committee_id": committeeId,
        "language_settings": {
          "english_enabled": enableEnglish,
          "arabic_enabled": enableArabic,
          "dual_enabled": enableBoth
        }
      };

      // Log the data being sent
      print("Sending data: ${json.encode(data)}");

      // Submit to backend
      bool success = await provider.insertNewCompetitionsForConfirmationOfIndependence(data);

      // Close loading dialog
      if (Navigator.canPop(context)) {
        Navigator.of(context, rootNavigator: true).pop();
      }

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Form saved successfully'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );

        // Navigate back after success
        Future.delayed(const Duration(seconds: 2), () {
          if (Navigator.canPop(context)) {
            Navigator.pushNamed(context, CompetitionsQuestionsWithConfirmationOfIndependenceListViews.routeName, arguments: {'committeeId': widget.committeeId});

          }
        });
      } else {
        String errorMsg = provider.errorMessage ?? 'Failed to save form';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMsg),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 4),
          ),
        );
      }
    } catch (e) {
      // Close loading dialog if open
      if (Navigator.canPop(context)) {
        Navigator.of(context, rootNavigator: true).pop();
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 4),
        ),
      );
      print("Exception in saveForm: ${e.toString()}");
    }
  }

  Widget buildAddButton() => Row(
    mainAxisAlignment: MainAxisAlignment.end,
    children: [
      InkWell(
        onTap: () {
          final CompetitionProviderPage provider =
          Provider.of<CompetitionProviderPage>(context, listen: false);
          provider.addParentForm();
        },
        child: const Icon(
          Icons.add,
          size: 35,
          color: Colors.white,
        ),
      ),
    ],
  );
}

Widget buildCustomTextFormField({
  required TextEditingController controller,
  required String hint,
  required String validatorMessage,
  IconData? icon,
}) {
  return TextFormField(
    maxLines: null,
    expands: true,
    controller: controller,
    validator: (val) => val != null && val.isEmpty ? validatorMessage : null,
    decoration: InputDecoration(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      hintText: hint,
      isDense: true,
      contentPadding: const EdgeInsets.fromLTRB(8.0, 8.0, 8.0, 0.0),
      prefixIcon: icon != null ? Icon(icon) : null,
    ),
  );
}

// Sticky Header Delegate
class _StickyHeaderDelegate extends SliverPersistentHeaderDelegate {
  final Widget child;
  final double headerHeight;

  _StickyHeaderDelegate({required this.child, required this.headerHeight});

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return SizedBox.expand(
      child: child,
    );
  }

  @override
  double get maxExtent => headerHeight;
  @override
  double get minExtent => headerHeight;
  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) {
    return true;
  }
}
