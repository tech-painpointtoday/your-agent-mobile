import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import '../../core/theme/app_colors.dart';

/// Minimal app button wrapper used by dialogs and shared UI.
///
/// This is intentionally lightweight compared to the old `old_lib/` button
/// implementation, but follows the same visual language and colors.

enum AppButtonStyle { primary, destructive, outline, ghost }

class AppButton extends StatelessWidget {
  final String text;
  final AppButtonStyle style;
  final VoidCallback? onPressed;
  final double? height;
  final Color? backgroundColor;
  final Color? textColor;
  final IconData? icon;
  final String? iconPath;
  final TextStyle? textStyle;
  final EdgeInsets? padding;

  const AppButton({
    super.key,
    required this.text,
    required this.style,
    this.onPressed,
    this.height,
    this.backgroundColor,
    this.textColor,
    this.icon,
    this.iconPath,
    this.textStyle,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final bool enabled = onPressed != null;

    Color background = switch (style) {
      AppButtonStyle.primary =>
        enabled ? AppColors.buttonPrimary : AppColors.buttonDisabledBg,
      AppButtonStyle.destructive =>
        enabled ? AppColors.supportRedDeep : AppColors.buttonDisabledBg,
      AppButtonStyle.outline => Colors.white,
      AppButtonStyle.ghost => Colors.transparent,
    };

    if (backgroundColor != null && enabled) {
      background = backgroundColor!;
    }

    Color textCol =
        style == AppButtonStyle.outline || style == AppButtonStyle.ghost
        ? (enabled ? AppColors.baseDarkGrey : AppColors.buttonDisabledText)
        : Colors.white;

    if (textColor != null && enabled) {
      textCol = textColor!;
    }

    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        padding: padding,
        backgroundColor: background,
        foregroundColor: textCol,
        disabledBackgroundColor: AppButtonStyle.outline == style
            ? AppColors.buttonDisabledBg
            : AppColors.primary.withValues(alpha: 0.5),
        disabledForegroundColor: AppButtonStyle.outline == style
            ? AppColors.buttonDisabledText
            : AppColors.white,
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
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null || iconPath != null) ...[
            if (iconPath != null)
              SvgPicture.asset(
                iconPath!,
                width: 20,
                height: 20,
                colorFilter: ColorFilter.mode(
                  textColor ?? AppColors.baseBlack,
                  BlendMode.srcIn,
                ),
              )
            else
              Icon(icon, size: 20),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Text(
              text,
              style:
                  textStyle ??
                  const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ),
        ],
      ),
    );
  }
}
