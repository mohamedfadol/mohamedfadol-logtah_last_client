import 'package:diligov_members/widgets/custome_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localization.dart';
class CustomDialog extends StatelessWidget {
  final String title;
  final VoidCallback onConfirm;
  final VoidCallback onCancel;

  const CustomDialog({
    required this.title,
    required this.onConfirm,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.white,
      insetPadding: const EdgeInsets.symmetric(horizontal: 100),
      title: Center(
        child: CustomText(
          text: title,
          color: Colors.red,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      content: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Container(
          color: Colors.white,
          width: MediaQuery.of(context).size.width * 0.35,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 10.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton.icon(
                  label: CustomText(
                    text: 'Yes',
                    color: Colors.white,
                  ),
                  icon: const Icon(Icons.check, color: Colors.white),
                  onPressed: onConfirm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    padding: const EdgeInsets.symmetric(horizontal: 10.0),
                  ),
                ),
                ElevatedButton.icon(
                  label: CustomText(
                    text: '${AppLocalizations.of(context)!.no_cancel}',
                    color: Colors.white,
                  ),
                  icon: const Icon(Icons.clear, color: Colors.white),
                  onPressed: onCancel,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    padding: const EdgeInsets.symmetric(horizontal: 10.0),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
