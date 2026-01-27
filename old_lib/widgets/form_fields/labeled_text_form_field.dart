import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:youragent/core/theme/app_colors.dart';

/// Reusable labeled text form field with standard decoration
class LabeledTextFormField extends StatelessWidget {
  final String label;
  final String? hintText;
  final TextEditingController controller;
  final IconData? prefixIcon;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;
  final bool obscureText;
  final Widget? suffixIcon;
  final int? maxLines;

  const LabeledTextFormField({
    super.key,
    required this.label,
    this.hintText,
    required this.controller,
    this.prefixIcon,
    this.keyboardType,
    this.validator,
    this.obscureText = false,
    this.suffixIcon,
    this.maxLines = 1,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.anuphan(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AppColors.baseDarkGrey,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          obscureText: obscureText,
          maxLines: maxLines,
          decoration: _buildInputDecoration(),
          validator: validator,
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  InputDecoration _buildInputDecoration() {
    return InputDecoration(
      hintText: hintText ?? label,
      prefixIcon: prefixIcon != null
          ? Icon(prefixIcon, color: AppColors.shadyLady)
          : null,
      suffixIcon: suffixIcon,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.bonJour),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.bonJour),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      filled: true,
      fillColor: AppColors.white,
    );
  }
}
