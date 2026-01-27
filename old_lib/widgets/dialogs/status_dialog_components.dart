import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:youragent/core/theme/app_colors.dart';
import 'status_dialog.dart';

class StatusIcon extends StatelessWidget {
  final DialogType type;

  const StatusIcon({super.key, required this.type});

  @override
  Widget build(BuildContext context) {
    Color bgColor;
    String iconPath;
    Color iconColor;

    switch (type) {
      case DialogType.success:
        bgColor = AppColors.statusConfirmedBg;
        iconPath = 'assets/icons/check-circle.svg';
        iconColor = AppColors.success600;
        break;
      case DialogType.error:
        bgColor = AppColors.statusCancelledBg;
        iconPath = 'assets/icons/x-circle.svg';
        iconColor = AppColors.supportRedDeep;
        break;
      case DialogType.destructive:
        bgColor = AppColors.statusCancelledBg;
        iconPath = 'assets/icons/alert-triangle.svg';
        iconColor = AppColors.supportRedDeep;
        break;
      case DialogType.warning:
        bgColor = AppColors.statusPendingBg;
        iconPath = 'assets/icons/alert-triangle.svg';
        iconColor = AppColors.warning;
        break;
      case DialogType.info:
        bgColor = AppColors.blue100;
        iconPath = ''; // Not used
        iconColor = AppColors.blue600;
        break;
    }

    Widget iconWidget;
    if (type == DialogType.info) {
      iconWidget = Icon(Icons.info_outline, color: iconColor, size: 24);
    } else {
      iconWidget = SvgPicture.asset(
        iconPath,
        colorFilter: ColorFilter.mode(iconColor, BlendMode.srcIn),
        width: 24,
        height: 24,
      );
    }

    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Center(child: iconWidget),
    );
  }
}

class StatusCloseButton extends StatelessWidget {
  const StatusCloseButton({super.key});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => Navigator.of(context).pop(false),
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: const BoxDecoration(
          color: AppColors.basePaleGrey,
          shape: BoxShape.circle,
        ),
        child: SvgPicture.asset(
          'assets/icons/x.svg',
          width: 12,
          height: 12,
          colorFilter: const ColorFilter.mode(
            AppColors.baseGrey,
            BlendMode.srcIn,
          ),
        ),
      ),
    );
  }
}
