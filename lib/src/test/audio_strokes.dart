import 'package:flutter/material.dart';
import 'package:multi_select_flutter/chip_display/multi_select_chip_display.dart';
import 'package:multi_select_flutter/dialog/multi_select_dialog_field.dart';
import 'package:multi_select_flutter/util/multi_select_item.dart';
import 'package:provider/provider.dart';
import '../../models/member.dart';
import '../../providers/audio_recording_provider.dart';
import '../../providers/laboratory_file_processing_provider_page.dart';
import '../../providers/member_page_provider.dart';
import '../../utility/recoding_keys_tools.dart';
import '../../widgets/custom_icon.dart';
import '../../widgets/custom_message.dart';
import '../../widgets/custom_slider.dart';
import '../../widgets/custome_text.dart';
import '../../widgets/loading_sniper.dart';
import '../canvas_audios.dart';
import 'package:flutter_gen/gen_l10n/app_localization.dart';

class DraggableAudioCanvas extends StatefulWidget {
  final CanvasAudios canvasAudios;
  final Function(Offset) onPositionChange;
  final VoidCallback onDelete;
  final int canvasPageIndex;

  const DraggableAudioCanvas(
      {Key? key,
      required this.canvasAudios,
      required this.onPositionChange,
      required this.onDelete,
      required this.canvasPageIndex})
      : super(key: key);

  @override
  _DraggableAudioCanvasState createState() => _DraggableAudioCanvasState();
}

class _DraggableAudioCanvasState extends State<DraggableAudioCanvas> {
  bool _isDrawing = true; // Initially, we're not drawing
  // Size? _canvasSize; // To hold the canvas size for dynamic bounds checking
  List _membersListIds = [];

  void _deleteCanvas() {
    print('Canvas delete');
    final laboratoryFileProcessingProviderPage = Provider.of<LaboratoryFileProcessingProviderPage>(context, listen: false);
    laboratoryFileProcessingProviderPage.audioFilesData.clear();
    laboratoryFileProcessingProviderPage.base64EncodedFiles.clear();
    widget.onDelete();
  }

  void _toggleDrawingMode() {
    setState(() {
      _isDrawing = !_isDrawing;
    });
  }

