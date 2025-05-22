import 'package:flutter/material.dart';

import '../colors.dart';

class ThemedContainer extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final double? borderRadius;

  const ThemedContainer({
    Key? key,
    required this.child,
    this.padding,
    this.borderRadius,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final containerColor = isDarkMode ? Colour().darkContainerColor : Colour().lightContainerColor ;

    return Container(
      padding: padding ?? EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: containerColor,
        borderRadius: BorderRadius.circular(borderRadius ?? 10.0),
      ),
      child: child,
    );
  }
}
