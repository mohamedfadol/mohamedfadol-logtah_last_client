import 'package:flutter/material.dart';

import '../colors.dart';
import 'custom_icon.dart';
import 'custome_text.dart';

class CustomPasswordFormField extends StatelessWidget {
  CustomPasswordFormField(
      { Key? key,
        required this.valid,
        required this.myController,
        required this.labelText,
        required this.prefixIcon,
        this.suffixIcon,
        required this.obscureText,
        required this.borderRadius,
        required this.toggleVisibility,
        required this.hintText, String? errorText}) : super(key: key);

  final String labelText;
  final bool obscureText;
  final String hintText;
  final IconData prefixIcon;
  final IconButton? suffixIcon;
  final double borderRadius;
  final String? Function(String?) valid;
  final TextEditingController? myController;
  final Function() toggleVisibility;
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
        obscureText: obscureText,
        textAlign: TextAlign.center,
        decoration: InputDecoration(
            isDense: true,
            floatingLabelBehavior: FloatingLabelBehavior.always,
            contentPadding:  EdgeInsets.symmetric(vertical: 1.0),
            label: CustomText(text: labelText),
            labelStyle: TextStyle(color: containerColor),
            prefixIcon: CustomIcon(icon: prefixIcon),
            suffixIcon: IconButton(
              icon: CustomIcon(icon:
                obscureText ? Icons.visibility_off : Icons.visibility,
              ),
              onPressed: toggleVisibility,
            ),
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
