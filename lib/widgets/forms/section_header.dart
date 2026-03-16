import 'package:flutter/material.dart';
import 'package:yourhome/core/theme/app_colors.dart';
import 'package:flutter_svg/flutter_svg.dart';

class SectionHeader extends StatelessWidget {
  final String title;
  final String? iconPath; // SVG asset path
  final IconData? icon; // Material icon (for backward compatibility)

  const SectionHeader({
    super.key,
    required this.title,
    this.iconPath,
    this.icon,
  }) : assert(
         iconPath != null || icon != null,
         'Either iconPath or icon must be provided',
       );

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.supportBlueLight,
            borderRadius: BorderRadius.circular(8),
          ),
          child: iconPath != null
              ? SvgPicture.asset(
                  iconPath!,
                  width: 20,
                  height: 20,
                  colorFilter: const ColorFilter.mode(
                    AppColors.supportBlueDeep,
                    BlendMode.srcIn,
                  ),
                )
              : Icon(icon!, size: 20, color: AppColors.supportBlueDeep),
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: AppColors.supportBlueDeep,
          ),
        ),
      ],
    );
  }
}
