import 'package:diligov_members/widgets/custom_dialog.dart';
import 'package:diligov_members/widgets/custome_text.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:open_file/open_file.dart';
import 'package:diligov_members/providers/meeting_page_provider.dart';
import 'package:provider/provider.dart';
import '../../providers/document_page_provider.dart';
import '../../providers/file_upload_page_provider.dart';
import '../../providers/member_page_provider.dart';
import '../../utility/pdf_api.dart';
import '../check_and_display_file_name.dart';
import '../check_and_display_nested_file_name.dart';
import '../child_document_dialog.dart';
import '../custom_icon.dart';
import '../custom_message.dart';
import '../files_upload_widget.dart';
import '../loading_sniper.dart';
import 'package:flutter_gen/gen_l10n/app_localization.dart';

import '../member_search_dialog.dart';
import '../parent_document_dialog.dart';

class EnglishFormWidget extends StatefulWidget {
  final MeetingPageProvider provider;

  const EnglishFormWidget({
    Key? key,
    required this.provider,
  }) : super(key: key);

  @override
  State<EnglishFormWidget> createState() => _EnglishFormWidgetState();
}

class _EnglishFormWidgetState extends State<EnglishFormWidget> {
  var log = Logger();
  List _membersListIds = [];
  List _membersChildListIds = [];

  @override
  void initState() {
    super.initState();
    // Fetch the documents when the widget is first built
    Future.microtask(() => Provider.of<DocumentPageProvider>(context, listen: false).getListOfDocuments());
    Future.microtask(() => Provider.of<MemberPageProvider>(context, listen: false).getListOfMemberMenu());

  }

