import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:youragent/core/theme/app_colors.dart';

/// Button variant types
enum ButtonVariant {
  filled, // Solid background
  outlined, // Border with transparent/white background
  light, // Light background with colored text
  disabled, // Disabled state
}

/// Button color scheme
enum ButtonColor {
  primary, // Blue (#1743C7)
  secondary, // Green/Teal (#32a792)
  gray, // Gray/Neutral
}

/// Button size
enum ButtonSize {
  small, // 8px 14px padding
  medium, // 10px 16px padding
  large, // 12px 20px padding
  icon, // Icon only (8px, 10px, 12px, 14px padding)
}

/// App Button - A comprehensive button widget matching the design system
class AppButton extends StatefulWidget {
  final String? label;
  final Widget? icon;
  final IconPosition iconPosition;
  final VoidCallback? onPressed;
  final ButtonVariant variant;
  final ButtonColor color;
  final ButtonSize size;
  final bool hasFocusRing;
  final double? width;
  final double? height;

  const AppButton({
    super.key,
    this.label,
    this.icon,
    this.iconPosition = IconPosition.start,
    this.onPressed,
    this.variant = ButtonVariant.filled,
    this.color = ButtonColor.primary,
    this.size = ButtonSize.medium,
    this.hasFocusRing = false,
    this.width,
    this.height,
  }) : assert(
         label != null || icon != null,
         'Either label or icon must be provided',
       );

  @override
  State<AppButton> createState() => _AppButtonState();
}

