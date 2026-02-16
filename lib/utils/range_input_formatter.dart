import 'package:flutter/services.dart';

class RangeInputFormatter extends TextInputFormatter {
  final int min;
  final int max;

  RangeInputFormatter({required this.min, required this.max});

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.isEmpty) {
      return newValue;
    }

    // Allow typing leading '0' if it's not the only character or if we allow it
    // But for 1-31, we don't really want '0' alone.
    // If we want to allow '01', '02', etc., we need to handle it.

    try {
      final int value = int.parse(newValue.text);
      if (value < min || value > max) {
        return oldValue;
      }
    } catch (e) {
      return oldValue;
    }

    return newValue;
  }
}
