import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';

class LabeledTextFormField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final IconData? prefixIcon;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;
  final int maxLines;

  const LabeledTextFormField({
    super.key,
    required this.label,
    required this.controller,
    this.prefixIcon,
    this.keyboardType,
    this.validator,
    this.maxLines = 1,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          maxLines: maxLines,
          decoration: InputDecoration(
            hintText: label,
            prefixIcon:
                prefixIcon != null ? Icon(prefixIcon, color: AppColors.shadyLady) : null,
          ),
          validator: validator,
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}

