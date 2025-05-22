
import 'dart:convert';
import 'dart:math';
import 'dart:io';
import 'package:diligov_members/extensions.dart';
import 'package:diligov_members/src/canvas_audios.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import '../models/signature.dart';
import '../models/user.dart';
import 'dart:typed_data';
import 'dart:ui' as ui;

import '../src/canvas_item.dart';
import '../src/stroke.dart';
import '../src/text_annotation.dart';

class LaboratoryFileProcessingProviderPage with ChangeNotifier {

  User user = User();
  var log = Logger();
  // String localPath = "";
  String _localPath = "";
  bool isLoading = false;

  String get localPath => _localPath;
  List<Stroke> currentPageStrokes =[];
  double _currentPenWidth = 5.0;
  bool showTextInput = false;
  bool showNewTextInput = false;
  Offset textPosition = Offset.zero;
  Offset? editTextPosition;
  int indexing = 0;
  int? totalPagesOfFile;
  String tempInputText = "";
  Offset? tempTextPosition;
  List<TextAnnotation> textAnnotations = [];
  double _currentFontSize = 18.0;
  Color _selectedColor = Colors.black;
  Color iconColor = Colors.grey;
  Size? _canvasSize;
  Size? get canvasSize => _canvasSize;
  bool showUsers = false;
  double _widthScale = 1.5;
  double _heightScale = 1.5;

  double get widthScale => _widthScale;
  double get heightScale => _heightScale;

  double _widthScaleForAudio = 1.5;
  double _heightScaleForAudio = 1.5;

  double get widthScaleForAudio => _widthScaleForAudio;
  double get heightScaleForAudio => _heightScaleForAudio;

  List<CanvasItem> canvasItems = [];
  List<CanvasAudios> canvasAudios = [];

  bool _isDraggable = true;
  bool get isDraggable => _isDraggable;

  bool _isDrawingEnabled = false;
  bool get isDrawingEnabled => _isDrawingEnabled;

  bool strokesStatus = false;
  bool isPrivate = true;
  bool isDrawingMode = true;
  List<AudioFileData> audioFilesData = [];
  List<Map<String, dynamic>> textList = [];
  final TextEditingController textEditingController = TextEditingController();
  List<String> base64EncodedFiles = [];

  final List<Signature> _signatures = [];

  List<Signature> get signatures => List.unmodifiable(_signatures);

  void addSignature(Signature signature) {
    print("Adding Signature ID: ${signature.id}");
    _signatures.add(signature);
    notifyListeners();
  }

  void printIndexedItems() {
    _signatures.mapIndexed((index, item) {
      print('$index: $item');
    }).toList();
  }

  String getFormattedSignatures() {
    return _signatures.mapIndexed((index, signature) {
      return 'Signature $index: User ${signature.userId}, Page ${signature.pageId}, Position ${signature.position}';
    }).join('\n');
  }


  void addOrUpdateSignature({
    required String memberId,
    required String memberName,
    required Offset position,
  }) {
    // Check if the signature already exists
    final existingIndex = _signatures.indexWhere((sig) => sig.id == memberId);

    if (existingIndex != -1) {
      // Update existing signature's position
      _signatures[existingIndex].position = position;
    } else {
      // Add new signature
      _signatures.add(Signature.create(
        userId: memberId,
        memberName: memberName,
        pageId: indexing.toString(),
        position: position,
      ));
    }
    List<Map<String, dynamic>> data = _signatures.map((sig) => sig.toMap()).toList();
    print("addOrUpdateSignature data: $data");

    notifyListeners();
  }


  void printSignatures() {
    print(getFormattedSignatures());
  }

  // Update the position of a signature by its ID
  void updateSignaturePosition(String id, String pageId, Offset newPosition) {
    try {
      final signature = _signatures.firstWhere((sig) => sig.id == id);
      signature.position = newPosition;
      notifyListeners();
    } catch (e) {
      // Handle signature not found
      print("Signature not found: $id");
    }

      List<Map<String, dynamic>> data = _signatures.map((sig) => sig.toMap()).toList();

    print("updateSignaturePosition data: $data");
  }

