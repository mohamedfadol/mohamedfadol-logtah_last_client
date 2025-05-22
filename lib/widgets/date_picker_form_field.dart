import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:nepali_date_picker/nepali_date_picker.dart';

class DatePickerFormField extends StatefulWidget {
  final TextEditingController dateController;
  final String fieldName;
  final Function(NepaliDateTime?) onDateSelected;

  DatePickerFormField({required this.dateController, required this.onDateSelected, required this.fieldName});

  @override
  _DatePickerFormFieldState createState() => _DatePickerFormFieldState();
}

class _DatePickerFormFieldState extends State<DatePickerFormField> {
  NepaliDateTime? _selectedDateTime;

  Future<void> _pickDateTime() async {
    NepaliDateTime now = NepaliDateTime.now();
    _selectedDateTime = await showMaterialDatePicker(
      // locale:  const Locale("ar","AR"),
      context: context,
      initialDate: NepaliDateTime(now.year, now.month, now.day),
      firstDate: NepaliDateTime(2000),
      lastDate: NepaliDateTime(2090),
      initialDatePickerMode: DatePickerMode.day,
    );

    if (_selectedDateTime != null) {
      var timeOfDay = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(
          _selectedDateTime!.toDateTime(),
        ),
      );
      if (timeOfDay != null) {
        _selectedDateTime = _selectedDateTime!.mergeTime(
          timeOfDay.hour,
          timeOfDay.minute,
          0,
        );
        widget.dateController.text = _formatDateTime(_selectedDateTime!); // Update the text field
        widget.onDateSelected(_selectedDateTime); // Return the selected value
      }
    }
  }

  String _formatDateTime(NepaliDateTime dateTime) {
    // Format the date without milliseconds
    DateTime normalDateTime = dateTime.toDateTime();
    return DateFormat('yyyy-MM-dd HH:mm:ss').format(normalDateTime);
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.dateController,
      validator: (val) => val != null && val.isEmpty ? 'please enter ${widget.fieldName}' : null,
      readOnly: true,
      onTap: _pickDateTime,
      decoration: InputDecoration(
        border: InputBorder.none,
        isDense: true,
        contentPadding: const EdgeInsets.fromLTRB(8.0, 8.0, 8.0, 0.0),
        labelText: widget.fieldName,
        suffixIcon: Icon(Icons.calendar_today),
      ),
    );
  }
}

