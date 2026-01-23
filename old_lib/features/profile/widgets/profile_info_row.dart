import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:youragent/core/theme/app_colors.dart';

import 'profile_constants.dart';

class ProfileInfoRow extends StatelessWidget {
  final String? svgAsset;
  final IconData? icon;
  final String text;

  const ProfileInfoRow({
    super.key,
    this.svgAsset,
    this.icon,
    required this.text,
  }) : assert(svgAsset != null || icon != null, 'Either svgAsset or icon must be provided');

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final iconColor = AppColors.avatarLabelSecondary;

    return Row(
      children: [
        if (svgAsset != null)
          SvgPicture.asset(
            svgAsset!,
            width: 18,
            height: 18,
            colorFilter: ColorFilter.mode(iconColor, BlendMode.srcIn),
          )
        else if (icon != null)
          Icon(
            icon,
            size: 18,
            color: iconColor,
          ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: AppColors.avatarLabelSecondary,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

class ProfileSmallHintText extends StatelessWidget {
  final String text;

  const ProfileSmallHintText({
    super.key,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Text(
      text,
      style: theme.textTheme.bodySmall?.copyWith(
        color: ProfileConstants.placeholderColor,
      ),
    );
  }
}