  // Remove a signature by its ID and page index
  void removeSignature(String id, int pageId) {
    _signatures.removeWhere((sig) => sig.id == id);
    notifyListeners();
  }

  // Get signatures for the current page
  List<Signature> getSignaturesForCurrentPage(String pageId) {
    return _signatures.where((sig) => sig.pageId == pageId).toList();
  }

  void onPageChanged(int currentPage, int totalPages) {
    indexing = currentPage;
    totalPagesOfFile = totalPages;
    notifyListeners();
    log.d("Current page: $currentPage, Total pages: $totalPages from LaboratoryFileProcessingProviderPage");
  }

  void setLocalPath(String path) {
    _localPath = path;
    notifyListeners();
  }


  void setLoading(bool loading) {
    isLoading = loading;
    notifyListeners();
  }

  Future<List<AudioFileData>> getAudioFileData({int? id}) {
    List<AudioFileData> filteredData;
    // Filter the list if an ID is provided; otherwise, use the entire list.
    if (id != null) {
      filteredData = audioFilesData.where((audioFileData) => audioFileData.id == id).toList();
    } else {
      filteredData = List<AudioFileData>.from(audioFilesData);
    }
    // Sort the resulting list by ID in descending order
    filteredData.sort((a, b) => b.id.compareTo(a.id));
    return Future.value(filteredData);
  }

  bool removeAudioFileByIdAndName(int id, String fileName) {
    List<AudioFileData> filesToRemove = audioFilesData.where(
            (data) => data.id == id && (data.file?.endsWith(fileName) ?? false)
    ).toList();
    for (var fileData in filesToRemove) {
      if (fileData.file != null) {
        File(fileData.file!).delete().catchError((e) {
          print("Failed to delete file: ${fileData.file}");
        });
      }
    }
    audioFilesData.removeWhere((data) => filesToRemove.contains(data));
    notifyListeners();
    return true;
  }

  void addAudioFileToCanvas(String? audioFile,int id,int pageIndex, Offset position) {
    audioFilesData.add(AudioFileData(file: audioFile, id: id,audioFilePageIndex: pageIndex, position: position));
    log.d("i here addAudioFileToCanvas ${audioFilesData}");
    notifyListeners();

  }

  Future<String> encodeFileToBase64(String filePath) async {
    File file = File(filePath);
    if (!await file.exists()) {
      throw Exception("File not found");
    }
    List<int> fileBytes = await file.readAsBytes();
    String base64Encoded = base64Encode(fileBytes);
    return base64Encoded;
  }

  Future<List<Map<String, dynamic>>> processAndCollectFileInfo() async {
    List<Map<String, dynamic>> fileInfoList = [];

    for (var audioFileData in audioFilesData) {
      if (audioFileData.file != null) {
        try {
          String fileName = audioFileData.file!.split('/').last;
          String base64 = await encodeFileToBase64(audioFileData.file!);
          Map<String, dynamic> fileInfo = {
            'id': audioFileData.id,
            'fileName': fileName,
            'filePageIndex': audioFileData.audioFilePageIndex,
            'base64': base64,
            'positionDx': audioFileData!.position!.dx,
            'positionDy': audioFileData!.position!.dy,
          };
          fileInfoList.add(fileInfo);
        } catch (e) {
          log.e("Error processing file ${audioFileData.file}: $e");
        }
      }
    }
    // print('fileInfoList fileInfoList fileInfoList fileInfoList ${fileInfoList}');
    return fileInfoList;
  }

