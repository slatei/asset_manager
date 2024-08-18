import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class AssetDatePicker extends StatefulWidget {
  const AssetDatePicker({
    super.key,
    required this.onChanged,
  });

  final Function(DateTime? picked) onChanged;

  @override
  State<AssetDatePicker> createState() => _AssetDatePickerState();
}

class _AssetDatePickerState extends State<AssetDatePicker> {
  DateTime? _purchaseDate;

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now().add(const Duration(days: 365 * 3)),
    );
    if (picked != null && picked != _purchaseDate) {
      setState(() {
        _purchaseDate = picked;
      });
      widget.onChanged(picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _selectDate(context),
      child: AbsorbPointer(
        child: TextFormField(
          decoration: InputDecoration(
            prefixIcon: const Icon(Icons.calendar_today),
            labelText: _purchaseDate == null
                ? 'Select a date'
                : DateFormat.yMMMd().format(_purchaseDate!),
            border: const OutlineInputBorder(),
          ),
          validator: (value) {
            return null; // No validation for optional field
          },
          onSaved: (value) {
            // No action needed as _purchaseDate is set directly by _selectDate
          },
        ),
      ),
    );
  }
}
