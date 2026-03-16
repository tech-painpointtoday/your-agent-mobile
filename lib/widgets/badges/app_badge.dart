import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:yourhome/core/theme/app_colors.dart';

/// Badge color scheme
enum BadgeColor {
  default_, // Light grey
  red,
  orange,
  green,
  yellow,
  blue,
  purple,
  pink,
  brown,
  // Custom colors can be provided via BadgeStyle
}

/// Badge style - determines the visual appearance
enum BadgeStyle {
  plain, // Just text
  dot, // Leading dot indicator
  dismissibleLeading, // Leading 'x' icon
  dismissibleTrailing, // Trailing 'x' icon
  done,
}

/// App Badge - A comprehensive badge widget matching the design system
class AppBadge extends StatefulWidget {
  final String label;
  final BadgeColor color;
  final BadgeStyle style;
  final VoidCallback? onDismiss;
  final Color? customBackgroundColor;
  final Color? customTextColor;
  final Color? customDotColor;
  final double? fontSize;
  final EdgeInsets? padding;
  final bool hasBorder;
  final Color? borderColor;

  const AppBadge({
    super.key,
    required this.label,
    this.color = BadgeColor.default_,
    this.style = BadgeStyle.plain,
    this.onDismiss,
    this.customBackgroundColor,
    this.customTextColor,
    this.customDotColor,
    this.fontSize = 14,
    this.padding,
    this.hasBorder = false,
    this.borderColor,
  });

  @override
  State<AppBadge> createState() => _AppBadgeState();
}

class _AppBadgeState extends State<AppBadge> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final backgroundColor =
        widget.customBackgroundColor ?? _getBackgroundColor();
    final textColor = widget.customTextColor ?? _getTextColor();
    final dotColor = widget.customDotColor ?? _getDotColor();
    final padding =
        widget.padding ??
        const EdgeInsets.symmetric(horizontal: 12, vertical: 4);
    final fontSize = widget.fontSize ?? 12.0;

    Widget content = Text(
      widget.label,
      style: GoogleFonts.anuphan(
        fontSize: fontSize,
        fontWeight: FontWeight.w500,
        color: textColor,
      ),
    );

    // Build badge content based on style
    switch (widget.style) {
      case BadgeStyle.plain:
        // Just text, no modifications needed
        break;
      case BadgeStyle.dot:
        // Add leading dot
        content = Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(
                color: dotColor,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 6),
            content,
          ],
        );
        break;
      case BadgeStyle.done:
        // Add leading dot
        content = Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SvgPicture.asset(
              'assets/icons/check.svg',
              width: 14,
              height: 14,
              colorFilter: ColorFilter.mode(textColor, BlendMode.srcIn),
            ),
            const SizedBox(width: 4),
            content,
          ],
        );
        break;

      case BadgeStyle.dismissibleLeading:
        // Add leading 'x' icon
        content = Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SvgPicture.asset(
              'assets/icons/x.svg',
              width: 14,
              height: 14,
              colorFilter: ColorFilter.mode(textColor, BlendMode.srcIn),
            ),
            const SizedBox(width: 4),
            content,
          ],
        );
        break;
      case BadgeStyle.dismissibleTrailing:
        // Add trailing 'x' icon
        content = Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            content,
            const SizedBox(width: 4),
            SvgPicture.asset(
              'assets/icons/x.svg',
              width: 14,
              height: 14,
              colorFilter: ColorFilter.mode(textColor, BlendMode.srcIn),
            ),
          ],
        );
        break;
    }

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: widget.onDismiss != null
          ? SystemMouseCursors.click
          : SystemMouseCursors.basic,
      child: GestureDetector(
        onTap: widget.onDismiss,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: padding,
          decoration: BoxDecoration(
            color: _isHovered && widget.onDismiss != null
                ? _getHoverBackgroundColor(backgroundColor)
                : backgroundColor,
            borderRadius: BorderRadius.circular(16),
            border: (widget.hasBorder || widget.borderColor != null)
                ? Border.all(
                    color: widget.borderColor ?? _getTextColor(),
                    width: 1,
                  )
                : null,
          ),
          child: content,
        ),
      ),
    );
  }

  Color _getBackgroundColor() {
    switch (widget.color) {
      case BadgeColor.default_:
        return AppColors.basePaleGrey; // Light gray
      case BadgeColor.red:
        return AppColors.supportRedLight; // Light red
      case BadgeColor.orange:
        return AppColors.supportOrangeLight; // Light orange-yellow
      case BadgeColor.green:
        return AppColors.supportGreenLight; // Light green
      case BadgeColor.yellow:
        return AppColors.supportYellowLight; // Light yellow
      case BadgeColor.blue:
        return AppColors.supportBlueLight; // Light blue
      case BadgeColor.purple:
        return AppColors.supportPurpleLight; // Light purple
      case BadgeColor.pink:
        return AppColors.supportPinkLight; // Light pink
      case BadgeColor.brown:
        return AppColors.supportOrangeLight; // Light orange/brown
    }
  }

  Color _getTextColor() {
    switch (widget.color) {
      case BadgeColor.default_:
        return AppColors.baseDarkGrey; // Dark gray
      case BadgeColor.red:
        return AppColors.supportRedDark; // Darker red
      case BadgeColor.orange:
        return AppColors.supportOrangeDark; // Darker orange
      case BadgeColor.green:
        return AppColors.supportGreenDark; // Darker green
      case BadgeColor.yellow:
        return AppColors.supportYellowDark; // Darker yellow
      case BadgeColor.blue:
        return AppColors.supportBlueDeep; // Medium blue
      case BadgeColor.purple:
        return AppColors.supportPurpleDark; // Darker purple
      case BadgeColor.pink:
        return AppColors.supportPinkDark; // Darker pink
      case BadgeColor.brown:
        return AppColors.supportOrangeDark; // Darker orange/brown
    }
  }

  Color _getDotColor() {
    // Dot color matches text color
    return _getTextColor();
  }

  Color _getHoverBackgroundColor(Color baseColor) {
    // Darken the background slightly on hover for dismissible badges
    return Color.lerp(baseColor, Colors.black, 0.05) ?? baseColor;
  }
}

