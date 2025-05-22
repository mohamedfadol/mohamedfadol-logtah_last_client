import 'package:equatable/equatable.dart';

class VoiceNoteModel extends Equatable{
  final String audioName;
  final DateTime createAt;
  final String audioPath;
  final String recordTime;

  const VoiceNoteModel({required this.audioName, required this.createAt, required this.audioPath, required this.recordTime});

  @override
  List<Object?> get props => [audioName,createAt,audioPath, recordTime];
}