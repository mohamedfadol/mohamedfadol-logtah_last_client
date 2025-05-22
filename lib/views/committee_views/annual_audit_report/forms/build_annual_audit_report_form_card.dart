import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../colors.dart';
import '../../../../models/user.dart';
import '../../../../providers/annual_audit_report_provider.dart';
import '../../../../providers/committee_provider_page.dart';
import '../../../../providers/meeting_page_provider.dart';
import '../../../../widgets/appBar.dart';
import 'package:flutter_gen/gen_l10n/app_localization.dart';
import '../../../../widgets/custom_icon.dart';
import '../../../../widgets/custom_message.dart';
import '../../../../widgets/custome_text.dart';
import '../../../../widgets/header_language_widget.dart';
import '../../../../widgets/loading_sniper.dart';
import '../../../modules/board_views/board_meetings/board_meetings_list_view.dart';
import '../../../modules/committees_annual_audit_report_views/committees_annual_audit_report_list_view.dart';

class BuildAnnualAuditReportFormCard extends StatefulWidget {
  const BuildAnnualAuditReportFormCard({super.key});
  static const routeName = '/BuildAnnualAuditReportFormCard';
  @override
  State<BuildAnnualAuditReportFormCard> createState() => _BuildAnnualAuditReportFormCardState();
}

