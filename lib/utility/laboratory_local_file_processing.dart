import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'dart:ui' as ui;

import 'package:diligov_members/models/minutes_model.dart';
import 'package:diligov_members/providers/member_page_provider.dart';
import 'package:diligov_members/providers/note_page_provider.dart';
import 'package:diligov_members/utility/pdf_api.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:multi_select_flutter/chip_display/multi_select_chip_display.dart';
import 'package:multi_select_flutter/dialog/multi_select_dialog_field.dart';
import 'package:multi_select_flutter/util/multi_select_item.dart';

import 'package:flutter_gen/gen_l10n/app_localization.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../models/member.dart';
import '../../../models/user.dart';
import '../../../providers/laboratory_file_processing_provider_page.dart';


import '../../../src/test/TextStroke.dart';
import '../../../src/test/audio_strokes.dart';
import '../../../src/text_annotation.dart';
import '../../../widgets/custom_icon.dart';
import '../../../widgets/custom_message.dart';
import '../../../widgets/custome_text.dart';
import '../../../widgets/laboratory_file_processing_appbar_buttons.dart';
import '../../../widgets/loading_sniper.dart';
import '../core/domains/app_uri.dart';

class LaboratoryLocalFileProcessing extends StatefulWidget {
  final Minute minute;
  const LaboratoryLocalFileProcessing({super.key, required this.minute,});

  @override
  State<LaboratoryLocalFileProcessing> createState() => _LaboratoryLocalFileProcessingState();
}

class _LaboratoryLocalFileProcessingState extends State<LaboratoryLocalFileProcessing> {

  final _parentScaffoldKey = GlobalKey<ScaffoldState>();
  User user = User();
  String localPath = "";
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

  @override
  void initState() {
    // Enforce portraitUp and portraitDown orientations
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    preparePdfFileFromNetwork();
    textEditingController.addListener(_handleTextChange);
    _controller!.addListener(_handleTextChange);
    super.initState();
  }

