import 'package:diligov_members/widgets/custome_text.dart';
import 'package:diligov_members/widgets/themed_container.dart';
import 'package:flutter/material.dart';

class CustomMessage extends StatelessWidget {
  final String text;
  CustomMessage({Key? key,required this.text}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return Center(
      child: ThemedContainer(
          padding: const EdgeInsets.all(20.0),
          child: Center(child: CustomText(text:text,fontSize: 20.0,fontWeight: FontWeight.bold),)
      ),
    );
  }
}