class _BuildAnnualAuditReportFormCardState extends State<BuildAnnualAuditReportFormCard> {
  final _formKey = GlobalKey<FormState>();
  var log = Logger();
  User user = User();


  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    Future.microtask(() {
      Provider.of<AnnualAuditReportProvider>(context, listen: false);
      final editAnnualAuditReportProvider = Provider.of<AnnualAuditReportProvider>(context, listen: false);
      editAnnualAuditReportProvider.clearAllControllers();;
    });
  }

  Widget CommitteesDataDropDownList() {
    return Container(
      width: 200,
      padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 15.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(10)),
        color: Colour().buttonBackGroundRedColor,
      ),
      child: Consumer<CommitteeProviderPage>(
        builder: (context, committeeProvider, child) {
          if (committeeProvider.committeesData ?.committees == null) {
            committeeProvider.getListOfCommitteesData();
            return buildLoadingSniper();
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              committeeProvider.committeesData!
                  .committees!.isEmpty
                  ? buildEmptyMessage(
                  AppLocalizations.of(context)!.no_data_to_show)
                  : DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  isExpanded: true,
                  isDense: true,
                  style: Theme.of(context).textTheme.titleLarge,
                  elevation: 2,
                  iconEnabledColor: Colors.white,
                  items: committeeProvider.committeesData
                      ?.committees
                      ?.map((committee) {
                    return DropdownMenuItem<String>(
                      alignment: Alignment.center,
                      value:'${committee.id}',
                      child: Container(
                        height: double.infinity,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          border:
                          Border.all(width: 0.1, color: Colors.black),
                        ),
                        child: Center(child: CustomText(text: committee.committeeName.toString())),
                      ),
                    );
                  }).toList(),
                  onChanged: (selectedItem) {
                    var selectedCommittee = committeeProvider.committeesData!.committees!
                        .firstWhere((committee) => committee.id.toString() == selectedItem);
                    committeeProvider.setCombinedCollectionBoardCommittee(
                      selectedItem,
                      selectedCommittee.committeeName.toString(),
                    );
                  },
                  hint: CustomText(
                    text: committeeProvider.selectedCombined != null
                        ? committeeProvider.selectedCombined!
                        : 'Select an item please',
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              if (committeeProvider.dropdownError != null)
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(
                    committeeProvider.dropdownError!,
                    style: TextStyle(color: Colors.red, fontSize: 12),
                  ),
                ),
            ],
          );
        },
      ),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: Header(context),
      body: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Consumer<AnnualAuditReportProvider>(
          builder: (BuildContext context, provider, child) {
            final annualAuditReportProvider =  Provider.of<AnnualAuditReportProvider>(context, listen: false);
            final theme = Theme.of(context);
            final enableArabic =
                context.watch<AnnualAuditReportProvider>().enableArabic;
            final enableEnglish =
                context.watch<AnnualAuditReportProvider>().enableEnglish;
            final enableArabicAndEnglish =
                context.watch<AnnualAuditReportProvider>().enableArabicAndEnglish;

            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 17),
              child: SingleChildScrollView(
                scrollDirection: Axis.vertical,
                child: Column(
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            buildBackButton(annualAuditReportProvider: annualAuditReportProvider),
                            SizedBox(width: 7.0),
                            CommitteesDataDropDownList()
                          ],
                        ),
                        // SizedBox(width: 10.0),
                        Spacer(),
                        LanguageWidget(
                            enableEnglish: enableEnglish,
                            enableArabicAndEnglish: enableArabicAndEnglish,
                            enableArabic: enableArabic),
                      ],
                    ),
                    SizedBox(
                      height: 20.0,
                    ),
                    Container(
                      margin: EdgeInsets.only(left: 10, right: 10),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Colors
                              .grey, // Set the border color here
                          width: 0.3, // Set the border width to 0.5
                        ),
                        borderRadius: BorderRadius.circular(
                            3), // Optional: to round the corners
                      ),
                      child: Builder(builder: (BuildContext context) {
                        return Form(
                          key: _formKey,
                          child: Column(
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: Colors
                                        .grey, // Set the border color here
                                    width: 0.5, // Set the border width to 0.5
                                  ),
                                  borderRadius: BorderRadius.circular(
                                      3), // Optional: to round the corners
                                ),
                                child: SingleChildScrollView(
                                  scrollDirection: Axis.vertical,
                                  child: Column(
                                    children: [
                                      Container(
                                          padding: EdgeInsets.all(10.0),
                                          child: CustomText(text: 'Annual Audit Report',fontSize: 18,fontWeight: FontWeight.bold,)
                                      ),
                                      Divider(height: 2,thickness: 2, color: Colors.red,),
                                      SizedBox(
                                        height: 10.0,
                                      ),
                                      if (enableEnglish)
                                        buildEnglishSideFormParent(provider),

                                      if (enableArabicAndEnglish)
                                        SingleChildScrollView(
                                          scrollDirection:
                                          Axis.vertical,
                                          child: Row(
                                            mainAxisAlignment:
                                            MainAxisAlignment
                                                .center,
                                            crossAxisAlignment:
                                            CrossAxisAlignment
                                                .start,
                                            children: [
                                              buildStepTwoContent(
                                                  provider),
                                              SizedBox(width: 10),
                                              buildArabicStepTwoContent(
                                                  provider),
                                            ],
                                          ),
                                        ),
                                      if (enableArabic)
                                        Column(
                                          children: [
                                            buildAddArabicButton(
                                                provider),
                                            SizedBox(height: 10),
                                            for (int j = 0;
                                            j <
                                                provider
                                                    .arabicTitleControllers
                                                    .length;
                                            j++)
                                              buildDynamicFormArabicItem(
                                                  j, provider),
                                          ],
                                        ),

                                      _buildStepperControls(context)
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      }),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget buildEnglishSideFormParent(AnnualAuditReportProvider provider) {
    return Column(
      children: [

        buildAddButtonForEnglishFormParent(provider),
        SizedBox(height: 10),
        for (int i = 0; i < provider.titleControllers.length;i++)
          buildDynamicFormForEnglishFormParent(i, provider),
      ],
    );
  }

  Widget buildFormRowFieldsForEnglishFormParent(int index, AnnualAuditReportProvider provider) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Container(
          padding: const EdgeInsets.all(5.0),
          color: Colors.white10,
          child: Text('${index + 1}',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
        ),
        const SizedBox(width: 6),
        Flexible(
          child: SizedBox(
            height: 100,
            child: Column(
              children: [
                Expanded(
                  child: buildCustomTextFormField(
                    controller: provider.titleControllers[index],
                    hint: 'Title',
                    validatorMessage: 'Please enter title',
                  ),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 5),
        Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          mainAxisSize: MainAxisSize.max,
          children: [
            buildRemoveButtonForEnglishParentFormFields(index, provider),
            buildAddChildrenButtonForEnglishFormFields(index, provider),
          ],
        ),
      ],
    );
  }

  Widget buildFormArabicRow(int index, AnnualAuditReportProvider provider) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            padding: const EdgeInsets.all(5.0),
            color: Colors.white10,
            child: Text('${index + 1}',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
          ),
          const SizedBox(width: 2),
          Flexible(
            child: SizedBox(
              height: 100,
              child: Column(
                children: [
                  Expanded(
                    child: buildCustomTextFormField(
                      controller: provider.arabicTitleControllers[index],
                      hint: 'Title',
                      validatorMessage: 'Please enter title',
                    ),
                  ),

                ],
              ),
            ),
          ),
          const SizedBox(width: 6),

          Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            mainAxisSize: MainAxisSize.max,
            children: [
              buildRemoveArabicButton(index, provider),
              buildAddChildrenArabicButton(index, provider),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStepperControls(BuildContext context) {
    final provider = Provider.of<AnnualAuditReportProvider>(context, listen: false);
    return provider.loading == true
        ? CustomText(
      text: 'Saving in progress...',
      color: Colors.green,
      fontWeight: FontWeight.bold,
      fontSize: 20.0,
    )
        : Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[

        TextButton(
          style: ButtonStyle(
            backgroundColor: MaterialStateProperty.all(
                Colour().buttonBackGroundRedColor),
          ),
          onPressed: () {
            _saveFormDataAgenda(provider);
          },
          child: CustomText(
            text: 'Save',
            color: Colour().mainWhiteTextColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(width: 20.0),
        // Show Back button if not the first step
        TextButton(
          style: ButtonStyle(
            backgroundColor: MaterialStateProperty.all(
                Colour().buttonBackGroundRedColor),
          ),
          onPressed: (){},
          child: CustomText(
            text: 'Back',
            color: Colour().mainWhiteTextColor,
            fontWeight: FontWeight.bold,
          ),
        )
      ],
    );
  }

  Widget buildDynamicFormArabicItem(int index, AnnualAuditReportProvider provider) {
    return Container(
      padding: EdgeInsets.all(5),
      margin: EdgeInsets.only(bottom: 10),
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
      child: Column(
        children: [
          buildFormArabicRow(index, provider),
          SizedBox(height: 5),
          buildArabicReOrderList(index, provider),
        ],
      ),
    );
  }

  Widget buildArabicReOrderList(int i, AnnualAuditReportProvider provider) {
    bool hasItems = provider.arabicChildItems.isNotEmpty &&
        provider.arabicChildItems[i].isNotEmpty;
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Container(
        color: Colors.grey[200],
        height: hasItems ? 300.0 : 0.0,
        width: MediaQuery.of(context).size.width,
        child: hasItems
            ? ReorderableListView(
          onReorder: (oldIndex, newIndex) {

            provider.reorderArabicChildItems(i, oldIndex, newIndex);
          },
          children: [
            if (provider.arabicChildItems.isNotEmpty &&
                provider.arabicChildItems[i].isNotEmpty)
              for (int j = 0;
              j < provider.arabicChildItems[i].length;
              j++)
                ListTile(
                  key: ValueKey(provider.arabicChildItems[i][j]),
                  title: Directionality(
                    textDirection: TextDirection.rtl,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [

                        Flexible(
                          child: SizedBox(
                            height: 150,
                            child: Column(
                              children: [
                                Expanded(
                                  child: buildCustomTextFormField(
                                    controller: provider
                                        .arabicDescriptionControllersList[i][j],
                                    hint: 'Description',
                                    validatorMessage:
                                    'Please enter Description',
                                  ),
                                ),

                              ],
                            ),
                          ),
                        ),
                        SizedBox(width: 6),
                        buildRemoveArabicChildrenButton(i, j, provider),
                      ],
                    ),
                  ),
                  trailing: ReorderableDragStartListener(
                    key: ValueKey<int>(provider.arabicChildItems.length),
                    index: j,
                    child: const Icon(Icons.drag_handle),
                  ),
                ),
          ],
        )
            : SizedBox.shrink(),
      ),
    );
  }

  Widget buildDynamicFormForEnglishFormParent(int index, AnnualAuditReportProvider provider) {
    return Container(
      padding: EdgeInsets.all(5.0),
      margin: EdgeInsets.only(bottom: 10),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          buildFormRowFieldsForEnglishFormParent(index, provider),
          SizedBox(height: 5),
          buildReOrderListChildrenRowFieldsForEnglishFormParent(index, provider),
        ],
      ),
    );
  }

  Widget buildReOrderListChildrenRowFieldsForEnglishFormParent(int i, AnnualAuditReportProvider provider) {
    bool hasItems = provider.childItems.isNotEmpty && provider.childItems[0].isNotEmpty;
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Container(
        color: Colors.grey[200],
        height: hasItems ? 300.0 : 0.0,
        width: MediaQuery.of(context).size.width,
        child: hasItems
            ? ReorderableListView(
          onReorder: (oldIndex, newIndex) {
            provider.reorderChildItems(i, oldIndex, newIndex);
          },
          children: [
            for (int j = 0; j < provider.childItems[i].length; j++)
              ListTile(
                key: ValueKey(provider.childItems[i][j]),
                title: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [

                    Flexible(
                      child: SizedBox(
                        height: 150,
                        child: Column(
                          children: [
                            Expanded(
                              child: buildCustomTextFormField(
                                controller: provider.descriptionControllersList[i][j],
                                hint: 'Description',
                                validatorMessage: 'Please enter Description',
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(width: 6),
                    buildRemoveChildrenButton(i, j, provider),
                  ],
                ),
                trailing: ReorderableDragStartListener(
                  index: j,
                  child: const Icon(Icons.drag_handle),
                ),
              ),
          ],
        )
            : SizedBox
            .shrink(), // If there are no items, return an empty widget
      ),
    );
  }

  Widget buildStepTwoContent(AnnualAuditReportProvider provider) {
    return Expanded(
      child: Column(
        children: [
          buildAddButtonForEnglishFormParent(provider),
          SizedBox(height: 10),
          for (int i = 0; i < provider.titleControllers.length; i++)
            buildDynamicFormForEnglishFormParent(i, provider),
        ],
      ),
    );
  }

  Widget buildArabicStepTwoContent(AnnualAuditReportProvider provider) {
    return Expanded(
      child: Column(
        children: [
          buildAddArabicButton(provider),
          SizedBox(height: 10),
          for (int i = 0; i < provider.arabicTitleControllers.length; i++)
            buildDynamicFormArabicItem(i, provider),
        ],
      ),
    );
  }

  Widget buildAddButtonForEnglishFormParent(AnnualAuditReportProvider provider) => Row(
    mainAxisAlignment: MainAxisAlignment.end,
    children: [
      InkWell(
        onTap: () {
          log.i('parent object');
          provider.addNewEnglishParentForm();
        },
        child: const Icon(
          Icons.add,
          size: 35,
          color: Colors.grey,
        ),
      ),
    ],
  );

  Widget buildAddArabicButton(AnnualAuditReportProvider provider) => Row(
    mainAxisAlignment: MainAxisAlignment.end,
    children: [
      InkWell(
        onTap: () {
          provider.addNewArabicParentForm();
        },
        child: const Icon(
          Icons.add,
          size: 35,
          color: Colors.grey,
        ),
      ),
    ],
  );

  buildRemoveButtonForEnglishParentFormFields(int index, AnnualAuditReportProvider provider) => Padding(
    padding: const EdgeInsets.only(bottom: 10.0),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        InkWell(
          child: const Icon(
            Icons.remove_circle_outline,
            color: Colors.red,
            size: 30.0,
          ),
          onTap: () {
            provider.removeButtonForEnglishParentFormFields(index);
          },
        ),
      ],
    ),
  );

  buildRemoveArabicButton(int index, AnnualAuditReportProvider provider) => Padding(
    padding: const EdgeInsets.only(bottom: 10.0),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        InkWell(
          child: const Icon(
            Icons.remove_circle_outline,
            color: Colors.red,
            size: 30.0,
          ),
          onTap: () {
            provider.removeArabicFormParentFields(index);
          },
        ),
      ],
    ),
  );

  buildRemoveChildrenButton(int i, int j, AnnualAuditReportProvider provider) =>
      Padding(
        padding: const EdgeInsets.only(bottom: 10.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            InkWell(
              child: const Icon(
                Icons.remove_circle_outline,
                color: Colors.red,
                size: 30.0,
              ),
              onTap: () {
                provider.removeEnglishChildItem(i, j);
              },
            ),
          ],
        ),
      );

  buildRemoveArabicChildrenButton(int i, int j, AnnualAuditReportProvider provider) =>
      Padding(
        padding: const EdgeInsets.only(bottom: 10.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            InkWell(
              child: const Icon(
                Icons.remove_circle_outline,
                color: Colors.red,
                size: 30.0,
              ),
              onTap: () {
                provider.removeArabicChildItem(i, j);
              },
            ),
          ],
        ),
      );

  buildAddChildrenButtonForEnglishFormFields(int i, AnnualAuditReportProvider provider) => Padding(
    padding: const EdgeInsets.only(bottom: 10.0),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        InkWell(
          child: const Icon(
            Icons.add,
            color: Colors.green,
            size: 30.0,
          ),
          onTap: () {
            log.i('child object');
            provider.addNewFormForEnglishChildren(i);
          },
        ),
      ],
    ),
  );

  buildAddChildrenArabicButton(int i, AnnualAuditReportProvider provider) => Padding(
    padding: const EdgeInsets.only(bottom: 10.0),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        InkWell(
          child: const Icon(
            Icons.add,
            color: Colors.green,
            size: 30.0,
          ),
          onTap: () {
            provider.addArabicChildItem(i);
          },
        ),
      ],
    ),
  );

  void _saveFormDataAgenda(AnnualAuditReportProvider meetingProvider) async {
    final isValid = _formKey.currentState!.validate();
    if (isValid) {

      final committeeProvider = Provider.of<CommitteeProviderPage>(context, listen: false);
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      user = User.fromJson(json.decode(prefs.getString("user")!));
      List<Map<String, dynamic>> AnnualAuditReport = [];

      // Validate the dropdown selection
      committeeProvider.validateDropdown();
      if (committeeProvider.dropdownError != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: CustomText(text: committeeProvider.dropdownError!),
            backgroundColor: Colors.redAccent,
          ),
        );
        return; // Stop the form submission if there's an error
      }

      String errorMessage = '';

      for (int i = 0; i < meetingProvider.titleControllers.length; i++) {
        if (meetingProvider.titleControllers[i].text.isEmpty &&
            meetingProvider.arabicTitleControllers.isNotEmpty &&
            meetingProvider.arabicTitleControllers[i].text.isEmpty) {
          continue; // Skip empty fields
        }

        List<Map<String, dynamic>> details = [];
        if (meetingProvider.descriptionControllersList.isNotEmpty &&
            i < meetingProvider.descriptionControllersList.length) {
          for (int j = 0; j < meetingProvider.descriptionControllersList[i].length; j++) {

            details.add({
              "detail_en": meetingProvider.descriptionControllersList[i][j].text,
              if (meetingProvider.arabicDescriptionControllersList.isNotEmpty && i < meetingProvider.arabicDescriptionControllersList.length && j < meetingProvider.arabicDescriptionControllersList[i].length)
                "detail_ar": meetingProvider.arabicDescriptionControllersList[i][j].text,
            });

          }
        }

        AnnualAuditReport.add({
          "category_en": meetingProvider.titleControllers[i].text,
          if (meetingProvider.arabicTitleControllers.isNotEmpty && i < meetingProvider.arabicTitleControllers.length)
            "category_ar": meetingProvider.arabicTitleControllers[i].text,
          "details": details,
        });
      }



      // Prepare and submit the meeting event
      Map<String, dynamic> data = {
        "created_by": user.userId,
        "categories": AnnualAuditReport,
        "business_id": user.businessId,
        "committee_id": committeeProvider.committeeId
      };
      log.i(data);
      meetingProvider.setLoading(true);
      await meetingProvider.insertNewAnnualAuditReport(data);

      if (meetingProvider.isBack == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: CustomText(text: 'Insert done'),
            backgroundColor: Colors.greenAccent,
          ),
        );
        Future.delayed(const Duration(seconds: 5), () {
          Navigator.of(context)
              .pushReplacementNamed(CommitteesAnnualAuditReportListView.routeName);
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: CustomText(text: 'Insert failed'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }
}



class buildBackButton extends StatelessWidget {
  const buildBackButton({
    super.key,
    required this.annualAuditReportProvider,
  });

  final AnnualAuditReportProvider annualAuditReportProvider;

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: 25,
      backgroundColor:
      Colour().buttonBackGroundRedColor,
      child: IconButton(
        icon: CustomIcon(
          icon: Icons.arrow_back_outlined,
        ),
        onPressed: () {
          annualAuditReportProvider.clearAllControllers();
          Navigator.of(context).pushReplacementNamed(CommitteesAnnualAuditReportListView.routeName);
        },
      ),
    );
  }
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



