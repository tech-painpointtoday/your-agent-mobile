import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../models/notification_model.dart';

/// Helper class to map notification types to their corresponding colors
class NotificationColors {
  /// Get the primary color for a notification type
  static Color getPrimaryColor(NotificationType type) {
    switch (type) {
      case NotificationType.info:
        return AppColors.blue600; // Blue
      case NotificationType.success:
        return AppColors.success600; // Green
      case NotificationType.warning:
        return AppColors.warning600; // Orange/Yellow
      case NotificationType.error:
        return AppColors.error600; // Red
      case NotificationType.system:
        return AppColors.gray700; // Gray
    }
  }

  /// Get the background color for a notification type (lighter variant)
  static Color getBackgroundColor(NotificationType type) {
    switch (type) {
      case NotificationType.info:
        return AppColors.blue100;
      case NotificationType.success:
        return AppColors.statusSuccessBg;
      case NotificationType.warning:
        return AppColors.statusWarningBg;
      case NotificationType.error:
        return AppColors.statusErrorBg;
      case NotificationType.system:
        return AppColors.gray100;
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
