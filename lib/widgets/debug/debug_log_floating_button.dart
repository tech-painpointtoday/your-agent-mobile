import 'package:flutter/material.dart';
import 'package:youragent/core/config/app_config.dart';
import 'package:youragent/core/theme/app_colors.dart';
import 'package:youragent/widgets/debug/debug_log_overlay.dart';

/// Floating button to open debug logs
/// Only visible in DEV environment
class DebugLogFloatingButton extends StatelessWidget {
  const DebugLogFloatingButton({super.key});

  @override
  Widget build(BuildContext context) {
    // Only show in DEV environment
    if (!AppConfig.isDev) {
      return const SizedBox.shrink();
    }

    return Positioned(
      left: 16,
      bottom: 16,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => DebugLogOverlay.toggle(),
          borderRadius: BorderRadius.circular(24),
          child: Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppColors.primary,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppColors.black.withValues(alpha: 0.2),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: const Icon(Icons.bug_report, color: Colors.white, size: 24),
          ),
        ),
      ),
    );
  }
}
