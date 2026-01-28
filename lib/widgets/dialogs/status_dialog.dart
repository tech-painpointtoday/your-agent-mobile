import 'dart:async';
import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:youragent/core/theme/app_colors.dart';
import 'base_status_dialog.dart';
import 'status_toast.dart';
export 'base_status_dialog.dart';
export 'status_dialog_components.dart';

enum DialogType { info, success, error, warning, destructive }

class _DialogRequest<T> {
  final BuildContext context;
  final Future<T> Function() builder;
  final Completer<T> completer;

  _DialogRequest(this.context, this.builder, this.completer);
}

/// Global Status Dialog Utility
/// Provides consistent dialog styling across the app.
/// Matches the new Clean UI design.
class StatusDialog {
  static final Queue<_DialogRequest> _dialogQueue = Queue();
  static bool _isDialogShowing = false;

  static Future<T?> _enqueue<T>({
    required BuildContext context,
    required Future<T> Function() builder,
  }) async {
    final completer = Completer<T>();
    _dialogQueue.add(_DialogRequest<T>(context, builder, completer));
    _processQueue();
    return completer.future;
  }

  static Future<void> _processQueue() async {
    if (_isDialogShowing || _dialogQueue.isEmpty) return;

    final request = _dialogQueue.first;

    // If context is no longer valid, skip this dialog and error the completer
    if (!request.context.mounted) {
      _dialogQueue.removeFirst();
      // request.completer.completeError('Context not mounted'); // Or just complete with null/default?
      // Since generic T, hard to return "null" if T is not nullable.
      // But _enqueue returns Future<T?> so locally we handle null.
      // But completer expects T.
      // Let's just catch and move on.
      try {
        request.completer.completeError('Context not mounted');
      } catch (_) {}
      _processQueue();
      return;
    }

    _isDialogShowing = true;
    final currentRequest = _dialogQueue.removeFirst();

    try {
      final result = await currentRequest.builder();
      currentRequest.completer.complete(result);
    } catch (e) {
      debugPrint('StatusDialog error: $e');
      currentRequest.completer.completeError(e);
    } finally {
      _isDialogShowing = false;
      // Small delay to ensure UI cleans up before showing next
      await Future.delayed(const Duration(milliseconds: 150));
      _processQueue();
    }
  }

