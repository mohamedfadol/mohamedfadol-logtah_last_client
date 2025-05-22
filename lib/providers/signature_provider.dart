import 'package:flutter/material.dart';

import '../models/signature.dart';

class SignatureProvider extends ChangeNotifier {
  final List<Signature> _signatures = [];

  List<Signature> get signatures => List.unmodifiable(_signatures);

  void addSignature(Signature signature) {
    _signatures.add(signature);
    notifyListeners();
  }

  void updateSignaturePosition(int index, Offset newPosition) {
    _signatures[index].position = newPosition;
    notifyListeners();
  }

  void removeSignature(int index) {
    _signatures.removeAt(index);
    notifyListeners();
  }

  List<Signature> getSignaturesForPage(String pageId) {
    return _signatures.where((signature) => signature.pageId == pageId).toList();
  }
}
