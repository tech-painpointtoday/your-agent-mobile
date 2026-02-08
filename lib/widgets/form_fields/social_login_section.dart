import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_colors.dart';
import '../../features/auth/bloc/auth_bloc.dart';
import '../../features/auth/bloc/auth_event.dart';

import '../../domain/entities/user.dart';
import '../../l10n/app_localizations.dart';
import '../dialogs/status_dialog.dart';

/// Stubbed for mobile until social auth is wired.
class SocialLoginSection extends StatelessWidget {
  final UserRole role;
  const SocialLoginSection({super.key, required this.role});

  Future<void> _handleGoogleLogin(BuildContext context) async {
    final l10n = AppLocalizations.of(context);
    await StatusDialog.confirm(
      context: context,
      title: l10n.confirm,
      message: l10n.social_login_confirmation('Google'),
      confirmLabel: l10n.confirm,
      onConfirm: () {
        context.read<AuthBloc>().add(AuthSignInWithGoogleRequested(role: role));
      },
    );
  }

  Future<void> _handleFacebookLogin(BuildContext context) async {
    final l10n = AppLocalizations.of(context);
    await StatusDialog.confirm(
      context: context,
      title: l10n.confirm,
      message: l10n.social_login_confirmation('Facebook'),
      confirmLabel: l10n.confirm,
      onConfirm: () {
        context.read<AuthBloc>().add(
          AuthSignInWithFacebookRequested(role: role),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: Divider(color: AppColors.baseLightGrey, thickness: 1),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'หรือ',
                style: GoogleFonts.anuphan(
                  fontSize: 14,
                  color: AppColors.baseGrey,
                ),
              ),
            ),
            Expanded(
              child: Divider(color: AppColors.baseLightGrey, thickness: 1),
            ),
          ],
        ),
        const SizedBox(height: 24),
        Row(
          children: [
            Expanded(
              child: _SocialButton(
                icon: 'assets/logo/google.png',
                label: 'Google',
                onPressed: () => _handleGoogleLogin(context),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _SocialButton(
                icon:
                    'assets/logo/facebook.png', // Assuming asset exists, fallback to empty container or text if not
                label: 'Facebook',
                onPressed: () => _handleFacebookLogin(context),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _SocialButton extends StatelessWidget {
  final String icon;
  final String label;
  final VoidCallback onPressed;

  const _SocialButton({
    required this.icon,
    required this.label,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 12),
        side: const BorderSide(color: AppColors.baseLightGrey),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        backgroundColor: Colors.white,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            icon,
            height: 24,
            width: 24,
            errorBuilder: (context, error, stackTrace) =>
                const SizedBox(width: 24, height: 24),
          ),
          const SizedBox(width: 8),
          Text(
            label,
            style: GoogleFonts.anuphan(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: AppColors.baseBlack,
            ),
          ),
        ],
      ),
    );
  }
}
