import 'package:diligov_members/models/member.dart';

class Signature {
  int? signatureId;
  bool? hasSigned;
  Member? member;

  Signature({this.signatureId,this.member,this.hasSigned});

  // create new converter
  Signature.fromJson(Map<String, dynamic> json) {
    signatureId = json['id'];
    hasSigned = json['has_signed'];
    member =  Member?.fromJson(json['member']);
  }


}