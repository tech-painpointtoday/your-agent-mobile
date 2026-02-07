import 'package:flutter/services.dart';

class ThaiPhoneInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    String text = newValue.text;

    if (text.isEmpty) {
      return newValue;
    }

    // 1. Clean data: keep only digits and the leading +
    bool hasPlus = text.startsWith('+');
    String cleanDigits = text.replaceAll(RegExp(r'[^\d]'), '');

    String formattedText = '';
    int removedCharsCount = 0;

    if (hasPlus) {
      if (cleanDigits.startsWith('66')) {
        // Thai International Format: +66X-XXXX-XXXX
        String remaining = cleanDigits.substring(2);

        // Remove leading '0' if it exists after '66' (+660 is not allowed)
        if (remaining.startsWith('0')) {
          remaining = remaining.replaceFirst('0', '');
          removedCharsCount = 1;
        }

        formattedText = '+66';
        if (remaining.isNotEmpty) {
          formattedText += remaining[0];
          if (remaining.length > 1) {
            // Use 4-4 split for mobile/BKK (following 08-1234-5678 pattern)
            formattedText +=
                '-${remaining.substring(1, remaining.length > 5 ? 5 : remaining.length)}';
            if (remaining.length > 5) {
              formattedText +=
                  '-${remaining.substring(5, remaining.length > 9 ? 9 : remaining.length)}';
            }
          }
        }
      } else {
        // Other country code: +{another country} -> don't limit the length, no Thai pattern
        formattedText = '+$cleanDigits';
      }
    } else {
      // Local Thai Pattern Logic
      // 1. Prevent multiple leading zeros
      if (cleanDigits.startsWith('00')) {
        int leadingZerosInOriginal = 0;
        for (int i = 0; i < cleanDigits.length; i++) {
          if (cleanDigits[i] == '0')
            leadingZerosInOriginal++;
          else
            break;
        }
        cleanDigits = '0${cleanDigits.substring(leadingZerosInOriginal)}';
        removedCharsCount = leadingZerosInOriginal - 1;
      }

      if (cleanDigits.startsWith('0')) {
        if (cleanDigits.length >= 2) {
          String firstTwo = cleanDigits.substring(0, 2);
          if (firstTwo == '02' ||
              firstTwo == '06' ||
              firstTwo == '08' ||
              firstTwo == '09') {
            // 10 digits local formatting: 0x-xxxx-xxxx
            formattedText = '$firstTwo';
            if (cleanDigits.length > 2) {
              formattedText +=
                  '-${cleanDigits.substring(2, cleanDigits.length > 6 ? 6 : cleanDigits.length)}';
              if (cleanDigits.length > 6) {
                formattedText +=
                    '-${cleanDigits.substring(6, cleanDigits.length > 10 ? 10 : cleanDigits.length)}';
              }
            }
          } else {
            // Province landline: 0xx-xxxxxx (9 digits)
            if (cleanDigits.length >= 3) {
              formattedText = '${cleanDigits.substring(0, 3)}';
              if (cleanDigits.length > 3) {
                formattedText +=
                    '-${cleanDigits.substring(3, cleanDigits.length > 9 ? 9 : cleanDigits.length)}';
              }
            } else {
              formattedText = cleanDigits;
            }
          }
        } else {
          formattedText = cleanDigits;
        }
      } else {
        // Doesn't start with 0 or +, limit to 10 digits as generic fallback
        formattedText = cleanDigits.substring(
          0,
          cleanDigits.length > 10 ? 10 : cleanDigits.length,
        );
      }
    }

    // 2. Calculate cursor position
    int selectionIndex = newValue.selection.end;
    int digitAndPlusCountBeforeSelection = 0;

    // Count how many significant chars (digits or +) were before the cursor in the typed text
    for (int i = 0; i < selectionIndex && i < newValue.text.length; i++) {
      String char = newValue.text[i];
      if (RegExp(r'\d').hasMatch(char) || char == '+') {
        digitAndPlusCountBeforeSelection++;
      }
    }

    // Adjust count based on removed characters (like extra zeros)
    // For +660, if cursor was after 0, digitAndPlusCountBeforeSelection was 4, now 3.
    if (hasPlus && text.startsWith('+660') && selectionIndex > 3) {
      digitAndPlusCountBeforeSelection -= 1;
    } else if (!hasPlus && text.startsWith('00')) {
      digitAndPlusCountBeforeSelection -= removedCharsCount;
    }

    if (digitAndPlusCountBeforeSelection < 0)
      digitAndPlusCountBeforeSelection = 0;

    int newSelectionIndex = 0;
    int currentCount = 0;
    while (newSelectionIndex < formattedText.length &&
        currentCount < digitAndPlusCountBeforeSelection) {
      String char = formattedText[newSelectionIndex];
      if (RegExp(r'\d').hasMatch(char) || char == '+') {
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
