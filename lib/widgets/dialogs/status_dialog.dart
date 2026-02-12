import 'dart:async';
import 'dart:collection';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:youragent/core/theme/app_colors.dart';
// ตรวจสอบ path import ให้ตรงกับโปรเจคจริงของคุณ
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
class StatusDialog {
  // Queue สำหรับ Modal Dialog (ที่ต้องรอและ Block หน้าจอ)
  static final Queue<_DialogRequest> _dialogQueue = Queue();
  static bool _isDialogShowing = false;

  // ==========================================
  // Private Queue Logic (สำหรับ Modal Dialog เท่านั้น)
  // ==========================================
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

    if (!request.context.mounted) {
      _dialogQueue.removeFirst();
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
      await Future.delayed(const Duration(milliseconds: 150));
      _processQueue();
    }
  }

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
      pageBuilder: (context, animation, secondaryAnimation) => builder(context),
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        return SlideTransition(
          position: Tween<Offset>(begin: const Offset(0, -1), end: Offset.zero)
              .animate(
                CurvedAnimation(parent: animation, curve: Curves.easeOutCubic),
              ),
          child: child,
        );
      },
    );
  }

  // ==========================================
  // Toast Logic (Overlay - Non-Blocking)
  // ==========================================

  /// Internal method to show Overlay Toast
  static void _showOverlayToast({
    required BuildContext context,
    required Widget child,
    required Duration duration,
    VoidCallback? onDismiss,
    Duration? callbackDelay,
  }) {
    final overlayState = Overlay.of(context);
    late OverlayEntry overlayEntry;

    overlayEntry = OverlayEntry(
      builder: (context) => _ToastAnimator(
        duration: duration,
        onDismissed: () {
          overlayEntry.remove();
          if (onDismiss != null) {
            // รอเวลาเพิ่มเติมถ้ามี callbackDelay ก่อนเรียก onDismiss
            if (callbackDelay != null) {
              Future.delayed(callbackDelay, onDismiss);
            } else {
              onDismiss();
            }
          }
        },
        child: Material(
          color: Colors.transparent,
          type: MaterialType.transparency,
          child: SafeArea(
            child: Align(
              alignment: Alignment.topCenter,
              child: Padding(
                padding: const EdgeInsets.only(
                  top: 16.0,
                  left: 16.0,
                  right: 16.0,
                ),
                child: child,
              ),
            ),
          ),
        ),
      ),
    );

    overlayState.insert(overlayEntry);
  }

  // ------------------------------------------
  // Toast Public Methods
  // ------------------------------------------

  /// Show Success Toast (Non-blocking, click-through)
  static void showSuccess({
    required BuildContext context,
    required String title,
    String? message,
    Duration duration = const Duration(seconds: 2),
    VoidCallback? onDismiss,
    Duration? callbackDelay,
  }) {
    _showOverlayToast(
      context: context,
      duration: duration,
      onDismiss: onDismiss,
      callbackDelay: callbackDelay,
      child: StatusToast(
        title: title,
        message: message,
        type: DialogType.success,
        duration: duration,
        onDismiss: null, // Overlay จัดการ dismiss เอง
      ),
    );
  }

  /// Show Error Toast (Non-blocking, click-through)
  static void showError({
    required BuildContext context,
    required String title,
    String? message,
    Duration duration = const Duration(seconds: 3),
    VoidCallback? onDismiss,
    Duration? callbackDelay,
  }) {
    _showOverlayToast(
      context: context,
      duration: duration,
      onDismiss: onDismiss,
      callbackDelay: callbackDelay,
      child: StatusToast(
        title: title,
        message: message,
        type: DialogType.error,
        duration: duration,
        onDismiss: null,
      ),
    );
  }

  /// Show Warning Toast (Non-blocking, click-through)
  static void showWarning({
    required BuildContext context,
    required String title,
    String? message,
    Duration duration = const Duration(seconds: 3),
    VoidCallback? onDismiss,
    Duration? callbackDelay,
  }) {
    _showOverlayToast(
      context: context,
      duration: duration,
      onDismiss: onDismiss,
      callbackDelay: callbackDelay,
      child: StatusToast(
        title: title,
        message: message,
        type: DialogType.warning,
        duration: duration,
        onDismiss: null,
      ),
    );
  }

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

  /// Confirmation Dialog (Two buttons)
  static Future<bool?> confirm({
    required BuildContext context,
    required String title,
    String? message,
    String? confirmLabel,
    String? cancelLabel,
    VoidCallback? onConfirm,
  }) async {
    return await _enqueue<bool>(
      context: context,
      builder: () async {
        final result = await _showAnimatedDialog<bool>(
          context: context,
          builder: (context) => BaseStatusDialog(
            title: title,
            message: message,
            confirmText: confirmLabel ?? 'Confirm',
            cancelText: cancelLabel ?? 'Cancel',
            confirmColor: AppColors.primary,
            type: DialogType.info,
            onConfirm: onConfirm,
          ),
        );
        return result ?? false;
      },
    );
  }

  /// Destructive/Delete Confirmation (Two buttons)
  static Future<bool?> showDestructive({
    required BuildContext context,
    required String title,
    String? message,
    String? actionLabel,
    String? cancelLabel,
    VoidCallback? onAction,
  }) async {
    return await _enqueue<bool>(
      context: context,
      builder: () async {
        final result = await _showAnimatedDialog<bool>(
          context: context,
          builder: (context) => BaseStatusDialog(
            title: title,
            message: message,
            confirmText: actionLabel ?? 'Delete',
            cancelText: cancelLabel ?? 'Cancel',
            confirmColor: AppColors.supportRedDeep,
            isDestructive: true,
            type: DialogType.destructive,
            onConfirm: onAction,
          ),
        );
        return result ?? false;
      },
    );
  }

  static Future<void> showLoading({
    required BuildContext context,
    String message = 'Loading...',
  }) async {
    await showGeneralDialog<void>(
      context: context,
      barrierDismissible: false,
      barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
      // We handle dimming/blur ourselves inside the pageBuilder
      barrierColor: Colors.transparent,
      transitionDuration: const Duration(milliseconds: 200),
      pageBuilder: (context, animation, secondaryAnimation) {
        return Stack(
          children: [
            // Blurred & slightly dimmed background
            Positioned.fill(
              child: BackdropFilter(
                filter: ui.ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Container(
                  color: Colors.black.withOpacity(0.25),
                ),
              ),
            ),
            // Centered loading spinner
            const Center(
              child: CircularProgressIndicator(
                color: AppColors.primary,
              ),
            ),
          ],
        );
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(
          opacity: CurvedAnimation(
            parent: animation,
            curve: Curves.easeOutCubic,
          ),
          child: child,
        );
      },
    );
  }

  static Future<T?> showLoadingWhile<T>({
    required BuildContext context,
    required Future<T> Function() operation,
    String? message,
  }) async {
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

// ==========================================
// Helper Widget for Overlay Animation
// ==========================================
class _ToastAnimator extends StatefulWidget {
  final Widget child;
  final Duration duration;
  final VoidCallback onDismissed;

  const _ToastAnimator({
    required this.child,
    required this.duration,
    required this.onDismissed,
  });

  @override
  State<_ToastAnimator> createState() => _ToastAnimatorState();
}

class _ToastAnimatorState extends State<_ToastAnimator>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _offsetAnimation;
  late Animation<double> _fadeAnimation;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _offsetAnimation = Tween<Offset>(
      begin: const Offset(0, -1.0),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));

    _fadeAnimation = CurvedAnimation(parent: _controller, curve: Curves.easeIn);

    // เริ่ม Animation เข้า
    _controller.forward();

    // ตั้งเวลาปิด
    _timer = Timer(widget.duration, () {
      if (mounted) {
        _controller.reverse().then((_) {
          widget.onDismissed();
        });
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: SlideTransition(
        position: _offsetAnimation,
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: GestureDetector(
            // Tap เพื่อปิด Toast ทันที
            onTap: () {
              _timer?.cancel();
              _controller.reverse().then((_) => widget.onDismissed());
            },
            // เพิ่มการปัดขึ้นเพื่อปิด Toast ก่อนเวลา
            onVerticalDragEnd: (details) {
              if (details.primaryVelocity! < 0) {
                _timer?.cancel();
                _controller.reverse().then((_) => widget.onDismissed());
              }
            },
            child: widget.child,
          ),
        ),
      ),
    );
  }
}
