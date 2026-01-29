import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

class CurrencyInputFormatter extends TextInputFormatter {
  final int decimalPlaces;
  final bool allowDecimals;
  final NumberFormat _integerFormatter;

  CurrencyInputFormatter({
    this.allowDecimals = true,
    this.decimalPlaces = 2,
    String locale = 'en_US',
  }) : _integerFormatter = NumberFormat.decimalPattern(locale);

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    // If the new value is empty, return it
    if (newValue.text.isEmpty) {
      return newValue.copyWith(text: '');
    }

    // 1. Clean data: keep only digits and the first decimal point
    String cleanText = newValue.text.replaceAll(RegExp(r'[^\d.]'), '');

    // Handle decimal points
    if (!allowDecimals) {
      cleanText = cleanText.replaceAll('.', '');
    } else {
      int dotIndex = cleanText.indexOf('.');
      if (dotIndex != -1) {
        String beforeDot = cleanText.substring(0, dotIndex);
        String afterDot = cleanText.substring(dotIndex + 1).replaceAll('.', '');
        if (afterDot.length > decimalPlaces) {
          afterDot = afterDot.substring(0, decimalPlaces);
        }
        cleanText = '$beforeDot.$afterDot';
      }
    }

    if (cleanText.isEmpty) {
      return newValue.copyWith(text: '');
    }

    // 2. Split into parts
    bool hasDot = cleanText.contains('.');
    String integerPart = hasDot ? cleanText.split('.')[0] : cleanText;
    String decimalPart = hasDot
        ? (cleanText.split('.').length > 1 ? cleanText.split('.')[1] : '')
        : '';

    // 3. Format integer part
    String formattedText = '';
    if (integerPart.isNotEmpty) {
      double? val = double.tryParse(integerPart);
      if (val != null) {
        formattedText = _integerFormatter.format(val);
      } else {
        formattedText = integerPart; // Fallback
      }
    } else if (hasDot) {
      formattedText = '0';
    }

    // 4. Add decimal part
    if (hasDot) {
      formattedText += '.$decimalPart';
    }

    // 5. Calculate cursor position
    // Count non-separator characters before the selection in newValue.text
    int selectionIndex = newValue.selection.end;
    int nonSeparatorCountBeforeSelection = 0;
    for (int i = 0; i < selectionIndex && i < newValue.text.length; i++) {
      String char = newValue.text[i];
      if (char == '.' || RegExp(r'\d').hasMatch(char)) {
        nonSeparatorCountBeforeSelection++;
      }
    }

    // Find the new selection index in formattedText
    int newSelectionIndex = 0;
    int currentCount = 0;
    while (newSelectionIndex < formattedText.length &&
        currentCount < nonSeparatorCountBeforeSelection) {
      String char = formattedText[newSelectionIndex];
      if (char == '.' || RegExp(r'\d').hasMatch(char)) {
        currentCount++;
      }
      newSelectionIndex++;
    }

    return TextEditingValue(
      text: formattedText,
      selection: TextSelection.collapsed(offset: newSelectionIndex),
    );
  }
}
