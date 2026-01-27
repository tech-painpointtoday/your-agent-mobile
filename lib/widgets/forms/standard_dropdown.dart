import 'package:flutter/material.dart';
import 'package:youragent/core/theme/app_colors.dart';
import 'package:youragent/l10n/app_localizations.dart';
import 'form_label.dart';

class StandardDropdown<T> extends StatelessWidget {
  final String label;
  final String? hintText;
  final T? value;
  final List<DropdownMenuItem<T>> items;
  final void Function(T?)? onChanged;
  final bool isRequired;
  final bool isReadOnly;
  final String? Function(T?)? validator;

  const StandardDropdown({
    super.key,
    required this.label,
    required this.items,
    this.hintText,
    this.value,
    this.onChanged,
    this.isRequired = true,
    this.isReadOnly = false,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        FormLabel(label: label, isRequired: isRequired),
        DropdownButtonFormField<T>(
          initialValue:
              value, // Changed from initialValue to value for better sync if needed
          isExpanded: true,
          items: items,
          onChanged: isReadOnly ? null : onChanged,
          validator:
              validator ??
              (value) {
                if (isRequired && value == null) {
                  return AppLocalizations.of(context)?.field_required;
                }
                return null;
              },
          icon: const Icon(
            Icons.keyboard_arrow_down_rounded, // Chevron down rounded
            color: AppColors.baseDarkGrey,
          ),
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: isReadOnly ? AppColors.baseDarkGrey : AppColors.baseDarkGrey,
          ),
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColors.baseGrey, // #A4A7AE
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
            filled: true,
            fillColor: isReadOnly ? AppColors.basePaleGrey : AppColors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: AppColors.baseGrey),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: AppColors.baseGrey),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: AppColors.primary),
            ),
            disabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: AppColors.baseLightGrey),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: AppColors.supportRedDeep),
            ),
          ),
        ),
      ],
    );
  }
}
