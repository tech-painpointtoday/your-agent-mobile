import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/theme/app_colors.dart';
import '../buttons/app_button.dart';

/// Dialog types used by `AppStatusDialog`.
enum AppDialogType { success, failure, warning, confirm, destructive }

/// Core dialog widget matching the new mobile design.
///
/// - **Status alerts (success / failure / warning)** look like picture 1:
///   a floating card with colored icon and text, auto-dismiss after a short delay.
/// - **Confirmation dialogs (confirm / destructive)** look like picture 2 & 3:
///   centered card, illustration, primary action button and secondary text action.
class AppStatusDialog extends StatefulWidget {
  final AppDialogType type;
  final String title;
  final String description;
  final String actionLabel;
  final VoidCallback? onAction;
  final String? cancelLabel; // For confirmation dialogs
  final VoidCallback? onCancel;

  /// Auto-dismiss duration for status alerts.
  /// Ignored for confirmation dialogs.
  final Duration autoDismissDuration;

  const AppStatusDialog({
    super.key,
    required this.type,
    required this.title,
    required this.description,
    this.actionLabel = 'ตกลง',
    this.onAction,
    this.cancelLabel,
    this.onCancel,
    this.autoDismissDuration = const Duration(seconds: 3),
  });

  /// Factory: Success banner
  factory AppStatusDialog.success({
    required String title,
    required String description,
    Duration autoDismiss = const Duration(seconds: 3),
  }) {
    return AppStatusDialog(
      type: AppDialogType.success,
      title: title,
      description: description,
      autoDismissDuration: autoDismiss,
    );
  }

  /// Factory: Failure banner
  factory AppStatusDialog.failure({
    required String title,
    required String description,
    Duration autoDismiss = const Duration(seconds: 3),
  }) {
    return AppStatusDialog(
      type: AppDialogType.failure,
      title: title,
      description: description,
      autoDismissDuration: autoDismiss,
    );
  }

  /// Factory: Warning banner
  factory AppStatusDialog.warning({
    required String title,
    required String description,
    Duration autoDismiss = const Duration(seconds: 3),
  }) {
    return AppStatusDialog(
      type: AppDialogType.warning,
      title: title,
      description: description,
      autoDismissDuration: autoDismiss,
    );
  }

  /// Factory: Normal confirmation dialog
  factory AppStatusDialog.confirm({
    required String title,
    required String description,
    required String actionLabel,
    required VoidCallback onAction,
    String cancelLabel = 'ยกเลิก',
    VoidCallback? onCancel,
  }) {
    return AppStatusDialog(
      type: AppDialogType.confirm,
      title: title,
      description: description,
      actionLabel: actionLabel,
      onAction: onAction,
      cancelLabel: cancelLabel,
      onCancel: onCancel,
      autoDismissDuration: const Duration(days: 1), // not used
    );
  }

  /// Factory: Destructive confirmation dialog
  factory AppStatusDialog.destructive({
    required String title,
    required String description,
    required String actionLabel,
    required VoidCallback onAction,
    String cancelLabel = 'ยกเลิก',
    VoidCallback? onCancel,
  }) {
    return AppStatusDialog(
      type: AppDialogType.destructive,
      title: title,
      description: description,
      actionLabel: actionLabel,
      onAction: onAction,
      cancelLabel: cancelLabel,
      onCancel: onCancel,
      autoDismissDuration: const Duration(days: 1), // not used
    );
  }

  @override
  State<AppStatusDialog> createState() => _AppStatusDialogState();
}

class _AppStatusDialogState extends State<AppStatusDialog> {
  bool get _isStatusAlert =>
      widget.type == AppDialogType.success ||
      widget.type == AppDialogType.failure ||
      widget.type == AppDialogType.warning;

