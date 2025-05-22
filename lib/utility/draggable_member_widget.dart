import 'package:flutter/material.dart';

import '../models/member.dart';

class DraggableMemberWidget extends StatelessWidget {
  final Member member;

  const DraggableMemberWidget({Key? key, required this.member}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Draggable<Member>(
      data: member, // Pass the user object as data
      feedback: Material(
        child: Container(
          padding: const EdgeInsets.all(8.0),
          color: Colors.blueAccent,
          child: Text(
            member.memberFirstName!,
            style: const TextStyle(color: Colors.white),
          ),
        ),
      ),
      child: Container(
        margin: const EdgeInsets.all(8.0),
        padding: const EdgeInsets.all(8.0),
        color: Colors.lightBlue,
        child: Text(
          member.memberFirstName!,
          style: const TextStyle(color: Colors.white),
        ),
      ),
    );
  }
}
