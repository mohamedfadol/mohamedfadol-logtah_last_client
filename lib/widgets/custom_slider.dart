import 'package:flutter/material.dart';

class CustomSlider extends StatelessWidget {
  final double min;
  final double max;
  final int divisions;
  final double value;
  final ValueChanged<double> onChanged;
  final String label;

  const CustomSlider({
    Key? key,
    required this.min,
    required this.max,
    required this.divisions,
    required this.value,
    required this.onChanged,
    required this.label,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Slider(
      min: min,
      max: max,
      divisions: divisions,
      value: value,
      onChanged: onChanged,
      label: label,
    );
  }
}
