import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../inputs/app_text_field.dart';

/// Wrapper for AppTextField to support legacy code using AppTextFormField
class AppTextFormField extends StatelessWidget {
  final String label;
  final TextEditingController? controller;
  final bool isRequired;
  final String? hintText;
  final int maxLines;
  final int? maxLength;
  final Widget? suffix;
  final Widget? prefix;
  final TextInputType? keyboardType;
  final bool readOnly;
  final VoidCallback? onTap;
  final ValueChanged<String>? onChanged;
  final FocusNode? focusNode;
  final bool showCursor;
  final List<TextInputFormatter>? inputFormatters;

  const AppTextFormField({
    super.key,
    required this.label,
    this.controller,
    this.isRequired = false,
    this.hintText,
    this.maxLines = 1,
    this.maxLength,
    this.suffix,
    this.prefix,
    this.keyboardType,
    this.readOnly = false,
    this.onTap,
    this.onChanged,
    this.focusNode,
    this.showCursor = true,
    this.inputFormatters,
  });

  @override
  Widget build(BuildContext context) {
    return AppTextField(
      label: label,
      controller: controller,
      isRequired: isRequired,
      hintText: hintText,
      maxLines: maxLines,
      maxLength: maxLength,
      suffix: suffix,
      prefix: prefix,
      keyboardType: keyboardType,
      readOnly: readOnly,
      onTap: onTap,
      onChanged: onChanged,
      focusNode: focusNode,
      showCursor: showCursor,
      inputFormatters: inputFormatters,
    );
  }
}
