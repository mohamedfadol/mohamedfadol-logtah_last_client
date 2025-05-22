import 'dart:math';

import 'package:diligov_members/models/agenda_model.dart';
import 'package:diligov_members/providers/note_page_provider.dart';
import 'package:diligov_members/src/test/show_draggable_canvas.dart';
import 'package:diligov_members/src/text_annotation.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:logger/logger.dart';
import 'package:flutter_gen/gen_l10n/app_localization.dart';
import 'package:multi_select_flutter/chip_display/multi_select_chip_display.dart';
import 'package:multi_select_flutter/dialog/multi_select_dialog_field.dart';
import 'package:multi_select_flutter/util/multi_select_item.dart';
import 'package:provider/provider.dart';
import '../colors.dart';
import '../core/domains/app_uri.dart';
import '../models/board_model.dart';
import '../models/committee_model.dart';
import '../models/data/years_data.dart';
import '../models/member.dart';
import '../models/user.dart';
import '../providers/audio_recording_provider.dart';
import '../providers/laboratory_file_processing_provider_page.dart';
import '../providers/member_page_provider.dart';
import '../utility/edit_laboratory_file_processing.dart';
import '../utility/meetings_expansion_panel.dart';
import '../utility/pdf_api.dart';
import '../utility/utils.dart';
import '../widgets/appBar.dart';
import '../widgets/custom_icon.dart';
import '../widgets/custom_message.dart';
import '../widgets/custome_text.dart';
import '../widgets/dropdown_string_list.dart';
import '../widgets/loading_sniper.dart';

class RenderFileManager extends StatefulWidget {
  final String path;
  final Agenda agenda;
  const RenderFileManager({super.key, required this.path, required this.agenda,});

  @override
  State<RenderFileManager> createState() => _RenderFileManagerState();
}

class _RenderFileManagerState extends State<RenderFileManager>with SingleTickerProviderStateMixin {

  User user = User();
  var log = Logger();
  int pageIndexing = 0;
  // Initial Selected Value
  String yearSelected = '2024';
  String localPath = "";
  UniqueKey? keyTile;
  TabController? defaultTabBarViewController;
  int tabIndex = 0;

  final _parentScaffoldKey = GlobalKey<ScaffoldState>();

  bool isLoading = false;
  int indexing = 0;
  int? totalPagesOfFile;

  List<TextAnnotation> textAnnotations = [];
  Color selectedColor = Colors.black; // Default color
  Color iconColor = Colors.grey;
  List<Map<String, dynamic>> textList = [];
  final TextEditingController textEditingController = TextEditingController();
  late TextEditingController? _controller = TextEditingController();
  List _membersNoteListIds = [];

  void initState() {
    defaultTabBarViewController = TabController(length: 3, vsync: this);
    preparePdfFileFromNetwork();
    super.initState();
  }

  @override
  void dispose() {
    defaultTabBarViewController!.dispose();
    super.dispose();
  }


  void _handleEditTextChange() {
    String text = _controller!.text;
    if (text.length > 25 && !text.contains('\n')) {
      // Find the last space before the 25th character
      int breakPoint = text.substring(0, 25).lastIndexOf(' ');
      if (breakPoint == -1) {
        breakPoint = 25; // If no space found, break at exactly 25 characters
      }
      String newText = '${text.substring(0, breakPoint)}\n${text.substring(breakPoint)}';
      _controller!.value = TextEditingValue(
        text: newText,
        selection: TextSelection.fromPosition(TextPosition(offset: breakPoint + 1)),
      );
    }
  }

  void _handleTextChange() {
    String text = textEditingController.text;
    if (text.length > 25 && !text.contains('\n')) {
      // Find the last space before the 25th character
      int breakPoint = text.substring(0, 25).lastIndexOf(' ');
      if (breakPoint == -1) {
        breakPoint = 25; // If no space found, break at exactly 25 characters
      }
      String newText = '${text.substring(0, breakPoint)}\n${text.substring(breakPoint)}';
      textEditingController.value = TextEditingValue(
        text: newText,
        selection: TextSelection.fromPosition(TextPosition(offset: breakPoint + 1)),
      );
    }
  }

