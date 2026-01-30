import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_colors.dart';

class AppTextField extends StatelessWidget {
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
  final bool obscureText;

  const AppTextField({
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
    this.obscureText = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label.isNotEmpty) ...[
          RichText(
            text: TextSpan(
              text: label,
              style: GoogleFonts.anuphan(
                color: AppColors.baseBlack,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
              children: [
                if (isRequired)
                  TextSpan(
                    text: ' *',
                    style: GoogleFonts.anuphan(
                      color: AppColors.supportRedDeep,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 8),
        ],
        TextFormField(
          focusNode: focusNode,
          controller: controller,
          obscureText: obscureText,
          maxLines: maxLines,
          maxLength: maxLength,
          keyboardType: keyboardType,
          readOnly: readOnly,
          onTap: onTap,
          onChanged: onChanged,
          showCursor: showCursor,
          inputFormatters: inputFormatters,
          style: GoogleFonts.anuphan(fontSize: 14, color: AppColors.baseBlack),
          decoration: InputDecoration(
            counterText: '',
            hintText: hintText ?? label,
            hintStyle: GoogleFonts.anuphan(
              color: AppColors.baseGrey,
              fontSize: 14,
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
            suffixIcon: Padding(
              padding: EdgeInsets.symmetric(horizontal: 8),
              child: suffix,
            ),
            prefixIcon: prefix,
            suffixIconConstraints: const BoxConstraints(),
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
              borderSide: const BorderSide(
                color: AppColors.primary,
                width: 1.5,
              ),
            ),
            filled: true,
            fillColor: AppColors.baseWhite,
          ),
        ),
      ],
    );
  }
}