  void _toggleDraggable() {
    setState(() {
      widget.canvasAudios.isDraggable = !widget.canvasAudios.isDraggable;
    });
  }


  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AudioRecordingProvider>(context, listen: false);
    return Stack(
      children: [
        widget.canvasAudios.isDraggable
            ? _buildDraggableCanvas(provider)
            : _buildStaticCanvas(provider),
      ],
    );
  }

  Widget VoiceNoteList(AudioRecordingProvider provider) {
    final laboratoryFileProcessingProviderPage = Provider.of<LaboratoryFileProcessingProviderPage>(context, listen: false);

    return Consumer<AudioRecordingProvider>(
      builder: (context, provider, child) {
        return  ListView(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          children: [
            provider.isRecording ?
            Center(
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 18.0),
                child: provider.isRecording ?
                Container(
                  child: CustomText(text: provider.formattedTime(timeInSecond: provider.time),fontSize: 20.0, color: Colors.grey,),
                ) : SizedBox(),
              ),
            )
                : SizedBox(),
            SizedBox(
                height: MediaQuery.of(context).size.height,
                child: FutureBuilder<List<AudioFileData>>(
                  future: laboratoryFileProcessingProviderPage.getAudioFileData(id :widget.canvasAudios.id),
                  builder: (BuildContext context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return CircularProgressIndicator();
                    } else if (snapshot.hasError) {
                      return Text('Error: ${snapshot.error}');
                    }else if (snapshot?.data == null || snapshot.data!.isEmpty) {
                      return Text('no data');
                    } else {
                      final filesData = snapshot.data!;
                      filesData.sort((a, b) => b.id.compareTo(a.id));  // Sorting by id in descending order

                      return ListView.separated(
                        scrollDirection: Axis.vertical,
                        itemCount: snapshot.data!.length,
                        itemBuilder: (BuildContext  context, index) {
                          return Padding(
                            padding: EdgeInsets.symmetric(horizontal: 2.0, vertical: 2.0),
                            child: Container(
                              decoration: BoxDecoration(
                                  color: Colors.grey[200],
                                  border: Border.all(width: 1.0, color: Colors.grey)
                              ),
                              child: ListTile(
                                title: CustomText(
                                  text: filesData[index].file!.split('/').last,
                                  fontSize: 20,
                                ),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    IconButton(
                                      onPressed: () async{
                                        await  provider.playAudioFromAssets(filesData[index].file!);
                                      },
                                      icon: provider.icon,
                                    ),

                                    SizedBox(width: 15,),
                                    IconButton(
                                      icon: Icon(Icons.delete,color: Colors.red,),
                                      onPressed: () async {
                                        bool deleted = await laboratoryFileProcessingProviderPage.removeAudioFileByIdAndName(filesData[index].id!, filesData[index].file!.split('/').last);
                                        if (deleted) {
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            SnackBar(content: Text("File deleted")),
                                          );
                                        } else {
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            SnackBar(content: Text("Error deleting file")),
                                          );
                                        }  },
                                    ),
                                  ],
                                ),
                                subtitle:
                                provider.isPlayingNow ?
                                Container(
                                  child: CustomText(text: provider.formattedTime(timeInSecond: provider.time),fontSize: 12.0, color: Colors.green,),
                                ) : SizedBox()
                                ,
                              ),
                            ),
                          );
                        },
                        separatorBuilder: (context, index) => buildStaticDividerSizeBox(Colors.white!),
                      );
                    }
                  },
                ))
          ],
        );
      }
    );
  }

  Widget buildStaticDividerSizeBox(Color dividerColor) {
    return new SizedBox(
      height: 1.0,
      // width: 100,
      child: new Container(
        margin: new EdgeInsetsDirectional.only(start: 1.0, end: 1.0),
        height: 1.0,
        color: dividerColor,
      ),
    );
  }



  Widget _buildStaticCanvas(AudioRecordingProvider provider) {
    return Positioned(
      left: widget.canvasAudios.position.dx,
      top: widget.canvasAudios.position.dy,
      child: _buildCanvas(provider),
    );
  }

  Widget _buildDraggableCanvas(AudioRecordingProvider provider) {
    return Positioned(
      left: widget.canvasAudios.position.dx,
      top: widget.canvasAudios.position.dy,
      child: Draggable(
        data: widget.canvasAudios,
        feedback: Material(
          child: _buildCanvas(provider),
          elevation: 4.0,
        ),
        childWhenDragging: Container(),
        onDragEnd: (details) => widget.onPositionChange(details.offset),
        child: Listener(
          onPointerDown: (_) => _toggleDrawingMode(),
          onPointerUp: (_) => _toggleDrawingMode(),
          child: _buildCanvas(provider),
        ),
      ),
    );
  }

  Widget _buildCanvas(AudioRecordingProvider provider) {
    final laboratoryFileProcessingProviderPage = Provider.of<LaboratoryFileProcessingProviderPage>(context, listen: false);
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Toggle draggable state button
            ElevatedButton(
              onPressed: _toggleDraggable,
              child: Icon(
                  widget.canvasAudios.isDraggable ? Icons.lock_open : Icons.lock),
            ),
            SizedBox(width: 10,),
            ElevatedButton(
              onPressed: _deleteCanvas,
              child: Icon(
                Icons.remove_circle_outline,
                color: Colors.red,
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15.0),
              child: RecodingKeysToolsControl(canvasAudios: widget.canvasAudios),
            ),

            _selectMenu()

          ],
        ),
        Column(
          children: [
            Row(
              mainAxisSize: MainAxisSize.max,
              children: [
                Container(
                  width: 400 * widget.canvasAudios.canvasWidth,
                  height: 400 * widget.canvasAudios.canvasHeight,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.black, width: 1.0),
                  ),
                  child: ClipRect(
                    child: VoiceNoteList(provider),
                  ),
                ),
                RotatedBox(
                  quarterTurns: 1,
                  child: CustomSlider(
                    min: 0.5,
                    max: 5.0,
                    divisions: 25,
                    value: laboratoryFileProcessingProviderPage.getCanvasAudioById(widget.canvasAudios.id).canvasHeight,
                    onChanged: (double value) {
                      laboratoryFileProcessingProviderPage.updateCanvasHeightScaleForAudio(widget.canvasAudios.id, value);
                    },
                    label: '${laboratoryFileProcessingProviderPage.heightScaleForAudio.toStringAsFixed(2)}',
                  ),
                )
              ],
            ),
            CustomSlider(
              min: 0.5,
              max: 5.0,
              divisions: 25,
              value: laboratoryFileProcessingProviderPage.getCanvasAudioById(widget.canvasAudios.id).canvasWidth,
              onChanged: (double value) {
                laboratoryFileProcessingProviderPage.updateCanvasWidthScaleForAudio(widget.canvasAudios.id, value);
              },
              label: '${laboratoryFileProcessingProviderPage.widthScaleForAudio.toStringAsFixed(2)}',
            )
          ],
        ),
      ],
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
              Provider.of<MemberPageProvider>(context, listen: false).getListOfMemberMenu()
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
                      provider.setSelectMemberAudioNote(values);
                      _membersListIds = provider.selectedMembersAudioNoteList
                          .map((e) => e.memberId)
                          .toList();
                      provider
                          .setSelectMemberAudioNoteId(_membersListIds);
                      print(_membersListIds);
                    },
                    chipDisplay: MultiSelectChipDisplay(
                      onTap: (item) {
                        provider.removeSelectedMembersAudioNote(item);
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
}
