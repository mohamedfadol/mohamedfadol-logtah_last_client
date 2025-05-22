import 'package:diligov_members/widgets/custome_text.dart';
import 'package:flutter/material.dart';

class CheckAndDisplayFileName extends StatelessWidget {
  const CheckAndDisplayFileName({
    super.key,
    required this.list,
    required this.index,
    required this.subIndex,
    this.customWidgetBuilder,
    this.onFileImport, // New function to handle file imports
  });

  final List<List<String>> list;
  final int index;
  final int subIndex;
  final Widget Function(String)? customWidgetBuilder; // Custom widget builder for display
  final Function(String)? onFileImport; // Function to handle file import

  @override
  Widget build(BuildContext context) {
    // Check if the list is not empty and contains valid sublists and indices
    if (list.isNotEmpty && index < list.length && subIndex < list[index].length) {
      final fileName = list[index][subIndex];
      if (fileName.isNotEmpty) {
        // If a file import function is provided, execute it
        if (onFileImport != null) {
          onFileImport!(fileName); // Trigger the file import action
        }

        // If a custom widget builder is provided, use it; otherwise, use the default widget
        return customWidgetBuilder != null
            ? customWidgetBuilder!(fileName)
            : CustomText(text: fileName); // Default widget for file display
      }
    }

    // Return SizedBox.shrink() if the conditions are not met
    return const SizedBox.shrink();
  }
}
