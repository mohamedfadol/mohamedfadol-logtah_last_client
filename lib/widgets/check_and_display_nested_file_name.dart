import 'package:diligov_members/widgets/custome_text.dart';
import 'package:flutter/material.dart';

class NestedFileNameWidget extends StatelessWidget {
  final List<List<List<String>>> list;
  final int index;
  final int subIndex;
  final int subSubIndex;
  final Widget Function(String)? customWidgetBuilder;

  const NestedFileNameWidget({
    Key? key,
    required this.list,
    required this.index,
    required this.subIndex,
    required this.subSubIndex,
    this.customWidgetBuilder,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return checkAndDisplayNestedFileName(
      list: list,
      index: index,
      subIndex: subIndex,
      subSubIndex: subSubIndex,
      customWidgetBuilder: customWidgetBuilder,
    );
  }

  Widget checkAndDisplayNestedFileName({
    required List<List<List<String>>> list,
    required int index,
    required int subIndex,
    required int subSubIndex,
    Widget Function(String)? customWidgetBuilder,
  }) {
    // Check if the nested lists and indices exist
    if (list.isNotEmpty &&
        index < list.length &&
        subIndex < list[index].length &&
        subSubIndex < list[index][subIndex].length) {
      final fileName = list[index][subIndex][subSubIndex];

      // If a custom widget builder is provided, use it; otherwise, use a default widget
      if (fileName.isNotEmpty) {
        return customWidgetBuilder != null
            ? customWidgetBuilder(fileName)
            : CustomText(text: fileName); // Use your custom widget here
      }
    }

    // Return SizedBox.shrink() if validation fails or file name is empty
    return const SizedBox.shrink();
  }
}

//
// NestedFileNameWidget(
// list: yourList,
// index: 0,
// subIndex: 1,
// subSubIndex: 2,
// customWidgetBuilder: (fileName) => TextButton(
// onPressed: () {},
// child: Text(fileName),
// ),
// )