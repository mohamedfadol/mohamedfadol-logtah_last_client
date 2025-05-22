import 'package:diligov_members/widgets/custome_text.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../providers/audio_recording_provider.dart';
import '../../../providers/laboratory_file_processing_provider_page.dart';
import '../../../src/canvas_audios.dart';
class RecodingKeysToolsControl extends StatelessWidget {
  final CanvasAudios canvasAudios;
  const RecodingKeysToolsControl({super.key, required this.canvasAudios });

  @override
  Widget build(BuildContext context) {
    final audioProvider = Provider.of<AudioRecordingProvider>(context, listen: true);
    final canvasProvider = Provider.of<LaboratoryFileProcessingProviderPage>(context, listen: false);

    final icon = audioProvider.isRecording ? Icons.stop : Icons.mic;
    final text = audioProvider.isRecording ? 'Stop' : 'Start';
    return Row(
      children: [
        if(audioProvider.isRecording)
          const Text('Recording ...', style: TextStyle(fontSize: 15.0)),
        ElevatedButton.icon(
          onPressed: () async {
            if (audioProvider.isRecording) {
              await audioProvider.stopRecording();
              if (audioProvider.audioPath != null) {
                canvasProvider.addAudioFileToCanvas(audioProvider.audioPath,canvasAudios.id, canvasAudios.pageIndex, canvasAudios.position);
              }
            } else {
                print('isRecording if onPressed is  ${audioProvider.isRecording}');
                showDialog(
                    context: context,
                    builder: (context) {
                      return Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 10.0),
                            height: 200,
                            width: 400,
                            decoration: BoxDecoration(
                                color: Colors.grey,
                                borderRadius:
                                BorderRadius.circular(15)),
                            child: Column(
                              children: [
                                CustomText(text: 'Put recording name', fontSize: 25.0,fontWeight: FontWeight.bold,),
                                Container(
                                  margin: EdgeInsets.all(10),
                                  height: 50,
                                  child: Material(
                                    child: TextField(
                                      controller: audioProvider.controller,
                                      textAlignVertical:
                                      TextAlignVertical.center,
                                      decoration: InputDecoration(
                                          isDense: true,
                                          fillColor: Colors.red,
                                          border: OutlineInputBorder(),
                                          contentPadding:
                                          EdgeInsets.all(12)),
                                    ),
                                  ),
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    GestureDetector(
                                      onTap: () async  {
                                        await  audioProvider.stopRecording();
                                        print('isRecording cancel onPressed is  ${audioProvider.isRecording}');
                                        Navigator.pop(context);
                                      },
                                      child: Container(
                                        height: 40,
                                        width: 150,
                                        color: Colors.blue,
                                        alignment: Alignment.center,
                                        child: Text('Cancel'),
                                      ),
                                    ),
                                    GestureDetector(
                                      onTap: () {
                                        Navigator.pop(context);
                                        if (audioProvider.controller.text.isNotEmpty) {
                                          audioProvider.startRecording();
                                        }
                                      },
                                      child: Container(
                                        height: 40,
                                        width: 150,
                                        color: Colors.green,
                                        alignment: Alignment.center,
                                        child: Text('Save'),
                                      ),
                                    )
                                  ],
                                )
                              ],
                            ),
                          )
                        ],
                      );
                    });

            }
          },
          icon: Icon(icon),
          label: Text(text),
        ),
      ],
    );
  }
}
