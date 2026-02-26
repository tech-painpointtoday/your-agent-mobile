import 'dart:io';

import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:geolocator/geolocator.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:youragent/core/extensions/l10n_extensions.dart';
import 'package:youragent/widgets/dialogs/status_dialog.dart';
import 'package:youragent/widgets/modals/app_confirmation_bottom_sheet.dart';

class PermissionHelper {
  /// Ensures the specified permission is granted.
  /// Shows dialogs if denied or permanently denied.
  static Future<bool> ensurePermission(
    BuildContext context,
    Permission permission, {
    String? title,
    String? message,
    String? deniedForeverMessage,
  }) async {
    final l10n = context.l10n;
    PermissionStatus status = await permission.status;

    if (status.isGranted || status.isLimited) {
      return true;
    }

    if (status.isPermanentlyDenied) {
      if (!context.mounted) return false;

      // Use StatusDialog for cleaner UI or confirmation sheet
      bool openSettings = false;
      await AppConfirmationBottomSheet.show(
        context: context,
        title: title ?? l10n.permission_generic_title,
        description:
            deniedForeverMessage ?? l10n.permission_generic_denied_settings,
        confirmLabel: l10n.permission_button_open_settings,
        cancelLabel: l10n.permission_button_cancel,
        onConfirm: () {
          openSettings = true;
        },
      );

      if (openSettings) {
        await openAppSettings();
      }
      return false;
    }

    // Request permission if not determined/denied
    status = await permission.request();

    if (status.isGranted || status.isLimited) {
      return true;
    }

    // If still denied after request (but not permanently yet)
    if (!context.mounted) return false;
    StatusDialog.showWarning(
      context: context,
      title: title ?? l10n.permission_generic_warning_title,
      message: message ?? l10n.permission_generic_warning_message,
    );
    return false;
  }

  /// Specialized handler for Location (includes Service check)
  static Future<bool> ensureLocationReady(BuildContext context) async {
    // 1. Check if Service is enabled
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      if (!context.mounted) return false;
      final l10n = context.l10n;
      StatusDialog.showWarning(
        context: context,
        title: l10n.permission_location_title,
        message: l10n.permission_location_message,
      );
      return false;
    }

    // 2. Check Permissions
    if (!context.mounted) return false;
    final l10n = context.l10n;
    return await ensurePermission(
      context,
      Permission.location,
      title: l10n.permission_location_title,
      message: l10n.permission_location_message,
      deniedForeverMessage: l10n.permission_location_denied_forever,
    );
  }

  /// Helper to get current position with permission check
  static Future<Position?> getCurrentPosition(BuildContext context) async {
    try {
      final ok = await ensureLocationReady(context);
      if (!ok) return null;
      return await Geolocator.getCurrentPosition();
    } catch (e) {
      if (!context.mounted) return null;
      final l10n = context.l10n;
      StatusDialog.showError(
        context: context,
        title: l10n.permission_location_error_title,
        message: l10n.permission_location_error_message,
      );
      return null;
    }
  }

  /// Ensures Camera permission is ready
  static Future<bool> ensureCameraReady(BuildContext context) async {
    final l10n = context.l10n;
    return await ensurePermission(
      context,
      Permission.camera,
      title: l10n.permission_camera_title,
      message: l10n.permission_camera_message,
      deniedForeverMessage: l10n.permission_camera_denied_forever,
    );
  }

  /// Ensures Photo/Gallery permission is ready
  static Future<bool> ensurePhotosReady(BuildContext context) async {
    if (!context.mounted) return false;
    final l10n = context.l10n;

    if (Platform.isAndroid) {
      final deviceInfo = DeviceInfoPlugin();
      final androidInfo = await deviceInfo.androidInfo;
      final sdkInt = androidInfo.version.sdkInt;

      if (sdkInt >= 33) {
        // Android 13+ : use READ_MEDIA_IMAGES via Permission.photos
        return await ensurePermission(
          context,
          Permission.photos,
          title: l10n.permission_photos_title,
          message: l10n.permission_photos_message,
          deniedForeverMessage: l10n.permission_photos_denied_forever,
        );
      } else {
        // Android 12 and below : use legacy storage permission for gallery
        return await ensurePermission(
          context,
          Permission.storage,
          title: l10n.permission_files_title,
          message: l10n.permission_files_message,
          deniedForeverMessage: l10n.permission_files_denied_forever,
        );
      }
    } else if (Platform.isIOS) {
      // iOS: use photos permission
      return await ensurePermission(
        context,
        Permission.photos,
        title: l10n.permission_photos_title,
        message: l10n.permission_photos_message,
        deniedForeverMessage: l10n.permission_photos_denied_forever,
      );
    }

    // Other platforms: no-op
    return true;
  }

  /// Ensures file picker access is ready (attachments/documents).
  /// - Android 13+ : no storage permission required (uses system picker).
  /// - Android 12- : request storage permission.
  /// - iOS/others : no additional permission.
  static Future<bool> ensureFilePickerReady(BuildContext context) async {
    if (!context.mounted) return false;
    final l10n = context.l10n;

    if (!Platform.isAndroid) {
      return true;
    }

    final deviceInfo = DeviceInfoPlugin();
    final androidInfo = await deviceInfo.androidInfo;
    final sdkInt = androidInfo.version.sdkInt;

    if (sdkInt >= 33) {
      // Android 13+ uses system picker, no broad storage permission.
      return true;
    }

    return await ensurePermission(
      context,
      Permission.storage,
      title: l10n.permission_files_title,
      message: l10n.permission_files_message,
      deniedForeverMessage: l10n.permission_files_denied_forever,
    );
  }

  /// Ensures Notification permission is ready
  static Future<bool> ensureNotificationReady(BuildContext context) async {
    final l10n = context.l10n;
    return await ensurePermission(
      context,
      Permission.notification,
      title: l10n.permission_notification_title,
      message: l10n.permission_notification_message,
      deniedForeverMessage: l10n.permission_notification_denied_forever,
    );
  }

  /// Returns true if notification permission is currently granted.
  static Future<bool> hasNotificationPermission() async {
    final status = await Permission.notification.status;
    return status.isGranted || status.isLimited;
  }

  /// Guides the user to system settings to turn OFF notifications.
  static Future<void> openNotificationSettingsForDisable(
    BuildContext context,
  ) async {
    final l10n = context.l10n;
    bool openSettings = false;
    await AppConfirmationBottomSheet.show(
      context: context,
      title: l10n.permission_notification_turn_off_title,
      description: l10n.permission_notification_turn_off_message,
      confirmLabel: l10n.permission_button_open_settings,
      cancelLabel: l10n.permission_button_cancel,
      onConfirm: () {
        openSettings = true;
      },
    );
    if (openSettings) {
      await openAppSettings();
    }
  }
}