class _AppButtonState extends State<AppButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final isEnabled =
        widget.onPressed != null && widget.variant != ButtonVariant.disabled;
    final effectiveVariant = !isEnabled
        ? ButtonVariant.disabled
        : widget.variant;

    final padding = _getPadding();
    final backgroundColor = _getBackgroundColor(effectiveVariant, _isHovered);
    final borderColor = _getBorderColor(effectiveVariant, _isHovered);
    final textColor = _getTextColor(effectiveVariant, _isHovered);
    final fontSize = _getFontSize();
    final fontWeight = _getFontWeight(effectiveVariant);
    final borderRadius = BorderRadius.circular(12);

    Widget content;

    // Helper to wrap icon with proper color for filled buttons
    Widget wrapIcon(Widget icon) {
      if (effectiveVariant == ButtonVariant.filled) {
        // For filled buttons, ensure icon matches text color (white)
        return IconTheme(
          data: IconThemeData(color: textColor),
          child: icon,
        );
      }
      return icon;
    }

    if (widget.icon != null && widget.label == null) {
      // Icon-only button - wrap icon with proper sizing
      content = SizedBox(
        width: widget.size == ButtonSize.icon ? 20 : 24,
        height: widget.size == ButtonSize.icon ? 20 : 24,
        child: wrapIcon(widget.icon!),
      );
    } else {
      content = Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (widget.icon != null &&
              widget.iconPosition == IconPosition.start) ...[
            SizedBox(width: 20, height: 20, child: wrapIcon(widget.icon!)),
            if (widget.label != null) const SizedBox(width: 8),
          ],
          if (widget.label != null)
            Text(
              widget.label!,
              style: GoogleFonts.anuphan(
                fontSize: fontSize,
                fontWeight: fontWeight,
                color: textColor,
                letterSpacing: 0,
              ),
            ),
          if (widget.icon != null &&
              widget.iconPosition == IconPosition.end) ...[
            if (widget.label != null) const SizedBox(width: 8),
            SizedBox(width: 20, height: 20, child: wrapIcon(widget.icon!)),
          ],
        ],
      );
    }

    final container = Container(
      width: widget.width,
      height: widget.height,
      padding: padding,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: borderRadius,
        border: Border.all(color: borderColor),
        boxShadow: widget.hasFocusRing ? _getFocusRingShadow() : null,
      ),
      child: Center(child: content),
    );

    if (!isEnabled) {
      return container;
    }

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: SystemMouseCursors.click,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: widget.onPressed,
          borderRadius: borderRadius,
          child: container,
        ),
      ),
    );
  }

  EdgeInsets _getPadding() {
    switch (widget.size) {
      case ButtonSize.small:
        return const EdgeInsets.symmetric(horizontal: 14, vertical: 8);
      case ButtonSize.medium:
        return const EdgeInsets.symmetric(horizontal: 16, vertical: 10);
      case ButtonSize.large:
        return const EdgeInsets.symmetric(horizontal: 20, vertical: 12);
      case ButtonSize.icon:
        return const EdgeInsets.all(8);
    }
  }

  Color _getBackgroundColor(ButtonVariant variant, bool isHovered) {
    if (!isHovered) {
      switch (variant) {
        case ButtonVariant.filled:
          switch (widget.color) {
            case ButtonColor.primary:
              return AppColors.buttonPrimary;
            case ButtonColor.secondary:
              return AppColors.buttonSecondary;
            case ButtonColor.gray:
              return AppColors.gray600;
          }
        case ButtonVariant.outlined:
          return AppColors.white;
        case ButtonVariant.light:
          switch (widget.color) {
            case ButtonColor.primary:
              return AppColors.buttonPrimary.withValues(alpha: 0.1);
            case ButtonColor.secondary:
              return AppColors.buttonLightGreen;
            case ButtonColor.gray:
              return AppColors.gray50;
          }
        case ButtonVariant.disabled:
          return AppColors.buttonDisabledBg;
      }
    } else {
      // Hover states
      switch (variant) {
        case ButtonVariant.filled:
          switch (widget.color) {
            case ButtonColor.primary:
              return AppColors.buttonPrimaryHover;
            case ButtonColor.secondary:
              return AppColors.buttonSecondaryHover;
            case ButtonColor.gray:
              return AppColors.gray700;
          }
        case ButtonVariant.outlined:
          switch (widget.color) {
            case ButtonColor.primary:
              return AppColors.buttonPrimary.withValues(alpha: 0.1);
            case ButtonColor.secondary:
              return AppColors.buttonLightGreen;
            case ButtonColor.gray:
              return AppColors.buttonGrayHover;
          }
        case ButtonVariant.light:
          switch (widget.color) {
            case ButtonColor.primary:
              return AppColors.buttonPrimary.withValues(alpha: 0.15);
            case ButtonColor.secondary:
              return AppColors.buttonSecondary.withValues(alpha: 0.15);
            case ButtonColor.gray:
              return AppColors.buttonGrayHover;
          }
        case ButtonVariant.disabled:
          return AppColors.buttonDisabledBg;
      }
    }
  }

  Color _getBorderColor(ButtonVariant variant, bool isHovered) {
    if (!isHovered) {
      switch (variant) {
        case ButtonVariant.filled:
          switch (widget.color) {
            case ButtonColor.primary:
              return AppColors.buttonPrimary;
            case ButtonColor.secondary:
              return AppColors.buttonSecondary;
            case ButtonColor.gray:
              return AppColors.gray600;
          }
        case ButtonVariant.outlined:
          switch (widget.color) {
            case ButtonColor.primary:
              return AppColors.buttonPrimary;
            case ButtonColor.secondary:
              return AppColors.buttonSecondary;
            case ButtonColor.gray:
              return AppColors.buttonBorderGray;
          }
        case ButtonVariant.light:
          switch (widget.color) {
            case ButtonColor.primary:
              return AppColors.buttonPrimary.withValues(alpha: 0.1);
            case ButtonColor.secondary:
              return AppColors.buttonLightGreen;
            case ButtonColor.gray:
              return AppColors.buttonBorderGray;
          }
        case ButtonVariant.disabled:
          return AppColors.buttonBorderGray;
      }
    } else {
      // Hover states
      switch (variant) {
        case ButtonVariant.filled:
          switch (widget.color) {
            case ButtonColor.primary:
              return AppColors.buttonPrimaryHover;
            case ButtonColor.secondary:
              return AppColors.buttonSecondaryHover;
            case ButtonColor.gray:
              return AppColors.gray700;
          }
        case ButtonVariant.outlined:
          switch (widget.color) {
            case ButtonColor.primary:
              return AppColors.buttonPrimaryHover;
            case ButtonColor.secondary:
              return AppColors.buttonSecondaryHover;
            case ButtonColor.gray:
              return AppColors.gray600;
          }
        case ButtonVariant.light:
          switch (widget.color) {
            case ButtonColor.primary:
              return AppColors.buttonPrimary.withValues(alpha: 0.2);
            case ButtonColor.secondary:
              return AppColors.buttonSecondary.withValues(alpha: 0.2);
            case ButtonColor.gray:
              return AppColors.gray600;
          }
        case ButtonVariant.disabled:
          return AppColors.buttonBorderGray;
      }
    }
  }

  Color _getTextColor(ButtonVariant variant, bool isHovered) {
    if (!isHovered) {
      switch (variant) {
        case ButtonVariant.filled:
          return AppColors.white;
        case ButtonVariant.outlined:
          switch (widget.color) {
            case ButtonColor.primary:
              return AppColors.buttonPrimary;
            case ButtonColor.secondary:
              return AppColors.buttonSecondary;
            case ButtonColor.gray:
              return AppColors.buttonTextDark;
          }
        case ButtonVariant.light:
          switch (widget.color) {
            case ButtonColor.primary:
              return AppColors.buttonPrimary;
            case ButtonColor.secondary:
              return AppColors.buttonSecondary;
            case ButtonColor.gray:
              return AppColors.gray500;
          }
        case ButtonVariant.disabled:
          return AppColors.buttonDisabledText;
      }
    } else {
      // Hover states - text color may change slightly
      switch (variant) {
        case ButtonVariant.filled:
          return AppColors.white; // Keep white on filled buttons
        case ButtonVariant.outlined:
          switch (widget.color) {
            case ButtonColor.primary:
              return AppColors.buttonPrimaryHover;
            case ButtonColor.secondary:
              return AppColors.buttonSecondaryHover;
            case ButtonColor.gray:
              return AppColors.gray700;
          }
        case ButtonVariant.light:
          switch (widget.color) {
            case ButtonColor.primary:
              return AppColors.buttonPrimaryHover;
            case ButtonColor.secondary:
              return AppColors.buttonSecondaryHover;
            case ButtonColor.gray:
              return AppColors.gray700;
          }
        case ButtonVariant.disabled:
          return AppColors.buttonDisabledText;
      }
    }
  }

  double _getFontSize() {
    switch (widget.size) {
      case ButtonSize.small:
        return 14; // body-sm
      case ButtonSize.medium:
        return 14; // body-sm
      case ButtonSize.large:
        return 16; // body-md
      case ButtonSize.icon:
        return 14;
    }
  }

  FontWeight _getFontWeight(ButtonVariant variant) {
    switch (variant) {
      case ButtonVariant.filled:
        return FontWeight.w600; // semibold
      case ButtonVariant.outlined:
      case ButtonVariant.light:
        return FontWeight.w500; // medium
      case ButtonVariant.disabled:
        return FontWeight.w500;
    }
  }

  List<BoxShadow>? _getFocusRingShadow() {
    switch (widget.color) {
      case ButtonColor.primary:
        return [
          BoxShadow(
            color: AppColors.buttonPrimary.withValues(alpha: 0.3),
            blurRadius: 4,
            spreadRadius: 0,
          ),
        ];
      case ButtonColor.secondary:
        return [
          BoxShadow(
            color: AppColors.buttonSecondary.withValues(alpha: 0.3),
            blurRadius: 4,
            spreadRadius: 0,
          ),
        ];
      case ButtonColor.gray:
        return [
          BoxShadow(
            color: AppColors.gray600.withValues(alpha: 0.2),
            blurRadius: 4,
            spreadRadius: 0,
          ),
        ];
    }
    return null;
  }
}

