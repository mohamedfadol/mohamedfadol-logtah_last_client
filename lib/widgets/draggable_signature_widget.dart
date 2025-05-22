import 'package:diligov_members/providers/laboratory_file_processing_provider_page.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/signature.dart';
import '../providers/signature_provider.dart';

class DraggableSignatureWidget extends StatelessWidget {
  final int signatureIndex;
  final Signature signature;

  const DraggableSignatureWidget({
    Key? key,
    required this.signatureIndex,
    required this.signature,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<LaboratoryFileProcessingProviderPage>(
        builder: (BuildContext context, provider, widget){
          return Positioned(
            left: signature.position.dx,
            top: signature.position.dy,
            child: Stack(
              alignment: Alignment.topRight,
              children: [
                Draggable(
                  feedback: Material(
                    child: SignatureBox(memberName: signature.userId),
                  ),
                  childWhenDragging: Container(),
                  onDraggableCanceled: (velocity, offset) {
                    // Ensure the new position is within the screen bounds
                    final screenSize = MediaQuery.of(context).size;
                    double dx = offset.dx;
                    double dy = offset.dy;
                    if (dx < 0) dx = 0;
                    if (dy < 0) dy = 0;
                    if (dx > screenSize.width - 200) dx = screenSize.width - 200;
                    if (dy > screenSize.height - 100) dy = screenSize.height - 100;

                    provider.updateSignaturePosition(signature.id,provider.signatures.indexOf(signature).toString(), Offset(dx, dy));

                  },

                  onDragEnd: (details) {
                    // Update position in the provider
                    provider.updateSignaturePosition(signature.id,provider.signatures.indexOf(signature).toString(), Offset(details.offset.dx, details.offset.dy));
                  },
                  child: GestureDetector(
                    onTap: () {
                      // Logic to edit or delete the signature
                    },
                    child: SignatureBox(memberName: signature.memberName),
                  ),
                ),
                Positioned(
                  top: 0,
                  right: 0,
                  child: GestureDetector(
                    onTap: () {
                      // Remove the signature
                      provider.removeSignature(signature.id, provider.indexing);
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                      padding: const EdgeInsets.all(4.0),
                      child: const Icon(
                        Icons.close,
                        color: Colors.white,
                        size: 16,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        }
    );
  }
}


class SignatureBox extends StatelessWidget {
  final String memberName;

  const SignatureBox({Key? key, required this.memberName}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 100,
      height: 50,
      color: Colors.blueAccent,
      alignment: Alignment.center,
      child: Text(
        memberName,
        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
      ),
    );
  }
}
