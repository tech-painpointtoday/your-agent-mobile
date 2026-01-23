import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:youragent/core/theme/app_colors.dart';

/// Compatibility Settings Section
class ProfileEditCompatibilitySection extends StatelessWidget {
  final TextEditingController compatibilityController;

  const ProfileEditCompatibilitySection({
    super.key,
    required this.compatibilityController,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: AppColors.blue100,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: SvgPicture.asset(
                    'assets/icons/profile/check-circle.svg',
                    width: 16,
                    height: 16,
                    colorFilter: const ColorFilter.mode(
                      AppColors.buttonPrimary,
                      BlendMode.srcIn,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Flexible(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'ตั้งค่าการค้นหาความเข้ากันได้',
                      style: theme.textTheme.titleLarge?.copyWith(
                        color: AppColors.buttonPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'ความเข้ากันได้ขั้นต่ำที่ต้องการให้อสังหาริมทรัพย์ของคุณปรากฏในผลการค้นหาความเข้ากันได้',
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: AppColors.cardLabelSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          width: 248,
          child: TextFormField(
            controller: compatibilityController,
            keyboardType: TextInputType.number,
            style: theme.textTheme.bodyMedium,
            decoration: InputDecoration(
              hintText: 'กรุณากรอก',
              hintStyle: theme.textTheme.bodyLarge?.copyWith(
                color: AppColors.cardLabelSecondary,
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
              filled: true,
              fillColor: AppColors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(
                  color: AppColors.buttonStrokeOutlinedRdDefault,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(
                  color: AppColors.buttonStrokeOutlinedRdDefault,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppColors.primary),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppColors.error600),
              ),
              suffixText: '% ขึ้นไป',
              suffixStyle: theme.textTheme.bodyMedium?.copyWith(
                color: AppColors.shadyLady,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
