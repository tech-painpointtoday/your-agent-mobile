import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/theme/app_colors.dart';

class NotificationEmptyState extends StatelessWidget {
  final String title;
  final String message;

  const NotificationEmptyState({
    super.key,
    required this.title,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Placeholder for empty state icon - you can add an SVG asset later
            Icon(Icons.notifications_none, size: 80, color: AppColors.baseGrey),
            const SizedBox(height: 24),
            Text(
              title,
              textAlign: TextAlign.center,
              style: GoogleFonts.anuphan(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.baseDarkGrey,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: GoogleFonts.anuphan(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppColors.baseDarkGrey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
