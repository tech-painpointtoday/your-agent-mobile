import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_colors.dart';

class AppChipOption<T> {
  final String label;
  final T value;

  const AppChipOption({required this.label, required this.value});
}

class AppChipSelection<T> extends StatelessWidget {
  final String label;
  final T? value;
  final List<AppChipOption<T>> options;
  final ValueChanged<T> onChanged;
  final bool isRequired;

  const AppChipSelection({
    super.key,
    required this.label,
    required this.value,
    required this.options,
    required this.onChanged,
    this.isRequired = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label.isNotEmpty) ...[
          Text.rich(
            TextSpan(
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
          const SizedBox(height: 12),
        ],
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: options.map((option) {
            final isSelected = value == option.value;

            return _ChipButton(
              label: option.label,
              isSelected: isSelected,
              onTap: () => onChanged(option.value),
            );
          }).toList(),
        ),
      ],
    );
  }
}

class _ChipButton extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _ChipButton({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(100),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.supportBlueLight : Colors.white,
          borderRadius: BorderRadius.circular(100),
          border: Border.all(
            color: isSelected
                ? AppColors.supportBlueDark
                : AppColors.baseLightGrey,
            width: 1,
          ),
        ),
        child: Text(
          label,
          style: GoogleFonts.anuphan(
            color: isSelected
                ? AppColors.supportBlueDark
                : AppColors.baseDarkGrey,
            fontSize: 16,
            fontWeight: isSelected ? FontWeight.w500 : FontWeight.w400,
          ),
        ),
      ),
    );
  }
}
