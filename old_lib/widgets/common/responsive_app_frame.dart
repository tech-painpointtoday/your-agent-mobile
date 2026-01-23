import 'package:flutter/material.dart';

/// A responsive frame that supports mobile, tablet, and desktop views.
/// - Mobile (< 768px): Allows vertical scrolling, no horizontal scrolling
/// - Tablet (768px - 1024px): Allows horizontal scrolling if needed
/// - Desktop (> 1024px): Normal rendering
class ResponsiveAppFrame extends StatelessWidget {
  final Widget child;
  final double? mobileBreakpoint;
  final double? tabletBreakpoint;

  const ResponsiveAppFrame({
    super.key,
    required this.child,
    this.mobileBreakpoint = 768,
    this.tabletBreakpoint = 1024,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final maxWidth = constraints.maxWidth;
        final mobileBreakpoint = this.mobileBreakpoint ?? 768;
        final tabletBreakpoint = this.tabletBreakpoint ?? 1024;

        if (maxWidth < mobileBreakpoint) {
          // Mobile: Allow vertical scrolling only, let child handle responsive layout
          return child;
        } else if (maxWidth < tabletBreakpoint) {
          // Tablet: Allow horizontal scrolling if content exceeds viewport
          // Use a fixed minimum width to prevent infinite constraints
          return SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: SizedBox(
              width: maxWidth < 1024 ? 1024 : maxWidth,
              child: child,
            ),
          );
        }

        // Desktop: Normal rendering
        return child;
      },
    );
  }
}
