import 'dart:convert';

import 'package:diligov_members/widgets/appBar.dart';
import 'package:diligov_members/widgets/check_and_display_file_name.dart';
import 'package:diligov_members/widgets/child_document_dialog.dart';
import 'package:diligov_members/widgets/custom_icon.dart';
import 'package:diligov_members/widgets/custom_message.dart';
import 'package:diligov_members/widgets/custome_text.dart';
import 'package:diligov_members/widgets/header_language_widget.dart';
import 'package:diligov_members/widgets/loading_sniper.dart';
import 'package:diligov_members/widgets/member_search_dialog.dart';
import 'package:diligov_members/widgets/parent_document_dialog.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:multi_select_flutter/chip_display/multi_select_chip_display.dart';
import 'package:multi_select_flutter/dialog/multi_select_dialog_field.dart';
import 'package:multi_select_flutter/util/multi_select_item.dart';
import 'package:open_file/open_file.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localization.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../colors.dart';
import '../models/member.dart';
import '../models/user.dart';
import '../providers/document_page_provider.dart';
import '../providers/file_upload_page_provider.dart';
import '../providers/meeting_page_provider.dart';
import '../providers/member_page_provider.dart';
import '../utility/pdf_api.dart';
import '../views/modules/board_views/board_meetings/board_meetings_list_view.dart';
import 'DateTimePickerWidget.dart';
import 'check_and_display_nested_file_name.dart';
import 'files_upload_widget.dart';

class BuildMeetingFormCard extends StatefulWidget {
  static const routeName = '/buildMeetingFormCard';

  const BuildMeetingFormCard({
    super.key,
  });

  @override
  State<BuildMeetingFormCard> createState() => _BuildMeetingFormCardState();
}

class _BuildMeetingFormCardState extends State<BuildMeetingFormCard> {
  final _formKey = GlobalKey<FormState>();
  var log = Logger();
  User user = User();

  List _membersListIds = [];
  List _membersChildListIds = [];

  List _arabicMembersListIds = [];
  List _arabicMembersChildListIds = [];

  // final ThemeData theme;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _membersListIds = [];
    _membersChildListIds = [];
    _arabicMembersListIds = [];
    _arabicMembersChildListIds = [];

