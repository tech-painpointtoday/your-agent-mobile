import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:yourhome/core/theme/app_colors.dart';
import 'package:yourhome/l10n/app_localizations.dart';
import 'package:yourhome/widgets/form_fields/app_form_text_field.dart';

/// Reusable number field widget for general form usage
class AppFormNumberField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final bool isPrice;
  final bool isDecimal;
  final AppLocalizations l10n;
  final bool isRequired;
  final String? suffixText;
  final bool isReadOnly;
  final GlobalKey<FormFieldState<dynamic>>? fieldKey;
  final ValueChanged<String>? onChanged;
  final bool enable;

  const AppFormNumberField({
    super.key,
    required this.controller,
    required this.label,
    this.isPrice = false,
    this.isDecimal = false,
    required this.l10n,
    this.isRequired = true,
    this.suffixText,
    required this.isReadOnly,
    this.fieldKey,
    this.onChanged,
    this.enable = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        FormFieldLabel(label: label, isRequired: isRequired),
        const SizedBox(height: 8),
        Theme(
          data: Theme.of(context).copyWith(
            textSelectionTheme: isReadOnly
                ? const TextSelectionThemeData(
                    selectionColor: AppColors.baseDarkGrey,
                    cursorColor: AppColors.baseDarkGrey,
                  )
                : null,
          ),
          child: Builder(
            builder: (fieldContext) {
              return TextFormField(
                key: fieldKey,
                controller: controller,
                enabled: (isReadOnly == false) && (enable == true),
                readOnly: (isReadOnly == true),
                keyboardType: TextInputType.numberWithOptions(
                  decimal: isDecimal,
                ),
                style: (enable == true)
                    ? theme.textTheme.bodyMedium
                    : theme.textTheme.bodyMedium?.copyWith(
                        color: AppColors.baseGrey,
                      ),
                inputFormatters: isDecimal
                    ? null
                    : [FilteringTextInputFormatter.digitsOnly],
                decoration: InputDecoration(
                  hintText: label,
                  hintStyle: theme.textTheme.bodyMedium?.copyWith(
                    color: AppColors.baseGrey,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.baseGrey),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.baseGrey),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: (isReadOnly == true || enable == false)
                          ? AppColors.baseGrey
                          : AppColors.primary,
                    ),
                  ),
                  disabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.baseGrey),
                  ),
                  isDense: true,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 16,
                  ),
                  suffixText: suffixText,
                  suffixStyle: theme.textTheme.bodyMedium?.copyWith(
                    color: (enable == true)
                        ? AppColors.baseDarkGrey
                        : AppColors.baseGrey,
                  ),
                  filled: (isReadOnly == true) || (enable == false),
                  fillColor: (enable == false)
                      ? AppColors.basePaleGrey
                      : (isReadOnly == true ? AppColors.white : null),
                ),
                validator: (isReadOnly == true)
                    ? null
                    : (value) {
                        if (isRequired == true &&
                            (value == null || value.isEmpty)) {
                          return l10n.this_field_required;
                        }
                        if (value != null && value.isNotEmpty) {
                          final num = isDecimal
                              ? double.tryParse(value)
                              : int.tryParse(value.replaceAll(',', ''));
                          if (num == null) {
                            return l10n.please_enter_valid_number;
                          }
                        }
                        return null;
                      },
                onChanged: (isReadOnly == true)
                    ? null
                    : (value) {
                        if (isPrice && value.isNotEmpty) {
                          final cleanValue = value.replaceAll(',', '');
                          final num = int.tryParse(cleanValue);
                          if (num != null) {
                            final formatted = NumberFormat('#,###').format(num);
                            if (formatted != value) {
                              controller.value = TextEditingValue(
                                text: formatted,
                                selection: TextSelection.collapsed(
                                  offset: formatted.length,
                                ),
                              );
                              // Call external onChanged with formatted value
                              onChanged?.call(formatted);
                              return;
                            }
                          }
                        }
                        // Call external onChanged with original value
                        onChanged?.call(value);
                      },
              );
            },
          ),
        ),
      ],
    );
  }
}
