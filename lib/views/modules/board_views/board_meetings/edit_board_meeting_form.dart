import 'dart:convert';

import 'package:diligov_members/views/modules/board_views/board_meetings/board_meetings_list_view.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:multi_select_flutter/chip_display/multi_select_chip_display.dart';
import 'package:multi_select_flutter/dialog/multi_select_dialog_field.dart';
import 'package:multi_select_flutter/util/multi_select_item.dart';
import 'package:open_file/open_file.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../colors.dart';
import '../../../../models/meeting_model.dart';
import '../../../../models/member.dart';
import '../../../../models/user.dart';
import '../../../../providers/document_page_provider.dart';
import '../../../../providers/file_upload_page_provider.dart';
import '../../../../providers/meeting_page_provider.dart';
import '../../../../providers/member_page_provider.dart';
import '../../../../utility/pdf_api.dart';
import '../../../../widgets/appBar.dart';
import '../../../../widgets/check_and_display_file_name.dart';
import '../../../../widgets/check_and_display_nested_file_name.dart';
import '../../../../widgets/child_document_dialog.dart';
import '../../../../widgets/custom_dialog.dart';
import '../../../../widgets/custom_icon.dart';
import '../../../../widgets/custom_message.dart';
import '../../../../widgets/custome_text.dart';
import '../../../../widgets/date_picker_form_field.dart';
import '../../../../widgets/files_upload_widget.dart';
import '../../../../widgets/header_language_widget.dart';
import '../../../../widgets/loading_sniper.dart';
import 'package:flutter_gen/gen_l10n/app_localization.dart';

import '../../../../widgets/meeting_form/build_english_form_widget.dart';
import '../../../../widgets/member_search_dialog.dart';
import '../../../../widgets/parent_document_dialog.dart';

class EditBoardMeetingForm extends StatefulWidget {
  final Meeting? event;
  // final String meetingId;
  const EditBoardMeetingForm({super.key, required this.event});

  @override
  State<EditBoardMeetingForm> createState() => _EditBoardMeetingFormState();
}

class _EditBoardMeetingFormState extends State<EditBoardMeetingForm> {

  final _formKey = GlobalKey<FormState>();
  var log = Logger();
  User user = User();

  late MeetingPageProvider editMeetingPageProvider = MeetingPageProvider();
  List _membersListIds = [];
  List _membersChildListIds = [];

  List _arabicMembersListIds = [];
  List _arabicMembersChildListIds = [];