  void addCanvasAudios() {
    final newPosition = Offset(100, 100);
    final newId = generateCanvasAudiosId();
    CanvasAudios newAudioItem = CanvasAudios(
        id: newId,
        position: newPosition,
        isDraggable: true,
        pageIndex: indexing,
        audioFiles: [],
        canvasWidth: _widthScaleForAudio,
        canvasHeight: _heightScaleForAudio
    );
    newAudioItem.audioFiles = audioFilesData;
    canvasAudios.add(newAudioItem);
    print('can can can');
    print(newAudioItem.audioFiles);
    print(newAudioItem.position);
    notifyListeners();
  }

  int generateCanvasAudiosId() {
    if (canvasAudios.isNotEmpty) {
      return canvasAudios.map((a) => a.id).reduce(max) + 1;
    }
    return 1;
  }

// Retrieve a CanvasAudio by its ID
  CanvasAudios getCanvasAudioById(int id) {
    try {
      return canvasAudios.firstWhere((item) => item.id == id);
    } catch (e) {
      throw Exception('CanvasItem with id $id not found');
    }
  }

  void updateCanvasAudiosPosition(int index, Offset newPosition) {
    if(index < canvasAudios.length) {
      canvasAudios[index].position = newPosition;
      print(canvasAudios[index].position);
      notifyListeners();
    }
  }

  void removeCanvasAudios(int index) {
    if(index < canvasAudios.length) {
      canvasAudios.removeAt(index);
      notifyListeners();
    }
  }

  void updateCanvasWidthScaleForAudio(int canvasId, double newWidthScaleForAudio) {
    var canvasAudio = canvasAudios.firstWhere((item) => item.id == canvasId);
    canvasAudio.updateWidthScaleForAudio(newWidthScaleForAudio);
    notifyListeners();
  }

  void updateCanvasHeightScaleForAudio(int canvasId, double newHeightScaleForAudio) {
    var canvasAudio = canvasAudios.firstWhere((item) => item.id == canvasId);
    canvasAudio.updateHeightScaleForAudio(newHeightScaleForAudio);
    notifyListeners();
  }

  // Retrieve a CanvasItem by its ID
  CanvasItem getCanvasItemById(int id) {
    try {
      return canvasItems.firstWhere((item) => item.id == id);
    } catch (e) {
      throw Exception('CanvasItem with id $id not found');
    }
  }

  void addCanvasStrokes() {
    log.d("i here to create a new addCanvasStrokes");
    final newPosition = Offset(100, 100);
    final newId = generateCanvasStrokesId();
    CanvasItem newItem = CanvasItem(
      id: newId,
      canvasWidth: _widthScale,
      canvasHeight: _heightScale,
      position: newPosition,
      strokes: [],
      penWidth: _currentPenWidth,
      color: _selectedColor,
      isDraggable: true ,
      pageIndex: indexing,
    );
    Stroke startingStroke = Stroke(
      canvasId: newItem.id!,
      points: [newPosition],
      pageIndex: newItem.pageIndex!,
      position: newItem.position!,
      strokeColor: newItem.color!,
      strokeWidth: newItem.penWidth!,
    );
    newItem.strokes!.add(startingStroke);
    canvasItems.add(newItem);

    notifyListeners();
  }

  int generateCanvasStrokesId() {
    if (canvasItems.isNotEmpty) {
      // Explicitly providing the type argument to `max` to avoid type inference issues.
      final int? maxId = canvasItems.map((item) => item.id).reduce((a, b) => max<int>(a!, b!));
      return maxId! + 1;
    }
    return 1; // Return 1 if canvasItems is empty, assuming IDs start at 1
  }

  void removeCanvas(int index) {
    if(index < canvasItems.length) {
      canvasItems.removeAt(index);
      notifyListeners();
    }
  }

  void updateCanvasWidthScale(int canvasId, double newWidthScale) {
    var canvasItem = canvasItems.firstWhere((item) => item.id == canvasId);
    canvasItem.updateWidthScale(newWidthScale);
    notifyListeners();
  }

  void updateCanvasHeightScale(int canvasId, double newHeightScale) {
    var canvasItem = canvasItems.firstWhere((item) => item.id == canvasId);
    canvasItem.updateHeightScale(newHeightScale);
    notifyListeners();
  }

