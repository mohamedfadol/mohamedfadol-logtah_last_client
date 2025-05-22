import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:record/record.dart';


class AudioRecordingProvider with ChangeNotifier {

  Timer? _timer;
  int _time = 0;
  bool _isPlayingNow = false;

  Timer? get timer => _timer;
  int get time => _time;
  bool get isPlayingNow => _isPlayingNow;
  bool get isRecording => _isRecording;

  bool _isRecording = false;
  String? _audioPath;
  final AudioRecorder _audioRecord = AudioRecorder();
   AudioPlayer? _audioPlayer;
  final TextEditingController controller = TextEditingController();

  AudioRecordingProvider() {
    _audioPlayer = AudioPlayer();
    _audioPlayer?.onPlayerStateChanged.listen((PlayerState state) {
      print("Player State Changed: $state");
      bool wasPlaying = _isPlayingNow;
      _isPlayingNow = state == PlayerState.playing;
      if (_isPlayingNow && !wasPlaying) {
        startTimer(); // Start the timer if we just started playing
      } else if (! _isPlayingNow && wasPlaying) {
        _time = 0; // Reset the timer to 0 whenever you start it
        _timer?.cancel(); // Cancel any existing timer
      }
      notifyListeners();
    }, onError: (message) {
      print("An error occurred in the audio stream: $message");
    });

    _audioPlayer?.onPlayerComplete.listen((event) {
      print("Playback complete. Setting _isPlayingNow to false.");
      _isPlayingNow = false;
      _time = 0; // Reset the timer to 0 whenever you start it
      _timer?.cancel(); // Cancel any existing timer
      notifyListeners();
    }, onError: (message) {
      print("An error occurred in the completion stream: $message");
    });

    controller.addListener(onTextChanged);
    controller.addListener(() {
      if (controller.text.isEmpty) {
        //startRecording();
      }
    });
  }

  Icon get icon {
    return _isPlayingNow
        ? const Icon(Icons.stop, color: Colors.green, size: 30)
        : const Icon(Icons.play_circle_outline, color: Colors.red, size: 30);
  }


  void onTextChanged() {
    notifyListeners();
  }

  Future<void > startRecording() async{
    try{
      if(await _audioRecord.hasPermission()){
        final status = await Permission.microphone.request();
        if(status != PermissionStatus.granted){
          print('Microphone permission');
        }else{
          Directory? dir;
          // final documentsDir = await getApplicationDocumentsDirectory();
          dir = Directory('/storage/emulated/0/Download/');
          dir = (await getExternalStorageDirectory())!;
          final fileCreateTime  =  DateTime.now().millisecondsSinceEpoch;
          await _audioRecord.start(const RecordConfig(), path: '${dir.path}/${controller.text}.mp3');
          // PDFApi.saveFileToDirectoryPath('$fileCreateTime.mp3', 'recordingNotes', 'This is a test file.');
           _isRecording = true;
          startTimer();
          notifyListeners();
        }
      }
    }catch(e){
      print('Error Starting recording $e');
    }
  }

  String formattedTime({required int timeInSecond}) {
    int sec = timeInSecond % 60;
    int min = (timeInSecond / 60).floor();
    String minute = min.toString().length <= 1 ? '0$min' : '$min';
    String seconds = sec.toString().length <= 1 ? '0$sec' : '$sec';
    // notifyListeners();
    return '$minute:$seconds';
  }

  void startTimer() {
    _time = 0; // Reset the timer to 0 whenever you start it
    _timer?.cancel(); // Cancel any existing timer
    const oneSec = Duration(seconds: 1);
    _timer = Timer.periodic(oneSec, (Timer timer) {
      _time++;
      print("Timer tick: $_time"); // Debug: Check if the timer is ticking
      notifyListeners(); // Notify listeners to update the UI
    });
  }

  Future<void> stopRecording() async {
    try {
      final String? path = await _audioRecord.stop();
      _timer?.cancel(); // Stop the timer
      _time = 0; // Reset the time if necessary
      _isRecording = false;
      if (path != null) {
        _audioPath = path;
        // print(_audioPath);
      }
    } catch (e) {
      print('Error stopping recording: $e');
    } finally {
      notifyListeners();
    }
  }
  String? get audioPath => _audioPath;

  Future<void > playRecording() async{
    try{
      Source urlSource = UrlSource(_audioPath!);
      print('url Source $urlSource');
      await _audioPlayer!.play(urlSource);
      _isPlayingNow = true;
      notifyListeners();
    }catch(e){
      _isPlayingNow = false;
      print('error playing problem $e');
    }
  }

  // Method to play audio
  Future<void> playAudioFromAssets(String assetPath) async {
    try {
      print("Player state in upper: ${_audioPlayer?.state}");
       await _audioPlayer!.play(DeviceFileSource(assetPath));
      _isPlayingNow = true;
      print("Player state in bottom: ${_audioPlayer?.state}");
      notifyListeners();
    } catch (e) {
      _isPlayingNow = false;
      print("An error occurred while playing audio: $e");
    }
    print("Player state in bottom bottom: ${_audioPlayer?.state}");
  }

   void seek(int durationInMill){
     notifyListeners();
    _audioPlayer!.seek(Duration(milliseconds: durationInMill));
   }

  @override
   void dispose() async{
    _timer?.cancel();
    _audioPlayer?.dispose();
   }


}
