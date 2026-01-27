import 'package:flutter/material.dart';
import '../inputs/app_text_field.dart';

/// Wrapper for AppTextField to support legacy code using AppTextFormField
class AppTextFormField extends StatelessWidget {
  final String label;
  final TextEditingController? controller;
  final bool isRequired;
  final String? hintText;
  final int maxLines;
  final Widget? suffix;
  final TextInputType? keyboardType;
  final bool readOnly;
  final VoidCallback? onTap;
  final ValueChanged<String>? onChanged;

  const AppTextFormField({
    super.key,
    required this.label,
    this.controller,
    this.isRequired = false,
    this.hintText,
    this.maxLines = 1,
    this.suffix,
    this.keyboardType,
    this.readOnly = false,
    this.onTap,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return AppTextField(
      label: label,
      controller: controller,
      isRequired: isRequired,
      hintText: hintText,
      maxLines: maxLines,
      suffix: suffix,
      keyboardType: keyboardType,
      readOnly: readOnly,
      onTap: onTap,
      onChanged: onChanged,
    );
  }
}
