import 'package:diligov_members/widgets/custome_text.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/theme_provider.dart';
class MenuButton extends StatelessWidget {
  final String text;
  final FontWeight? fontWeight;
  final double? fontSize;
  final Color? color ;
  MenuButton({Key? key, required this.text,this.fontWeight, this.fontSize, this.color}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return CustomText(text: text, fontSize: fontSize,fontWeight: fontWeight,color: color,);
  }
}
