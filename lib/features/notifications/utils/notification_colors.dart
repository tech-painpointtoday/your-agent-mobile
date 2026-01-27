import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../models/notification_model.dart';

/// Helper class to map notification types to their corresponding colors
class NotificationColors {
  /// Get the primary color for a notification type
  static Color getPrimaryColor(NotificationType type) {
    switch (type) {
      case NotificationType.info:
        return AppColors.supportBlueDeep; // Blue
      case NotificationType.success:
        return AppColors.supportGreenDark; // Green
      case NotificationType.warning:
        return AppColors.supportOrangeDark; // Orange/Yellow
      case NotificationType.error:
        return AppColors.supportRedDeep; // Red
      case NotificationType.system:
        return AppColors.baseDarkGrey; // Gray
    }
  }

  /// Get the background color for a notification type (lighter variant)
  static Color getBackgroundColor(NotificationType type) {
    switch (type) {
      case NotificationType.info:
        return AppColors.supportBlueLight;
      case NotificationType.success:
        return AppColors.supportGreenLight;
      case NotificationType.warning:
        return AppColors.supportOrangeLight;
      case NotificationType.error:
        return AppColors.supportRedLight;
      case NotificationType.system:
        return AppColors.basePaleGrey;
    }
  }

  /// Get the icon for a notification type
  static IconData getIcon(NotificationType type) {
    switch (type) {
      case NotificationType.info:
        return Icons.info_outline;
      case NotificationType.success:
        return Icons.check_circle_outline;
      case NotificationType.warning:
        return Icons.warning_amber_outlined;
      case NotificationType.error:
        return Icons.error_outline;
      case NotificationType.system:
        return Icons.notifications_outlined;
    }
  }
}