  List<String> agendaIds = [];
  late List<List<String>> childrenAgendaIds;

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      Provider.of<MeetingPageProvider>(context, listen: false).findMeetingById(widget!.event!.meetingId.toString());
      final editMeetingPageProvider = Provider.of<MeetingPageProvider>(context, listen: false);
      if (widget.event != null) {
        editMeetingPageProvider.initializeFromEvent(widget.event!);
      }
    });


      // Fetch the documents when the widget is first built
      Future.microtask(() => Provider.of<DocumentPageProvider>(context, listen: false).getListOfDocuments());
    Future.microtask(() => Provider.of<MemberPageProvider>(context, listen: false).getListOfMemberMenu());
  }


  @override
  void dispose() {

    // Dispose main controllers
    for (var controller in editMeetingPageProvider.titleControllers) {
      controller.dispose();
    }
    for (var controller in editMeetingPageProvider.descriptionControllers) {
      controller.dispose();
    }
    for (var controller in editMeetingPageProvider.timeControllers) {
      controller.dispose();
    }
    for (var controller in editMeetingPageProvider.userControllers) {
      controller.dispose();
    }


     for (var controller in editMeetingPageProvider.arabicTitleControllers) {
       controller.dispose();
     }
     for (var controller in editMeetingPageProvider.arabicDescriptionControllers) {
       controller.dispose();
     }
     for (var controller in editMeetingPageProvider.arabicTimeControllers) {
       controller.dispose();
     }
     for (var controller in editMeetingPageProvider.arabicUserControllers) {
       controller.dispose();
     }


    // Dispose child controllers
    for (var list in editMeetingPageProvider.titleControllersList) {
      for (var controller in list) {
        controller.dispose();
      }
    }
    for (var list in editMeetingPageProvider.descriptionControllersList) {
      for (var controller in list) {
        controller.dispose();
      }
    }
    for (var list in editMeetingPageProvider.timeControllersList) {
      for (var controller in list) {
        controller.dispose();
      }
    }
    for (var list in editMeetingPageProvider.userControllersList) {
      for (var controller in list) {
        controller.dispose();
      }
    }

     for (var list in editMeetingPageProvider.arabicTitleControllersList) {
       for (var controller in list) {
         controller.dispose();
       }
     }
     for (var list in editMeetingPageProvider.arabicDescriptionControllersList) {
       for (var controller in list) {
         controller.dispose();
       }
     }
     for (var list in editMeetingPageProvider.arabicTimeControllersList) {
       for (var controller in list) {
         controller.dispose();
       }
     }
     for (var list in editMeetingPageProvider.arabicUserControllersList) {
       for (var controller in list) {
         controller.dispose();
       }
     }
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    final meetingProvider =  Provider.of<MeetingPageProvider>(context, listen: false);
    final theme = Theme.of(context);
    final enableArabic = context.watch<MeetingPageProvider>().enableArabic;
    final enableEnglish = context.watch<MeetingPageProvider>().enableEnglish;
    final enableArabicAndEnglish = context.watch<MeetingPageProvider>().enableArabicAndEnglish;
    return Scaffold(
      appBar: Header(context),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 25,
                        backgroundColor: Colour()
                            .buttonBackGroundRedColor,
                        child: IconButton(
                          icon: CustomIcon(
                            icon: Icons.arrow_back_outlined,),
                          onPressed: () {
                            meetingProvider.clearAllControllers();
                            Navigator.of(context).pushReplacementNamed(BoardMeetingsListView.routeName);
                          },
                        ),
                      ),
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
                height: 15.0,
              ),
              Consumer<MeetingPageProvider>(
                builder: (BuildContext context, provider, child) {
                  return meetingProvider.loading
                      ? Center(child: CircularProgressIndicator())
                      : provider.meeting != null
                      ? SingleChildScrollView(
                    scrollDirection: Axis.vertical,
                    child: Builder(
                      builder: (BuildContext context) {
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
                              buildMeetingFormCardStepOneContent(context, provider, theme),
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
                                      if(enableEnglish)
                                        EnglishFormWidget(provider: provider),

                                      if(enableArabicAndEnglish)
                                        buildArabicAndEnglishFormWidget(context,provider),

                                      if(enableArabic)
                                        buildArabicFormWidget(provider),
                                      _buildButtonsControls(context)
                                    ],
                                  ),
                                ),
                              )
                            ],
                          ),
                        );
                      },
                    ),
                  ) : Center(child: Text('No data found'));
                },
              ),
            ],
          ),
        ),
      ),
    );
  }







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
            if (index < provider.agendaIds.length) {
              if (provider.titleControllers.length > index && provider.titleControllers[index].text.isNotEmpty) {
                Map<String, dynamic> data = {"agenda_id": provider.agendaIds[index], "index" : index};
                dialogDeleteAgenda(data);
              }
            } else {
              provider.removeArabicFormParentFields(index);
            }

          },
        ),
      ],
    ),
  );

  Future dialogDeleteAgenda(Map<String, dynamic> data) => showDialog(
    context: context,
    builder: (BuildContext context) {
      return CustomDialog(
        title: '${AppLocalizations.of(context)!.are_you_sure_to_delete} ?',
        onConfirm: () async {
          String message = await removeAgenda(data);
          Navigator.of(context).pop();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: CustomText(text: message),
              // backgroundColor: message.contains('successfully') ? Colors.greenAccent : Colors.redAccent,
              backgroundColor: message == 'Meeting deleted successfully.' ? Colors.greenAccent : Colors.redAccent,
            ),
          );
        },
        onCancel: () {  Navigator.of(context).pop(); },
      );
    },
  );

  Future<String> removeAgenda(Map<String, dynamic> data) async {
    final provider = Provider.of<MeetingPageProvider>(context, listen: false);

    // Step 1: Check if the meeting has associated agendas
    String message = await provider.deleteAgenda(data);

    // Step 2: If the meeting has agendas, ask for additional confirmation
    if (message.contains('associated agendas')) {
      message = await showAdditionalConfirmationDialog(context, data);
    }else{
      provider.removeButtonForEnglishParentFormFields(data['index']);
    }

    return message;
  }

  Future<String> showAdditionalConfirmationDialog(BuildContext context, Map<String, dynamic> data) async {
    // Await the dialog result and ensure non-null value is returned
    String? result = await showDialog<String>(
      context: context,
      builder: (BuildContext dialogContext) {
        return CustomDialog(
          title: 'This meeting has associated agendas. Are you sure you want to delete it?',
          onConfirm: () async {
            final provider = Provider.of<MeetingPageProvider>(context, listen: false);
            String message = await provider.deleteAgendaWithChildren(data); // Call the final delete function
            provider.removeButtonForEnglishParentFormFields(data['index']);
            Navigator.of(dialogContext).pop(message); // Return the message to the parent dialog
          },
          onCancel: () {
            Navigator.of(dialogContext).pop('Meeting deletion cancelled.');
          },
        );
      },
    );

    // Return result or default message if the dialog result is null
    return result ?? 'Action cancelled.';
  }

  Widget buildArabicParentFormWidget(int index, MeetingPageProvider provider) {
    final enableArabicAndEnglish = context.watch<MeetingPageProvider>().enableArabicAndEnglish;
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            padding: const EdgeInsets.all(5.0),
            color: Colors.white10,
            child: Text('${index + 1}', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
          ),
          const SizedBox(width: 2),
          Flexible(
            child: SizedBox(
              height: 150,
              child: Column(
                children: [
                  Expanded(child: buildCustomTextFormField(
                    controller: provider.arabicTitleControllers[index],
                    hint: 'Title',
                    validatorMessage: 'Please enter title',
                  )),
                  // arabic parent
                  CheckAndDisplayFileName(
                      list: provider.fileName,
                      index: index,
                      subIndex: 0,
                    customWidgetBuilder: (fileName) => TextButton(
                      onPressed: () async {
                        try {
                            if(await PDFApi.requestPermission()){
                              provider.setArabicWaitingForOpeningFile(true);

                              if (provider.fileName.isNotEmpty) {
                                print('open file ${fileName}');
                                await PDFApi.downloadAndOpenFile('https://diligov.com/public/meetings/${fileName}', context);
                               provider.setArabicWaitingForOpeningFile(false);
                              }

                              if (provider.filePath.isNotEmpty) {
                                final result = await OpenFile.open(provider.filePath[index][0]);
                                print("Open file result: ${result}");
                                provider.setArabicWaitingForOpeningFile(false);
                              }

                            } else {
                              // widget.provider.setWaitingForOpeningFile(false);
                              print("Lacking permissions to access the file");
                            }
                        } catch (e) {
                          provider.setArabicWaitingForOpeningFile(false);
                          print("Error opening PDF: $e");
                        }


                      },
                      child:  provider.arabicWaitingForOpeningFileOne == true ? CircularProgressIndicator(color: Colors.green,) : Row(
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          Expanded(child: CustomText(text:fileName, softWrap: true,overflow: TextOverflow.ellipsis,)),
                          Expanded(child: CustomIcon(icon: Icons.file_open)),
                          Expanded(child: IconButton(
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
                    MainAxisAlignment
                        .spaceBetween,
                    children: [
                      Flexible(
                        flex: 1,
                        child: TextButton(
                          style:
                          ButtonStyle(
                            backgroundColor:
                            MaterialStateProperty.all(Colors.red),
                          ),
                          onPressed:
                              () async {
                            openArabicDocumentOptionListForParentBoxDialog(context,index);
                          },
                          child: CustomText(text: 'Add file',color: Colors.white),
                        ),
                      ),
                      Flexible(
                        flex: 1,
                        child: TextButton(
                          onPressed: () {
                            final provider = Provider.of<MemberPageProvider>(context, listen: false);
                            openMemberSearchBoxDialog(context, provider);
                          },
                          child: Row(
                            children: [
                              enableArabicAndEnglish == true ? SizedBox.shrink() : Expanded(child: CustomText(text: 'Signature')),
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
          Expanded(child: SizedBox(
            height: 100,
            child: buildCustomTextFormField(
              controller: provider.arabicDescriptionControllers[index],
              hint: 'Description',
              validatorMessage: 'Please enter description',
            ),
          )),
          const SizedBox(width: 6),
          Expanded(child: SizedBox(
            height: 100,
            child: buildCustomTextFormField(
              controller: provider.arabicTimeControllers[index],
              hint: 'Time',
              validatorMessage: 'Please enter time',
            ),
          )),
          const SizedBox(width: 6),
          Expanded(child: SizedBox(
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

  Widget _buildButtonsControls(BuildContext context) {
    final provider = Provider.of<MeetingPageProvider>(context, listen: false);
    return provider.loading == true ? CustomText(text: 'Saving in progress...',color: Colors.green, fontWeight: FontWeight.bold,fontSize: 20.0,) : Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
          TextButton(
            style: ButtonStyle(
              backgroundColor: MaterialStateProperty.all(Colour().buttonBackGroundRedColor),
            ),
            onPressed: ()  {
              saveBuildButton(provider);
            },
            child: CustomText(
              text: 'Update',
              color: Colour().mainWhiteTextColor,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(width: 20.0),
          TextButton(
            style: ButtonStyle(
              backgroundColor: MaterialStateProperty.all(Colour().buttonBackGroundRedColor),
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

  Widget CombinedCollectionBoardCommitteeDataDropDownList(){
    return Container(
      width: 200,
      padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 15.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(10)),
        color: Colour().buttonBackGroundRedColor,
      ),
      child: Consumer<MeetingPageProvider>(
        builder: (context, combinedDataProvider, child) {
          if (combinedDataProvider.collectionBoardCommitteeData?.combinedCollectionBoardCommitteeData == null) {
            combinedDataProvider.getListOfCombinedCollectionBoardAndCommittee();
            return buildLoadingSniper();
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              combinedDataProvider.collectionBoardCommitteeData!.combinedCollectionBoardCommitteeData!.isEmpty
                  ? buildEmptyMessage(AppLocalizations.of(context)!.no_data_to_show)
                  : DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  isExpanded: true,
                  isDense: true,
                  style: Theme.of(context).textTheme.titleLarge,
                  elevation: 2,
                  iconEnabledColor: Colors.white,
                  items: combinedDataProvider.collectionBoardCommitteeData?.combinedCollectionBoardCommitteeData?.map((item) {
                    return DropdownMenuItem<String>(
                      alignment: Alignment.center,
                      value: '${item.type.toString()}-${item.id.toString()}',
                      child: Container(
                        height: double.infinity,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          border: Border.all(width: 0.1, color: Colors.black),
                        ),
                        child: Center(child: CustomText(text: item.name.toString())),
                      ),
                    );
                  }).toList(),
                  onChanged: (selectedItem) {
                    combinedDataProvider.selectCombinedCollectionBoardCommittee(selectedItem!);
                  },
                  hint: CustomText(
                    text: combinedDataProvider.selectedCombined != null
                        ? combinedDataProvider.selectedCombined!
                        : 'Select an item pleace',
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              if (combinedDataProvider.dropdownError != null)
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: CustomText(text:
                    combinedDataProvider.dropdownError!,
                    fontSize: 12 ,
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  Widget buildDynamicFormArabicParentForm(int index, MeetingPageProvider provider) {
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
          buildArabicParentFormWidget(index, provider),
          SizedBox(height: 5),
          buildArabicReOrderListFormForChildrenWidget(index, provider),
        ],
      ),
    );
  }

  Widget buildArabicReOrderListFormForChildrenWidget(int i, MeetingPageProvider provider) {
    final enableArabicAndEnglish = context.watch<MeetingPageProvider>().enableArabicAndEnglish;
    if (i >= provider.arabicChildItems.length || provider.arabicChildItems[i].isEmpty) {
      return SizedBox.shrink(); // Return an empty widget if there are no children
    }
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Container(
        color: Colors.grey[200],
        // padding: EdgeInsets.only(right: 3),
        height:  300.0 ,
        width: MediaQuery.of(context).size.width,
        child:   ReorderableListView(
          onReorder: (oldIndex,newIndex) {
            provider.reorderArabicChildItems(i,oldIndex,newIndex);
          },
          children: [
            if (provider.arabicChildItems.isNotEmpty && provider.arabicChildItems[i].isNotEmpty)
              for (int j = 0;j < provider.arabicChildItems[i].length;j++)
                ListTile(
                  key: ValueKey(provider.arabicChildItems[i][j]),
                  title:  Directionality(
                    textDirection: TextDirection.rtl,
                    child: Row(
                      mainAxisAlignment:MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding:const EdgeInsets.all(3.0),
                          color: Colors.white10,
                          child: CustomText(text:'${i + 1}.${j + 1}',fontWeight:FontWeight.bold,fontSize: 20,),
                        ),
                        SizedBox(width: 3),
                        Flexible(
                          child: SizedBox(
                            height: 150,
                            child: Column(
                              children: [
                                Expanded(
                                  child: buildCustomTextFormField(
                                    controller: provider.arabicTitleControllersList[i][j],
                                    hint: 'Title',
                                    validatorMessage: 'Please enter title',
                                  ),
                                ),
                                // arabic children
                                NestedFileNameWidget(
                                  list: provider.fileNameChild,
                                  index: i,
                                  subIndex: j,
                                  subSubIndex: 0,
                                  customWidgetBuilder: (fileName) => TextButton(
                                    onPressed: () async {

                                      try {
                                        if(await PDFApi.requestPermission()){
                                          provider.setArabicWaitingForOpeningFileChild(true);

                                          if (provider.fileNameChild.isNotEmpty) {
                                            print('open file ${fileName}');
                                            await PDFApi.downloadAndOpenFile('https://diligov.com/public/meetings/${fileName}', context);
                                            provider.setArabicWaitingForOpeningFileChild(false);
                                          }

                                          if (provider.filePathChild.isNotEmpty && provider.filePathChild[i][j][0] != null) {
                                            final result = await OpenFile.open(provider.filePathChild[i][j][0]);
                                            print("Open file result: ${result}");
                                            provider.setArabicWaitingForOpeningFileChild(false);
                                          }

                                        } else {
                                          // widget.provider.setWaitingForOpeningFile(false);
                                          print("Lacking permissions to access the file");
                                        }
                                      } catch (e) {
                                        provider.setArabicWaitingForOpeningFileChild(false);
                                        print("Error opening PDF: $e");
                                      }


                                    },
                                    child: provider.arabicWaitingForOpeningFileChild == true ? CircularProgressIndicator(color: Colors.green,) : Row(
                                      mainAxisSize: MainAxisSize.max,
                                      children: [
                                        Flexible(
                                            flex: 6,child: CustomText(text:fileName, softWrap: true,overflow: TextOverflow.ellipsis,)),
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
                                  mainAxisAlignment:
                                  MainAxisAlignment
                                      .spaceBetween,
                                  children: [
                                    Flexible(
                                      flex: 1,
                                      child: TextButton(
                                        style:
                                        ButtonStyle(
                                          backgroundColor:
                                          MaterialStateProperty.all(Colors.red),
                                        ),
                                        onPressed:
                                            () async {
                                          final DocumentPageProvider documen = Provider.of<DocumentPageProvider>(context, listen: false);
                                          // Ensure the selectedChildDocumentId has the main list and sublist to the required depth
                                          if (documen.selectedChildDocumentId.length <= i) {
                                            documen.selectedChildDocumentId.addAll(
                                                List.generate(i - documen.selectedChildDocumentId.length + 1, (_) => null)
                                            );
                                          }
                                          if (documen.selectedChildDocumentId.length <= j) {
                                            documen.selectedChildDocumentId.addAll(List.filled(j - documen.selectedChildDocumentId.length + 1, null));
                                          }
                                          openArabicDocumentChildrenOptionListForParentBoxDialog(context, i,j);
                                        },
                                        child: CustomText(text: 'Add file', color: Colors.white),
                                      ),
                                    ),
                                    Flexible(
                                      flex: 1,
                                      child:
                                      TextButton(
                                        onPressed:() {
                                          final memberProvider = Provider.of<MemberPageProvider>(context, listen: false);
                                          openMemberChildSearchBoxDialog(context, memberProvider);
                                        },
                                        child: Row(
                                        children: [
                                          enableArabicAndEnglish == true ? SizedBox.shrink() : Expanded(child: CustomText(text: 'Signature')),
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
                        SizedBox(
                            width: 6),
                        Expanded(
                          child: SizedBox(
                            height: 100,
                            child: buildCustomTextFormField(
                              controller: provider.arabicDescriptionControllersList[i][j],
                              hint: 'Description',
                              validatorMessage: 'Please enter description',
                            ),
                          ),
                        ),
                        SizedBox(
                            width: 6),
                        Expanded(
                          child: SizedBox(
                            height: 100,
                            child: buildCustomTextFormField(
                              controller: provider.arabicTimeControllersList[i][j],
                              hint: 'Time',
                              validatorMessage: 'Please enter time',
                            ),
                          ),
                        ),
                        SizedBox(
                            width: 6),
                        Expanded(
                          child: SizedBox(
                            height: 100,
                            child: buildCustomTextFormField(
                              controller: provider.arabicUserControllersList[i][j],
                              hint: 'Presenter',
                              validatorMessage: 'Please enter presenter',
                            ),
                          ),
                        ),

                        buildRemoveArabicChildrenButton(i, j ,provider),
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
        )   ,

      ),
    );
  }

  Widget buildRemoveArabicChildrenButton(int i, int j, MeetingPageProvider provider) => Padding(
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
            // log.i(provider.childrenAgendaIds);
            log.i(provider.childrenAgendaIds);
            // Check if the parent and child indices are valid
            if (i >= 0 && i < provider.childrenAgendaIds.length && j >= 0 && j < provider.childrenAgendaIds[i].length) {
              final childAgendaId = provider.childrenAgendaIds[i][j];

              // If the childAgendaId is empty or null, remove it locally (newly added field)
              if (childAgendaId.isEmpty) {
                provider.removeArabicChildItem(i, j);
              } else {
                // If the child has an ID, show the delete dialog
                Map<String, dynamic> data = {
                  "agenda_child_id": childAgendaId,
                  "index": i,
                  "child": j
                };
                dialogDeleteAgendaArabicChild(data);
              }
            } else {
              log.i("${i} -- ${j}");
              provider.removeArabicChildItem(i, j);
              print('Invalid parent or child index');
            }
          },
        ),
      ],
    ),
  );

  Future dialogDeleteAgendaArabicChild(Map<String, dynamic> data) => showDialog(
    context: context,
    builder: (BuildContext context) {
      return CustomDialog(
        title: '${AppLocalizations.of(context)!.are_you_sure_to_delete}',
        onConfirm: () async {
          String message = await removeAgendaArabicChild(data);
          Navigator.of(context).pop();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: CustomText(text: message),
              // backgroundColor: message.contains('successfully') ? Colors.greenAccent : Colors.redAccent,
              backgroundColor: message == 'Meeting deleted successfully.' ? Colors.greenAccent : Colors.redAccent,
            ),
          );
        },
        onCancel: () {  Navigator.of(context).pop(); },
      );
    },
  );

  Future<String> removeAgendaArabicChild(Map<String, dynamic> data) async {
    final provider = Provider.of<MeetingPageProvider>(context, listen: false);
    // Step 1: Check if the meeting has associated agendas
    String message = await provider.deleteAgendaChild(data);
    provider.removeArabicChildItem(data['index'],data["child"]);
    return message;
  }

  Widget buildMeetingFormCardStepOneContent(BuildContext context, MeetingPageProvider provider, ThemeData theme) {
    // Assumes _buildMeetingFormCard is a method that returns a widget
    return _buildMeetingFormCard(
      context: context,
      titleController: provider.meetingTitleController,
      descriptionController: provider.meetingDescriptionController,
      startDateController: provider.startDateController,
      endDateController: provider.endDateController,
      moreInfoController: provider.moreInfoController,
      linkController: provider.linkController,
      theme: theme,
    );
  }

  Widget buildArabicStepColumnContent(MeetingPageProvider provider) {
    return Expanded(
      child: Column(
        children: [
          buildButtonForArabicParentForm(provider),
          SizedBox(height: 10),
          for (int i = 0; i < provider.arabicTitleControllers.length; i++)
            buildDynamicFormArabicParentForm(i, provider),
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

  Future<void> openDocumentChildBoxDialog(BuildContext context, int i, int j) {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return ChildDocumentChildDialog(i: i, j: j);
      },
    );
  }

  Future<void> openDocumentBoxDialog(BuildContext context, int i) {
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
            if (i >= provider.selectedDocumentId!.length) {
              provider.selectedDocumentId!.addAll(List.filled(i - provider.selectedDocumentId!.length + 1, null));
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
                  provider.selectedDocumentId?[i] != null
                      ? CustomText(
                    text: 'Selected Document: ${provider.getSelectedDocumentName(i)}',
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
                        selected: document.documentId == provider.selectedDocumentId?[i],
                        onSelectChanged: (bool? selected) {
                          if (selected != null) {
                            provider.selectDocument(i, document.documentId!);
                          }
                        },
                        cells: [
                          DataCell(Text(document.documentName ?? '')),
                          DataCell(Text(document.documentCategory ?? '')),
                          DataCell(
                            Radio<int>(
                              value: document.documentId!,
                              groupValue: provider.selectedDocumentId![i],
                              onChanged: (int? value) {
                                provider.selectDocument(i, value);
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

  Future<void> openDocumentChildOptionBoxDialog(BuildContext context,int i,int j) {
    final MeetingPageProvider meetingPageProvider = Provider.of<MeetingPageProvider>(context, listen: false);
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
                                      (pickedFileName, pickedFileContent, filePaths) {
                                        meetingPageProvider.setFileChildAtIndex(i, j, pickedFileName,pickedFileContent, filePaths);
                                  },
                                  provider: Provider.of<FileUploadPageProvider>(context,listen: false),
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
                                  onFilePicked: (List<String> pickedFileName,List<String> pickedFileContent, filePaths) {
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
                          while (provider.selectedChildDocumentId.length <= i) {
                            provider.selectedChildDocumentId.add(null);
                          }
                          while (provider.selectedChildDocumentId.length <= j) {
                            provider.selectedChildDocumentId.add(null);
                          }

                          openDocumentChildBoxDialog(context, i, j);
                        },
                        child: Column(
                          children: [
                            provider.selectedChildDocumentId.length > j && provider.selectedChildDocumentId[j] != null
                                ? CustomText(text: 'Selected Document: ${provider.getSelectedChildDocumentName(i,j)}', color: Colors.red,
                                fontSize: 20, fontWeight: FontWeight.bold)
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

  Widget buildButtonForArabicParentForm(MeetingPageProvider provider) => Row(
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

  Widget buildArabicAndEnglishFormWidget(BuildContext context, MeetingPageProvider provider) {
    final enableArabicAndEnglish = context.watch<MeetingPageProvider>().enableArabicAndEnglish;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if(enableArabicAndEnglish)
          buildEnglishStepColumnContent(context,provider),
        SizedBox(width: 10,),
        if(enableArabicAndEnglish)
          buildArabicStepColumnContent(provider),
      ],
    );
  }

  Widget buildEnglishStepColumnContent(BuildContext context, MeetingPageProvider provider) {
    return Expanded(
      child: EnglishFormWidget(provider: provider),
    );
  }

  Widget buildArabicFormWidget(MeetingPageProvider provider) {
    return Column(
      children: [
        buildButtonForArabicParentForm(provider),
        SizedBox(height: 10),
        for (int j = 0; j < provider.arabicTitleControllers.length; j++)
          buildDynamicFormArabicParentForm(j, provider),
      ],
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
                        List members = values.map((member) => member['id']).toList();
                        if (members.contains("member_first_name")) {
                          return "Member are weird!";
                        }
                        return null;
                      },
                      onConfirm: (values) {
                        provider.setSelectMemberNote(values);
                        _arabicMembersChildListIds = provider.selectedMembersNoteList.map((e) => e.memberId).toList();
                        provider.setSelectedMembersNoteId(_arabicMembersChildListIds);
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
              provider.selectedArabicDocumentId!.addAll(List.filled(i - provider.selectedArabicDocumentId!.length + 1, null));
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
                    text: 'Selected Document: ${provider.getSelectedArabicDocumentName(i)}',
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
                        selected: document.documentId == provider.selectedArabicDocumentId?[i],
                        onSelectChanged: (bool? selected) {
                          if (selected != null) {
                            provider.selectArabicDocument(i, document.documentId!);
                          }
                        },
                        cells: [
                          DataCell(Text(document.documentName ?? '')),
                          DataCell(Text(document.documentCategory ?? '')),
                          DataCell(
                            Radio<int>(
                              value: document.documentId!,
                              groupValue: provider.selectedArabicDocumentId![i],
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
    final MeetingPageProvider meetingPageProvider = Provider.of<MeetingPageProvider>(context, listen: false);
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
                          final provider = Provider.of<DocumentPageProvider>(context, listen: false);
                          openParentDocumentBoxDialog(context, i, provider);
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

  Future<void> openParentDocumentBoxDialog(BuildContext context, int i, DocumentPageProvider provider) {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return ParentDocumentDialog(index: i, provider: provider);
      },
    );
  }

  Future<void> openArabicDocumentChildrenBoxDialog(BuildContext context, int i,int j) {
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
                    text: 'Selected Document: ${provider.getSelectedArabicChildDocumentName(i, j)}',
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
                        selected: document.documentId == provider.selectedArabicChildDocumentId[j],
                        onSelectChanged: (bool? selected) {
                          if (selected != null) {
                            provider.selectArabicDocumentChild(i,j, document.documentId!);
                            print("Document ID List Prepared: ${provider.selectedArabicChildDocumentId}");
                          }
                        },
                        cells: [
                          DataCell(Text(document.documentName ?? '')),
                          DataCell(Text(document.documentCategory ?? '')),
                          DataCell(
                            Radio<int>(
                              value: document.documentId!,
                              groupValue: provider.selectedArabicChildDocumentId[j],
                              onChanged: (int? value) {
                                provider.selectArabicDocumentChild(i, j,value!);
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

  Future<void> openArabicDocumentChildrenOptionListForParentBoxDialog(BuildContext context,int i,int j) {
    final MeetingPageProvider meetingPageProvider = Provider.of<MeetingPageProvider>(context, listen: false);
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
                height: 300,
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
                                  onFilePicked: (List<String> pickedFileName,List<String> pickedFileContent, filePaths) {
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
                          while (provider.selectedArabicChildDocumentId.length <= i) {
                            provider.selectedArabicChildDocumentId.add(null);
                          }
                          while (provider.selectedArabicChildDocumentId.length <= j) {
                            provider.selectedArabicChildDocumentId.add(null);
                          }
                          openDocumentChildBoxDialog(context, i, j);
                        },
                        child: Column(
                          children: [
                            provider.selectedArabicChildDocumentId.length > j && provider.selectedArabicChildDocumentId[j] != null
                                ? CustomText(text: 'Selected Document: ${provider.getSelectedArabicChildDocumentName(i,j)}', color: Colors.red,
                                fontSize: 20, fontWeight: FontWeight.bold)
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

  buildEmptyMessage(String message) {
    return CustomMessage(
      text: message,
    );
  }

  buildLoadingSniper() {
    return const LoadingSniper();
  }

  Widget _buildMeetingFormCard({
    required BuildContext context,
    required TextEditingController titleController,
    required TextEditingController descriptionController,
    required TextEditingController startDateController,
    required TextEditingController endDateController,
    required TextEditingController moreInfoController,
    required TextEditingController linkController,
    required ThemeData theme,
  }) {
    final toggleProvider = Provider.of<MeetingPageProvider>(context);
    return DottedBorder(
      borderType: BorderType.RRect,
      radius: Radius.circular(20),
      dashPattern: [10, 10],
      color: Colour().buttonBackGroundRedColor,
      strokeWidth: 4,
      child: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height - 350,
        padding: const EdgeInsets.all(5.0),
        margin: const EdgeInsets.all(5.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Material(
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
                  borderRadius: BorderRadius.circular(3),
                ),
                child: TextFormField(
                  // maxLines: null,
                  // expands: true,
                  controller: titleController,
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
                        controller: descriptionController,
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
                            child: DatePickerFormField(
                              fieldName: 'Select Start Date and Time',
                              dateController: startDateController,
                              onDateSelected: (selectedDate) {
                                startDateController.text = selectedDate.toString();
                                print(
                                    'Selected Start date: ${startDateController.text}');
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
                          child: DatePickerFormField(
                            fieldName: 'Select End Date and Time',
                            dateController: endDateController,
                            onDateSelected: (selectedDate) {
                              endDateController.text = selectedDate.toString();
                              print(
                                  'Selected End date: ${endDateController.text}');
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
                    controller: moreInfoController,
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

            Padding(
              padding: const EdgeInsets.all(8.0),
              child: ElevatedButton(
                onPressed: () {
                  toggleProvider.toggleVisibility();
                },
                child: CustomText(text: toggleProvider.isVisible ? 'Attended' : 'Online Meeting'),
              ),
            ),

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
                      controller: toggleProvider.isVisible ? toggleProvider.linkController : null,
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

  void saveBuildButton(MeetingPageProvider provider) async {
    final meetingProvider = Provider.of<MeetingPageProvider>(context, listen: false);

    final documentProvider = Provider.of<DocumentPageProvider>(context, listen: false);
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    user = User.fromJson(json.decode(prefs.getString("user")!));
    List<Map<String, dynamic>> agendas = [];
    final isValid = _formKey.currentState!.validate();

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

    if (isValid) {
      if (meetingProvider.titleControllers.isNotEmpty) {
        for (int i = 0; i < meetingProvider.titleControllers.length; i++) {
          List<Map<String, dynamic>> childAgendas = [];
          if (meetingProvider.titleControllersList.isNotEmpty) {
            for (int j = 0; j < meetingProvider.titleControllersList[i].length; j++) {

                // Ensure documentProvider.selectedChildDocumentId has enough elements
                while (documentProvider.selectedChildDocumentId.length <= j) {
                  documentProvider.selectedChildDocumentId.add(null);
                }

                // Ensure documentProvider.selectedArabicChildDocumentId has enough elements
                while (documentProvider.selectedArabicChildDocumentId.length <= i) {
                  documentProvider.selectedArabicChildDocumentId.add(null);
                }

                childAgendas.add({
                  "child_agenda_id":(i <= meetingProvider.childrenAgendaIds.length && meetingProvider.childrenAgendaIds[i].length != null) ? meetingProvider.childrenAgendaIds[i] : null,
                  "child_agenda_title": meetingProvider.titleControllersList[i][j].text,
                  "child_agenda_description": meetingProvider.descriptionControllersList[i][j].text,
                  "child_agenda_time": meetingProvider.timeControllersList[i][j].text,
                  "child_presenter": meetingProvider.userControllersList[i][j].text,
                  "child_documentIds":(i < documentProvider.selectedChildDocumentId.length && documentProvider.selectedChildDocumentId[j] != null) ? documentProvider.selectedChildDocumentId[j] : null,
                  "child_membersSignedIds": _membersChildListIds ?? [],
                  if (meetingProvider.arabicTitleControllersList.isNotEmpty)"child_agenda_title_arabic" :meetingProvider.arabicTitleControllersList[i][j].text,
                  if (meetingProvider.arabicDescriptionControllersList.isNotEmpty)"child_agenda_description_arabic": meetingProvider.arabicDescriptionControllersList[i][j].text,
                  if (meetingProvider.arabicTimeControllersList.isNotEmpty)"child_agenda_time_arabic": meetingProvider.arabicTimeControllersList[i][j].text,
                  if (meetingProvider.arabicUserControllersList.isNotEmpty)"child_presenter_arabic": meetingProvider.arabicUserControllersList[i][j].text,
                  "child_documentIds_arabic":(i < documentProvider.selectedArabicChildDocumentId.length && documentProvider.selectedArabicChildDocumentId[i] != null) ? documentProvider.selectedArabicChildDocumentId[i] : null,
                  "child_membersSignedIds_arabic": _arabicMembersChildListIds,
                  "child_files": [
                    if (i < meetingProvider.fileNameChild.length &&
                        j < meetingProvider.fileNameChild[i].length)
                      {
                        "file_name": meetingProvider.fileNameChild[i][j],
                        "file_base64": meetingProvider.fileBase64OneChild[i][j],
                      },
                    if (i < meetingProvider.fileNameTwoChild.length && j < meetingProvider.fileNameTwoChild[i].length)
                      {
                        "file_name_two": meetingProvider.fileNameTwoChild[i][j],
                        "file_base64_two": meetingProvider.fileBase64TwoChild[i][j],
                      },
                  ]
                });
            }
          }

          // Ensure documentProvider.selectedDocumentId has enough elements
          if (documentProvider.selectedDocumentId.length <= i) {
            documentProvider.selectedDocumentId.addAll(List<int?>.filled(i - documentProvider.selectedDocumentId.length + 1, null));
          }

          // Ensure documentProvider.selectedArabicDocumentId has enough elements
          if (documentProvider.selectedArabicDocumentId.length <= i) {
            documentProvider.selectedArabicDocumentId.addAll(List<int?>.filled(i - documentProvider.selectedArabicDocumentId.length + 1, null));
          }

          // Ensure documentProvider.selectedDocumentId has enough elements
          while (documentProvider.selectedDocumentId.length <= i) {
            documentProvider.selectedDocumentId.add(null);
          }

          // Ensure documentProvider.selectedArabicDocumentId has enough elements
          while (documentProvider.selectedArabicDocumentId.length <= i) {
            documentProvider.selectedArabicDocumentId.add(null);
          }

          agendas.add({
            "agenda_id": (i < meetingProvider.agendaIds.length && meetingProvider.agendaIds[i] != null) ? meetingProvider.agendaIds[i] : null,
            "agenda_title": meetingProvider.titleControllers[i].text,
            "agenda_description": meetingProvider.descriptionControllers[i].text,
            "agenda_time": meetingProvider.timeControllers[i].text,
            "agenda_file_name_one"  : (i < meetingProvider.fileName.length && meetingProvider.fileName[i] != null) ? meetingProvider.fileName[i] : null,
            "agenda_file_content_one"  : (i < meetingProvider.fileBase64One.length && meetingProvider.fileBase64One[i] != null) ? meetingProvider.fileBase64One[i] : null,
            "agenda_file_name_two"  : (i < meetingProvider.fileNameTwo.length && meetingProvider.fileNameTwo[i] != null) ? meetingProvider.fileNameTwo[i] : null,
            "agenda_file_content_two"  : (i < meetingProvider.fileBase64Two.length && meetingProvider.fileBase64Two[i] != null) ? meetingProvider.fileBase64Two[i] : null,
            "documentIds": (i < documentProvider.selectedDocumentId.length && documentProvider.selectedDocumentId[i] != null) ? documentProvider.selectedDocumentId[i] : null,
            "presenter": meetingProvider.userControllers[i].text,
            "membersSignedIds": _membersListIds ?? [],
            if (i < meetingProvider.arabicTitleControllers.length && meetingProvider.arabicTitleControllers.isNotEmpty)"agenda_title_arabic":meetingProvider.arabicTitleControllers[i].text,
            if (i < meetingProvider.arabicDescriptionControllers.length &&meetingProvider.arabicDescriptionControllers.isNotEmpty)"agenda_description_arabic":meetingProvider.arabicDescriptionControllers[i].text,
            if (i < meetingProvider.arabicTimeControllers.length &&meetingProvider.arabicTimeControllers.isNotEmpty)"agenda_time_arabic": meetingProvider.arabicTimeControllers[i].text,
            if (i < meetingProvider.arabicUserControllers.length &&meetingProvider.arabicUserControllers.isNotEmpty)"presenter_arabic": meetingProvider.arabicUserControllers[i].text,
            "membersSignedIds_arabic": _arabicMembersListIds,
            "documentIds_arabic": (i < documentProvider.selectedArabicDocumentId.length && documentProvider.selectedArabicDocumentId[i] != null) ? documentProvider.selectedArabicDocumentId[i] : null,
            "childAgendas": childAgendas,
          });
        }
      }


      Map<String, dynamic> event = {
        "meeting_id": widget.event!.meetingId!,
        "created_by": user.userId,
        "meeting_title": meetingProvider.meetingTitleController.text,
        "meeting_description": meetingProvider.meetingDescriptionController.text,
        "meeting_media_name": meetingProvider.linkController.text,
        "is_visible": meetingProvider.isVisible,
        "meeting_by": meetingProvider.moreInfoController.text,
        "meeting_start": meetingProvider.startDateController.text,
        "meeting_end": meetingProvider.endDateController.text,
        "listOfAgendas": agendas,
        "combined": meetingProvider.combined!,
        "business_id": user.businessId
      };
      log.i(provider.agendaParentMaps);
      meetingProvider.setLoading(true);
      await meetingProvider.editingMeeting(event, widget.event!);
      if (meetingProvider.isBack == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: CustomText(text: 'Updated done'),
            backgroundColor: Colors.greenAccent,
          ),
        );
        Navigator.of(context).pushReplacementNamed(BoardMeetingsListView.routeName);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: CustomText(text: ' Update was failed'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
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


