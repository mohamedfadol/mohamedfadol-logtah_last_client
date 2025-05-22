import 'package:flutter/material.dart';

import '../colors.dart';
import 'custom_icon.dart';
import 'custome_text.dart';

class CustomTextFormField extends StatelessWidget {
  CustomTextFormField(
      { Key? key,
        required this.valid,
        required this.myController,
        required this.lableText,
        required this.prefixIcon,
        required this.borderRadius,
        required this.hintText}) : super(key: key);

  final String lableText;
  final String hintText;
  final IconData prefixIcon;
  final double borderRadius;
  final String? Function(String?) valid;
  final TextEditingController? myController;
  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final containerColor = isDarkMode ? Colour().darkContainerColor : Colour().lightContainerColor ;

    return Container(
      decoration: BoxDecoration(
        color: containerColor,
        borderRadius: BorderRadius.circular(30),
      ),
      margin: const EdgeInsets.symmetric(horizontal: 300),
      child: TextFormField(
        validator: valid,
        controller: myController,
        textAlign: TextAlign.center,
        decoration: InputDecoration(
            isDense: true,
            floatingLabelBehavior: FloatingLabelBehavior.always,
            contentPadding:  EdgeInsets.symmetric(vertical: 1.0),
            label: CustomText(text: lableText),
            labelStyle:  TextStyle(color: containerColor),
            prefixIcon: CustomIcon(icon: prefixIcon),

            hintText: hintText,
            hintStyle: TextStyle(fontSize: 14,color: containerColor,fontWeight: FontWeight.bold),
            border: OutlineInputBorder(
                borderSide: BorderSide(color: containerColor,),
              borderRadius: BorderRadius.circular(borderRadius),
            )
        ),
      ),
    );
  }


}
