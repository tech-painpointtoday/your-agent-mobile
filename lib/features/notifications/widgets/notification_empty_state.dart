import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:youragent/core/theme/app_colors.dart';
import 'package:youragent/l10n/app_localizations.dart';

class NotificationEmptyState extends StatelessWidget {
  const NotificationEmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Placeholder for empty state icon - you can add an SVG asset later
            Image.asset(
              'assets/images/YA_Illustration_EmptyState_NoNotification.png',
              fit: BoxFit.contain,
              width: 180,
              height: 180,
            ),
            const SizedBox(height: 24),

            Text(
              '${l10n.notifications_empty_title}\n${l10n.notifications_empty_subtitle}',
              textAlign: TextAlign.center,
              style: GoogleFonts.anuphan(
                fontSize: 14,
                color: AppColors.baseGrey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