  @override
  Widget build(BuildContext context) {
    final enableArabicAndEnglish = context.watch<MeetingPageProvider>().enableArabicAndEnglish;
    return Column(
      children: [
        buildButtonForEnglishParentForm(
            widget.provider), // Assuming you have this function elsewhere
        const SizedBox(height: 10),
        Column(
          children: [
            SizedBox(
              child: ListView.builder(
                scrollDirection: Axis.vertical,
                physics: const ScrollPhysics(),
                shrinkWrap: true,
                itemCount: widget.provider.titleControllers.length,
                itemBuilder: (context, index) {
                  if (index >= 0 && index < widget.provider.titleControllers.length) {
                    print('parent index is ${index}');
                    return Container(
                      padding: const EdgeInsets.all(5),
                      margin: const EdgeInsets.only(bottom: 10),
                      decoration: BoxDecoration(
                        border: const Border(
                          right: BorderSide(width: 0.1),
                          left: BorderSide(width: 0.1),
                          bottom: BorderSide(width: 0.1),
                        ),
                        color: Colors.white,
                        boxShadow: const [
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
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(5.0),
                                color: Colors.white10,
                                child: Text(
                                  '${index + 1}',
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 20),
                                ),
                              ),
                              const SizedBox(width: 6),
                              Flexible(
                                child: SizedBox(
                                  height: 150,
                                  child: Column(
                                    children: [
                                      Expanded(
                                        child: buildCustomTextFormField(
                                          controller: widget
                                              .provider.titleControllers[index],
                                          hint: 'Title',
                                          validatorMessage:
                                              'Please enter title',
                                        ),
                                      ),
                                      CheckAndDisplayFileName(
                                        list: widget.provider.fileName,
                                        index: index,
                                        subIndex: 0,
                                        customWidgetBuilder: (fileName) =>
                                            TextButton(
                                          onPressed: () async {
                                            try {
                                              if (await PDFApi.requestPermission()) {
                                                widget.provider.setWaitingForOpeningFileOne(true);

                                                if (widget.provider.fileName.isNotEmpty) {
                                                  print('open file ${fileName}');
                                                  await PDFApi.downloadAndOpenFile('https://diligov.com/public/meetings/${fileName}',context);
                                                  widget.provider.setWaitingForOpeningFileOne(false);
                                                }

                                                if (widget.provider.filePath.isNotEmpty &&  widget.provider.filePath[index] != null) {
                                                  final result = await OpenFile.open(widget.provider.filePath[index][0]);
                                                  print("Open file result: ${result}");
                                                  widget.provider.setWaitingForOpeningFileOne(false);
                                                }
                                              } else {
                                                // widget.provider.setWaitingForOpeningFile(false);
                                                print(
                                                    "Lacking permissions to access the file");
                                              }
                                            } catch (e) {
                                              widget.provider
                                                  .setWaitingForOpeningFileOne(
                                                      false);
                                              print("Error opening PDF: $e");
                                            }
                                          },
                                          child: widget.provider
                                                      .waitingForOpeningFileOne ==
                                                  true
                                              ? CircularProgressIndicator(
                                                  color: Colors.green,
                                                )
                                              : Row(
                                                  mainAxisSize:MainAxisSize.max,
                                                  children: [
                                                    Flexible(
                                                        flex: 5,
                                                        child: CustomText(
                                                          text: fileName,
                                                          softWrap: true,
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                        )),
                                                    Flexible(
                                                      flex: 1,
                                                      child: CustomIcon(
                                                          icon: Icons
                                                              .file_open),
                                                    ),
                                                    Flexible(
                                                        flex: 1,
                                                        child: IconButton(
                                                          onPressed: () {
                                                            widget.provider.removeFiles(index);
                                                          },
                                                          icon: CustomIcon(
                                                            icon: Icons
                                                                .delete_forever_rounded,
                                                            color: Colors.red,
                                                          ),
                                                        )
                                                    ),
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
                                              ),
                                            ),
                                          ),
                                          Flexible(
                                            flex: 1,
                                            child: TextButton(
                                              onPressed: () {
                                                  final memberProvider = Provider.of<MemberPageProvider>(context,listen: false);
                                                  openMemberSearchBoxDialog(context, memberProvider);
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
                              Expanded(
                                child: SizedBox(
                                  height: 100,
                                  child: buildCustomTextFormField(
                                    controller: widget
                                        .provider.descriptionControllers[index],
                                    hint: 'Description',
                                    validatorMessage:
                                        'Please enter description',
                                  ),
                                ),
                              ),
                              const SizedBox(width: 6),
                              Expanded(
                                child: SizedBox(
                                  height: 100,
                                  child: buildCustomTextFormField(
                                    controller:
                                        widget.provider.timeControllers[index],
                                    hint: 'Time',
                                    validatorMessage: 'Please enter time',
                                  ),
                                ),
                              ),
                              const SizedBox(width: 6),
                              Expanded(
                                child: SizedBox(
                                  height: 100,
                                  child: buildCustomTextFormField(
                                    controller:
                                        widget.provider.userControllers[index],
                                    hint: 'Presenter',
                                    validatorMessage: 'Please enter presenter',
                                  ),
                                ),
                              ),
                              const SizedBox(height: 5),
                              Column(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                mainAxisSize: MainAxisSize.max,
                                children: [
                                  buildRemoveButtonForParentEnglishForm(
                                      index, widget.provider),
                                  buildButtonForEnglishChildren(
                                      index, widget.provider),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 5),
                          buildReOrderListFormForEnglishChildrenWidget(
                              index, widget.provider),
                        ],
                      ),
                    );
                  } else {
                    return const SizedBox
                        .shrink(); // Handle invalid index gracefully
                  }
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  buildRemoveButtonForParentEnglishForm(
          int index, MeetingPageProvider provider) =>
      Padding(
        padding: const EdgeInsets.only(bottom: 10.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            InkWell(
              key: UniqueKey(),
              child: CustomIcon(
                icon: Icons.remove_circle_outline,
                color: Colors.red,
                size: 30.0,
              ),
              onTap: () {
                if (index < provider.agendaIds.length) {
                  if (provider.titleControllers.length > index &&
                      provider.titleControllers[index].text.isNotEmpty) {
                    provider.addAgendaParentIds(provider.agendaIds[index]);
                    Map<String, dynamic> data = {
                      "agenda_id": provider.agendaIds[index],
                      "index": index
                    };
                    dialogDeleteAgenda(data);
                  }
                } else {
                  provider.removeButtonForEnglishParentFormFields(index);
                }
              },
            ),
          ],
        ),
      );

  buildButtonForEnglishChildren(int i, MeetingPageProvider provider) => Padding(
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
                print(i);
                provider.addNewFormForEnglishChildren(i);
              },
            ),
          ],
        ),
      );

  Widget buildReOrderListFormForEnglishChildrenWidget(int i, MeetingPageProvider provider) {
    bool hasItems = provider.childItems.isNotEmpty && provider.childItems[i].isNotEmpty;
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
                  if (provider.childItems.isNotEmpty &&
                      provider.childItems[i].isNotEmpty)
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
                                text: '${newIndex + 1}.${j + 1}',
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
                                        controller:
                                            provider.titleControllersList[i][j],
                                        hint: 'Title',
                                        validatorMessage: 'Please enter title',
                                      ),
                                    ),
                                    // english children
                                    NestedFileNameWidget(
                                      list: provider.fileNameChild,
                                      index: i,
                                      subIndex: j,
                                      subSubIndex: 0,
                                      customWidgetBuilder: (fileName) =>
                                          TextButton(
                                        onPressed: () async {
                                          try {
                                            if (await PDFApi
                                                .requestPermission()) {
                                              widget.provider
                                                  .setWaitingForOpeningFileChild(
                                                      true);

                                              if (widget.provider.fileNameChild
                                                  .isNotEmpty) {
                                                print('open file ${fileName}');
                                                await PDFApi.downloadAndOpenFile(
                                                    'https://diligov.com/public/meetings/${fileName}',
                                                    context);
                                                widget.provider
                                                    .setWaitingForOpeningFileChild(
                                                        false);
                                              }

                                              if (widget.provider.filePathChild
                                                      .isNotEmpty &&
                                                  widget.provider
                                                              .filePathChild[i]
                                                          [j][0] !=
                                                      null) {
                                                final result =
                                                    await OpenFile.open(widget
                                                            .provider
                                                            .filePathChild[i][j]
                                                        [0]);
                                                print(
                                                    "Open file result: ${result}");
                                                widget.provider
                                                    .setWaitingForOpeningFileChild(
                                                        false);
                                              }
                                            } else {
                                              // widget.provider.setWaitingForOpeningFile(false);
                                              print(
                                                  "Lacking permissions to access the file");
                                            }
                                          } catch (e) {
                                            widget.provider
                                                .setWaitingForOpeningFileChild(
                                                    false);
                                            print("Error opening PDF: $e");
                                          }
                                        },
                                        child: widget.provider
                                                    .waitingForOpeningFileChild ==
                                                true
                                            ? CircularProgressIndicator(
                                                color: Colors.green,
                                              )
                                            : Row(
                                                mainAxisSize: MainAxisSize.max,
                                                children: [
                                                  Flexible(
                                                      flex: 5,
                                                      child: CustomText(
                                                        text: fileName,
                                                        softWrap: true,
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                      )),
                                                  Flexible(
                                                      flex: 1,
                                                      child: CustomIcon(
                                                          icon:
                                                              Icons.file_open)),
                                                  Flexible(
                                                      flex: 1,
                                                      child: IconButton(
                                                        onPressed: () {
                                                          provider.removeFilesChild(i,j);
                                                        },
                                                        icon: CustomIcon(
                                                          icon: Icons
                                                              .delete_forever_rounded,
                                                          color: Colors.red,
                                                        ),
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
                                              // openDocumentChildBoxDialog(context, i, j);
                                              openDocumentChildOptionBoxDialog(
                                                  context, i, j);
                                            },
                                            child: CustomText(
                                              text: 'Add file',
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                        Flexible(
                                          flex: 1,
                                          child: TextButton(
                                            onPressed: () {
                                                final memberProvider = Provider.of<MemberPageProvider>(context, listen: false);
                                                openMemberChildSearchBoxDialog(context, memberProvider);
                                            },
                                            child: Row(
                                              children: [
                                                CustomText(text: 'Signature'),
                                                CustomIcon(icon: Icons.edit),
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
                                  controller: provider.timeControllersList[i]
                                      [j],
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
                                  controller: provider.userControllersList[i]
                                      [j],
                                  hint: 'Presenter',
                                  validatorMessage: 'Please enter presenter',
                                ),
                              ),
                            ),
                            buildRemoveEnglishChildrenButton(i, j, provider),
                          ],
                        ),
                        trailing: ReorderableDragStartListener(
                          key: ValueKey<int>(provider.childItems.length),
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

  buildRemoveEnglishChildrenButton(
          int i, int j, MeetingPageProvider provider) =>
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
                // log.i(provider.childrenAgendaIds);
                // Check if the parent and child indices are valid
                if (i >= 0 &&
                    i < provider.childrenAgendaIds.length &&
                    j >= 0 &&
                    j < provider.childrenAgendaIds[i].length) {
                  final childAgendaId = provider.childrenAgendaIds[i][j];

                  // If the childAgendaId is empty or null, remove it locally (newly added field)
                  if (childAgendaId == null || childAgendaId.isEmpty) {
                    provider.removeEnglishChildItem(i, j);
                  } else {
                    // If the child has an ID, show the delete dialog
                    Map<String, dynamic> data = {
                      "agenda_child_id": childAgendaId,
                      "index": i,
                      "child": j
                    };
                    dialogDeleteAgendaEnglishChild(data);
                  }
                } else {
                  log.i("${i} -- ${j}");
                  provider.removeEnglishChildItem(i, j);
                  print('Invalid parent or child index');
                }
              },
            ),
          ],
        ),
      );

  Future dialogDeleteAgendaEnglishChild(Map<String, dynamic> data) =>
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return CustomDialog(
            title: '${AppLocalizations.of(context)!.are_you_sure_to_delete}',
            onConfirm: () async {
              String message = await removeAgendaEnglishChild(data);
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: CustomText(text: message),
                  // backgroundColor: message.contains('successfully') ? Colors.greenAccent : Colors.redAccent,
                  backgroundColor: message == 'Meeting deleted successfully.'
                      ? Colors.greenAccent
                      : Colors.redAccent,
                ),
              );
            },
            onCancel: () {
              Navigator.of(context).pop();
            },
          );
        },
      );

  Future<String> removeAgendaEnglishChild(Map<String, dynamic> data) async {
    final provider = Provider.of<MeetingPageProvider>(context, listen: false);
    // Step 1: Check if the meeting has associated agendas
    String message = await provider.deleteAgendaChild(data);
    provider.removeEnglishChildItem(data['index'], data["child"]);
    return message;
  }

  Widget buildButtonForEnglishParentForm(MeetingPageProvider provider) => Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          InkWell(
            onTap: () {
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
                                  onFilePicked: (pickedFileName,
                                      pickedFileContent, filePaths) {
                                    meetingPageProvider.setFileAtIndex(
                                        i,
                                        pickedFileName,
                                        pickedFileContent,
                                        filePaths);
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
                                  onFilePicked: (pickedFileName,
                                      pickedFileContent, filePaths) {
                                    meetingPageProvider.setFileTwoAtIndex(
                                        i,
                                        pickedFileName,
                                        pickedFileContent,
                                        filePaths);
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
                          final provider = Provider.of<DocumentPageProvider>(context, listen: false);
                          openParentDocumentBoxDialog(context, i, provider);
                        },
                        child: Column(
                          children: [
                            provider.selectedDocumentId != null
                                ? CustomText(
                                    text:
                                        'Selected Document: ${provider.getSelectedDocumentName(i)}',
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

  Future<void> openParentDocumentBoxDialog(BuildContext context, int i, DocumentPageProvider provider) {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return ParentDocumentDialog(index: i, provider: provider);
      },
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
                  backgroundColor: message == 'Meeting deleted successfully.'
                      ? Colors.greenAccent
                      : Colors.redAccent,
                ),
              );
            },
            onCancel: () {
              Navigator.of(context).pop();
            },
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
    } else {
      provider.removeButtonForEnglishParentFormFields(data['index']);
    }

    return message;
  }

  Future<String> showAdditionalConfirmationDialog(
      BuildContext context, Map<String, dynamic> data) async {
    // Await the dialog result and ensure non-null value is returned
    String? result = await showDialog<String>(
      context: context,
      builder: (BuildContext dialogContext) {
        return CustomDialog(
          title:
              'This meeting has associated agendas. Are you sure you want to delete it?',
          onConfirm: () async {
            final provider =
                Provider.of<MeetingPageProvider>(context, listen: false);
            String message = await provider.deleteAgendaWithChildren(
                data); // Call the final delete function
            provider.removeButtonForEnglishParentFormFields(data['index']);
            Navigator.of(dialogContext)
                .pop(message); // Return the message to the parent dialog
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


  Future<void> openDocumentChildBoxDialog(BuildContext context, int i, int j) {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return ChildDocumentChildDialog(i: i, j: j);
      },
    );
  }


  Future<void> openDocumentChildOptionBoxDialog(BuildContext context, int i, int j) {
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
                                  onFilePicked: (pickedFileName,
                                      pickedFileContent, filePaths) {
                                    meetingPageProvider.setFileChildAtIndex(
                                        i,
                                        j,
                                        pickedFileName,
                                        pickedFileContent,
                                        filePaths);
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
                                      List<String> pickedFileContent,
                                      filePaths) {
                                    meetingPageProvider.setFileChildTwoAtIndex(
                                        i,
                                        j,
                                        pickedFileName,
                                        pickedFileContent,
                                        filePaths);
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
                            provider.selectedChildDocumentId.length > j &&
                                    provider.selectedChildDocumentId[j] != null
                                ? CustomText(
                                    text:
                                        'Selected Document: ${provider.getSelectedChildDocumentName(i, j)}',
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
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: CustomText(text: 'Save'),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: CustomText(text: 'Close'),
                ),
              ],
            );
          },
        );
      },
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