  void updateCanvasPosition(int index, Offset newPosition) {
    if(index < canvasItems.length) {
      canvasItems[index].position = newPosition;
      notifyListeners();
    }
  }

  void toggleIsDrawingMode() {
    isDrawingMode = !isDrawingMode;
    notifyListeners();
  }



  void toggleShowUsers() {
    showUsers = !showUsers;
    notifyListeners();
  }

  void togglePrivate() {
    isPrivate = !isPrivate;
    notifyListeners();
  }

  // Getters
  double get currentPenWidth => _currentPenWidth;
  double get currentFontSize => _currentFontSize;
  Color get selectedColor => _selectedColor;

  // Setters
  void setCurrentPenWidth(double newWidth) {
    _currentPenWidth = newWidth;
    notifyListeners();
  }

  void setCurrentFontSize(double newSize) {
    _currentFontSize = newSize;
    notifyListeners();
  }

  void setSelectedColor(Color newColor) {
    _selectedColor = newColor;
    notifyListeners();
  }

// Add a stroke to a specific CanvasItem by ID
  void addStrokeToCanvasItem(int itemId, Stroke stroke) {
    // Notice how the type CanvasItem? is explicitly managed
    var item = canvasItems.firstWhere((item) => item.id == itemId);

    // Check if item is not null before using it
    Stroke newStroke = Stroke(
        canvasId: item.id!,
        points: stroke.points,
        strokeColor: stroke.strokeColor,
        strokeWidth: stroke.strokeWidth,
        pageIndex: item.pageIndex!,
        position: stroke.position
    );
    item.strokes!.add(newStroke);
    notifyListeners();
    }
  List<CanvasItem> get canvasItemsList => canvasItems;

  void toggleTextInput() {
    showTextInput = !showTextInput;
    tempTextPosition = showTextInput ? Offset.zero : null;
    notifyListeners();
  }

  void setTextInputPosition(Offset position) {
    tempTextPosition = position;
    log.i(tempTextPosition);
    notifyListeners();
  }

  void setEditTextPosition(Offset position) {
    editTextPosition = position;
    notifyListeners();
  }

  void toggleCloseTextInput() {
    showTextInput = false;
    tempTextPosition = null;
    notifyListeners();
  }


  // Add a new text annotation
  void addTextAnnotation(TextAnnotation annotation) {
    textAnnotations.add(annotation);
    textList.add({
      "id": annotation.id,
      "text": annotation.text,
      "positionDx": annotation.position.dx,
      "positionDy": annotation.position.dy,
      "annotation_color": annotation.color!.value,
      "isPrivate": isPrivate,
      "pageIndex": annotation.pageIndex,
    });
    notifyListeners();
  }

  // Update an existing text annotation
  void updateTextAnnotation(TextAnnotation annotation) {
    int index = textAnnotations.indexWhere((a) => a.id == annotation.id);
    if (index != -1) {
      textAnnotations[index] = annotation;
      updateTextListObjectById(textList, annotation.id!, {
        "text": annotation.text,
        "positionDx": annotation.position.dx,
        "positionDy": annotation.position.dy,
        "annotation_color": annotation.color!.value,
        "isPrivate": annotation.isPrivate,
        "pageIndex": annotation.pageIndex,
      });
      notifyListeners();
    }
  }

  // Remove a text annotation
  void removeTextAnnotation(int id) {
    textAnnotations.removeWhere((a) => a.id == id);
    textList.removeWhere((item) => item['id'] == id);
    notifyListeners();
  }

