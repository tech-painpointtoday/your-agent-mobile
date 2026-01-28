import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

class CurrencyInputFormatter extends TextInputFormatter {
  final NumberFormat _formatter;
  final bool allowDecimals;
  final int decimalPlaces;

  CurrencyInputFormatter({
    this.allowDecimals = true,
    this.decimalPlaces = 2,
    String locale = 'en_US',
  }) : _formatter = NumberFormat.currency(
         locale: locale,
         symbol: '',
         decimalDigits: decimalPlaces,
       );

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    // If the new value is empty, return it
    if (newValue.text.isEmpty) {
      return newValue.copyWith(text: '');
    }

    // Remove all non-digit characters except decimal point (if allowed)
    String newText = newValue.text.replaceAll(RegExp(r'[^\d.]'), '');

    // Handle multiple decimal points
    if (allowDecimals) {
      int firstDecimal = newText.indexOf('.');
      if (firstDecimal != -1) {
        String afterDecimal = newText
            .substring(firstDecimal + 1)
            .replaceAll('.', '');
        // Limit decimal places
        if (afterDecimal.length > decimalPlaces) {
          afterDecimal = afterDecimal.substring(0, decimalPlaces);
        }
        newText = newText.substring(0, firstDecimal + 1) + afterDecimal;
      }
    } else {
      newText = newText.replaceAll('.', '');
    }

    // Parse the number
    double value = double.tryParse(newText) ?? 0.0;

    // Format string
    // If user is typing decimal, don't force formatting yet otherwise it's hard to type
    if (newText.endsWith('.') && allowDecimals) {
      return newValue.copyWith(
        text: newText,
        selection: TextSelection.collapsed(offset: newText.length),
      );
    }

    // If there are decimals but not full amount, keep them
    if (allowDecimals && newText.contains('.')) {
      // Check if there are trailing zeros that formatter removes
      // We want to keep user input if they typed "10.0" -> "10.0" not "10"
      return newValue.copyWith(
        text: newText,
        selection: TextSelection.collapsed(offset: newText.length),
      );
    }

    String formatted = _formatter.format(value).trim();

    // Calculate cursor position
    // This is a simple heuristic; for complex cases usually cursor logic is more involved
    // but for simple adding commas it usually works to just put at end if standard forward typing
    // If backspacing, need more logic.
    // Since this is a simple implementation, let's just return formatted value with cursor at end unless specified otherwise

    // Better implementation to keep cursor relative position?
    // Let's stick to standard behavior for now: cursor at end is often acceptable for basic currency input
    // or we can try to preserve selection.

    // Basic approach:
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}
