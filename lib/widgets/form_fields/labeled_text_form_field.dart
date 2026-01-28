import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:youragent/core/theme/app_colors.dart';

/// Reusable labeled text form field with standard decoration
class LabeledTextFormField extends StatelessWidget {
  final String label;
  final String? hintText;
  final TextEditingController controller;
  final IconData? prefixIcon;
  final String? prefixIconSvg;
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
    this.prefixIconSvg,
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
    Widget? prefixWidget;
    if (prefixIconSvg != null) {
      prefixWidget = Padding(
        padding: const EdgeInsets.all(16),
        child: SvgPicture.asset(
          prefixIconSvg!,
          width: 16,
          height: 16,
          colorFilter: const ColorFilter.mode(
            AppColors.primary,
            BlendMode.srcIn,
          ),
        ),
      );
    } else if (prefixIcon != null) {
      prefixWidget = Icon(prefixIcon, color: AppColors.primary);
    }

    return InputDecoration(
      hintText: hintText ?? label,
      hintStyle: GoogleFonts.anuphan(color: AppColors.baseGrey),
      prefixIcon: prefixWidget,
      suffixIcon: suffixIcon,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.baseLightGrey),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.baseLightGrey),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.primary),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      filled: true,
      fillColor: AppColors.white,
    );
  }
}
