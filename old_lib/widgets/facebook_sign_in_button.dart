import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:youragent/core/theme/app_colors.dart';
import 'package:youragent/domain/entities/user.dart';
import 'package:youragent/l10n/app_localizations.dart';
import 'package:youragent/features/auth/bloc/auth_bloc.dart';
import 'package:youragent/features/auth/bloc/auth_event.dart';
import 'package:youragent/features/auth/bloc/auth_state.dart';

class FacebookSignInButton extends StatelessWidget {
  final UserRole role;
  final bool isCompact;

  const FacebookSignInButton({
    super.key,
    required this.role,
    this.isCompact = false,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return BlocSelector<AuthBloc, AuthState, bool>(
      selector: (state) => state is AuthLoading,
      builder: (context, isLoading) {
        // Web Style (Matches Google renderButton)
        if (kIsWeb) {
          return SizedBox(
            height: 40, // Match Google 'large' size
            width: isCompact ? 40 : double.infinity,
            child: OutlinedButton(
              onPressed: isLoading
                  ? null
                  : () {
                      context.read<AuthBloc>().add(
                        SignInWithFacebookEvent(role: role),
                      );
                    },
              style: OutlinedButton.styleFrom(
                padding: EdgeInsets.zero,
                side: const BorderSide(color: AppColors.bonJour),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: isCompact
                  ? const Icon(
                      Icons.facebook,
                      size: 20,
                      color: Color(0xFF1877F2),
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.facebook,
                          size: 20,
                          color: Color(0xFF1877F2),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          l10n.sign_in_with_facebook,
                          style: GoogleFonts.roboto(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: AppColors.eerieBlack,
                          ),
                        ),
                      ],
                    ),
            ),
          );
        }

        // Mobile Style (Matches custom Google button)
        return SizedBox(
          width: isCompact ? 48 : double.infinity,
          height: 48,
          child: OutlinedButton(
            onPressed: isLoading
                ? null
                : () {
                    context.read<AuthBloc>().add(
                      SignInWithFacebookEvent(role: role),
                    );
                  },
            style: OutlinedButton.styleFrom(
              padding: EdgeInsets.zero,
              side: const BorderSide(color: AppColors.bonJour),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: isCompact
                ? const Icon(Icons.facebook, size: 24, color: Color(0xFF1877F2))
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.facebook,
                        size: 24,
                        color: Color(0xFF1877F2),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        l10n.sign_in_with_facebook,
                        style: GoogleFonts.anuphan(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: AppColors.eerieBlack,
                        ),
                      ),
                    ],
                  ),
          ),
        );
      },
    );
  }
}