/// Helper class with factory methods for common badge types
class AppBadges {
  /// Status badge with dot indicator
  /// Automatically maps status strings to correct theme colors
  static AppBadge status({required String label, BadgeColor? color}) {
    // Normalize label for comparison
    final normalizedLabel = label.toLowerCase().trim();

    // Determine badge color based on status
    BadgeColor badgeColor;

    if (normalizedLabel == 'confirmed' || normalizedLabel == 'available') {
      badgeColor = BadgeColor.green;
    } else if (normalizedLabel == 'pending') {
      badgeColor = BadgeColor.orange;
    } else if (normalizedLabel == 'cancelled' ||
        normalizedLabel == 'canceled' ||
        normalizedLabel == 'sold') {
      badgeColor = BadgeColor.red;
    } else {
      badgeColor = color ?? BadgeColor.default_;
    }

    return AppBadge(label: label, color: badgeColor, style: BadgeStyle.dot);
  }

  /// Plain badge (just text)
  static AppBadge plain({
    required String label,
    BadgeColor color = BadgeColor.default_,
    Color? customBackgroundColor,
    Color? customTextColor,
  }) {
    return AppBadge(
      label: label,
      color: color,
      style: BadgeStyle.plain,
      customBackgroundColor: customBackgroundColor,
      customTextColor: customTextColor,
    );
  }

  /// Dismissible badge with trailing 'x'
  static AppBadge dismissible({
    required String label,
    required VoidCallback onDismiss,
    BadgeColor color = BadgeColor.default_,
  }) {
    return AppBadge(
      label: label,
      color: color,
      style: BadgeStyle.dismissibleTrailing,
      onDismiss: onDismiss,
    );
  }

  /// Dismissible badge with leading 'x'
  static AppBadge dismissibleLeading({
    required String label,
    required VoidCallback onDismiss,
    BadgeColor color = BadgeColor.default_,
  }) {
    return AppBadge(
      label: label,
      color: color,
      style: BadgeStyle.dismissibleLeading,
      onDismiss: onDismiss,
    );
  }
}