  @override
  void initState() {
    super.initState();

    // Auto-dismiss for status alerts (success/failure/warning), similar to old_lib toasts.
    if (_isStatusAlert) {
      Future.delayed(widget.autoDismissDuration, () {
        if (!mounted) return;
        Navigator.of(context, rootNavigator: true).maybePop();
        widget.onAction?.call(); // treat onAction as onDismiss for banners
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isStatusAlert) {
      return _buildStatusAlert(context);
    }
    return _buildConfirmationModal(context);
  }

  Widget _buildStatusAlert(BuildContext context) {
    // Colors & icon by type
    Color pillBg;
    Color iconColor;
    IconData iconData;

    switch (widget.type) {
      case AppDialogType.success:
        pillBg = AppColors.statusSuccessBg;
        iconColor = AppColors.success600;
        iconData = Icons.check_circle_outline;
        break;
      case AppDialogType.failure:
        pillBg = AppColors.statusErrorBg;
        iconColor = AppColors.error600;
        iconData = Icons.error_outline;
        break;
      case AppDialogType.warning:
      default:
        pillBg = AppColors.statusWarningBg;
        iconColor = AppColors.warning600;
        iconData = Icons.warning_amber_rounded;
        break;
    }

    // Positioned similar to a floating banner (picture 1)
    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Align(
        alignment: Alignment.topCenter,
        child: Material(
          color: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: pillBg,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(iconData, color: iconColor, size: 24),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.title,
                        style: GoogleFonts.anuphan(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.eerieBlack,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        widget.description,
                        style: GoogleFonts.anuphan(
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                          color: AppColors.gray500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildConfirmationModal(BuildContext context) {
    final bool isDestructive = widget.type == AppDialogType.destructive;
    final AppButtonStyle buttonStyle = isDestructive
        ? AppButtonStyle.destructive
        : AppButtonStyle.primary;

    // TODO: wire real illustrations here. For now, keep placeholders but
    //       respect the blue vs red accent from the design.
    final Color illustrationBg = isDestructive
        ? AppColors.statusErrorBg
        : AppColors.statusSuccessBg;
    final Color illustrationStroke = isDestructive
        ? AppColors.error600
        : AppColors.blue600;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(24),
      child: Container(
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 32,
              offset: const Offset(0, 18),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Close button row
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                InkWell(
                  onTap: () => Navigator.of(context).pop(),
                  borderRadius: BorderRadius.circular(16),
                  child: const Icon(
                    Icons.close,
                    color: Color(0xFF9EA3AE),
                    size: 22,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),

            // Illustration area
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: illustrationBg,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: illustrationStroke, width: 1.2),
              ),
              child: Center(
                child: Text(
                  isDestructive
                      ? 'Illustration\n(Destructive)'
                      : 'Illustration\n(Confirm)',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.anuphan(
                    fontSize: 11,
                    color: AppColors.gray500,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Title & description
            Text(
              widget.title,
              textAlign: TextAlign.center,
              style: GoogleFonts.anuphan(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: AppColors.eerieBlack,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              widget.description,
              textAlign: TextAlign.center,
              style: GoogleFonts.anuphan(
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: AppColors.gray500,
              ),
            ),
            const SizedBox(height: 24),

            // Primary action button
            AppButton(
              text: widget.actionLabel,
              style: buttonStyle,
              onPressed: () {
                Navigator.of(context).pop();
                widget.onAction?.call();
              },
            ),
            const SizedBox(height: 16),

            // Secondary text action (cancel)
            InkWell(
              onTap: () {
                Navigator.of(context).pop();
                widget.onCancel?.call();
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Text(
                  widget.cancelLabel ?? 'ยกเลิก',
                  style: GoogleFonts.anuphan(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: AppColors.gray500,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Helper methods to show dialogs easily.
///
/// These are the main API surface used across the app.
class StatusDialog {
  static Future<void> showSuccess({
    required BuildContext context,
    required String title,
    required String message,
    VoidCallback? onDismiss,
  }) async {
    await showDialog(
      context: context,
      barrierColor: Colors.transparent,
      barrierDismissible: true,
      builder: (_) =>
          AppStatusDialog.success(title: title, description: message),
    );
    onDismiss?.call();
  }

  static Future<void> showError({
    required BuildContext context,
    required String title,
    required String message,
  }) async {
    await showDialog(
      context: context,
      barrierColor: Colors.transparent,
      barrierDismissible: true,
      builder: (_) =>
          AppStatusDialog.failure(title: title, description: message),
    );
  }

  static Future<void> showWarning({
    required BuildContext context,
    required String title,
    required String message,
  }) async {
    await showDialog(
      context: context,
      barrierColor: Colors.transparent,
      barrierDismissible: true,
      builder: (_) =>
          AppStatusDialog.warning(title: title, description: message),
    );
  }

  static Future<bool> showConfirm({
    required BuildContext context,
    required String title,
    required String message,
    required String actionLabel,
    required VoidCallback onAction,
    String cancelLabel = 'ยกเลิก',
    VoidCallback? onCancel,
  }) async {
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: true,
      builder: (_) => AppStatusDialog.confirm(
        title: title,
        description: message,
        actionLabel: actionLabel,
        onAction: onAction,
        cancelLabel: cancelLabel,
        onCancel: onCancel,
      ),
    );
    // If dialog was dismissed without explicit action, treat as "false".
    return result ?? false;
  }

  static Future<bool> showDestructive({
    required BuildContext context,
    required String title,
    required String message,
    required String actionLabel,
    required VoidCallback onAction,
    String cancelLabel = 'ยกเลิก',
    VoidCallback? onCancel,
  }) async {
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: true,
      builder: (_) => AppStatusDialog.destructive(
        title: title,
        description: message,
        actionLabel: actionLabel,
        onAction: onAction,
        cancelLabel: cancelLabel,
        onCancel: onCancel,
      ),
    );
    return result ?? false;
  }
}
