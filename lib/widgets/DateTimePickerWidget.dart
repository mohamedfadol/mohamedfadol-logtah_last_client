import 'package:flutter/material.dart';
import 'package:intl/intl.dart';  // For formatting the date and time

class DateTimePickerWidget extends StatefulWidget {
  final String fieldName;
  final TextEditingController controller;
  final Function(String) onDateTimeSelected;

  DateTimePickerWidget({
    required this.fieldName,
    required this.controller,
    required this.onDateTimeSelected,
  });

  @override
  _DateTimePickerWidgetState createState() => _DateTimePickerWidgetState();
}

class _DateTimePickerWidgetState extends State<DateTimePickerWidget> {
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;

  Future<void> _pickDate() async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),  // Can adjust to suit your need
      lastDate: DateTime(2101),
    );

    setState(() {
      _selectedDate = pickedDate;
      _pickTime(); // Once date is selected, proceed to pick time
    });
    }

  Future<void> _pickTime() async {
    TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (pickedTime != null) {
      setState(() {
        _selectedTime = pickedTime;
        _formatDateTime(); // Once time is selected, format and return the combined value
      });
    }
  }

  void _formatDateTime() {
    if (_selectedDate != null && _selectedTime != null) {
      final formattedDate = DateFormat('yyyy-MM-dd').format(_selectedDate!);
      final formattedTime = _selectedTime!.format(context);

      final dateTimeString = '$formattedDate $formattedTime';
      widget.controller.text = dateTimeString;
      widget.onDateTimeSelected(dateTimeString);
    }
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      readOnly: true,
      onTap: _pickDate,
      decoration: InputDecoration(
        labelText: widget.fieldName,
        suffixIcon: Icon(Icons.calendar_today),
        border: OutlineInputBorder(),
        isDense: true,
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please select ${widget.fieldName}';
        }
        return null;
      },
    );
  }
}