  @override
  void dispose() {
    // Allow all orientations when the widget is disposed
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    textEditingController.removeListener(_handleTextChange);
    textEditingController.dispose();

    _controller!.removeListener(_handleEditTextChange);
    _controller!.dispose();
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
          print('provi provi dkdkkd');
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
                        final newId = provider.getNextAnnotationId();
                        provider.addTextAnnotation(TextAnnotation(
                          position: provider.tempTextPosition!,
                          text: textEditingController.text,
                          id: newId,
                          color: provider.selectedColor,
                          pageIndex: provider.indexing,
                          isPrivate: provider.isPrivate,
                        ));
                        // setState(() {
                        //   // Create a new annotation with a unique ID
                        //   textAnnotations.add(
                        //       TextAnnotation(
                        //         position: provider.tempTextPosition!,
                        //         text: textEditingController.text,
                        //         id: newId,
                        //         color: selectedColor,
                        //         pageIndex: provider.indexing,
                        //       )
                        //   );
                        //
                        //   textList.add({
                        //     "id": newId,
                        //     "text": textEditingController!.text,
                        //     "positionDx": provider.tempTextPosition!.dx,
                        //     "positionDy": provider.tempTextPosition!.dy,
                        //     "annotation_color": selectedColor.value,
                        //     "isPrivate": provider.isPrivate,
                        //     "pageIndex": provider.indexing
                        //   });
                        //
                          provider.showTextInput = false; // Hide TextField after saving
                          textEditingController.clear(); // Clear text field for next input
                          provider.tempTextPosition = null; // Reset position
                        //
                        // });


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
                  style: TextStyle(color: provider.selectedColor!),
                  controller: textEditingController,
                  maxLines: null,
                  autofocus: true,
                  onChanged: (value) => provider.tempInputText = value,
                  decoration: const InputDecoration(
                    hintText: "Enter text",
                    border: OutlineInputBorder(),
                  ),
                  onSubmitted: (value) {
                    final newId = provider.getNextAnnotationId();
                    provider.addTextAnnotation(TextAnnotation(
                      position: provider.tempTextPosition!,
                      text: value,
                      id: newId,
                      color: provider.selectedColor,
                      pageIndex: provider.indexing,
                      isPrivate: provider.isPrivate,
                    ));
                    // setState(() {
                    //   textAnnotations.add(
                    //       TextAnnotation(
                    //         position: provider.tempTextPosition!,
                    //         text: value,
                    //         id: newId,
                    //         color: selectedColor,
                    //         pageIndex: provider.indexing,
                    //       )
                    //   );
                    //   textList.add({
                    //     "id": newId,
                    //     "text": value,
                    //     "positionDx": provider.tempTextPosition!.dx,
                    //     "positionDy": provider.tempTextPosition!.dy,
                    //     "annotation_color": selectedColor.value,
                    //     "isPrivate": provider.isPrivate,
                    //     "pageIndex": provider.indexing
                    //   });
                      provider.showTextInput = false; // Hide TextField after submission
                      provider.tempTextPosition = null; // Reset position for the next input
                    // });
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

  void showEditOptions(TextAnnotation annotation, {bool isNew = false}) {
    _controller = TextEditingController(text: annotation.text);
    showDialog(
      context: context,
      builder: (context) {
        return Consumer<LaboratoryFileProcessingProviderPage>(
          builder: (BuildContext context, provider, child) {
            provider.setEditTextPosition(annotation.position);
            return AlertDialog(
              title: Text(isNew ? 'Add Annotation' : 'Edit Annotation'),
              content: TextField(
                controller: _controller,
                maxLines: null,
                autofocus: true,
              ),
              actions: <Widget>[
                if (!isNew)
                  TextButton(
                    onPressed: () {
                      // setState(() {
                        provider.textAnnotations.removeWhere((a) => a.id == annotation.id); // Delete annotation
                        int indexToRemove = provider.textList.indexWhere((item) => item['id'] == annotation.id);
                        if (indexToRemove != -1) {
                          provider.textList.removeAt(indexToRemove);
                        }
                      // });
                      Navigator.of(context).pop();
                    },
                    child: CustomText(text: 'Delete',color: Colors.black,),
                  ),
                TextButton(
                  onPressed: () {
                    // setState(() {
                      if (isNew) {
                        // Add the new annotation
                        provider.addTextAnnotation(TextAnnotation(
                          position: annotation.position,
                          text: _controller!.text,
                          id: annotation.id,
                          color: provider.selectedColor,
                          pageIndex: provider.indexing,
                            isPrivate: provider.isPrivate,
                        ));
                        provider.updateTextListObjectById(provider.textList, annotation.id!, {"text": _controller!.text, "pageIndex": provider.indexing});
                      } else {
                        // Update existing annotation
                        annotation.text = _controller!.text;
                        provider.updateTextListObjectById(provider.textList, annotation.id!, {"text": _controller!.text, "pageIndex": provider.indexing});
                      }
                    // });
                    Navigator.of(context).pop();
                  },
                  child: const Text('Save'),
                ),
              ],
            );
          },

        );
      },
    );
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
    final provider = Provider.of<LaboratoryFileProcessingProviderPage>(context, listen: false);
    try {
      if(await PDFApi.requestPermission()){
        final baseUriMeetings = '${AppUri.baseUntilPublicDirectoryMeetings}';
        final filePath = await PDFApi.loadNetworkFromLocalPath('${baseUriMeetings}/'+widget.minute.minuteFile!);
        print("filePath filePath pppppp ${filePath}");
        provider.setLocalPath(filePath.path);
        // setState(() { localPath = filePath.path!;});
      } else {
        print("Lacking permissions to access the file in preparePdfFileFromNetwork function");
        return;
      }
    } catch (e) { print("Error preparePdfFileFromNetwork function PDF: $e"); }
  }

  Future<void> takeScreenshot() async {
    try {
      if(await PDFApi.requestPermission()){
        final provider = Provider.of<NotePageProvider>(context,listen: false);
        provider.setLoading(true);
        final laboratoryProvider = Provider.of<LaboratoryFileProcessingProviderPage>(context, listen: false);
        final memberProvider = Provider.of<MemberPageProvider>(context, listen: false);
        laboratoryProvider.base64EncodedFiles.clear();
        final SharedPreferences prefs = await SharedPreferences.getInstance();
        user =  User.fromJson(json.decode(prefs.getString("user")!));
        List<Map<String, dynamic>> fileInfo = await laboratoryProvider.processAndCollectFileInfo();

        List<Map<String, dynamic>> canvasItemData = laboratoryProvider.canvasItemsList.map((canvasItem) => canvasItem.toMap()).toList();
        Map<String, dynamic> data = {
          "List_data_of_notes": laboratoryProvider.textList,
          // "file_edited": widget.path,
          "business_id": user.businessId,
          "add_by": user.userId,
          "minute_id": widget.minute.minuteId,
          "shared_strokes_members": memberProvider.selectedMembersIds,
          "records_files" : fileInfo,
          "shared_note_members": memberProvider.selectedMembersNoteIds,
          "shared_audio_note_members": memberProvider.selectedMembersAudioNoteIds,
          "canvas": canvasItemData
        };

        Future.delayed(Duration.zero, () {
          provider.insertNewMinuteNote(data);

        });
        if(provider.loading == true) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: CustomText(text: AppLocalizations.of(context)!.agenda_add_successfully ),
              backgroundColor: Colors.greenAccent,
            ),
          );
          Future.delayed(const Duration(seconds: 10), () {
            // Navigator.pushReplacementNamed(context, MinutesMeetingList.routeName);
          });
        }else{
          provider.setLoading(false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: CustomText(text: AppLocalizations.of(context)!.agenda_add_failed ),
              backgroundColor: Colors.redAccent,
            ),
          );
        }
        print('done to open download file');
      } else {
        print("Lacking permissions to access the file.");
        return;
      }
    } catch (e) {
      print("Error catch taking screenshot function: $e");
    }
  }


  @override
  Widget build(BuildContext context) {

    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title:  LaboratoryFileProcessingAppBarButtons(),
      ),
      body: Consumer<LaboratoryFileProcessingProviderPage>(
        builder: (BuildContext context, laboratoryFileProcessingProvider, child) {
          return Form(
            child: RepaintBoundary(
              key: _parentScaffoldKey,
              child: laboratoryFileProcessingProvider.localPath.isNotEmpty
                  ? GestureDetector(
                onTapDown: (TapDownDetails details) {
                  if (laboratoryFileProcessingProvider.showTextInput) {
                    // Convert local position to global
                    final RenderBox overlay = Overlay.of(context).context.findRenderObject() as RenderBox;
                    final globalPosition = overlay.globalToLocal(details.globalPosition);

                    // Adjust for AppBar height and SafeArea padding if necessary
                    final appBarHeight = Scaffold.of(context).appBarMaxHeight ?? 0;
                    final safePaddingTop = MediaQuery.of(context).padding.top;

                    // this function make text box initialized in top left position
                    laboratoryFileProcessingProvider.setTextInputPosition(globalPosition.translate(0, -(appBarHeight + safePaddingTop)),);

                  }
                },
                child: SafeArea(
                  child: Stack(
                    children: [
                      PDFView(
                        fitEachPage: true,
                        filePath: laboratoryFileProcessingProvider.localPath,
                        autoSpacing: false,
                        enableSwipe: true,
                        pageSnap: true,
                        swipeHorizontal: false,
                        nightMode: false,
                        onPageChanged: (int? currentPage, int? totalPages) {
                          // Access the provider
                          if (currentPage != null && totalPages != null) {
                            laboratoryFileProcessingProvider.onPageChanged(currentPage, totalPages);
                          }
                        },
                      ),

                      ...laboratoryFileProcessingProvider.canvasAudios.asMap().entries.where((audio) => audio.value.pageIndex == laboratoryFileProcessingProvider.indexing).map((entry) {
                        return DraggableAudioCanvas(
                          canvasPageIndex: entry.value.pageIndex,
                          key: ValueKey("${entry.key}#hfhfhf"),
                          canvasAudios: entry.value,
                          onPositionChange: (newPosition) => laboratoryFileProcessingProvider.updateCanvasAudiosPosition(entry.key, newPosition),
                          onDelete: () => laboratoryFileProcessingProvider.removeCanvasAudios(entry.key),
                        );
                      }).toList(),

                      ...laboratoryFileProcessingProvider.canvasItems.asMap().entries.where((stroke) => stroke.value.pageIndex == laboratoryFileProcessingProvider.indexing).map((entry) {
                        return DraggableCanvas(
                          canvasPageIndex: entry.value.pageIndex!,
                          key: ValueKey(entry.key),
                          item: entry.value,
                          onPositionChange: (newPosition) => laboratoryFileProcessingProvider.updateCanvasPosition(entry.key, newPosition),
                          onDelete: () => laboratoryFileProcessingProvider.removeCanvas(entry.key),
                        );
                      }).toList(),

                      if (laboratoryFileProcessingProvider.showTextInput && laboratoryFileProcessingProvider.tempTextPosition != null)
                        Positioned(
                          left: laboratoryFileProcessingProvider.tempTextPosition!.dx,
                          top: laboratoryFileProcessingProvider.tempTextPosition!.dy,
                          child: Draggable(
                            feedback: Material(
                              child: buildTextInputField(),
                            ),
                            childWhenDragging: Container(),
                            onDraggableCanceled: (velocity, offset) {
                              // Ensure the new position is within the screen bounds
                              final screenSize = MediaQuery.of(context).size;
                              double dx = offset.dx;
                              double dy = offset.dy;
                              if (dx < 0) dx = 0;
                              if (dy < 0) dy = 0;
                              if (dx > screenSize.width - 200) dx = screenSize.width - 200;
                              if (dy > screenSize.height - 100) dy = screenSize.height - 100;
                              laboratoryFileProcessingProvider.setTextInputPosition(Offset(dx, dy));
                            },
                            child: buildTextInputField(),
                          ),
                        ),
                      ...laboratoryFileProcessingProvider.textAnnotations
                          .where((annotation) => annotation.pageIndex == laboratoryFileProcessingProvider.indexing)
                          .map((annotation) {
                        return Positioned(
                          left: annotation.position.dx,
                          top: annotation.position.dy,
                          child: Draggable(
                            feedback: Material(
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                                color: Colors.yellow.withAlpha(100),
                                child: Text(annotation.text!, style: TextStyle(color: annotation.color, fontSize: 18)),
                              ),
                            ),
                            childWhenDragging: Container(),
                            onDraggableCanceled: (velocity, offset) {
                              // Ensure the new position is within the screen bounds
                              final screenSize = MediaQuery.of(context).size;
                              double dx = offset.dx;
                              double dy = offset.dy;
                              if (dx < 0) dx = 0;
                              if (dy < 0) dy = 0;
                              if (dx > screenSize.width - 200) dx = screenSize.width - 200;
                              if (dy > screenSize.height - 100) dy = screenSize.height - 100;
                              setState(() {
                                annotation.position = Offset(dx, dy);
                              });
                            },
                            child: GestureDetector(
                              onTap: () => showEditOptions(annotation),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                                color: Colors.yellow.withAlpha(100),
                                child: Text(annotation.text!, style: TextStyle(color: annotation.color, fontSize: 18)),
                              ),
                            ),
                          ),
                        );
                      }).toList(),

                    ],
                  ),
                ),
              )
                  : const Center(child: CircularProgressIndicator()),
            ),
          );
        },

      ),
      floatingActionButton: Consumer<NotePageProvider>(
          builder: (context, provider, child){
            return provider.loading == true ?  CircularProgressIndicator(color: Colors.green,) : FloatingActionButton(
              onPressed: () async{
                // Adding a delay can sometimes help if the widget is not rendered yet
                Future.delayed(const Duration(milliseconds: 500), () async {
                  takeScreenshot();
                });
              },
              tooltip: 'Save File',
              child: const Icon(Icons.save),
            );
          }
      ),
    );
  }







}
