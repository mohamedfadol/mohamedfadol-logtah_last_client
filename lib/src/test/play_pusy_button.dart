// import 'package:flutter/material.dart';
// import 'package:just_audio/just_audio.dart';
// import 'package:on_audio_query/on_audio_query.dart';
// class AudioItem extends StatefulWidget {
//   final SongModel item;
//   const AudioItem({super.key, required this.item});
//
//   @override
//   State<AudioItem> createState() => _AudioItemState();
// }
//
// class _AudioItemState extends State<AudioItem> {
//   final AudioPlayer _player = AudioPlayer();
//   bool _isPlay = true;
//   @override
//   Widget build(BuildContext context) {
//     return InkWell(
//       onTap: (){
//         if(_isPlay){
//           _player.setAudioSource(AudioSource.file(widget.item.data));
//           _player.play();
//         }else{
//           _player.stop();
//         }
//         setState(() {
//           _isPlay = !_isPlay;
//         });
//       },
//       child: ListTile(
//         title: Text(widget.item.title),
//         subtitle: Text(widget.item.artist ?? 'no artist'),
//         trailing: Container(
//           height: 30,
//           width: 30,
//           decoration: BoxDecoration(
//             gradient: LinearGradient(colors: [
//               Color.fromARGB(255, 46, 96, 24),
//               Color.fromARGB(255, 211, 51, 255),
//             ],
//                 begin: FractionalOffset(0.0,1.0),
//                 end: FractionalOffset(0.0,0.0),
//                 stops: [0.0, 1.0],
//                 tileMode: TileMode.clamp
//             ),borderRadius: BorderRadius.circular(30),
//           ),
//           padding: EdgeInsets.all(10),
//           child: _isPlay ? Icon(Icons.play_arrow) : Icon(Icons.pause),
//         ),
//         leading: QueryArtworkWidget(id: widget.item.id, type: ArtworkType.AUDIO,),
//       ),
//     );
//   }
// }