  // Assuming textAnnotations is a List<TextAnnotation>
  int getNextAnnotationId() {
    if (textAnnotations.isNotEmpty) {
      return textAnnotations.map((a) => a.id!).reduce(max) + 1;
    }
    return 1; // Start IDs from 1 if the list is empty
  }

  Widget buildTextInputField() {

    return Container(
      padding: const EdgeInsets.all(8),
      color: Colors.white,
      child: Consumer<LaboratoryFileProcessingProviderPage>(
        builder: (BuildContext context, provider, child) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    color: Colors.grey[300],
                    child: IconButton(
                      icon: const Icon(Icons.check, color: Colors.green,), // Icon for saving the text
                      onPressed: () {
                        final newId = getNextAnnotationId();
                        setState(() {
                          // Create a new annotation with a unique ID
                          textAnnotations.add(
                              TextAnnotation(
                                position: provider.tempTextPosition!,
                                text: textEditingController.text,
                                id: newId,
                                color: selectedColor,
                                pageIndex: provider.indexing,
                                isPrivate: provider.isPrivate,
                              )
                          );

                          textList.add({
                            "id": newId,
                            "text": textEditingController!.text,
                            "positionDx": provider.tempTextPosition!.dx,
                            "positionDy": provider.tempTextPosition!.dy,
                            "isPrivate": provider.isPrivate,
                            "pageIndex": provider.indexing
                          });

                          provider.showTextInput = false; // Hide TextField after saving
                          textEditingController.clear(); // Clear text field for next input
                          provider.tempTextPosition = null; // Reset position

                        });


                      },

                    ),
                  ),
                  const SizedBox(width: 5.0,),
                  Container(
                    color: Colors.grey[300],
                    child: IconButton(
                      icon: const Icon(Icons.close, color: Colors.red,), // Icon for closing the text field
                      onPressed: () {
                        provider.toggleCloseTextInput();
                      },
                    ),
                  ),

                  const SizedBox(width: 5.0,),
                  Container(
                    color: Colors.grey[300],
                    child: Tooltip(
                      message: provider.isPrivate ? 'make public' : 'make private' ,
                      height: 40.0,
                      padding: EdgeInsets.all(10.0),
                      verticalOffset: 48,
                      preferBelow: false,
                      child: IconButton(
                        onPressed: provider.togglePrivate,
                        icon: Icon( provider.isPrivate ? Icons.visibility_off_outlined : Icons.remove_red_eye_outlined, color: iconColor,),
                      ),
                    ),
                  ),
                  _selectMenu()
                ],
              ),
              const SizedBox(height: 5.0,),
              Container(
                color: Colors.white,
                width: 200, // Adjust as needed
                child: TextField(
                  style: TextStyle(color: selectedColor!),
                  controller: textEditingController,
                  maxLines: null,
                  autofocus: true,
                  onChanged: (value) => provider.tempInputText = value,
                  decoration: const InputDecoration(
                    hintText: "Enter text",
                    border: OutlineInputBorder(),
                  ),
                  onSubmitted: (value) {
                    final newId = getNextAnnotationId();
                    setState(() {
                      textAnnotations.add(
                          TextAnnotation(
                            position: provider.tempTextPosition!,
                            text: value,
                            id: newId,
                            color: selectedColor,
                            pageIndex: provider.indexing,
                            isPrivate: provider.isPrivate,
                          )
                      );
                      textList.add({
                        "id": newId,
                        "text": value,
                        "positionDx": provider.tempTextPosition!.dx,
                        "positionDy": provider.tempTextPosition!.dy,
                        "isPrivate": provider.isPrivate,
                        "pageIndex": provider.indexing
                      });
                      provider.showTextInput = false; // Hide TextField after submission
                      provider.tempTextPosition = null; // Reset position for the next input
                    });
                    // provider.showTextInput = false; // Hide TextField after submission
                    // provider.tempTextPosition = null; // Reset position for the next input
                  },
                ),
              ),
            ],
          );
        },

      ),
    );
  }


  void updateTextListObjectById(List<Map<String, dynamic>> list, int id, Map<String, dynamic> newData) {
    // Find the object with the specified ID and update its properties
    list.forEach((element) {
      if (element["id"] == id) {
        newData.forEach((key, value) {
          if (element.containsKey(key)) {
            element[key] = value;
          }
        });
      }
    });
  }



  Widget _selectMenu() {
    return PopupMenuButton<int>(
        position: PopupMenuPosition.under,
        padding: EdgeInsets.only(bottom: 0.0),
        icon: Container(
          padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 4.0),
          decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.all(Radius.circular(20)),
              border: Border.all(width: 1.0, color: Colors.white24)),
          child: CustomIcon(
            icon: Icons.share,
            size: 30.0,
            color: Colors.green,
          ),
        ),
        onSelected: (value) => 0,
        itemBuilder: (context) => [
          PopupMenuItem<int>(
            onTap: () {
              Provider.of<MemberPageProvider>(context, listen: false)
                  .getListOfMemberMenu()
                  .then((_) {
                openMemberSearchBoxDialog(context);
              });
            },
            value: 0,
            child: ListTile(
              leading: CustomIcon(
                icon: Icons.list,
              ),
              title: Text("Boards"),
            ),
          ),
          PopupMenuItem<int>(
            value: 1,
            child: ListTile(
              leading: CustomIcon(
                icon: Icons.list,
              ),
              title: Text("Committees"),
            ),
          ),
          PopupMenuItem<int>(
            onTap: () {
              Provider.of<MemberPageProvider>(context, listen: false)
                  .getListOfMemberMenu()
                  .then((_) {
                openMemberSearchBoxDialog(context);
              });
            },
            value: 2,
            child: ListTile(
              leading: CustomIcon(
                icon: Icons.list,
              ),
              title: Text("Members"),
            ),
          ),
        ]);
  }

  Future<void> openMemberSearchBoxDialog(BuildContext context) {
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
                  text: 'Share Notes With Members',
                  color: Colors.red,
                  fontSize: 20,
                  fontWeight: FontWeight.bold),
              content: Form(
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
                      member, member.memberFirstName!,))
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
                      _membersNoteListIds = provider.selectedMembersNoteList
                          .map((e) => e.memberId)
                          .toList();
                      provider
                          .setSelectedMembersNoteId(_membersNoteListIds);
                      print(_membersNoteListIds);
                    },
                    chipDisplay: MultiSelectChipDisplay(
                      onTap: (item) {
                        provider.removeSelectedMembersNote(item);
                      },
                    ),
                  ),
                ),
              ),
              actions: [
                // Your actions here, for example, buttons that use model methods
              ],
            );
          },
        );
      },
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

  Future<void> preparePdfFileFromNetwork() async {
    try {
      if (await PDFApi.requestPermission()) {
        //'https://diligov.com/public/charters/1/logtah.pdf'; // Replace with your PDF URL
        final filePath = await PDFApi.loadNetwork(widget.path);
        setState(() {
          localPath = filePath.path;
        });
        print('preparePdfFileFromNetwork function $localPath');
      } else {
        print("Lacking permissions to access the file in preparePdfFileFromNetwork function");
        return;
      }
    } catch (e) {
      print("Error preparePdfFileFromNetwork function PDF: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: Header(context),
      body: Container(
        padding: EdgeInsets.symmetric(horizontal: 10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            buildFullTopFilter(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 500,
                  margin: EdgeInsets.only(right: 25.0),
                  color: Theme.of(context).scaffoldBackgroundColor,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      buildStaticDividerSizeBox(Colors.grey[100]!),
                      SizedBox(
                        height: 50,
                        width: 400,
                        child: TabBar(
                          onTap: (index) {
                            setState(() {
                              tabIndex = index;
                            });
                            print(index);
                          },
                          enableFeedback: true,
                          controller: defaultTabBarViewController,
                          dividerColor: Colors.grey,
                          indicatorColor: Colour().buttonBackGroundRedColor,
                          labelColor: Colour().buttonBackGroundRedColor,
                          unselectedLabelColor: Colors.grey,
                          labelStyle: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                              color: Colour().buttonBackGroundRedColor),
                          tabs: [
                            Tab(child: CustomText(text:"Boards")),
                            Tab(child: CustomText(text:"Committees")),
                            Tab(
                                child: Consumer<NotePageProvider>(
                                  builder: (context, provider, child) {
                                    return Wrap(
                                      direction: Axis.horizontal,
                                      crossAxisAlignment: WrapCrossAlignment.center,
                                      spacing: 2,
                                      children: [
                                          Checkbox(
                                            checkColor: Colour().mainWhiteIconColor,
                                            value: provider.isChecked,
                                            onChanged: (newValue) {
                                              provider.setChecked(newValue!);
                                              Map<String, dynamic> data = {"isChecked": newValue!};
                                              provider.getListOfBoardNotes(data);
                                          },
                                          fillColor: MaterialStateProperty.all<Color>(Colour().buttonBackGroundRedColor),
                                        ),
                                        CustomText(text: "Filter"),
                                      ],
                                    );
                                  },
                                )
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: SizedBox(
                          width: 400,
                          child: TabBarView(
                              controller: defaultTabBarViewController,
                              children: [
                                Consumer<NotePageProvider>(
                                    builder: (context, provider, child) {
                                  if (provider.boardsData?.boards == null) {
                                    provider.getListOfBoardNotes(context);
                                    return Center(
                                      child: SpinKitThreeBounce(
                                        itemBuilder:
                                            (BuildContext context, int index) {
                                          return DecoratedBox(
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(15),
                                              color: index.isEven
                                                  ? Colors.red
                                                  : Colors.green,
                                            ),
                                          );
                                        },
                                      ),
                                    );
                                  }
                                  return provider.boardsData!.boards!.isEmpty
                                      ? buildEmptyContainerNotes()
                                      : buildResponseDataOfBoardNotes(provider);
                                }),
                                Consumer<NotePageProvider>(
                                    builder: (context, provider, child) {
                                  if (provider.committeesData?.committees ==
                                      null) {
                                    provider.getListOfCommitteeNotes(context);
                                    return Center(
                                      child: SpinKitThreeBounce(
                                        itemBuilder:
                                            (BuildContext context, int index) {
                                          return DecoratedBox(
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(15),
                                              color: index.isEven
                                                  ? Colors.red
                                                  : Colors.green,
                                            ),
                                          );
                                        },
                                      ),
                                    );
                                  }
                                  return provider
                                          .committeesData!.committees!.isEmpty
                                      ? buildEmptyContainerNotes()
                                      : buildResponseDataOfCommitteesNotes(
                                          provider);
                                }),
                                SizedBox(),
                              ]),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: RepaintBoundary(
                    key: _parentScaffoldKey,
                    child: SafeArea(
                      child: Stack(
                        children: [
                          localPath.isNotEmpty
                              ? SizedBox(
                                  height: 500,
                                  child: PDFView(
                                    fitEachPage: true,
                                    filePath: localPath,
                                    autoSpacing: true,
                                    enableSwipe: true,
                                    pageSnap: true,
                                    swipeHorizontal: false,
                                    nightMode: false,
                                    onPageChanged:
                                        (int? currentPage, int? totalPages) {
                                      print("Current page: $currentPage!, Total pages: $totalPages!");
                                      setState(() {
                                        pageIndexing = currentPage!;
                                      });
                                      print(pageIndexing);
                                      // You can use this callback to keep track of the current page.
                                    },
                                  ),
                                )
                              : const Center(child: CircularProgressIndicator()),

                          if (widget.agenda.canvasItems!.isNotEmpty)
                          ...widget.agenda.canvasItems!.asMap().entries.where((stroke) => stroke.value.pageIndex == pageIndexing).map((entry) {
                              return ShowDraggableCanvas(
                                  canvasPageIndex: entry!.value!.pageIndex!,
                                  key: ValueKey("${entry.key}#hfhfhf"),
                                  item: entry.value,
                                );
                          }).toList(),


                          if (widget.agenda.notes!.isNotEmpty)
                            ...widget.agenda.notes!
                                .where((annotation) => annotation.pageIndex ==pageIndexing)
                                .map((annotation) => Positioned(
                                    left: annotation.positionDx,
                                    top: annotation.positionDy,
                                    child: Builder(builder: (context) {
                                      return Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 4, vertical: 2),
                                        color: Colors.yellow.withAlpha(100),
                                        child: Column(
                                          children: [
                                            CustomText(text: annotation.text ?? '', color: Colors.black,fontSize: 18 ),
                                            Padding(
                                              padding: EdgeInsets.symmetric(vertical: 15.0),
                                              child: Container(
                                                padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 10.0),
                                                decoration: BoxDecoration(
                                                    color: Colors.red[50],
                                                    border: Border.all(width: 0.5, color: Colors.grey),
                                                    borderRadius: BorderRadius.all(Radius.circular(10))
                                                ),
                                                child: CustomText(text: 'author ${annotation.user?.firstName} ${annotation.user?.lastName} \n ${Utils.convertStringToDateFunction(annotation.createdAt!)}' ?? '',
                                                    color: Colors.grey[800],
                                                    fontSize: 18),
                                              ),
                                            ),
                                          ],
                                        ),
                                      );
                                    }),
                                  ),
                                ),

                          if (widget.agenda.audioNotes!.isNotEmpty)
                            SizedBox(
                              width: 300,
                              height: 400,
                              child: ListView.builder(
                                itemCount: widget.agenda.audioNotes!.length,
                                itemBuilder: (BuildContext context, int index) {
                                  return GestureDetector(
                                    child: Container(
                                      decoration: BoxDecoration(
                                          color: Colors.transparent,
                                          border: Border.all(
                                              width: 0.1, color: Colors.grey)),
                                      // padding: EdgeInsets.symmetric(vertical: 5,horizontal: 5),
                                      child: ListTile(
                                        title: CustomText(
                                          text: widget.agenda.audioNotes![index].audioNoteName!,
                                          fontSize: 20,
                                          color: Colors.black,
                                        ),
                                        trailing:
                                            Consumer<AudioRecordingProvider>(
                                                builder:
                                                    (context, provider, child) {
                                          return IconButton(
                                            onPressed: () async {
                                              final String dir = '${AppUri.baseUntilPublicDirectory}/record_notes/${widget.agenda.audioNotes![index].businessId!.toString()}/notes/records/${widget.agenda.audioNotes![index].audioNoteRandomName!}';
                                              print(dir);
                                              await provider.playAudioFromAssets(dir);
                                            },
                                            icon: Icon(
                                              Icons.play_circle,
                                              color: Colors.greenAccent,
                                            ),
                                          );
                                        }),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            )
                        ],
                      ),
                    ),
                  ),
                )
              ],
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async{
          Navigator.of(context).push(MaterialPageRoute(builder: (context) => EditLaboratoryFileProcessing(agenda: widget.agenda,)));
        },
        child: const Icon(Icons.edit),
      ),
    );
  }


  Widget buildFullTopFilter() => Padding(
        padding:
            const EdgeInsets.only(top: 3.0, left: 0.0, right: 8.0, bottom: 8.0),
        child: Row(
          children: [
            Container(
              width: 200,
              padding:
                  const EdgeInsets.symmetric(vertical: 8.0, horizontal: 15.0),
              color: Colour().buttonBackGroundRedColor,
              child: Center(
                  child: CustomText(
                      text: 'My Notes',
                      color: Colour().mainWhiteTextColor,
                      fontSize: 20,
                      fontWeight: FontWeight.bold)),
            ),
            const SizedBox(
              width: 5.0,
            ),
            Container(
              width: 200,
              padding:
                  const EdgeInsets.symmetric(vertical: 8.0, horizontal: 15.0),
              color: Colour().buttonBackGroundRedColor,
              child: DropdownButtonHideUnderline(
                child: DropdownStringList(
                  boxDecoration: Colour().mainWhiteTextColor,
                  hint: CustomText(
                      text: AppLocalizations.of(context)!.select_year,
                      color: Colour().mainWhiteTextColor),
                  selectedValue: yearSelected,
                  dropdownItems: yearsData,
                  onChanged: (String? newValue) async {
                    yearSelected = newValue!.toString();
                    setState(() {
                      yearSelected = newValue;
                    });
                    Map<String, dynamic> data = {
                      "dateYearRequest": yearSelected,
                      // "member_id": "member_id"
                    };
                    NotePageProvider providerGetNotesByDateYear =
                        Provider.of<NotePageProvider>(context, listen: false);
                    if (tabIndex == 0) {
                      Future.delayed(Duration.zero, () {
                        providerGetNotesByDateYear.getListOfBoardNotes(data);
                      });
                    } else {
                      Future.delayed(Duration.zero, () {
                        providerGetNotesByDateYear
                            .getListOfCommitteeNotes(data);
                      });
                    }
                  },
                  color: Colors.grey,
                ),
              ),
            ),
          ],
        ),
      );



  Widget buildStaticDividerSizeBox(Color dividerColor) {
    return new SizedBox(
      height: 2.0,
      width: 400,
      child: new Container(
        margin: new EdgeInsetsDirectional.only(start: 50.0, end: 1.0),
        height: 2.0,
        color: dividerColor,
      ),
    );
  }

  Widget buildEmptyContainerNotes() {
    return Container(
        decoration:
            BoxDecoration(border: Border.all(color: Colors.white, width: 1.0)),
        padding: const EdgeInsets.all(20.0),
        child: Center(
          child: CustomText(
            text: AppLocalizations.of(context)!.no_data_to_show,
            fontSize: 20.0,
            fontWeight: FontWeight.bold,
            color: Colors.red,
          ),
        ));
  }

  Widget buildResponseDataOfBoardNotes(NotePageProvider provider) {
    return Container(
      // color: Colors.red,
      padding: EdgeInsets.only(top: 10.0),
      child: SingleChildScrollView(
        physics: BouncingScrollPhysics(),
        scrollDirection: Axis.vertical,
        child: ExpansionPanelList(
          materialGapSize: 10.0,
          dividerColor: Colors.grey[100],
          elevation: 3.0,
          expandedHeaderPadding: EdgeInsets.all(0.0),
          expandIconColor: Colour().mainWhiteIconColor,
          expansionCallback: (int index, bool isExpanded) {
            provider.toggleBoardParentMenu(index);
            print(index);
          },
          children:
              provider.boardsData!.boards!.map<ExpansionPanel>((Board board) {
            return ExpansionPanel(
              canTapOnHeader: true,
              backgroundColor:
                  board.isExpanded! ? Colors.grey : Colors.blueGrey[200],
              headerBuilder: (BuildContext context, bool isExpanded) {
                return ListTile(
                  title: CustomText(
                    text: '${board.boardName ?? ''}',
                    fontWeight: FontWeight.bold,
                  ),
                );
              },
              body: MeetingsExpansionPanel(
                meetings: board.meetings!,
              ),
              isExpanded: board.isExpanded!,
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget buildResponseDataOfCommitteesNotes(NotePageProvider provider) {
    return Container(
      // color: Colors.red,
      padding: EdgeInsets.only(top: 10.0),
      child: SingleChildScrollView(
        physics: BouncingScrollPhysics(),
        scrollDirection: Axis.vertical,
        child: ExpansionPanelList(
          materialGapSize: 10.0,
          dividerColor: Colors.grey[100],
          elevation: 3.0,
          expandedHeaderPadding: EdgeInsets.all(0.0),
          expandIconColor: Colors.white,
          expansionCallback: (int index, bool isExpanded) {
            provider.toggleCommitteeParentMenu(index);
            print(index);
          },
          children: provider.committeesData!.committees!
              .map<ExpansionPanel>((Committee committee) {
            return ExpansionPanel(
              canTapOnHeader: true,
              backgroundColor:
                  committee.isExpanded ? Colors.grey : Colors.blueGrey[200],
              headerBuilder: (BuildContext context, bool isExpanded) {
                return ListTile(
                  title: CustomText(
                    text: '${committee.committeeName ?? ''}',
                    fontWeight: FontWeight.bold,
                  ),
                );
              },
              body: MeetingsExpansionPanel(
                meetings: committee.meetings!,
              ),
              isExpanded: committee.isExpanded,
            );
          }).toList(),
        ),
      ),
    );
  }
}

