import 'package:flutter/material.dart';

import 'package:uuid/uuid.dart';

class Signature {
  final String id;
  final String memberName;
  final String userId;
  final String pageId;
  Offset position;

  Signature( {
    required this.id,
    required this.memberName,
    required this.userId,
    required this.pageId,
    required this.position,
  });

  factory Signature.create({
    required String userId,
    required memberName,
    required String pageId,
    required Offset position,
  }) {
    return Signature(
      id: const Uuid().v4(), // Generate a unique ID
      memberName: memberName,
      userId: userId,
      pageId: pageId,
      position: position,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      "position_dy": position.dy,
      "position_dx": position.dx,
      "userId": userId,
      "pageId" : pageId
    };
  }

}
