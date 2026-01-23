import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';

/// Minimal app button wrapper used by dialogs and shared UI.
///
/// This is intentionally lightweight compared to the old `old_lib/` button
/// implementation, but follows the same visual language and colors.

enum AppButtonStyle { primary, destructive }

class AppButton extends StatelessWidget {
  final String text;
  final AppButtonStyle style;
  final VoidCallback? onPressed;
  final double height;

  const AppButton({
    super.key,
    required this.text,
    required this.style,
    this.onPressed,
    this.height = 48,
  });

  @override
  Widget build(BuildContext context) {
    final bool enabled = onPressed != null;
    final Color background = switch (style) {
      AppButtonStyle.primary =>
        enabled ? AppColors.buttonPrimary : AppColors.buttonDisabledBg,
      AppButtonStyle.destructive =>
        enabled ? AppColors.error600 : AppColors.buttonDisabledBg,
    };

    return SizedBox(
      width: double.infinity,
      height: height,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: background,
          foregroundColor: Colors.white,
          disabledBackgroundColor: AppColors.buttonDisabledBg,
          disabledForegroundColor: AppColors.buttonDisabledText,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
        ),
        child: Text(
          text,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}
