import 'package:flutter/material.dart';
import 'package:youragent/core/theme/app_colors.dart';

/// Reusable text form field matching the design system
/// Used in both change password dialog and edit profile form
class AppTextFormField extends StatelessWidget {
  final String label;
  final String? hintText;
  final TextEditingController controller;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;
  final int? maxLines;
  final Widget? suffix;
  final bool isRequired;
  final bool isReadOnly;

  const AppTextFormField({
    super.key,
    required this.label,
    this.hintText,
    required this.controller,
    this.keyboardType,
    this.validator,
    this.maxLines = 1,
    this.suffix,
    this.isRequired = false,
    this.isReadOnly = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              label,
              style: theme.textTheme.titleSmall?.copyWith(
                color: AppColors.baseDarkGrey,
              ),
            ),
            if (isRequired) ...[
              const SizedBox(width: 4),
              Text(
                '*',
                style: theme.textTheme.titleSmall?.copyWith(
                  color: AppColors.supportRedDeep,
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          maxLines: maxLines,
          readOnly: isReadOnly,
          enabled: !isReadOnly,
          validator: validator,
          decoration: InputDecoration(
            hintText: hintText ?? label,
            hintStyle: theme.textTheme.bodyLarge?.copyWith(
              color: AppColors.baseGrey,
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
            filled: true,
            fillColor: AppColors.white,
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
              borderSide: const BorderSide(color: AppColors.primary),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.supportRedDeep),
            ),
            suffix: suffix,
          ),
        ),
      ],
    );
  }
}
