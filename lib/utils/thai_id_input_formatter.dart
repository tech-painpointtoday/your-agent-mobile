import 'package:flutter/services.dart';

class ThaiIdInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    String text = newValue.text;

    if (text.isEmpty) {
      return newValue;
    }

    // Clean data: keep only digits
    String cleanDigits = text.replaceAll(RegExp(r'[^\d]'), '');

    // Limit to 13 digits
    if (cleanDigits.length > 13) {
      cleanDigits = cleanDigits.substring(0, 13);
    }

    String formattedText = '';

    // Pattern: #-####-#####-##-#
    for (int i = 0; i < cleanDigits.length; i++) {
      if (i == 1 || i == 5 || i == 10 || i == 12) {
        formattedText += '-';
      }
      formattedText += cleanDigits[i];
    }

    // Calculate cursor position
    int selectionIndex = newValue.selection.end;
    int digitCountBeforeSelection = 0;
    for (int i = 0; i < selectionIndex && i < newValue.text.length; i++) {
      if (RegExp(r'\d').hasMatch(newValue.text[i])) {
        digitCountBeforeSelection++;
      }
    }

    int newSelectionIndex = 0;
    int currentDigits = 0;
    while (newSelectionIndex < formattedText.length &&
        currentDigits < digitCountBeforeSelection) {
      if (RegExp(r'\d').hasMatch(formattedText[newSelectionIndex])) {
        currentDigits++;
      }
      newSelectionIndex++;
    }

    return TextEditingValue(
      text: formattedText,
      selection: TextSelection.collapsed(offset: newSelectionIndex),
    );
  }

  /// Validates Thai National ID using Mod 11 algorithm
  static bool isValidThaiID(String id) {
    // Remove dashes
    String cleanID = id.replaceAll(RegExp(r'[^\d]'), '');

    if (cleanID.length != 13) return false;

    // Mod 11 check digit algorithm
    int sum = 0;
    for (int i = 0; i < 12; i++) {
      sum += int.parse(cleanID[i]) * (13 - i);
    }

    int checkDigit = (11 - (sum % 11)) % 10;

    return int.parse(cleanID[12]) == checkDigit;
  }
}