  // Helper for Slide from Top Animation
  static Future<T?> _showAnimatedDialog<T>({
    required BuildContext context,
    required WidgetBuilder builder,
    bool barrierDismissible = true,
  }) {
    return showGeneralDialog<T>(
      context: context,
      barrierDismissible: barrierDismissible,
      barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
      barrierColor: Colors.black54,
      transitionDuration: const Duration(milliseconds: 400),
      pageBuilder: (context, animation, secondaryAnimation) {
        return builder(context);
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        final curvedAnimation = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutCubic,
        );
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, -1),
            end: Offset.zero,
          ).animate(curvedAnimation),
          child: child,
        );
      },
    );
  }

  /// Show a Confirmation dialog (Primary Blue Action)
  static Future<bool> showConfirmation({
    required BuildContext context,
    required String title,
    required String message,
    String confirmText = 'Confirm',
    String cancelText = 'Cancel',
    VoidCallback? onConfirmed,
  }) async {
    return await _enqueue<bool>(
          context: context,
          builder: () async {
            final result = await _showAnimatedDialog<bool>(
              context: context,
              builder: (context) => BaseStatusDialog(
                title: title,
                message: message,
                confirmText: confirmText,
                cancelText: cancelText,
                confirmColor: AppColors.supportBlueDeep,
                isDestructive: false,
                type: DialogType.info,
                onConfirm: onConfirmed,
              ),
            );
            return result ?? false;
          },
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
    return await _enqueue<bool>(
          context: context,
          builder: () async {
            final result = await _showAnimatedDialog<bool>(
              context: context,
              builder: (context) => BaseStatusDialog(
                title: title,
                message: message,
                confirmText: confirmText,
                cancelText: cancelText,
                confirmColor: AppColors.supportRedDeep,
                isDestructive: true,
                type: DialogType.destructive,
              ),
            );
            return result ?? false;
          },
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
    Duration? callbackDelay,
  }) async {
    await _enqueue(
      context: context,
      builder: () async {
        await _showAnimatedDialog(
          context: context,
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
      },
    );
  }

  /// Show Error Toast (auto-dismiss in 3 seconds, top right corner)
  static Future<void> showError({
    required BuildContext context,
    required String title,
    String? message,
    Duration duration = const Duration(seconds: 3),
    VoidCallback? onDismiss,
    Duration? callbackDelay,
  }) async {
    await _enqueue(
      context: context,
      builder: () async {
        await _showAnimatedDialog(
          context: context,
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
      },
    );
  }

  /// Show Warning Toast (auto-dismiss in 3 seconds, top right corner)
  static Future<void> showWarning({
    required BuildContext context,
    required String title,
    String? message,
    Duration duration = const Duration(seconds: 3),
    VoidCallback? onDismiss,
    Duration? callbackDelay,
  }) async {
    await _enqueue(
      context: context,
      builder: () async {
        await _showAnimatedDialog(
          context: context,
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
      },
    );
  }

  // ==========================================
  // Modal Dialogs (Center Screen, Single Action)
  // ==========================================

  /// Show Info Dialog (Blue, Single OK Action)
  static Future<void> showInfoDialog({
    required BuildContext context,
    required String title,
    String? message,
    String buttonText = 'OK',
    VoidCallback? onOk,
  }) async {
    await _enqueue(
      context: context,
      builder: () async {
        await _showAnimatedDialog(
          context: context,
          builder: (context) => BaseStatusDialog(
            title: title,
            message: message,
            confirmText: buttonText,
            confirmColor: AppColors.supportBlueDeep,
            isSingleAction: true,
            type: DialogType.info,
            onConfirm: onOk,
          ),
        );
      },
    );
  }

  /// Show Success Dialog (Green, Single OK Action)
  static Future<void> showSuccessDialog({
    required BuildContext context,
    required String title,
    String? message,
    String buttonText = 'OK',
    VoidCallback? onOk,
  }) async {
    await _enqueue(
      context: context,
      builder: () async {
        await _showAnimatedDialog(
          context: context,
          builder: (context) => BaseStatusDialog(
            title: title,
            message: message,
            confirmText: buttonText,
            confirmColor: AppColors.supportGreenDark,
            isSingleAction: true,
            type: DialogType.success,
            onConfirm: onOk,
          ),
        );
      },
    );
  }

  /// Show Error Dialog (Red, Single OK Action)
  static Future<void> showErrorDialog({
    required BuildContext context,
    required String title,
    String? message,
    String buttonText = 'OK',
    VoidCallback? onOk,
  }) async {
    await _enqueue(
      context: context,
      builder: () async {
        await _showAnimatedDialog(
          context: context,
          builder: (context) => BaseStatusDialog(
            title: title,
            message: message,
            confirmText: buttonText,
            confirmColor: AppColors.supportRedDeep,
            isSingleAction: true,
            type: DialogType.error,
            onConfirm: onOk,
          ),
        );
      },
    );
  }

  /// Show Warning Dialog (Orange, Single OK Action)
  static Future<void> showWarningDialog({
    required BuildContext context,
    required String title,
    String? message,
    String buttonText = 'OK',
    VoidCallback? onOk,
  }) async {
    await _enqueue(
      context: context,
      builder: () async {
        await _showAnimatedDialog(
          context: context,
          builder: (context) => BaseStatusDialog(
            title: title,
            message: message,
            confirmText: buttonText,
            confirmColor: AppColors.supportOrangeDark,
            isSingleAction: true,
            type: DialogType.warning,
            onConfirm: onOk,
          ),
        );
      },
    );
  }

  /// Show Loading Dialog
  static Future<void> showLoading({
    required BuildContext context,
    String message = 'Loading...',
  }) async {
    await _showAnimatedDialog(
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
                  color: AppColors.baseDarkGrey,
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
  static Future<T?> showLoadingWhile<T>({
    required BuildContext context,
    required Future<T> Function() operation,
    String? message,
  }) async {
    // Show loading dialog
    _showAnimatedDialog(
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
                    color: AppColors.baseDarkGrey,
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
      if (context.mounted) {
        Navigator.of(context, rootNavigator: true).pop();
      }
      return result;
    } catch (e) {
      if (context.mounted) {
        Navigator.of(context, rootNavigator: true).pop();
      }
      rethrow;
    }
  }
}
