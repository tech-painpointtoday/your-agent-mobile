import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:youragent/core/theme/app_colors.dart';
import 'base_status_dialog.dart';
import 'status_toast.dart';
export 'base_status_dialog.dart';
export 'status_dialog_components.dart';

enum DialogType { info, success, error, warning, destructive }

/// Global Status Dialog Utility
/// Provides consistent dialog styling across the app.
/// Matches the new Clean UI design.
class StatusDialog {
  /// Show a Confirmation dialog (Primary Blue Action)
  static Future<bool> showConfirmation({
    required BuildContext context,
    required String title,
    required String message,
    String confirmText = 'Confirm',
    String cancelText = 'Cancel',
  }) async {
    return await showDialog<bool>(
          context: context,
          builder: (context) => BaseStatusDialog(
            title: title,
            message: message,
            confirmText: confirmText,
            cancelText: cancelText,
            confirmColor: AppColors.blue600,
            isDestructive: false,
            type: DialogType.info,
          ),
        ) ??
        false;
  }

  /// Show a Destructive dialog (Red Action)
  static Future<bool> showDestructive({
    required BuildContext context,
    required String title,
    required String message,
    String confirmText = 'Delete',
    String cancelText = 'Cancel',
  }) async {
    return await showDialog<bool>(
          context: context,
          builder: (context) => BaseStatusDialog(
            title: title,
            message: message,
            confirmText: confirmText,
            cancelText: cancelText,
            confirmColor: AppColors.error600,
            isDestructive: true,
            type: DialogType.destructive,
          ),
        ) ??
        false;
  }

  /// Show Success Toast (auto-dismiss in 3 seconds, top right corner)
  static Future<void> showSuccess({
    required BuildContext context,
    required String title,
    String? message,
    Duration duration = const Duration(seconds: 3),
    VoidCallback? onDismiss,
    Duration? callbackDelay, // Optional delay before running callback
  }) async {
    await showDialog(
      context: context,
      barrierColor: Colors.transparent,
      barrierDismissible: true,
      builder: (context) => StatusToast(
        title: title,
        message: message,
        type: DialogType.success,
        duration: duration,
        onDismiss: onDismiss,
        callbackDelay: callbackDelay,
      ),
    );
  }

  /// Show Error Toast (auto-dismiss in 3 seconds, top right corner)
  static Future<void> showError({
    required BuildContext context,
    required String title,
    String? message,
    Duration duration = const Duration(seconds: 3),
    VoidCallback? onDismiss,
    Duration? callbackDelay, // Optional delay before running callback
  }) async {
    await showDialog(
      context: context,
      barrierColor: Colors.transparent,
      barrierDismissible: true,
      builder: (context) => StatusToast(
        title: title,
        message: message,
        type: DialogType.error,
        duration: duration,
        onDismiss: onDismiss,
        callbackDelay: callbackDelay,
      ),
    );
  }

  /// Show Warning Toast (auto-dismiss in 3 seconds, top right corner)
  static Future<void> showWarning({
    required BuildContext context,
    required String title,
    String? message,
    Duration duration = const Duration(seconds: 3),
    VoidCallback? onDismiss,
    Duration? callbackDelay, // Optional delay before running callback
  }) async {
    await showDialog(
      context: context,
      barrierColor: Colors.transparent,
      barrierDismissible: true,
      builder: (context) => StatusToast(
        title: title,
        message: message,
        type: DialogType.warning,
        duration: duration,
        onDismiss: onDismiss,
        callbackDelay: callbackDelay,
      ),
    );
  }

  /// Show Loading Dialog
  static Future<void> showLoading({
    required BuildContext context,
    String message = 'Loading...',
  }) async {
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(),
              const SizedBox(width: 20),
              Text(
                message,
                style: GoogleFonts.anuphan(
                  fontSize: 16,
                  color: AppColors.eerieBlack,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Show Loading Dialog while executing an async operation
  /// Returns the result of the operation and dismisses the dialog when done
  static Future<T?> showLoadingWhile<T>({
    required BuildContext context,
    required Future<T> Function() operation,
    String? message,
  }) async {
    // Show loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(),
              const SizedBox(width: 20),
              Flexible(
                child: Text(
                  message ?? 'Loading...',
                  style: GoogleFonts.anuphan(
                    fontSize: 16,
                    color: AppColors.eerieBlack,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );

    try {
      final result = await operation();
      // Dismiss loading dialog
      if (context.mounted) {
        Navigator.of(context, rootNavigator: true).pop();
      }
      return result;
    } catch (e) {
      // Dismiss loading dialog
      if (context.mounted) {
        Navigator.of(context, rootNavigator: true).pop();
      }
      rethrow;
    }
  }
}
