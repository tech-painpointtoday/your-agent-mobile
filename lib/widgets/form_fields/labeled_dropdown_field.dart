import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:yourhome/core/theme/app_colors.dart';

/// Reusable labeled dropdown field
class LabeledDropdownField<T> extends StatelessWidget {
  final String label;
  final String? hintText;
  final T? value;
  final List<DropdownMenuItem<T>> items;
  final void Function(T?)? onChanged;
  final String? Function(T?)? validator;
  final IconData? prefixIcon;
  final String? prefixIconSvg;

  const LabeledDropdownField({
    super.key,
    required this.label,
    this.hintText,
    this.value,
    required this.items,
    this.onChanged,
    this.validator,
    this.prefixIcon,
    this.prefixIconSvg,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DropdownButtonFormField<T>(
          selectedItemBuilder: (context) {
            return items.map((item) {
              return Text(
                item.value.toString(),
                style: GoogleFonts.anuphan(
                  color: AppColors.baseBlack,
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                ),
              );
            }).toList();
          },
          initialValue: value,
          icon: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: SvgPicture.asset(
              'assets/icons/chevron-down.svg',
              width: 16,
              height: 16,
              colorFilter: const ColorFilter.mode(
                AppColors.baseGrey,
                BlendMode.srcIn,
              ),
            ),
          ),
          dropdownColor: AppColors.white,
          borderRadius: BorderRadius.circular(12),
          decoration: _buildInputDecoration(),
          items: items,
          onChanged: onChanged,
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
      labelStyle: GoogleFonts.anuphan(color: AppColors.baseLightGrey),
      helperStyle: GoogleFonts.anuphan(color: AppColors.baseLightGrey),
      prefixIcon: prefixWidget,

      // 3. Ensures the field container also has the 12 radius
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
