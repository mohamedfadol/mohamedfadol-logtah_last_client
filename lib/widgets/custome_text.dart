import 'package:flutter/material.dart';

class CustomText extends StatelessWidget {
  final String text;
  final Color? color;
  final FontWeight? fontWeight;
  final double? fontSize;
  final bool? softWrap;
  final int? maxLines;
  final TextOverflow? overflow;
  final TextAlign? textAlign;
  CustomText({
    Key? key,
    required this.text,
    this.color,
    this.fontWeight,
    this.fontSize,
    this.softWrap,
    this.maxLines,
    this.overflow, this.textAlign,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final TextStyle defaultStyle = Theme.of(context).textTheme.bodyMedium ?? TextStyle();

    return Text(
      text,
      style: defaultStyle.copyWith(
        color: color ?? defaultStyle.color, // Use theme color if not provided
        fontSize: fontSize ?? defaultStyle.fontSize, // Use theme fontSize if not provided
        fontWeight: fontWeight ?? defaultStyle.fontWeight, // Use theme fontWeight if not provided
      ),
      softWrap: softWrap,
      maxLines: maxLines,
      overflow: overflow,
      textAlign: textAlign,
    );
  }
}