class LanguageWidget extends StatelessWidget {
  const LanguageWidget({
    super.key,
    required this.enableEnglish,
    required this.enableArabicAndEnglish,
    required this.enableArabic,
  });

  final bool enableEnglish;
  final bool enableArabicAndEnglish;
  final bool enableArabic;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: enableEnglish == true ? Colour().buttonBackGroundMainColor : Colour().buttonBackGroundRedColor,
          ),
          onPressed: () {
            context.read<AnnualAuditReportProvider>().toggleEnableEnglish();
            },
          child: CustomText(text: "English Only", color: Colors.white,),
        ),
        SizedBox(width: 15.0),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: enableArabicAndEnglish == true ? Colour().buttonBackGroundMainColor : Colour().buttonBackGroundRedColor,
          ),
          onPressed: () {
            context.read<AnnualAuditReportProvider>().toggleEnableArabicAndEnglish();
          },
          child: CustomText(text: "Dual", color: Colors.white,),
        ),
        SizedBox(width: 15.0),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: enableArabic == true ? Colour().buttonBackGroundMainColor : Colour().buttonBackGroundRedColor,
          ),
          onPressed: () {
            context.read<AnnualAuditReportProvider>().toggleEnableArabic();
          },
          child: CustomText(text: "Arabic Only", color: Colors.white,),
        ),
      ],
    );
  }
}