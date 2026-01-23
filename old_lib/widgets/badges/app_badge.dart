import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:youragent/core/theme/app_colors.dart';

/// Badge color scheme
enum BadgeColor {
  default_, // Light grey
  red,
  orange,
  green,
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

  const AppBadge({
    super.key,
    required this.label,
    this.color = BadgeColor.default_,
    this.style = BadgeStyle.plain,
    this.onDismiss,
    this.customBackgroundColor,
    this.customTextColor,
    this.customDotColor,
    this.fontSize,
    this.padding,
  });

  @override
  State<AppBadge> createState() => _AppBadgeState();
}

class _AppBadgeState extends State<AppBadge> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final backgroundColor = widget.customBackgroundColor ?? _getBackgroundColor();
    final textColor = widget.customTextColor ?? _getTextColor();
    final dotColor = widget.customDotColor ?? _getDotColor();
    final padding = widget.padding ?? const EdgeInsets.symmetric(horizontal: 12, vertical: 4);
    final fontSize = widget.fontSize ?? 14.0;

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
      case BadgeStyle.dismissibleLeading:
        // Add leading 'x' icon
        content = Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.close,
              size: 14,
              color: textColor,
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
            Icon(
              Icons.close,
              size: 14,
              color: textColor,
            ),
          ],
        );
        break;
    }

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: widget.onDismiss != null ? SystemMouseCursors.click : SystemMouseCursors.basic,
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
          ),
          child: content,
        ),
      ),
    );
  }

  Color _getBackgroundColor() {
    switch (widget.color) {
      case BadgeColor.default_:
        return const Color(0xFFF5F5F5); // Light gray
      case BadgeColor.red:
        return const Color(0xFFFFE5E5); // Light red
      case BadgeColor.orange:
        return const Color(0xFFFFF4E5); // Light orange-yellow
      case BadgeColor.green:
        return const Color(0xFFE5F5ED); // Light green
      case BadgeColor.blue:
        return const Color(0xFFE5F0FF); // Light blue
      case BadgeColor.purple:
        return const Color(0xFFF3E5FF); // Light purple
      case BadgeColor.pink:
        return const Color(0xFFFFE5F0); // Light pink
      case BadgeColor.brown:
        return const Color(0xFFFFF0E5); // Light orange/brown
    }
  }

  Color _getTextColor() {
    switch (widget.color) {
      case BadgeColor.default_:
        return const Color(0xFF525252); // Dark gray
      case BadgeColor.red:
        return const Color(0xFFDC2626); // Darker red
      case BadgeColor.orange:
        return const Color(0xFFEA580C); // Darker orange
      case BadgeColor.green:
        return const Color(0xFF16A34A); // Darker green
      case BadgeColor.blue:
        return const Color(0xFF2563EB); // Medium blue
      case BadgeColor.purple:
        return const Color(0xFF9333EA); // Darker purple
      case BadgeColor.pink:
        return const Color(0xFFDB2777); // Darker pink
      case BadgeColor.brown:
        return const Color(0xFFD97706); // Darker orange/brown
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
  static AppBadge status({
    required String label,
    BadgeColor? color,
  }) {
    // Normalize label for comparison
    final normalizedLabel = label.toLowerCase().trim();
    
    // Determine colors based on status
    Color? bgColor;
    Color? textColor;
    
    if (normalizedLabel == 'confirmed' || normalizedLabel == 'available') {
      bgColor = AppColors.statusConfirmedBg;
      textColor = AppColors.statusConfirmedText;
    } else if (normalizedLabel == 'pending') {
      bgColor = AppColors.statusPendingBg;
      textColor = AppColors.statusPendingText;
    } else if (normalizedLabel == 'cancelled' || normalizedLabel == 'canceled' || normalizedLabel == 'sold') {
      bgColor = AppColors.statusCancelledBg;
      textColor = AppColors.statusCancelledText;
    }
    
    // If custom colors were provided or status not recognized, use default color scheme
    if (bgColor == null || textColor == null || color != null) {
      return AppBadge(
        label: label,
        color: color ?? BadgeColor.green,
        style: BadgeStyle.dot,
      );
    }
    
    // Use theme colors for recognized statuses
    return AppBadge(
      label: label,
      style: BadgeStyle.dot,
      customBackgroundColor: bgColor,
      customTextColor: textColor,
      customDotColor: textColor,
    );
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

