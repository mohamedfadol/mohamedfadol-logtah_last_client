import 'package:flutter/material.dart';

class CustomModelDropdown<T> extends StatelessWidget {
  final T? value;
  final List<T> items;
  final String hintText;
  final String Function(T item) getLabel;
  final int? Function(T item) getValue;
  final void Function(int?) onChanged;
  final String allItemsLabel;

  const CustomModelDropdown({
    super.key,
    required this.value,
    required this.items,
    required this.getLabel,
    required this.getValue,
    required this.onChanged,
    this.hintText = 'Select Item',
    this.allItemsLabel = 'All Items',
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButton<int?>(
      value: value != null ? getValue(value!) : null,
      isExpanded: true,
      underline: const SizedBox(),
      hint: Text(hintText),
      items: [
        DropdownMenuItem<int?>(
          value: null,
          child: Text(allItemsLabel),
        ),
        ...items.map((item) {
          final itemValue = getValue(item);
          return DropdownMenuItem<int?>(
            value: itemValue,
            child: Container(
              height: double.infinity,
              width: double.infinity,
              decoration: BoxDecoration(
                border: Border.all(width: 0.1, color: Colors.black),
              ),
              child: Center(child: Text(getLabel(item))),
            ),
          );
        }).toList()
      ],
      onChanged: onChanged,
    );
  }
}
