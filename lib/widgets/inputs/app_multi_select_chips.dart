import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_colors.dart';

class AppMultiSelectChips<T> extends StatelessWidget {
  final String label;
  final List<T> values;
  final List<T> options;
  final ValueChanged<T> onSelected;
  final bool isRequired;

  const AppMultiSelectChips({
    super.key,
    required this.label,
    required this.values,
    required this.options,
    required this.onSelected,
    this.isRequired = false,
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
                const TextSpan(
                  text: ' (เลือกได้หลายรายการ)',
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 12,
                    fontWeight: FontWeight.normal,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
        ],
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: options.map((option) {
            final isSelected = values.contains(option);
            return GestureDetector(
              onTap: () => onSelected(option),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: isSelected ? Colors.white : Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isSelected
                        ? AppColors.primary
                        : AppColors.baseGrey.withValues(alpha: 0.3),
                    width: isSelected ? 1.5 : 1,
                  ),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: AppColors.primary.withValues(alpha: 0.1),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ]
                      : null,
                ),
                child: Text(
                  option.toString(),
                  style: GoogleFonts.anuphan(
                    color: isSelected
                        ? AppColors.primary
                        : AppColors.baseDarkGrey,
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
