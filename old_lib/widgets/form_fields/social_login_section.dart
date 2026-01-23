import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:youragent/l10n/app_localizations.dart';
import 'package:youragent/core/theme/app_colors.dart';
import 'package:youragent/domain/entities/user.dart';
import '../google_sign_in_button.dart';
import '../facebook_sign_in_button.dart';

/// Reusable social login section with OR divider and Google/Facebook buttons
class SocialLoginSection extends StatelessWidget {
  final UserRole role;

  const SocialLoginSection({super.key, required this.role});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Column(
      children: [
        const SizedBox(height: 24),

        // OR Divider
        Row(
          children: [
            const Expanded(child: Divider(color: AppColors.bonJour)),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                l10n.or,
                style: GoogleFonts.anuphan(
                  fontSize: 14,
                  color: AppColors.shadyLady,
                ),
              ),
            ),
            const Expanded(child: Divider(color: AppColors.bonJour)),
          ],
        ),
        const SizedBox(height: 24),

        // Social Buttons
        Row(
          children: [
            Expanded(child: GoogleSignInButton(role: role, isCompact: false)),
            const SizedBox(width: 16),
            Expanded(child: FacebookSignInButton(role: role, isCompact: false)),
          ],
        ),
      ],
    );
  }
}
