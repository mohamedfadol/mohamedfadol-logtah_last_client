
import 'package:flutter/material.dart';

class CanvasAudios {
  int id;
  Offset position;
  int pageIndex;
  double canvasWidth;
  double canvasHeight;
  bool isDraggable;
  bool isRecording;
  List<AudioFileData> audioFiles;

  CanvasAudios({
    required this.id,
    required this.position,
    required this.canvasWidth,
    required this.canvasHeight,
    this.pageIndex = 0,
    this.isDraggable = true,
    this.isRecording = false,
    this.audioFiles = const [],
  });

  void updateWidthScaleForAudio(double scale) {
    canvasWidth = scale;
  }

  void updateHeightScaleForAudio(double scale) {
    canvasHeight = scale;
  }

}

class AudioFileData {
  int id;
  String? file;
  int audioFilePageIndex;
  Offset? position;

  AudioFileData({
     required this.id,
      required this.audioFilePageIndex,
     this.file,
     this.position,
  });
}