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
  final bool enabled;
  final VoidCallback? onPressed;
  final double? height;
  final double? iconSize;
  final Color? backgroundColor;
  final Color? textColor;
  final IconData? icon;
  final String? iconPath;
  final TextStyle? textStyle;
  final EdgeInsets? padding;
  final bool isLoading;
  final Color? borderColor;
  final double? width;
  final double? textSize;
  final double elevation;

  const AppButton({
    super.key,
    required this.text,
    required this.style,
    this.enabled = true,
    this.onPressed,
    this.height,
    this.iconSize,
    this.backgroundColor,
    this.textColor,
    this.icon,
    this.iconPath,
    this.textStyle,
    this.padding,
    this.isLoading = false,
    this.borderColor,
    this.width,
    this.textSize,
    this.elevation = 0,
  });

  @override
  Widget build(BuildContext context) {
    final bool isEnabled = enabled && onPressed != null;

    Color background = switch (style) {
      AppButtonStyle.primary =>
        isEnabled ? AppColors.buttonPrimary : AppColors.buttonDisabledBg,
      AppButtonStyle.destructive =>
        isEnabled ? AppColors.supportRedDeep : AppColors.buttonDisabledBg,
      AppButtonStyle.outline => Colors.white,
      AppButtonStyle.ghost => Colors.transparent,
    };

    if (backgroundColor != null && isEnabled) {
      background = backgroundColor!;
    }

    Color textCol =
        style == AppButtonStyle.outline || style == AppButtonStyle.ghost
        ? (isEnabled ? AppColors.baseDarkGrey : AppColors.buttonDisabledText)
        : Colors.white;

    Color disabledBgCol = switch (style) {
      AppButtonStyle.primary => AppColors.primary.withValues(alpha: 0.5),
      AppButtonStyle.destructive => AppColors.supportRedDeep.withValues(
        alpha: 0.5,
      ),
      AppButtonStyle.outline => AppColors.buttonDisabledBg,
      AppButtonStyle.ghost => AppColors.buttonDisabledBg,
    };

    Color disabledTxtCol = switch (style) {
      AppButtonStyle.primary => AppColors.baseWhite,
      AppButtonStyle.destructive => AppColors.baseWhite,
      AppButtonStyle.outline => AppColors.buttonDisabledText,
      AppButtonStyle.ghost => AppColors.buttonDisabledText,
    };

    Color enabledTxtCol = switch (style) {
      AppButtonStyle.primary => textColor ?? AppColors.baseWhite,
      AppButtonStyle.destructive => textColor ?? AppColors.baseWhite,
      AppButtonStyle.outline => textColor ?? AppColors.baseDarkGrey,
      AppButtonStyle.ghost => textColor ?? AppColors.baseDarkGrey,
    };

    if (textColor != null && isEnabled) {
      textCol = textColor!;
    }

    return SizedBox(
      height: height,
      width: width,
      child: ElevatedButton(
        onPressed: isEnabled ? onPressed : null,
        style: ElevatedButton.styleFrom(
          padding: height != null ? padding ?? EdgeInsets.zero : padding,
          backgroundColor: background,
          foregroundColor: textCol,
          disabledBackgroundColor: disabledBgCol,
          disabledForegroundColor: disabledTxtCol,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: style == AppButtonStyle.outline
                ? BorderSide(
                    color: isEnabled
                        ? (borderColor ?? AppColors.baseLightGrey)
                        : AppColors.baseLightGrey,
                    width: 1,
                  )
                : BorderSide.none,
          ),
          elevation: elevation,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isLoading)
              SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: textCol,
                ),
              )
            else ...[
              if (icon != null || iconPath != null) ...[
                if (iconPath != null)
                  SvgPicture.asset(
                    iconPath!,
                    width: iconSize ?? 20,
                    height: iconSize ?? 20,
                    fit: BoxFit.scaleDown,
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
                      TextStyle(
                        fontSize: textSize ?? 16,
                        fontWeight: FontWeight.w500,
                        color: enabledTxtCol,
                      ),
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