/// Icon position relative to label
enum IconPosition { start, end }

/// Helper class with factory methods for common button types
class AppButtons {
  /// Primary filled button (blue)
  static AppButton primary({
    required String label,
    Widget? icon,
    IconPosition iconPosition = IconPosition.start,
    VoidCallback? onPressed,
    ButtonSize size = ButtonSize.medium,
    bool hasFocusRing = false,
    double? width,
    double? height,
  }) {
    return AppButton(
      label: label,
      icon: icon,
      iconPosition: iconPosition,
      onPressed: onPressed,
      variant: ButtonVariant.filled,
      color: ButtonColor.primary,
      size: size,
      hasFocusRing: hasFocusRing,
      width: width,
      height: height,
    );
  }

  /// Secondary filled button (green/teal)
  static AppButton secondary({
    required String label,
    Widget? icon,
    IconPosition iconPosition = IconPosition.start,
    VoidCallback? onPressed,
    ButtonSize size = ButtonSize.medium,
    bool hasFocusRing = false,
    double? width,
    double? height,
  }) {
    return AppButton(
      label: label,
      icon: icon,
      iconPosition: iconPosition,
      onPressed: onPressed,
      variant: ButtonVariant.filled,
      color: ButtonColor.secondary,
      size: size,
      hasFocusRing: hasFocusRing,
      width: width,
      height: height,
    );
  }

  /// Outlined button
  static AppButton outlined({
    required String label,
    Widget? icon,
    IconPosition iconPosition = IconPosition.start,
    VoidCallback? onPressed,
    ButtonColor color = ButtonColor.primary,
    ButtonSize size = ButtonSize.medium,
    bool hasFocusRing = false,
    double? width,
    double? height,
  }) {
    return AppButton(
      label: label,
      icon: icon,
      iconPosition: iconPosition,
      onPressed: onPressed,
      variant: ButtonVariant.outlined,
      color: color,
      size: size,
      hasFocusRing: hasFocusRing,
      width: width,
      height: height,
    );
  }

  /// Light button (light background)
  static AppButton light({
    required String label,
    Widget? icon,
    IconPosition iconPosition = IconPosition.start,
    VoidCallback? onPressed,
    ButtonColor color = ButtonColor.secondary,
    ButtonSize size = ButtonSize.medium,
    double? width,
    double? height,
  }) {
    return AppButton(
      label: label,
      icon: icon,
      iconPosition: iconPosition,
      onPressed: onPressed,
      variant: ButtonVariant.light,
      color: color,
      size: size,
      width: width,
      height: height,
    );
  }

  /// Icon-only button
  static AppButton iconOnly({
    required Widget icon,
    VoidCallback? onPressed,
    ButtonColor color = ButtonColor.primary,
    ButtonVariant variant = ButtonVariant.filled,
    ButtonSize size = ButtonSize.icon,
    bool hasFocusRing = false,
  }) {
    return AppButton(
      icon: icon,
      onPressed: onPressed,
      variant: variant,
      color: color,
      size: size,
      hasFocusRing: hasFocusRing,
    );
  }
}
