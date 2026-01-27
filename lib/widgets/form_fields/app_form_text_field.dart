import 'package:flutter/material.dart';
import 'package:youragent/core/theme/app_colors.dart';
import 'package:youragent/l10n/app_localizations.dart';

/// Helper widget to build label with red asterisk for required fields
class FormFieldLabel extends StatelessWidget {
  final String label;
  final bool isRequired;
  final int maxLines;

  const FormFieldLabel({
    super.key,
    required this.label,
    this.isRequired = true,
    this.maxLines = 1,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return RichText(
      maxLines: maxLines,
      text: TextSpan(
        style: theme.textTheme.labelLarge,
        children: [
          TextSpan(text: label),
          if (isRequired)
            TextSpan(
              text: ' *',
              style: theme.textTheme.labelMedium?.copyWith(color: Colors.red),
            ),
        ],
      ),
    );
  }
}

/// Reusable text field widget for general form usage
class AppFormTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final int maxLines;
  final bool readOnly;
  final AppLocalizations l10n;
  final bool isRequired;
  final bool enable;
  final ValueChanged<String>? onChanged;
  final bool isReadOnly;
  final GlobalKey<FormFieldState<dynamic>>? fieldKey;

  const AppFormTextField({
    super.key,
    required this.controller,
    required this.label,
    this.maxLines = 1,
    this.readOnly = false,
    required this.l10n,
    this.isRequired = true,
    this.enable = true,
    this.onChanged,
    required this.isReadOnly,
    this.fieldKey,
  });

  @override
  Widget build(BuildContext context) {
    final isReadOnlyField = isReadOnly || readOnly;
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        FormFieldLabel(label: label, isRequired: isRequired),
        const SizedBox(height: 8),
        Theme(
          data: Theme.of(context).copyWith(
            textSelectionTheme: isReadOnlyField
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
                readOnly: isReadOnlyField,
                enabled: (isReadOnly == false) && (enable == true),
                maxLines: maxLines,
                onChanged: (isReadOnly == true) ? null : onChanged,
                style: (enable == true)
                    ? theme.textTheme.bodyMedium
                    : theme.textTheme.bodyMedium?.copyWith(
                        color: AppColors.baseGrey,
                      ),
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
                      color: (enable == false || isReadOnlyField == true)
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
                  filled: (isReadOnlyField == true) || (enable == false),
                  fillColor: (enable == false)
                      ? AppColors.basePaleGrey
                      : (isReadOnlyField == true ? AppColors.white : null),
                ),
                validator: isReadOnly
                    ? null
                    : (value) {
                        if (isRequired && (value == null || value.isEmpty)) {
                          return l10n.this_field_required;
                        }
                        return null;
                      },
              );
            },
          ),
        ),
      ],
    );
  }
}
