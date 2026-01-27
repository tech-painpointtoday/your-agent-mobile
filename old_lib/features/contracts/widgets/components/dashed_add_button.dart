import 'package:flutter/material.dart';
import 'package:youragent/core/theme/app_colors.dart';

import 'dashed_border_painter.dart';

class DashedAddButton extends StatelessWidget {
  final VoidCallback? onTap;
  final bool fullWidth;

  const DashedAddButton({
    super.key,
    required this.onTap,
    this.fullWidth = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final button = Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: CustomPaint(
          painter: const DashedBorderPainter(
            color: AppColors.baseGrey,
            strokeWidth: 1.5,
            radius: 12,
            dashLength: 6,
            dashGap: 4,
          ),
          child: Container(
            height: 48,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            alignment: Alignment.center,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.add,
                  size: 18,
                  color: AppColors.baseLabelSecondary,
                ),
                const SizedBox(width: 8),
                Text(
                  'เพิ่มรายการ',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: AppColors.baseLabelSecondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    if (!fullWidth) return button;
    return SizedBox(width: double.infinity, child: button);
  }
}
