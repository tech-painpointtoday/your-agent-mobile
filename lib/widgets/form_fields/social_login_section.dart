import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../../core/theme/app_colors.dart';
import '../../features/auth/bloc/auth_bloc.dart';
import '../../features/auth/bloc/auth_event.dart';
import '../dialogs/status_dialog.dart';

import '../../domain/entities/user.dart';

/// Stubbed for mobile until social auth is wired.
class SocialLoginSection extends StatelessWidget {
  final UserRole role;
  const SocialLoginSection({super.key, required this.role});

  Future<void> _handleGoogleLogin(BuildContext context) async {
    try {
      final googleSignIn = GoogleSignIn(scopes: ['email', 'profile']);

      // Force account selection
      await googleSignIn.signOut();

      final result = await googleSignIn.signIn();
      if (result == null) return; // User canceled

      final auth = await result.authentication;
      final token = auth.accessToken ?? auth.idToken;

      if (token != null && context.mounted) {
        context.read<AuthBloc>().add(
          AuthSocialLoginRequested(
            provider: 'google',
            token: token,
            role: role,
          ),
        );
      }
    } catch (e) {
      debugPrint('Google Signin Error: $e');
      if (context.mounted) {
        StatusDialog.showError(
          context: context,
          title: 'Google Login Failed',
          message: e.toString(),
        );
      }
    }
  }

  Future<void> _handleFacebookLogin(BuildContext context) async {
    try {
      final result = await FacebookAuth.instance.login();

      if (result.status == LoginStatus.success) {
        final token = result.accessToken!.tokenString;
        if (context.mounted) {
          context.read<AuthBloc>().add(
            AuthSocialLoginRequested(
              provider: 'facebook',
              token: token,
              role: role,
            ),
          );
        }
      } else if (result.status == LoginStatus.cancelled) {
        // do nothing
      } else {
        if (context.mounted) {
          StatusDialog.showError(
            context: context,
            title: 'Facebook Login Failed',
            message: result.message ?? 'Unknown error',
          );
        }
      }
    } catch (e) {
      debugPrint('Facebook Signin Error: $e');
      if (context.mounted) {
        StatusDialog.showError(
          context: context,
          title: 'Facebook Login Failed',
          message: e.toString(),
        );
      }
    }
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
                'หรือเข้าสู่ระบบด้วย',
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
                icon: 'assets/icons/google-icon.png',
                label: 'Google',
                onPressed: () => _handleGoogleLogin(context),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _SocialButton(
                icon:
                    'assets/icons/form/facebook-icon.png', // Assuming asset exists, fallback to empty container or text if not
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
              fontWeight: FontWeight.w600,
              color: AppColors.baseBlack,
            ),
          ),
        ],
      ),
    );
  }
}
