import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';

/// Minimal app button wrapper used by dialogs and shared UI.
///
/// This is intentionally lightweight compared to the old `old_lib/` button
/// implementation, but follows the same visual language and colors.

enum AppButtonStyle { primary, destructive, outline }

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
        enabled ? AppColors.supportRedDeep : AppColors.buttonDisabledBg,
      AppButtonStyle.outline => Colors.white,
    };

    final Color textColor = style == AppButtonStyle.outline
        ? (enabled ? AppColors.baseDarkGrey : AppColors.buttonDisabledText)
        : Colors.white;

    return SizedBox(
      width: double.infinity,
      height: height,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: background,
          foregroundColor: textColor,
          disabledBackgroundColor: AppColors.buttonDisabledBg,
          disabledForegroundColor: AppColors.buttonDisabledText,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: style == AppButtonStyle.outline
                ? BorderSide(
                    color: enabled
                        ? AppColors.baseLightGrey
                        : AppColors.baseLightGrey,
                    width: 1,
                  )
                : BorderSide.none,
          ),
          elevation: 0,
        ),
        child: Text(
          text,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          textAlign: TextAlign.center,
          overflow: TextOverflow.ellipsis,
          maxLines: 1,
        ),
      ),
    );
  }
}
