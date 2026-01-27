import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:youragent/core/di/dependency_injection.dart';
import 'package:youragent/core/theme/app_colors.dart';
import 'package:youragent/data/repositories/auth_repository_impl.dart';
import 'package:youragent/domain/entities/user.dart';
import 'package:youragent/l10n/app_localizations.dart';
import 'package:youragent/features/auth/bloc/auth_bloc.dart';
import 'package:youragent/features/auth/bloc/auth_event.dart';
import 'package:youragent/features/auth/bloc/auth_state.dart';
import 'web_wrapper/web_wrapper.dart' as web;

/// Google Sign-In button following the official example pattern
/// https://github.com/flutter/packages/blob/main/packages/google_sign_in/google_sign_in/example/lib/main.dart
class GoogleSignInButton extends StatefulWidget {
  final UserRole role;
  final bool isCompact;

  const GoogleSignInButton({
    super.key,
    required this.role,
    this.isCompact = false,
  });

  @override
  State<GoogleSignInButton> createState() => _GoogleSignInButtonState();
}

class _GoogleSignInButtonState extends State<GoogleSignInButton> {
  // Cache the web button to prevent recreation on rebuilds
  Widget? _cachedWebButton;

  // Get singleton GoogleSignIn instance from repository
  GoogleSignIn get _googleSignIn {
    final authRepo = DependencyInjection.authRepository;
    if (authRepo is AuthRepositoryImpl) {
      return authRepo.googleSignIn;
    }
    // Fallback: use instance directly if repository doesn't expose it
    return GoogleSignIn.instance;
  }

  @override
  Widget build(BuildContext context) {
    // Follow the official example pattern
    // Use singleton GoogleSignIn instance from repository
    try {
      // Check if supportsAuthenticate is available (may throw if not initialized)
      final supportsAuth = _googleSignIn.supportsAuthenticate();

      if (supportsAuth) {
        // Mobile platforms: show custom button that calls authenticate()
        return BlocSelector<AuthBloc, AuthState, bool>(
          selector: (state) => state is AuthLoading,
          builder: (context, isLoading) {
            return _buildMobileButton(context, isLoading);
          },
        );
      } else {
        // Web platform: use renderButton from google_sign_in_web
        if (kIsWeb) {
          // Cache the web button widget to prevent iframe recreation
          _cachedWebButton ??= _buildWebButton();
          return _cachedWebButton!;
        } else {
          // Fallback for unknown platforms
          return const Text(
            'This platform does not have a known authentication method',
          );
        }
      }
    } catch (e) {
      // If Google Sign-In is not initialized, show a disabled button or placeholder
      debugPrint('Google Sign-In not initialized: $e');
      return const SizedBox.shrink(); // Or show a placeholder/error message
    }
  }

  Widget _buildMobileButton(BuildContext context, bool isLoading) {
    final l10n = AppLocalizations.of(context)!;
    return SizedBox(
      width: widget.isCompact ? 48 : double.infinity,
      height: 48,
      child: OutlinedButton.icon(
        onPressed: isLoading
            ? null
            : () async {
                try {
                  // Set role before authentication (for stream handler)
                  context.read<AuthBloc>().add(SetRoleEvent(role: widget.role));
                  // Use singleton GoogleSignIn instance from repository
                  // Call authenticate() directly - authenticationEvents stream will handle it
                  await _googleSignIn.authenticate();
                } catch (e) {
                  // Error will be handled by authenticationEvents listener
                  debugPrint('Google Sign-In error: $e');
                }
              },
        icon: Image.asset(
          'assets/images/google-icon.png',
          width: 24,
          height: 24,
          errorBuilder: (context, error, stackTrace) {
            return const Icon(Icons.g_mobiledata, size: 24);
          },
        ),
        label: Text(
          l10n.sign_in_with_google,
          style: GoogleFonts.anuphan(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: AppColors.baseDarkGrey,
          ),
        ),
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: AppColors.bonJour),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
    );
  }

  Widget _buildWebButton() {
    // Build the web button once and cache it
    // This prevents the iframe from being recreated on every rebuild
    return SizedBox(
      width: widget.isCompact ? 40 : double.infinity,
      height: 48,
      child: web.renderButton(
        configuration: web.GSIButtonConfiguration(
          type: widget.isCompact
              ? web.GSIButtonType.icon
              : web.GSIButtonType.standard,
          theme: web.GSIButtonTheme.outline,
          size: web.GSIButtonSize.large,
          text: web.GSIButtonText.signinWith,
          shape: web.GSIButtonShape.rectangular,
          logoAlignment: web.GSIButtonLogoAlignment.left,
        ),
      ),
    );
  }
}