    Future.microtask(() {
      Provider.of<MeetingPageProvider>(context, listen: false);
      final editMeetingPageProvider = Provider.of<MeetingPageProvider>(context, listen: false);
        editMeetingPageProvider.clearAllControllers();;
    });
    // Fetch the documents when the widget is first built
    Future.microtask(() => Provider.of<DocumentPageProvider>(context, listen: false).getListOfDocuments());
    Future.microtask(() => Provider.of<MemberPageProvider>(context, listen: false).getListOfMemberMenu());
  }

  Widget CombinedCollectionBoardCommitteeDataDropDownList() {
    return Container(
      width: 200,
      padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 15.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(10)),
        color: Colour().buttonBackGroundRedColor,
      ),
      child: Consumer<MeetingPageProvider>(
        builder: (context, combinedDataProvider, child) {
          if (combinedDataProvider.collectionBoardCommitteeData
                  ?.combinedCollectionBoardCommitteeData ==
              null) {
            combinedDataProvider.getListOfCombinedCollectionBoardAndCommittee();
            return buildLoadingSniper();
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              combinedDataProvider.collectionBoardCommitteeData!
                      .combinedCollectionBoardCommitteeData!.isEmpty
                  ? buildEmptyMessage(
                      AppLocalizations.of(context)!.no_data_to_show)
                  : DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        isExpanded: true,
                        isDense: true,
                        style: Theme.of(context).textTheme.titleLarge,
                        elevation: 2,
                        iconEnabledColor: Colors.white,
                        items: combinedDataProvider.collectionBoardCommitteeData
                            ?.combinedCollectionBoardCommitteeData
                            ?.map((item) {
                          return DropdownMenuItem<String>(
                            alignment: Alignment.center,
                            value:
                                '${item.type.toString()}-${item.id.toString()}',
                            child: Container(
                              height: double.infinity,
                              width: double.infinity,
                              decoration: BoxDecoration(
                                border:
                                    Border.all(width: 0.1, color: Colors.black),
                              ),
                              child: Center(
                                  child:
                                      CustomText(text: item.name.toString())),
                            ),
                          );
                        }).toList(),
                        onChanged: (selectedItem) {
                          combinedDataProvider
                              .setCombinedCollectionBoardCommittee(
                                  selectedItem!);
                        },
                        hint: CustomText(
                          text: combinedDataProvider.selectedCombined != null
                              ? combinedDataProvider.selectedCombined!
                              : 'Select an item please',
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
              if (combinedDataProvider.dropdownError != null)
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(
                    combinedDataProvider.dropdownError!,
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
        child: Consumer<MeetingPageProvider>(
          builder: (BuildContext context, provider, child) {
            final meetingProvider =  Provider.of<MeetingPageProvider>(context, listen: false);
            final theme = Theme.of(context);
            final enableArabic =
                context.watch<MeetingPageProvider>().enableArabic;
            final enableEnglish =
                context.watch<MeetingPageProvider>().enableEnglish;
            final enableArabicAndEnglish =
                context.watch<MeetingPageProvider>().enableArabicAndEnglish;

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
                            buildBackButton(meetingProvider: meetingProvider),
                            SizedBox(width: 7.0),
                            CombinedCollectionBoardCommitteeDataDropDownList()
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
                                  padding: EdgeInsets.all(10.0),
                                  child: CustomText(text: 'Meeting Details',fontSize: 18,fontWeight: FontWeight.bold,)
                              ),
                              Divider(height: 2,thickness: 2, color: Colors.red),
                              SizedBox(height: 10.0),
                              buildStepOneContent(context, provider, theme),
                              SizedBox(height: 40.0),
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
                                          child: CustomText(text: 'Agenda Details',fontSize: 18,fontWeight: FontWeight.bold,)
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

  Widget buildEnglishSideFormParent(MeetingPageProvider provider) {
    return Column(
      children: [

        buildAddButtonForEnglishFormParent(provider),
        SizedBox(height: 10),
        for (int i = 0; i < provider.titleControllers.length;i++)
          buildDynamicFormForEnglishFormParent(i, provider),
      ],
    );
  }

  Widget buildFormRowFieldsForEnglishFormParent(int index, MeetingPageProvider provider) {
    final enableArabicAndEnglish = context.watch<MeetingPageProvider>().enableArabicAndEnglish;
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
            height: 150,
            child: Column(
              children: [
                Expanded(
                    child: buildCustomTextFormField(
                  controller: provider.titleControllers[index],
                  hint: 'Title',
                  validatorMessage: 'Please enter title',
                ),
                ),
                CheckAndDisplayFileName(
                  list: provider.fileName,
                  index: index,
                  subIndex: 0,
                  customWidgetBuilder: (fileName) => TextButton(
                    onPressed: () async {
                      try {
                        if (await PDFApi.requestPermission()) {
                          if (provider.filePath.isNotEmpty) {
                            print('open file ${fileName}');
                            final result = await OpenFile.open(provider.filePath[index][0]);
                            print("Open file result: ${result}");
                          }
                        } else {
                          print("Lacking permissions to access the file");
                        }
                      } catch (e) {
                        print("Error opening PDF: $e");
                      }
                    },
                    child: Row(
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        Flexible(
                            flex: 5,child: CustomText(text:fileName, softWrap: true,overflow: TextOverflow.ellipsis,)),
                        Flexible(
                            flex: 1,child: CustomIcon(icon: Icons.file_open)),
                        Flexible(
                            flex: 1,child: IconButton(
                          onPressed: (){
                            provider.removeFiles(index);
                          },
                          icon: CustomIcon(icon: Icons.delete_forever_rounded, color: Colors.red,),
                        )),
                      ],
                    ),
                  ),
                ),

                Row(
                  mainAxisAlignment:
                  MainAxisAlignment.spaceBetween,
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    Flexible(
                      flex: 1,
                      child: TextButton(
                        style: ButtonStyle(
                          backgroundColor:
                          MaterialStateProperty.all(
                              Colors.red),
                        ),
                        onPressed: () async {
                          openDocumentOptionBoxDialog(
                              context, index);
                        },
                        child: CustomText(
                          text: 'Add file',
                          color: Colors.white,
                          softWrap: true,overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                    Flexible(
                      flex: 1,
                      child: TextButton(
                        onPressed: () {
                            final memberProvider =    Provider.of<MemberPageProvider>(context,listen: false);
                            openMemberSearchBoxDialog(context, memberProvider);
                        },
                        child: Row(
                          children: [
                            enableArabicAndEnglish == true ? SizedBox.shrink() : Expanded(child: CustomText(text: 'Signature', softWrap: true,overflow: TextOverflow.ellipsis,)),
                            Expanded(child:CustomIcon(icon: Icons.edit)),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 6),
        Expanded(
            child: SizedBox(
          height: 100,
          child: buildCustomTextFormField(
            controller: provider.descriptionControllers[index],
            hint: 'Description',
            validatorMessage: 'Please enter description',
          ),
        )),
        const SizedBox(width: 6),
        Expanded(
            child: SizedBox(
          height: 100,
          child: buildCustomTextFormField(
            controller: provider.timeControllers[index],
            hint: 'Time',
            validatorMessage: 'Please enter time',
          ),
        )),
        const SizedBox(width: 6),
        Expanded(
            child: SizedBox(
          height: 100,
          child: buildCustomTextFormField(
            controller: provider.userControllers[index],
            hint: 'Presenter',
            validatorMessage: 'Please enter presenter',
          ),
        )),
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

  Widget buildFormArabicRow(int index, MeetingPageProvider provider) {
    final enableArabicAndEnglish = context.watch<MeetingPageProvider>().enableArabicAndEnglish;
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
              height: 150,
              child: Column(
                children: [
                  Expanded(
                      child: buildCustomTextFormField(
                    controller: provider.arabicTitleControllers[index],
                    hint: 'Title',
                    validatorMessage: 'Please enter title',
                  ),
                  ),
                  CheckAndDisplayFileName(
                    list: provider.fileName,
                    index: index,
                    subIndex: 0,
                    customWidgetBuilder: (fileName) => TextButton(
                      onPressed: () async {
                        try {
                          if (await PDFApi.requestPermission()) {
                            if (provider.filePath.isNotEmpty) {
                              print('open file ${fileName}');
                              final result = await OpenFile.open(provider.filePath[index][0]);
                              print("Open file result: ${result}");
                            }
                          } else {
                            print("Lacking permissions to access the file");
                          }
                        } catch (e) {
                          print("Error opening PDF: $e");
                        }
                      },
                      child: Row(
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          Flexible(
                              flex: 1,
                              child: IconButton(
                                onPressed: (){
                                  provider.removeFiles(index);
                                },
                                icon: CustomIcon(icon: Icons.delete_forever_rounded, color: Colors.red,),
                              )
                          ),
                          Flexible(
                              flex: 5,
                              child: CustomText(text:fileName, softWrap: true,overflow: TextOverflow.ellipsis,)),
                          Flexible(flex: 1,child: CustomIcon(icon: Icons.file_open)),

                        ],
                      ),
                    ),
                  ),

                  Row(
                    mainAxisAlignment:
                    MainAxisAlignment.spaceBetween,
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      Flexible(
                        flex: 1,
                        child: TextButton(
                          onPressed: () {
                            final memberProvider = Provider.of<MemberPageProvider>(context,listen: false);
                            openMemberSearchBoxDialog(context, memberProvider);
                          },
                          child: Row(
                            children: [
                              Expanded(child:CustomIcon(icon: Icons.edit)),
                              enableArabicAndEnglish == true ? SizedBox.shrink() : Expanded(child: CustomText(text: 'Signature', softWrap: true,overflow: TextOverflow.ellipsis,)),
                            ],
                          ),
                        ),
                      ),
                      Flexible(
                        flex: 1,
                        child: TextButton(
                          style: ButtonStyle(
                            backgroundColor:
                            MaterialStateProperty.all(
                                Colors.red),
                          ),
                          onPressed: () async {
                            openDocumentOptionBoxDialog(
                                context, index);
                          },
                          child: CustomText(
                            text: 'Add file',
                            color: Colors.white
                              , softWrap: true,overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),

                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 6),
          Expanded(
              child: SizedBox(
            height: 100,
            child: buildCustomTextFormField(
              controller: provider.arabicDescriptionControllers[index],
              hint: 'Description',
              validatorMessage: 'Please enter description',
            ),
          )),
          const SizedBox(width: 6),
          Expanded(
              child: SizedBox(
            height: 100,
            child: buildCustomTextFormField(
              controller: provider.arabicTimeControllers[index],
              hint: 'Time',
              validatorMessage: 'Please enter time',
            ),
          )),
          const SizedBox(width: 6),
          Expanded(
              child: SizedBox(
            height: 100,
            child: buildCustomTextFormField(
              controller: provider.arabicUserControllers[index],
              hint: 'Presenter',
              validatorMessage: 'Please enter presenter',
            ),
          )),
          const SizedBox(height: 5),
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
    final provider = Provider.of<MeetingPageProvider>(context, listen: false);
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
                  onPressed: provider.onStepCancel,
                  child: CustomText(
                    text: 'Back',
                    color: Colour().mainWhiteTextColor,
                    fontWeight: FontWeight.bold,
                  ),
                )
            ],
          );
  }

  Widget buildDynamicFormArabicItem(int index, MeetingPageProvider provider) {
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

  Widget buildArabicReOrderList(int i, MeetingPageProvider provider) {
    final enableArabicAndEnglish = context.watch<MeetingPageProvider>().enableArabicAndEnglish;
    bool hasItems = provider.arabicChildItems.isNotEmpty &&
        provider.arabicChildItems[i].isNotEmpty;
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Container(
        color: Colors.grey[200],
        // padding: EdgeInsets.only(right: 3),
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
                              Container(
                                padding: const EdgeInsets.all(3.0),
                                color: Colors.white10,
                                child: CustomText(
                                  text: '${i + 1}.${j + 1}',
                                  fontWeight: FontWeight.bold,
                                  fontSize: 20,
                                ),
                              ),
                              SizedBox(width: 3),
                              Flexible(
                                child: SizedBox(
                                  height: 150,
                                  child: Column(
                                    children: [
                                      Expanded(
                                        child: buildCustomTextFormField(
                                          controller: provider
                                              .arabicTitleControllersList[i][j],
                                          hint: 'Title',
                                          validatorMessage:
                                              'Please enter title',
                                        ),
                                      ),

                                      NestedFileNameWidget(
                                        list: provider.fileNameChild,
                                        index: i,
                                        subIndex: j,
                                        subSubIndex: 0,
                                        customWidgetBuilder: (fileName) => TextButton(
                                          onPressed: () async {
                                            try {
                                              if (await PDFApi.requestPermission()) {
                                                if (provider.filePathChild.isNotEmpty) {

                                                  final result = await OpenFile.open(provider.filePathChild[i][j][0]);
                                                  print("Open file result: ${result}");
                                                }
                                              } else {
                                                print("Lacking permissions to access the file");
                                              }
                                            } catch (e) {
                                              print("Error opening PDF: $e");
                                            }
                                          },
                                          child: Row(
                                            mainAxisSize: MainAxisSize.max,
                                            children: [
                                          Flexible(
                                          flex: 6,
                                              child: CustomText(text:fileName, softWrap: true,overflow: TextOverflow.ellipsis,)),
                                              Flexible(
                                                  flex: 1,child: CustomIcon(icon: Icons.file_open)),
                                              Flexible(
                                                  flex: 2,
                                                  child: IconButton(
                                                    onPressed: (){
                                                      provider.removeFilesChild(i,j);
                                                    },
                                                    icon: CustomIcon(icon: Icons.delete_forever_rounded, color: Colors.red,),
                                                  )),
                                            ],
                                          ),
                                        ),
                                      ),

                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Flexible(
                                            flex: 1,
                                            child:
                                            TextButton(
                                              onPressed:
                                                  () {
                                                    final memberProvider = Provider.of<MemberPageProvider>(context, listen: false);
                                                    openMemberChildSearchBoxDialog(context, memberProvider);
                                              },
                                              child: Row(
                                                children: [
                                                  Expanded(child:CustomIcon(icon: Icons.edit)),
                                                  Expanded(child: CustomText(text: 'Signature', softWrap: true,overflow: TextOverflow.ellipsis,)),
                                                ],
                                              ),

                                            ),
                                          ),
                                          Flexible(
                                            flex: 1,
                                            child: TextButton(
                                              style: ButtonStyle(
                                                backgroundColor:
                                                    MaterialStateProperty.all(
                                                        Colors.red),
                                              ),
                                              onPressed: () async {
                                                final DocumentPageProvider
                                                    documen = Provider.of<
                                                            DocumentPageProvider>(
                                                        context,
                                                        listen: false);
                                                // Ensure the selectedChildDocumentId has the main list and sublist to the required depth
                                                if (documen
                                                        .selectedChildDocumentId
                                                        .length <=
                                                    i) {
                                                  documen.selectedChildDocumentId
                                                      .addAll(List.generate(
                                                          i -
                                                              documen
                                                                  .selectedChildDocumentId
                                                                  .length +
                                                              1,
                                                          (_) => null));
                                                }
                                                if (documen
                                                        .selectedChildDocumentId
                                                        .length <=
                                                    j) {
                                                  documen.selectedChildDocumentId
                                                      .addAll(List.filled(
                                                          j -
                                                              documen
                                                                  .selectedChildDocumentId
                                                                  .length +
                                                              1,
                                                          null));
                                                }
                                                openArabicDocumentChildrenOptionListForParentBoxDialog(
                                                    context, i, j);
                                              },
                                              child: CustomText(text: "Add file", color: Colors.white, softWrap: true,overflow: TextOverflow.ellipsis,),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              SizedBox(width: 6),
                              Expanded(
                                child: SizedBox(
                                  height: 100,
                                  child: buildCustomTextFormField(
                                    controller: provider
                                        .arabicDescriptionControllersList[i][j],
                                    hint: 'Description',
                                    validatorMessage:
                                        'Please enter description',
                                  ),
                                ),
                              ),
                              SizedBox(width: 6),
                              Expanded(
                                child: SizedBox(
                                  height: 100,
                                  child: buildCustomTextFormField(
                                    controller: provider
                                        .arabicTimeControllersList[i][j],
                                    hint: 'Time',
                                    validatorMessage: 'Please enter time',
                                  ),
                                ),
                              ),
                              SizedBox(width: 6),
                              Expanded(
                                child: SizedBox(
                                  height: 100,
                                  child: buildCustomTextFormField(
                                    controller: provider
                                        .arabicUserControllersList[i][j],
                                    hint: 'Presenter',
                                    validatorMessage: 'Please enter presenter',
                                  ),
                                ),
                              ),
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

  Widget buildDynamicFormForEnglishFormParent(int index, MeetingPageProvider provider) {
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



  Widget buildReOrderListChildrenRowFieldsForEnglishFormParent(int i, MeetingPageProvider provider) {
    bool hasItems = provider.childItems.isNotEmpty && provider.childItems[0].isNotEmpty;
    int? newIndex = i;
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
                          Container(
                            padding: const EdgeInsets.all(5.0),
                            color: Colors.white10,
                            child: CustomText(
                              text: '${newIndex + 1}.${j}',
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                            ),
                          ),
                          SizedBox(width: 6),
                          Flexible(
                            child: SizedBox(
                              height: 150,
                              child: Column(
                                children: [
                                  Expanded(
                                    child: buildCustomTextFormField(
                                      controller: provider.titleControllersList[i][j],
                                      hint: 'Title',
                                      validatorMessage: 'Please enter title',
                                    ),
                                  ),
                                  NestedFileNameWidget(
                                    list: provider.fileNameChild,
                                    index: i,
                                    subIndex: j,
                                    subSubIndex: 0,
                                    customWidgetBuilder: (fileName) => TextButton(
                                      onPressed: () async {
                                        try {
                                          if (await PDFApi.requestPermission()) {
                                            if (provider.filePathChild.isNotEmpty) {

                                              final result = await OpenFile.open(provider.filePathChild[i][j][0]);
                                              print("Open file result: ${result}");
                                            }
                                          } else {
                                            print("Lacking permissions to access the file");
                                          }
                                        } catch (e) {
                                          print("Error opening PDF: $e");
                                        }
                                      },
                                      child: Row(
                                        mainAxisSize: MainAxisSize.max,
                                        children: [
                                          Flexible(
                                              flex: 6,
                                              child: CustomText(text:fileName, softWrap: true,overflow: TextOverflow.ellipsis,)),
                                          Flexible(
                                              flex: 1,child: CustomIcon(icon: Icons.file_open)),
                                          Flexible(
                                              flex: 2,
                                              child: IconButton(
                                                onPressed: (){
                                                  provider.removeFilesChild(i,j);
                                                },
                                                icon: CustomIcon(icon: Icons.delete_forever_rounded, color: Colors.red,),
                                              )),
                                        ],
                                      ),
                                    ),
                                  ),

                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Flexible(
                                        flex: 1,
                                        child: TextButton(
                                          style: ButtonStyle(
                                            backgroundColor:
                                            MaterialStateProperty.all(
                                                Colors.red),
                                          ),
                                          onPressed: () async {
                                            final DocumentPageProvider
                                            documen = Provider.of<
                                                DocumentPageProvider>(
                                                context,
                                                listen: false);
                                            // Ensure the selectedChildDocumentId has the main list and sublist to the required depth
                                            if (documen
                                                .selectedChildDocumentId
                                                .length <=
                                                i) {
                                              documen.selectedChildDocumentId
                                                  .addAll(List.generate(
                                                  i -
                                                      documen
                                                          .selectedChildDocumentId
                                                          .length +
                                                      1,
                                                      (_) => null));
                                            }
                                            if (documen
                                                .selectedChildDocumentId
                                                .length <=
                                                j) {
                                              documen.selectedChildDocumentId
                                                  .addAll(List.filled(
                                                  j -
                                                      documen
                                                          .selectedChildDocumentId
                                                          .length +
                                                      1,
                                                  null));
                                            }
                                            openArabicDocumentChildrenOptionListForParentBoxDialog(
                                                context, i, j);
                                          },
                                          child: CustomText(text: "Add file", color: Colors.white, softWrap: true,overflow: TextOverflow.ellipsis,),
                                        ),
                                      ),
                                      Flexible(
                                        flex: 1,
                                        child:
                                        TextButton(
                                          onPressed:
                                              () {
                                                final memberProvider = Provider.of<MemberPageProvider>(context, listen: false);
                                                openMemberChildSearchBoxDialog(context, memberProvider);
                                          },
                                          child: Row(
                                            children: [
                                              Expanded(child: CustomText(text: 'Signature', softWrap: true,overflow: TextOverflow.ellipsis,)),
                                              Expanded(child:CustomIcon(icon: Icons.edit)),

                                            ],
                                          ),

                                        ),
                                      ),

                                    ],
                                  ),

                                ],
                              ),
                            ),
                          ),
                          SizedBox(width: 6),
                          Expanded(
                            child: SizedBox(
                              height: 100,
                              child: buildCustomTextFormField(
                                controller:
                                    provider.descriptionControllersList[i][j],
                                hint: 'Description',
                                validatorMessage: 'Please enter description',
                              ),
                            ),
                          ),
                          SizedBox(width: 6),
                          Expanded(
                            child: SizedBox(
                              height: 100,
                              child: buildCustomTextFormField(
                                controller: provider.timeControllersList[i][j],
                                hint: 'Time',
                                validatorMessage: 'Please enter time',
                              ),
                            ),
                          ),
                          SizedBox(width: 6),
                          Expanded(
                            child: SizedBox(
                              height: 100,
                              child: buildCustomTextFormField(
                                controller: provider.userControllersList[i][j],
                                hint: 'Presenter',
                                validatorMessage: 'Please enter presenter',
                              ),
                            ),
                          ),
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

  Widget buildStepOneContent(BuildContext context, MeetingPageProvider provider, ThemeData theme) {
    return _buildMeetingFormCard(
      context: context,
      theme: theme,
      provider: provider,
    );
  }

  Widget buildStepTwoContent(MeetingPageProvider provider) {
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

  Widget buildArabicStepTwoContent(MeetingPageProvider provider) {
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

  Future<void> openMemberSearchBoxDialog(BuildContext context, MemberPageProvider provider) {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return MemberSearchDialog(
          fetchMembersFuture: provider.getListOfMemberMenu(),
          dialogTitle: 'Select Members',
          onConfirm: (selectedMembers) {
            provider.setSelectMemberAudioNote(selectedMembers);
            _membersListIds = provider
                .selectedMembersAudioNoteList
                .map((e) => e.memberId)
                .toList();
            provider.setSelectMemberAudioNoteId(
                _membersListIds);
            print(_membersListIds);
          },
          onCancel: () {
            // Handle cancel action
          },
        );
      },
    );
  }

  Future<void> openMemberChildSearchBoxDialog(BuildContext context, MemberPageProvider provider) {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return MemberSearchDialog(
          fetchMembersFuture: provider.getListOfMemberMenu(),
          dialogTitle: 'Select Members',
          onConfirm: (selectedMembers) {
            provider.setSelectMemberNote(selectedMembers);
            _membersChildListIds = provider
                .selectedMembersNoteList
                .map((e) => e.memberId)
                .toList();
            provider.setSelectedMembersNoteId(
                _membersChildListIds);
            print(_membersChildListIds);
          },
          onCancel: () {
            // Handle cancel action
          },
        );
      },
    );
  }


  Future<void> openDocumentOptionBoxDialog(BuildContext context, int i) {
    final MeetingPageProvider meetingPageProvider =
        Provider.of<MeetingPageProvider>(context, listen: false);
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return Consumer<DocumentPageProvider>(
          builder: (context, provider, child) {
            return AlertDialog(
              backgroundColor: Colors.grey[100],
              insetPadding: const EdgeInsets.symmetric(horizontal: 10),
              title: CustomText(
                text: 'Upload Document',
                color: Colors.black,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
              content: SizedBox(
                width: 900,
                height: 400,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Column(
                          children: [
                            ChangeNotifierProvider(
                              create: (_) => FileUploadPageProvider(),
                              child: Builder(builder: (context) {
                                return FilesUploadWidget(
                                  labelName: 'Choose File',
                                  allowedExtensions: ['pdf'],
                                  onFilePicked:
                                      (pickedFileName, pickedFileContent , filePaths) {
                                       meetingPageProvider.setFileAtIndex(i,pickedFileName,pickedFileContent, filePaths);
                                  },
                                  provider: Provider.of<FileUploadPageProvider>(context,listen: false),
                                );
                              }),
                            ),
                          ],
                        ),
                        Column(
                          children: [
                            ChangeNotifierProvider(
                              create: (_) => FileUploadPageProvider(),
                              child: Builder(builder: (context) {
                                return FilesUploadWidget(
                                  labelName: 'Choose Local File',
                                  allowedExtensions: ['pdf'],
                                  onFilePicked: (pickedFileName, pickedFileContent, filePaths) {
                                    meetingPageProvider.setFileTwoAtIndex(i,pickedFileName,pickedFileContent, filePaths);
                                  },
                                  provider: Provider.of<FileUploadPageProvider>(context,listen: false),
                                );
                              }),
                            ),
                          ],
                        ),
                      ],
                    ),
                    SizedBox(height: 30),
                    CustomText(
                      text: 'Document Type',
                      color: Colors.black,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                    SizedBox(
                      width: 400,
                      child: TextButton(
                        style: ButtonStyle(
                          shape: MaterialStateProperty.all(
                            RoundedRectangleBorder(
                              borderRadius: BorderRadius.zero,
                            ),
                          ),
                          padding: MaterialStateProperty.all(
                            EdgeInsets.symmetric(
                              vertical: 10.0,
                              horizontal: 20,
                            ),
                          ),
                          backgroundColor:
                              MaterialStateProperty.all(Colors.white),
                        ),
                        onPressed: () async {
                          final provider = Provider.of<DocumentPageProvider>(context, listen: false);
                          openParentDocumentBoxDialog( context,  i,  provider);
                        },
                        child: provider.selectedDocumentId != null
                            ? CustomText(
                                text:
                                    'Selected Document: ${provider.getSelectedDocumentName(i)}',
                                color: Colors.red,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              )
                            : CustomText(
                                text: 'Upload File',
                                color: Colors.red,
                                fontWeight: FontWeight.bold,
                                fontSize: 20,
                              ),
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text('Save'),
                ),

                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text('Close'),
                ),

              ],
            );
          },
        );
      },
    );
  }

  Future<void> openDocumentChildBoxDialog(BuildContext context, int i, int j) {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return ChildDocumentChildDialog(i: i, j: j);
      },
    );
  }

  Future<void> openParentDocumentBoxDialog(BuildContext context, int i, DocumentPageProvider provider) {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return ParentDocumentDialog(index: i, provider: provider);
      },
    );
  }

  //arabic section
  Future<void> openArabicMemberSearchBoxDialog(BuildContext context) {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return Consumer<MemberPageProvider>(
          builder: (context, provider, child) {
            if (provider.dataOfMembers?.members == null) {
              provider.getListOfMemberMenu();
              return buildLoadingSniper();
            }

            return provider.dataOfMembers!.members!.isEmpty
                ? buildEmptyMessage(
                    AppLocalizations.of(context)!.no_data_to_show)
                : AlertDialog(
                    backgroundColor: Colors.white,
                    // insetPadding: const EdgeInsets.symmetric(horizontal: 50),
                    title: CustomText(
                        text:
                            'SIGNATURE REQUEST DELOITTEE AUDIT COMMITTEE PRACTICE.PDF',
                        color: Colors.red,
                        fontSize: 20,
                        fontWeight: FontWeight.bold),
                    content: SizedBox(
                      width: 600,
                      height: 150,
                      child: Form(
                        child: SingleChildScrollView(
                          scrollDirection: Axis.vertical,
                          child: provider.loading
                              ? CircularProgressIndicator() // Show loading indicator while fetching data
                              : MultiSelectDialogField<dynamic>(
                                  decoration: BoxDecoration(
                                      border:
                                          Border.all(color: Colors.blueAccent)),
                                  confirmText: const Text(
                                    'add Members',
                                    style: TextStyle(
                                        color: Colors.red,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  cancelText: const Text(
                                    'cancel',
                                    style: TextStyle(
                                        color: Colors.red,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  separateSelectedItems: true,
                                  buttonIcon: const Icon(
                                      Icons.keyboard_arrow_down,
                                      size: 20,
                                      color: Colors.black),
                                  title: CustomText(text: 'Members List'),
                                  buttonText: Text(
                                      'You Could Select Multiple Members',
                                      style: TextStyle(
                                          color: Colors.black,
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold)),
                                  items: provider.dataOfMembers!.members!
                                      .map((member) => MultiSelectItem<Member>(
                                            member,
                                            '${member.memberFirstName!} ${member.position!.positionName!}',
                                          ))
                                      .toList(),
                                  searchable: true,
                                  validator: (values) {
                                    if (values == null || values.isEmpty) {
                                      return "Required";
                                    }
                                    List members = values
                                        .map((member) => member['id'])
                                        .toList();
                                    if (members.contains("member_first_name")) {
                                      return "Member are weird!";
                                    }
                                    return null;
                                  },
                                  onConfirm: (values) {
                                    provider.setSelectMemberAudioNote(values);
                                    _arabicMembersListIds = provider
                                        .selectedMembersAudioNoteList
                                        .map((e) => e.memberId)
                                        .toList();
                                    provider.setSelectMemberAudioNoteId(
                                        _arabicMembersListIds);
                                    print(_arabicMembersListIds);
                                  },
                                  chipDisplay: MultiSelectChipDisplay(
                                    onTap: (item) {
                                      provider
                                          .removeSelectedMembersAudioNote(item);
                                    },
                                  ),
                                ),
                        ),
                      ),
                    ),
                    actions: [
                      // Your actions here, for example, buttons that use model methods
                      TextButton(
                        style: ButtonStyle(
                            shape: MaterialStateProperty.all(
                                RoundedRectangleBorder(
                                    borderRadius: BorderRadius.zero)),
                            padding: MaterialStateProperty.all(
                                EdgeInsets.symmetric(
                                    vertical: 10.0, horizontal: 20)),
                            backgroundColor:
                                MaterialStateProperty.all(Colors.white)),
                        onPressed: () async {
                          Navigator.of(context).pop();
                        },
                        child: CustomText(
                            text: 'Cancel',
                            color: Colors.red,
                            fontWeight: FontWeight.bold,
                            fontSize: 20),
                      ),
                      TextButton(
                        style: ButtonStyle(
                            shape: MaterialStateProperty.all(
                                RoundedRectangleBorder(
                                    borderRadius: BorderRadius.zero)),
                            padding: MaterialStateProperty.all(
                                EdgeInsets.symmetric(
                                    vertical: 10.0, horizontal: 20)),
                            backgroundColor:
                                MaterialStateProperty.all(Colors.white)),
                        onPressed: () async {},
                        child: CustomText(
                            text: 'Confirm',
                            color: Colors.red,
                            fontWeight: FontWeight.bold,
                            fontSize: 20),
                      ),
                    ],
                  );
          },
        );
      },
    );
  }

  Future<void> openArabicMemberChildSearchBoxDialog(BuildContext context) {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return Consumer<MemberPageProvider>(
          builder: (context, provider, child) {
            if (provider.dataOfMembers?.members == null) {
              provider.getListOfMemberMenu();
              return buildLoadingSniper();
            }

            return provider.dataOfMembers!.members!.isEmpty
                ? buildEmptyMessage(
                    AppLocalizations.of(context)!.no_data_to_show)
                : AlertDialog(
                    backgroundColor: Colors.white,
                    // insetPadding: const EdgeInsets.symmetric(horizontal: 50),
                    title: CustomText(
                        text:
                            'SIGNATURE REQUEST DELOITTEE AUDIT COMMITTEE PRACTICE.PDF',
                        color: Colors.red,
                        fontSize: 20,
                        fontWeight: FontWeight.bold),
                    content: SizedBox(
                      width: 600,
                      height: 150,
                      child: Form(
                        child: SingleChildScrollView(
                          scrollDirection: Axis.vertical,
                          child: provider.loading
                              ? CircularProgressIndicator() // Show loading indicator while fetching data
                              : MultiSelectDialogField<dynamic>(
                                  decoration: BoxDecoration(
                                      border:
                                          Border.all(color: Colors.blueAccent)),
                                  confirmText: const Text(
                                    'add Members',
                                    style: TextStyle(
                                        color: Colors.red,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  cancelText: const Text(
                                    'cancel',
                                    style: TextStyle(
                                        color: Colors.red,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  separateSelectedItems: true,
                                  buttonIcon: const Icon(
                                      Icons.keyboard_arrow_down,
                                      size: 20,
                                      color: Colors.black),
                                  title: CustomText(text: 'Members List'),
                                  buttonText: Text(
                                      'You Could Select Multiple Members',
                                      style: TextStyle(
                                          color: Colors.black,
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold)),
                                  items: provider.dataOfMembers!.members!
                                      .map((member) => MultiSelectItem<Member>(
                                            member,
                                            '${member.memberFirstName!} ${member.position!.positionName!}',
                                          ))
                                      .toList(),
                                  searchable: true,
                                  validator: (values) {
                                    if (values == null || values.isEmpty) {
                                      return "Required";
                                    }
                                    List members = values
                                        .map((member) => member['id'])
                                        .toList();
                                    if (members.contains("member_first_name")) {
                                      return "Member are weird!";
                                    }
                                    return null;
                                  },
                                  onConfirm: (values) {
                                    provider.setSelectMemberNote(values);
                                    _arabicMembersChildListIds = provider
                                        .selectedMembersNoteList
                                        .map((e) => e.memberId)
                                        .toList();
                                    provider.setSelectedMembersNoteId(
                                        _arabicMembersChildListIds);
                                    print(_arabicMembersChildListIds);
                                  },
                                  chipDisplay: MultiSelectChipDisplay(
                                    onTap: (item) {
                                      provider.removeSelectedMembersNote(item);
                                    },
                                  ),
                                ),
                        ),
                      ),
                    ),
                    actions: [
                      // Your actions here, for example, buttons that use model methods
                      TextButton(
                        style: ButtonStyle(
                            shape: MaterialStateProperty.all(
                                RoundedRectangleBorder(
                                    borderRadius: BorderRadius.zero)),
                            padding: MaterialStateProperty.all(
                                EdgeInsets.symmetric(
                                    vertical: 10.0, horizontal: 20)),
                            backgroundColor:
                                MaterialStateProperty.all(Colors.white)),
                        onPressed: () async {
                          Navigator.of(context).pop();
                        },
                        child: CustomText(
                            text: 'Cancel',
                            color: Colors.red,
                            fontWeight: FontWeight.bold,
                            fontSize: 20),
                      ),
                      TextButton(
                        style: ButtonStyle(
                            shape: MaterialStateProperty.all(
                                RoundedRectangleBorder(
                                    borderRadius: BorderRadius.zero)),
                            padding: MaterialStateProperty.all(
                                EdgeInsets.symmetric(
                                    vertical: 10.0, horizontal: 20)),
                            backgroundColor:
                                MaterialStateProperty.all(Colors.white)),
                        onPressed: () async {
                          Navigator.of(context).pop();
                        },
                        child: CustomText(
                            text: 'Confirm',
                            color: Colors.red,
                            fontWeight: FontWeight.bold,
                            fontSize: 20),
                      ),
                    ],
                  );
          },
        );
      },
    );
  }

  Future<void> openArabicDocumentForParentBoxDialog(BuildContext context, int i) {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return Consumer<DocumentPageProvider>(
          builder: (context, provider, child) {
            // Fetch documents if not already loaded
            if (provider.documentData?.documents == null) {
              provider.getListOfDocuments();
              return Center(child: CircularProgressIndicator());
            }

            // Show empty state if no documents are available
            if (provider.documentData!.documents!.isEmpty) {
              return Center(child: Text('No data to show'));
            }

            // Ensure selectedDocumentId list has enough elements
            if (i >= provider.selectedArabicDocumentId!.length) {
              provider.selectedArabicDocumentId!.addAll(List.filled(
                  i - provider.selectedArabicDocumentId!.length + 1, null));
            }

            // Document selection dialog
            return AlertDialog(
              backgroundColor: Colors.white,
              title: Column(
                children: [
                  CustomText(
                    text: 'Document Type',
                    color: Colors.black,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                  SizedBox(height: 5),
                  provider.selectedArabicDocumentId?[i] != null
                      ? CustomText(
                          text:
                              'Selected Document: ${provider.getSelectedArabicDocumentName(i)}',
                          color: Colors.red,
                          fontSize: 20,
                        )
                      : Container(),
                ],
              ),
              content: SizedBox(
                width: 600,
                child: SingleChildScrollView(
                  scrollDirection: Axis.vertical,
                  child: DataTable(
                    columns: [
                      DataColumn(label: Text('Document Name')),
                      DataColumn(label: Text('Document Category')),
                      DataColumn(label: Text('Select')),
                    ],
                    rows: provider.documentData!.documents!
                        .map(
                          (document) => DataRow(
                            selected: document.documentId ==
                                provider.selectedArabicDocumentId?[i],
                            onSelectChanged: (bool? selected) {
                              if (selected != null) {
                                provider.selectArabicDocument(
                                    i, document.documentId!);
                              }
                            },
                            cells: [
                              DataCell(Text(document.documentName ?? '')),
                              DataCell(Text(document.documentCategory ?? '')),
                              DataCell(
                                Radio<int>(
                                  value: document.documentId!,
                                  groupValue:
                                      provider.selectedArabicDocumentId![i],
                                  onChanged: (int? value) {
                                    provider.selectArabicDocument(i, value);
                                  },
                                ),
                              ),
                            ],
                          ),
                        )
                        .toList(),
                  ),
                ),
              ),
              actions: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text('Selected Category'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> openArabicDocumentOptionListForParentBoxDialog(BuildContext context, int i) {
    final MeetingPageProvider meetingPageProvider =
        Provider.of<MeetingPageProvider>(context, listen: false);
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return Consumer<DocumentPageProvider>(
          builder: (context, provider, child) {
            return AlertDialog(
              backgroundColor: Colors.grey[100],
              insetPadding: const EdgeInsets.symmetric(horizontal: 10),
              title: CustomText(
                  text: 'Upload Document',
                  color: Colors.black,
                  fontSize: 20,
                  fontWeight: FontWeight.bold),
              content: SizedBox(
                width: 1000,
                height: 500,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Column(
                          children: [
                            ChangeNotifierProvider(
                              create: (_) => FileUploadPageProvider(),
                              child: Builder(builder: (context) {
                                return FilesUploadWidget(
                                  labelName: 'Choose File',
                                  allowedExtensions: ['pdf'],
                                  onFilePicked: (pickedFileName, pickedFileContent, filePaths) {
                                    meetingPageProvider.setFileAtIndex(i,pickedFileName,pickedFileContent, filePaths);
                                  },
                                  provider: Provider.of<FileUploadPageProvider>(
                                      context,
                                      listen: false),
                                );
                              }),
                            ),
                          ],
                        ),

                        // SizedBox(width: 10.0,),
                        Column(
                          children: [
                            ChangeNotifierProvider(
                              create: (_) => FileUploadPageProvider(),
                              child: Builder(builder: (context) {
                                return FilesUploadWidget(
                                  labelName: 'Choose Local File',
                                  allowedExtensions: ['pdf'],
                                  onFilePicked:(pickedFileName, pickedFileContent, filePaths) {
                                    meetingPageProvider.setFileTwoAtIndex(i,pickedFileName,pickedFileContent, filePaths);
                                  },
                                  provider: Provider.of<FileUploadPageProvider>(
                                      context,
                                      listen: false),
                                );
                              }),
                            ),
                          ],
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 30,
                    ),
                    CustomText(
                        text: 'Document Type',
                        color: Colors.black,
                        fontSize: 20,
                        fontWeight: FontWeight.bold),
                    SizedBox(
                      width: 400,
                      child: TextButton(
                        style: ButtonStyle(
                            shape: MaterialStateProperty.all(
                                RoundedRectangleBorder(
                                    borderRadius: BorderRadius.zero)),
                            padding: MaterialStateProperty.all(
                                EdgeInsets.symmetric(
                                    vertical: 10.0, horizontal: 20)),
                            backgroundColor:
                                MaterialStateProperty.all(Colors.white)),
                        onPressed: () async {
                          openArabicDocumentForParentBoxDialog(context, i);
                        },
                        child: Column(
                          children: [
                            provider.selectedArabicDocumentId != null
                                ? CustomText(
                                    text:
                                        'Selected Document: ${provider.getSelectedArabicDocumentName(i)}',
                                    color: Colors.red,
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold)
                                : CustomText(
                                    text: 'Upload File',
                                    color: Colors.red,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 20,
                                  ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                // Your actions here, for example, buttons that use model methods
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text('Save'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> openArabicDocumentChildrenBoxDialog(BuildContext context, int i, int j) {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return Consumer<DocumentPageProvider>(
          builder: (context, provider, child) {
            // Fetch documents if not already loaded
            if (provider.documentData?.documents == null) {
              provider.getListOfDocuments();
              return Center(child: CircularProgressIndicator());
            }

            // Show empty state if no documents are available
            if (provider.documentData!.documents!.isEmpty) {
              return Center(child: Text('No data to show'));
            }

            // Ensure selectedChildDocumentId list has enough elements
            while (provider.selectedArabicChildDocumentId.length <= i) {
              provider.selectedArabicChildDocumentId.add(null);
            }
            while (provider.selectedArabicChildDocumentId.length <= j) {
              provider.selectedArabicChildDocumentId.add(null);
            }

            // Document selection dialog
            return AlertDialog(
              backgroundColor: Colors.white,
              title: Column(
                children: [
                  CustomText(
                    text: 'Document Type',
                    color: Colors.black,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                  SizedBox(height: 5),
                  provider.selectedArabicChildDocumentId[j] != null
                      ? CustomText(
                          text:
                              'Selected Document: ${provider.getSelectedArabicChildDocumentName(i, j)}',
                          color: Colors.red,
                          fontSize: 20,
                        )
                      : Container(),
                ],
              ),
              content: SizedBox(
                width: 600,
                child: SingleChildScrollView(
                  scrollDirection: Axis.vertical,
                  child: DataTable(
                    columns: [
                      DataColumn(label: Text('Document Name')),
                      DataColumn(label: Text('Document Category')),
                      DataColumn(label: Text('Select')),
                    ],
                    rows: provider.documentData!.documents!
                        .map(
                          (document) => DataRow(
                            selected: document.documentId ==
                                provider.selectedArabicChildDocumentId[j],
                            onSelectChanged: (bool? selected) {
                              if (selected != null) {
                                provider.selectArabicDocumentChild(
                                    i, j, document.documentId!);
                                print(
                                    "Document ID List Prepared: ${provider.selectedArabicChildDocumentId}");
                              }
                            },
                            cells: [
                              DataCell(Text(document.documentName ?? '')),
                              DataCell(Text(document.documentCategory ?? '')),
                              DataCell(
                                Radio<int>(
                                  value: document.documentId!,
                                  groupValue:
                                      provider.selectedArabicChildDocumentId[j],
                                  onChanged: (int? value) {
                                    provider.selectArabicDocumentChild(
                                        i, j, value!);
                                  },
                                ),
                              ),
                            ],
                          ),
                        )
                        .toList(),
                  ),
                ),
              ),
              actions: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text('Selected Category'),
                ),

                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text('Close'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> openArabicDocumentChildrenOptionListForParentBoxDialog(BuildContext context, int i, int j) {
    final MeetingPageProvider meetingPageProvider =
        Provider.of<MeetingPageProvider>(context, listen: false);
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return Consumer<DocumentPageProvider>(
          builder: (context, provider, child) {
            return AlertDialog(
              backgroundColor: Colors.grey[100],
              insetPadding: const EdgeInsets.symmetric(horizontal: 10),
              title: CustomText(
                  text: 'Upload Document',
                  color: Colors.black,
                  fontSize: 20,
                  fontWeight: FontWeight.bold),
              content: SizedBox(
                width: 1000,
                height: 400,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Column(
                          children: [
                            ChangeNotifierProvider(
                              create: (_) => FileUploadPageProvider(),
                              child: Builder(builder: (context) {
                                return FilesUploadWidget(
                                  labelName: 'Choose File',
                                  allowedExtensions: ['pdf'],
                                  onFilePicked:(pickedFileName, pickedFileContent, filePaths) {
                                    meetingPageProvider.setFileChildAtIndex(i, j, pickedFileName,pickedFileContent, filePaths);
                                  },
                                  provider: Provider.of<FileUploadPageProvider>(
                                      context,
                                      listen: false),
                                );
                              }),
                            ),
                          ],
                        ),

                        // SizedBox(width: 10.0,),
                        Column(
                          children: [
                            ChangeNotifierProvider(
                              create: (_) => FileUploadPageProvider(),
                              child: Builder(builder: (context) {
                                return FilesUploadWidget(
                                  labelName: 'Choose Local File',
                                  allowedExtensions: ['pdf'],
                                  onFilePicked: (List<String> pickedFileName,
                                      List<String> pickedFileContent , filePaths) {
                                    meetingPageProvider.setFileChildTwoAtIndex(i, j, pickedFileName,pickedFileContent, filePaths);
                                  },
                                  provider: Provider.of<FileUploadPageProvider>(
                                      context,
                                      listen: false),
                                );
                              }),
                            ),
                          ],
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 30,
                    ),
                    CustomText(
                        text: 'Document Type',
                        color: Colors.black,
                        fontSize: 20,
                        fontWeight: FontWeight.bold),
                    SizedBox(
                      width: 400,
                      child: TextButton(
                        style: ButtonStyle(
                            shape: MaterialStateProperty.all(
                                RoundedRectangleBorder(
                                    borderRadius: BorderRadius.zero)),
                            padding: MaterialStateProperty.all(
                                EdgeInsets.symmetric(
                                    vertical: 10.0, horizontal: 20)),
                            backgroundColor:
                                MaterialStateProperty.all(Colors.white)),
                        onPressed: () async {
                          // Ensure the selectedChildDocumentId has the main list and sublist to the required depth
                          while (
                              provider.selectedArabicChildDocumentId.length <=
                                  i) {
                            provider.selectedArabicChildDocumentId.add(null);
                          }
                          while (
                              provider.selectedArabicChildDocumentId.length <=
                                  j) {
                            provider.selectedArabicChildDocumentId.add(null);
                          }

                          openArabicDocumentChildrenBoxDialog(context, i, j);
                        },
                        child: Column(
                          children: [
                            provider.selectedArabicChildDocumentId.length > j &&
                                    provider.selectedArabicChildDocumentId[j] !=
                                        null
                                ? CustomText(
                                    text:
                                        'Selected Document: ${provider.getSelectedArabicChildDocumentName(i, j)}',
                                    color: Colors.red,
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold)
                                : CustomText(
                                    text: 'Upload File',
                                    color: Colors.red,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 20,
                                  ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                // Your actions here, for example, buttons that use model methods
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text('Save'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  //arabic section

  Widget buildAddButtonForEnglishFormParent(MeetingPageProvider provider) => Row(
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

  Widget buildAddArabicButton(MeetingPageProvider provider) => Row(
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

  Widget _buildMeetingFormCard({
    required BuildContext context,
    required MeetingPageProvider provider,
    required ThemeData theme,
  }) {

    final toggleProvider = Provider.of<MeetingPageProvider>(context);
    return DottedBorder(
      borderType: BorderType.RRect,
      radius: Radius.circular(20),
      dashPattern: [10, 10],
      color: Colour().buttonBackGroundRedColor,
      strokeWidth: 3,
      child: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height - 300,
        padding: const EdgeInsets.all(10.0),
        margin: const EdgeInsets.all(0.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Material(
              elevation: 5,
              child: Container(
                padding: EdgeInsets.all(2),
                margin: EdgeInsets.only(bottom: 0),
                decoration: BoxDecoration(
                  border: Border(
                      right: BorderSide(width: 0.1),
                      left: BorderSide(width: 0.1),
                      bottom: BorderSide(width: 0.1)),
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey,
                      offset: Offset(0.0, 1.0), //(x,y)
                      blurRadius: 6.0,
                    ),
                  ],
                  borderRadius: BorderRadius.circular(3),
                ),
                child: TextFormField(
                  // maxLines: null,
                  // expands: true,
                  controller: provider.meetingTitleController,
                  validator: (val) =>
                      val != null && val.isEmpty ? 'please enter title' : null,
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: 'Meeting Title',
                    // isDense: true,
                    contentPadding:
                        const EdgeInsets.fromLTRB(8.0, 8.0, 8.0, 0.0),
                  ),
                ),
              ),
            ),
            SizedBox(height: 5.0),
            Flexible(
                child: Material(
              elevation: 5,
              child: Container(
                padding: EdgeInsets.all(2),
                margin: EdgeInsets.only(bottom: 2),
                decoration: BoxDecoration(
                  border: Border(
                      right: BorderSide(width: 0.1),
                      left: BorderSide(width: 0.1),
                      bottom: BorderSide(width: 0.1)),
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey,
                      offset: Offset(0.0, 1.0),
                      blurRadius: 6.0,
                    ),
                  ],
                  borderRadius: BorderRadius.circular(2),
                ),
                child: SizedBox(
                  child: TextFormField(
                    maxLines: null,
                    expands: true,
                    controller: provider.meetingDescriptionController,
                    validator: (val) => val != null && val.isEmpty
                        ? 'please enter meeting description'
                        : null,
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      hintText: 'Meeting Description',
                      isDense: true,
                      contentPadding:
                          const EdgeInsets.fromLTRB(8.0, 8.0, 8.0, 0.0),
                    ),
                  ),
                ),
              ),
            )),
            SizedBox(height: 5.0),
            SizedBox(
              height: 100,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                      child: Material(
                    elevation: 5,
                    child: Container(
                      padding: EdgeInsets.all(10),
                      margin: EdgeInsets.only(bottom: 2),
                      decoration: BoxDecoration(
                        border: Border(
                            right: BorderSide(width: 0.1),
                            left: BorderSide(width: 0.1),
                            bottom: BorderSide(width: 0.1)),
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey,
                            offset: Offset(0.0, 1.0), //(x,y)
                            blurRadius: 6.0,
                          ),
                        ],
                        borderRadius: BorderRadius.circular(2),
                      ),
                      child: SizedBox(
                        child: DateTimePickerWidget(
                          fieldName: 'Select Start Date and Time',
                          controller: provider.startDateController,
                          onDateTimeSelected: (String) {
                            provider.startDateController.text =
                                String.toString();
                          },
                        ),
                      ),
                    ),
                  )),
                  SizedBox(
                    width: 5.0,
                  ),
                  Flexible(
                    child: Material(
                      elevation: 5,
                      child: Container(
                        padding: EdgeInsets.all(10),
                        margin: EdgeInsets.only(bottom: 2),
                        decoration: BoxDecoration(
                          border: Border(
                              right: BorderSide(width: 0.1),
                              left: BorderSide(width: 0.1),
                              bottom: BorderSide(width: 0.1)),
                          color: Colors.white,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey,
                              offset: Offset(0.0, 1.0), //(x,y)
                              blurRadius: 6.0,
                            ),
                          ],
                          borderRadius: BorderRadius.circular(2),
                        ),
                        child: SizedBox(
                          child: DateTimePickerWidget(
                            fieldName: 'Select End Date and Time',
                            controller: provider.endDateController,
                            onDateTimeSelected: (String) {
                              provider.endDateController.text =
                                  String.toString();
                            },
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 5.0),
            Flexible(
              child: Material(
                elevation: 5,
                child: Container(
                  padding: EdgeInsets.all(2),
                  margin: EdgeInsets.only(bottom: 2),
                  decoration: BoxDecoration(
                    border: Border(
                        right: BorderSide(width: 0.1),
                        left: BorderSide(width: 0.1),
                        bottom: BorderSide(width: 0.1)),
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey,
                        offset: Offset(0.0, 1.0), //(x,y)
                        blurRadius: 6.0,
                      ),
                    ],
                    borderRadius: BorderRadius.circular(2),
                  ),
                  child: TextFormField(
                    // maxLines: null,
                    // expands: true,
                    controller: provider.moreInfoController,
                    // validator: (val) => val != null && val.isEmpty ? 'please enter meeting more information ' : null,
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      hintText: 'Meeting more information',
                      // isDense: true,
                      contentPadding:
                          const EdgeInsets.fromLTRB(8.0, 8.0, 8.0, 0.0),
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(height: 5.0),
            // Flexible(
            //   child: Material(
            //     elevation: 5,
            //     child: Container(
            //       padding: EdgeInsets.all(2),
            //       margin: EdgeInsets.only(bottom: 2),
            //       decoration: BoxDecoration(
            //         border: Border(
            //             right: BorderSide(width: 0.1),
            //             left: BorderSide(width: 0.1),
            //             bottom: BorderSide(width: 0.1)),
            //         color: Colors.white,
            //         boxShadow: [
            //           BoxShadow(
            //             color: Colors.grey,
            //             offset: Offset(0.0, 1.0), //(x,y)
            //             blurRadius: 6.0,
            //           ),
            //         ],
            //         borderRadius: BorderRadius.circular(2),
            //       ),
            //       child: SizedBox(
            //         child: TextFormField(
            //           // maxLines: null,
            //           // expands: true,
            //           controller: provider.linkController,
            //           // validator: (val) => val != null && val.isEmpty ? 'please enter Meeting link' : null,
            //           decoration: InputDecoration(
            //             border: InputBorder.none,
            //             hintText: 'Meeting link',
            //             // isDense: true,
            //             contentPadding:
            //                 const EdgeInsets.fromLTRB(8.0, 8.0, 8.0, 0.0),
            //           ),
            //         ),
            //       ),
            //     ),
            //   ),
            // ),

            Padding(
              padding: const EdgeInsets.all(8.0),
              child: ElevatedButton(
                onPressed: () {
                  toggleProvider.toggleVisibility();
                },
                child: CustomText(text: toggleProvider.isVisible ? 'Attended' : 'Online Meeting'),
              ),
            ),

            // Conditionally Show TextFormField
            toggleProvider.isVisible ?
              Flexible(
                child: Material(
                  elevation: 5,
                  child: Container(
                    padding: EdgeInsets.all(2),
                    margin: EdgeInsets.only(bottom: 2),
                    decoration: BoxDecoration(
                      border: Border(
                          right: BorderSide(width: 0.1),
                          left: BorderSide(width: 0.1),
                          bottom: BorderSide(width: 0.1)),
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey,
                          offset: Offset(0.0, 1.0), //(x,y)
                          blurRadius: 6.0,
                        ),
                      ],
                      borderRadius: BorderRadius.circular(2),
                    ),
                    child: SizedBox(
                      height: 50,
                      child: TextFormField(
                        maxLines: null,
                        expands: true,
                        controller: toggleProvider.isVisible ? provider.linkController : null,
                        // validator: (val) => val != null && val.isEmpty ? 'please enter Meeting link' : null,
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          hintText: 'Meeting link',
                          // isDense: true,
                          contentPadding: const EdgeInsets.fromLTRB(8.0, 8.0, 8.0, 0.0),
                        ),
                        validator: (value) {
                          if (toggleProvider.isVisible &&
                              (value == null || value.isEmpty)) {
                            return 'Please enter a meeting link';
                          }
                          return null;
                        },
                      ),
                    ),
                  ),
                ),
              ) : SizedBox.shrink(),
          ],
        ),
      ),
    );
  }

  buildRemoveButtonForEnglishParentFormFields(int index, MeetingPageProvider provider) => Padding(
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

  buildRemoveArabicButton(int index, MeetingPageProvider provider) => Padding(
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

  buildRemoveChildrenButton(int i, int j, MeetingPageProvider provider) =>
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

  buildRemoveArabicChildrenButton(int i, int j, MeetingPageProvider provider) =>
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

  buildAddChildrenButtonForEnglishFormFields(int i, MeetingPageProvider provider) => Padding(
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

  buildAddChildrenArabicButton(int i, MeetingPageProvider provider) => Padding(
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

  void _saveFormDataAgenda(MeetingPageProvider meetingProvider) async {
    final isValid = _formKey.currentState!.validate();
    if (isValid) {
    final documentProvider =
        Provider.of<DocumentPageProvider>(context, listen: false);

    final SharedPreferences prefs = await SharedPreferences.getInstance();
    user = User.fromJson(json.decode(prefs.getString("user")!));
    List<Map<String, dynamic>> agendas = [];


    // Validate the dropdown selection
    meetingProvider.validateDropdown();
    if (meetingProvider.dropdownError != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: CustomText(text: meetingProvider.dropdownError!),
          backgroundColor: Colors.redAccent,
        ),
      );
      return; // Stop the form submission if there's an error
    }

    bool isDocumentSelected = true;
    String errorMessage = '';

    // Iterate through each agenda and validate files and document IDs
    for (int i = 0; i < meetingProvider.titleControllers.length; i++) {
      // print('-----------------------------------------------------${meetingProvider.fileName[i]}');
      // Only validate document ID if a file is uploaded
      if (meetingProvider.fileName.length <= i &&
          meetingProvider.fileName.isNotEmpty &&
          meetingProvider.fileName[i].isNotEmpty) {
        if (documentProvider.selectedDocumentId == null ||
            documentProvider.selectedDocumentId.length <= i ||
            documentProvider.selectedDocumentId[i] == null) {
          print('-----------------------------------------------------in if');
          isDocumentSelected = false;
          errorMessage =
              'No parent document selected for Agenda $i, but a file is uploaded! Please provide a document ID.';
          break;
        }
      }

      if (!isDocumentSelected) break;

      // Build the agendas list

        List<Map<String, dynamic>> childAgendas = [];
        if(meetingProvider.titleControllersList.isNotEmpty || meetingProvider.arabicTitleControllersList.isNotEmpty){
          for (int j = 0; j < meetingProvider.titleControllersList[i].length;j++) {
            childAgendas.add({
              if (meetingProvider.titleControllersList.isNotEmpty)"child_agenda_title" :meetingProvider.titleControllersList[i][j].text,
              if (meetingProvider.descriptionControllersList.isNotEmpty)"child_agenda_description": meetingProvider.descriptionControllersList[i][j].text,
              if (meetingProvider.timeControllersList.isNotEmpty)"child_agenda_time": meetingProvider.timeControllersList[i][j].text,
              if (meetingProvider.userControllersList.isNotEmpty)"child_presenter": meetingProvider.userControllersList[i][j].text,

              if (meetingProvider.arabicTitleControllersList.isNotEmpty)"child_agenda_title_arabic" :meetingProvider.arabicTitleControllersList[i][j]?.text ?? [],
              if (meetingProvider.arabicDescriptionControllersList.isNotEmpty)"child_agenda_description_arabic": meetingProvider.arabicDescriptionControllersList[i][j].text,
              if (meetingProvider.arabicTimeControllersList.isNotEmpty)"child_agenda_time_arabic": meetingProvider.arabicTimeControllersList[i][j].text,
              if (meetingProvider.arabicUserControllersList.isNotEmpty)"child_presenter_arabic": meetingProvider.arabicUserControllersList[i][j].text,

              "child_documentIds":
              (i < documentProvider.selectedChildDocumentId.length && documentProvider.selectedChildDocumentId[i] != null) ? documentProvider.selectedChildDocumentId[i] : [], // Empty array if not available
              "child_files": [
                if (i < meetingProvider.fileNameChild.length &&
                    j < meetingProvider.fileNameChild[i].length)
                  {
                    "file_name": meetingProvider.fileNameChild[i][j],
                    "file_base64": meetingProvider.fileBase64OneChild[i][j],
                  },
                if (i < meetingProvider.fileNameTwoChild.length &&
                    j < meetingProvider.fileNameTwoChild[i].length)
                  {
                    "file_name_two": meetingProvider.fileNameTwoChild[i][j],
                    "file_base64_two": meetingProvider.fileBase64TwoChild[i][j],
                  },
              ]
            });
          }
        }

        agendas.add({
          "agenda_title": meetingProvider.titleControllers[i].text,
          "agenda_description": meetingProvider.descriptionControllers[i].text,
          "agenda_time": meetingProvider.timeControllers[i].text,
          "presenter": meetingProvider.userControllers[i].text,
          // Only include file data if a file was uploaded
          if (meetingProvider.fileName.isNotEmpty) "agenda_file_name_one": meetingProvider.fileName[i],
          if (meetingProvider.fileBase64One.isNotEmpty)'agenda_file_content_one': meetingProvider.fileBase64One[i],
          if (meetingProvider.fileNameTwo.isNotEmpty)"agenda_file_name_two": meetingProvider.fileNameTwo[i],
          if (meetingProvider.fileBase64Two.isNotEmpty)'agenda_file_content_two': meetingProvider.fileBase64Two[i],
          "documentIds": (i < documentProvider.selectedDocumentId.length &&
                  documentProvider.selectedDocumentId[i] != null)
              ? documentProvider.selectedDocumentId[i]
              : null,
          "membersSignedIds": _membersListIds ?? [],

          if (meetingProvider.arabicTitleControllers.isNotEmpty)"agenda_title_arabic":meetingProvider.arabicTitleControllers[i].text,
          if (meetingProvider.arabicDescriptionControllers.isNotEmpty)"agenda_description_arabic":meetingProvider.arabicDescriptionControllers[i].text,
          if (meetingProvider.arabicTimeControllers.isNotEmpty)"agenda_time_arabic": meetingProvider.arabicTimeControllers[i].text,
          if (meetingProvider.arabicUserControllers.isNotEmpty)"presenter_arabic": meetingProvider.arabicUserControllers[i].text,

          "membersSignedIds_arabic": _arabicMembersListIds,
          "documentIds_arabic":
              (i < documentProvider.selectedArabicDocumentId.length &&
                      documentProvider.selectedArabicDocumentId[i] != null)
                  ? documentProvider.selectedArabicDocumentId[i]
                  : null,
          "childAgendas": childAgendas,
        });
        log.i(childAgendas);

    }

    // If document validation fails, show an error message and return early
    if (!isDocumentSelected) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: CustomText(text: errorMessage),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Prepare and submit the meeting event
    Map<String, dynamic> event = {
      "created_by": user.userId,
      "meeting_title": meetingProvider.meetingTitleController.text,
      "meeting_description": meetingProvider.meetingDescriptionController.text,
      "meeting_media_name": meetingProvider.linkController.text,
      "is_visible": meetingProvider.isVisible,
      "meeting_by": meetingProvider.moreInfoController.text,
      "meeting_start": meetingProvider.startDateController.text,
      "meeting_end": meetingProvider.endDateController.text,
      "listOfAgendas": agendas,
      "business_id": user.businessId,
      "combined": meetingProvider.combined!
    };
    meetingProvider.setLoading(true);
    await meetingProvider.insertNewMeeting(event);

    if (meetingProvider.isBack == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: CustomText(text: 'Insert done'),
          backgroundColor: Colors.greenAccent,
        ),
      );
      Future.delayed(const Duration(seconds: 5), () {
        Navigator.of(context)
            .pushReplacementNamed(BoardMeetingsListView.routeName);
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
    required this.meetingProvider,
  });

  final MeetingPageProvider meetingProvider;

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
          meetingProvider.clearAllControllers();
          Navigator.of(context).pushReplacementNamed(BoardMeetingsListView.routeName);
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
