import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:youragent/core/theme/app_colors.dart';

/// Action icon button with default, hover, and disabled states
/// Matches the design:
/// - Default: White background, gray border (#E9EAEB), gray icon (#717680)
/// - Hover: White background, gray border, darker icon (#181D27)
/// - Disabled: Light gray background (#FAFAFA), gray border (#E9E9EB), light gray icon (#D5D6D9)
class ActionIconButton extends StatefulWidget {
  final IconData? icon;
  final String? svgAsset;
  final VoidCallback? onPressed;

  const ActionIconButton({
    super.key,
    this.icon,
    this.svgAsset,
    required this.onPressed,
  }) : assert(icon != null || svgAsset != null, 'Either icon or svgAsset must be provided');

  @override
  State<ActionIconButton> createState() => _ActionIconButtonState();
}

class _ActionIconButtonState extends State<ActionIconButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final isEnabled = widget.onPressed != null;

    // Determine colors based on state
    Color backgroundColor;
    Color borderColor;
    Color iconColor;

    if (!isEnabled) {
      // Disabled state
      backgroundColor = const Color(0xFFFAFAFA);
      borderColor = const Color(0xFFE9E9EB);
      iconColor = const Color(0xFFD5D6D9);
    } else if (_isHovered) {
      // Hover state
      backgroundColor = AppColors.white;
      borderColor = const Color(0xFFE9EAEB);
      iconColor = const Color(0xFF181D27);
    } else {
      // Default state
      backgroundColor = AppColors.white;
      borderColor = const Color(0xFFE9EAEB);
      iconColor = const Color(0xFF717680);
    }

    // Determine shadow based on hover state
    List<BoxShadow>? boxShadow;
    if (isEnabled && _isHovered) {
      boxShadow = [
        BoxShadow(
          color: const Color(0xFF717680).withValues(alpha: 0.24),
          blurRadius: 6,
          spreadRadius: 1,
          offset: Offset.zero,
        ),
      ];
    }

    Widget iconWidget;
    if (widget.svgAsset != null) {
      iconWidget = SvgPicture.asset(
        widget.svgAsset!,
        width: 20,
        height: 20,
        colorFilter: ColorFilter.mode(iconColor, BlendMode.srcIn),
      );
    } else {
      iconWidget = Icon(widget.icon, size: 20, color: iconColor);
    }

    final button = Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: borderColor),
        boxShadow: boxShadow,
      ),
      child: Center(child: iconWidget),
    );

    if (!isEnabled) {
      return button;
    }

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(onTap: widget.onPressed, child: button),
    );
  }
}
