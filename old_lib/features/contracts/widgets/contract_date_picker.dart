import 'package:flutter/material.dart';
import 'package:youragent/core/theme/app_colors.dart';
import 'package:youragent/l10n/app_localizations.dart';
import 'package:youragent/widgets/form_fields/app_form_text_field.dart';

class ContractDatePicker extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final AppLocalizations l10n;
  final bool isReadOnly;
  final DateTime? initialDate;
  final DateTime? firstDate;
  final DateTime? lastDate;
  final void Function(DateTime) onDateSelected;
  final String? Function(String?)? customValidator;
  final DateTime? Function(String) parseThaiDate;
  final VoidCallback onTapPick;

  const ContractDatePicker({
    super.key,
    required this.controller,
    required this.label,
    required this.l10n,
    required this.isReadOnly,
    required this.onTapPick,
    required this.onDateSelected,
    required this.parseThaiDate,
    this.initialDate,
    this.firstDate,
    this.lastDate,
    this.customValidator,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        FormFieldLabel(label: label, isRequired: true),
        const SizedBox(height: 8),
        Theme(
          data: Theme.of(context).copyWith(
            textSelectionTheme: isReadOnly
                ? const TextSelectionThemeData(
                    selectionColor: AppColors.gray800,
                    cursorColor: AppColors.gray800,
                  )
                : null,
          ),
          child: TextFormField(
            controller: controller,
            enabled: !isReadOnly,
            readOnly: true,
            style: theme.textTheme.bodyMedium,
            decoration: InputDecoration(
              hintText: label,
              hintStyle: theme.textTheme.bodyMedium?.copyWith(
                color: const Color(0xFFA4A7AE),
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: AppColors.grayBorder),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: AppColors.grayBorder),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: isReadOnly ? AppColors.grayBorder : AppColors.primary,
                ),
              ),
              disabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFFE9EAEB)),
              ),
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 16,
              ),
              filled: isReadOnly,
              fillColor: isReadOnly ? const Color(0xFFFFFFFF) : null,
              suffixIcon: isReadOnly
                  ? const Icon(
                      Icons.calendar_today_outlined,
                      size: 20,
                      color: AppColors.gray400,
                    )
                  : IconButton(
                      icon: const Icon(
                        Icons.calendar_today_outlined,
                        size: 20,
                        color: AppColors.gray400,
                      ),
                      onPressed: onTapPick,
                    ),
            ),
            onTap: isReadOnly ? null : onTapPick,
            validator: isReadOnly
                ? null
                : (customValidator ??
                    (value) {
                      if (value == null || value.isEmpty) {
                        return l10n.this_field_required;
                      }
                      final date = parseThaiDate(value);
                      if (date == null) {
                        return 'รูปแบบวันที่ไม่ถูกต้อง';
                      }
                      return null;
                    }),
          ),
        ),
      ],
    );
  }
}

