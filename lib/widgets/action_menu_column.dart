import 'package:diligov_members/widgets/custom_icon.dart';
import 'package:diligov_members/widgets/custome_text.dart';
import 'package:flutter/material.dart';

import '../colors.dart';

class ActionMenuColumn extends StatelessWidget {
  final Map<String, IconData> actions; // Maps a label to an icon
  final Map<String, VoidCallback> callbacks; // Maps a label to a callback function

  const ActionMenuColumn({
    Key? key,
    required this.actions,
    required this.callbacks,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final containerColor = isDarkMode ? Colour().darkContainerColor : Colour().lightContainerColor ;

    return Column(
      children: actions.keys.map((action) => Container(

      margin: EdgeInsets.symmetric(vertical: 2), // Adds spacing between items
      decoration: BoxDecoration(
        color: containerColor,
        border: Border.all(color: Colors.white!, width: 1.0), // Border for each ListTile
        borderRadius: BorderRadius.circular(5), // Optional: Rounded corners
      ),
      child: InkWell(
        onTap: callbacks[action],
        child: ListTile(
          title: CustomText(text: action),
          trailing: IconButton(
            icon: CustomIcon(icon: actions[action]!), // Use the icon mapped to this action
            onPressed: callbacks[action], // Use the callback mapped to this action
          ),
        ),
      ),
    )).toList(),

    );
  }
}