  // Update the text list object by ID
  void updateTextListObjectById(List<Map<String, dynamic>> list, int id, Map<String, dynamic> newData) {
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

  // Getters
  List<TextAnnotation> get getTextAnnotations => textAnnotations;
  List<Map<String, dynamic>> get getTextList => textList;

  // Function to get the next unique ID
  int getNextAnnotationId() {
    if (textAnnotations.isNotEmpty) {
      return textAnnotations.map((a) => a.id!).reduce(max) + 1;
    }
    return 1; // Start IDs from 1 if the list is empty
  }

  void updateCanvasSize(Size size) {
    _canvasSize = size;
    notifyListeners();
  }

  void toggleDraggable(int canvasId) {
    try {
      // Find the CanvasItem by ID
      final canvasItem = canvasItems.firstWhere((item) => item.id == canvasId);
      // Toggle the isDraggable property with a default value
      canvasItem.isDraggable = !(canvasItem.isDraggable ?? true);
      // Notify listeners to rebuild the UI
      notifyListeners();
      print("Toggled draggable for CanvasItem ID: $canvasId, isDraggable: ${canvasItem.isDraggable}");
    } catch (e) {
      print("CanvasItem with ID $canvasId not found: $e");
    }
  }


  void toggleDrawing() {
    _isDrawingEnabled = !_isDrawingEnabled;
    notifyListeners();
  }

  void undoLastStroke(int canvasId) {
    try {
      // Find the canvas item by ID
      var canvasItem = canvasItems.firstWhere((item) => item.id == canvasId);

      // Remove the last stroke if it exists
      if (canvasItem.strokes != null && canvasItem.strokes!.isNotEmpty) {
        canvasItem.strokes!.removeLast();
        notifyListeners(); // Notify listeners to update the UI
      }
    } catch (e) {
      // Handle the case where the canvas item is not found
      print("CanvasItem with ID $canvasId not found: $e");
    }
  }

  void handlePanStart(
      int canvasId,
      Offset position, {
        required Color selectedColor,
        required double penWidth,
        required int pageIndex,
      }) {
    try {
      // Find the canvas item by ID
      var canvasItem = canvasItems.firstWhere((item) => item.id == canvasId);

      // Add the new stroke
      final newStroke = Stroke(
        canvasId: canvasItem.id!,
        points: [position],
        pageIndex: pageIndex,
        position: position,
        strokeColor: selectedColor,
        strokeWidth: penWidth,
      );

      canvasItem.strokes!.add(newStroke); // Add the stroke to the canvas
      notifyListeners(); // Notify listeners to rebuild the UI
    } catch (e) {
      print("CanvasItem with ID $canvasId not found: $e");
    }
  }

  void handlePanUpdate(
      int canvasId,
      Offset position, {
        required Color selectedColor,
        required double penWidth,
        required int pageIndex,
      }) {
    try {
      // Find the canvas item by ID
      var canvasItem = canvasItems.firstWhere((item) => item.id == canvasId);

      if (canvasItem.strokes != null && canvasItem.strokes!.isNotEmpty) {
        // Update the last stroke with the new position
        canvasItem.strokes!.last.points.add(position);

        // Optionally update the last stroke completely if additional logic is needed
        Stroke updatedStroke = Stroke(
          canvasId: canvasItem.id!,
          points: canvasItem.strokes!.last.points,
          pageIndex: pageIndex,
          position: position,
          strokeColor: selectedColor,
          strokeWidth: penWidth,
        );

        // Update the strokes list if needed
        canvasItem.strokes!.last = updatedStroke;

        notifyListeners(); // Notify listeners to rebuild the UI
      }
    } catch (e) {
      print("CanvasItem with ID $canvasId not found: $e");
    }
  }

  void clearStrokes(int canvasId) {
    try {
      // Find the canvas item by ID
      var canvasItem = canvasItems.firstWhere((item) => item.id == canvasId);

      // Clear the strokes for the canvas item
      if (canvasItem.strokes != null && canvasItem.strokes!.isNotEmpty) {
        canvasItem.strokes!.clear();
        notifyListeners(); // Notify listeners to rebuild the UI
      }
    } catch (e) {
      print("CanvasItem with ID $canvasId not found: $e");
    }
  }



}
