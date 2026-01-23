import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:youragent/core/theme/app_colors.dart';

import 'profile_constants.dart';

class ProfileAccountActionTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final String actionText;
  final VoidCallback onActionPressed;

  const ProfileAccountActionTile({
    super.key,
    required this.title,
    required this.subtitle,
    required this.actionText,
    required this.onActionPressed,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: AppColors.cardLabelPrimary,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                subtitle,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: ProfileConstants.placeholderColor,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 16),
        Builder(
          builder: (context) {
            // All buttons are outlined, with icons for "แก้ไขข้อมูล" and "คัดลอก"
            final isEditButton = actionText == 'แก้ไขข้อมูล';
            final isCopyButton = actionText == 'คัดลอก';

            if (isEditButton) {
              return OutlinedButton(
                onPressed: onActionPressed,
                style: OutlinedButton.styleFrom(
                  backgroundColor: AppColors.buttonContainerOutlinedDefault,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 18,
                  ),
                  side: const BorderSide(
                    color: AppColors.buttonStrokeOutlinedRdDefault,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  actionText,
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.75),
                  ),
                ),
              );
            }

            if (isCopyButton) {
              return OutlinedButton.icon(
                onPressed: onActionPressed,
                style: OutlinedButton.styleFrom(
                  backgroundColor: AppColors.buttonContainerOutlinedDefault,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 18,
                  ),
                  side: const BorderSide(
                    color: AppColors.buttonStrokeOutlinedRdDefault,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                icon: SvgPicture.asset(
                  'assets/icons/profile/copy-1.svg',
                  width: 18,
                  height: 18,
                  colorFilter: ColorFilter.mode(
                    theme.colorScheme.onSurface.withValues(alpha: 0.75),
                    BlendMode.srcIn,
                  ),
                ),
                label: Text(
                  actionText,
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.75),
                  ),
                ),
              );
            }

            // "เปลี่ยนรหัสผ่าน" - text only, no icon
            return OutlinedButton(
              onPressed: onActionPressed,
              style: OutlinedButton.styleFrom(
                backgroundColor: AppColors.buttonContainerOutlinedDefault,
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 18,
                ),
                side: const BorderSide(
                  color: AppColors.buttonStrokeOutlinedRdDefault,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                actionText,
                style: theme.textTheme.labelLarge?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.75),
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}
