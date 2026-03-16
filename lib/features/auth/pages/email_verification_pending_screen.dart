import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../widgets/buttons/app_button.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';
import 'package:yourhome/l10n/app_localizations.dart';
import 'package:yourhome/widgets/dialogs/status_dialog.dart';

class EmailVerificationPendingScreen extends StatelessWidget {
  final String email;
  const EmailVerificationPendingScreen({super.key, required this.email});

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthOperationState) {
          if (state.resendEmailStatus == ResendEmailStatus.success) {
            StatusDialog.showSuccess(
              context: context,
              title: AppLocalizations.of(context).emailSentSuccessfully,
            );
          } else if (state.resendEmailStatus == ResendEmailStatus.failure) {
            StatusDialog.showError(
              context: context,
              title: AppLocalizations.of(context).errorOccurredTitle,
              message:
                  state.resendEmailError ??
                  AppLocalizations.of(context).submitEmail,
            );
          }
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.white,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: IconButton(
                    onPressed: () => context.go('/login'),
                    icon: SvgPicture.asset(
                      'assets/icons/chevron-left.svg',
                      width: 24,
                      height: 24,
                      colorFilter: const ColorFilter.mode(
                        AppColors.baseGrey,
                        BlendMode.srcIn,
                      ),
                    ),
                  ),
                ),
                const Spacer(),
                // Illustration placeholder
                Center(
                  child: Image.asset(
                    'assets/images/sign_in/YA_Illustration_VerifyEmail.png',
                    width: 170,
                    height: 170,
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  AppLocalizations.of(context).confirmEmail,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    color: AppColors.baseDarkGrey,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  AppLocalizations.of(context).confirmSubmitEmail(email),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.baseGrey,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 18),
                BlocBuilder<AuthBloc, AuthState>(
                  builder: (context, state) {
                    final isLoading =
                        state is AuthOperationState &&
                        state.resendEmailStatus == ResendEmailStatus.loading;
                    return AppButton(
                      width: double.infinity,
                      text: AppLocalizations.of(context).resendLink,
                      style: AppButtonStyle.primary,
                      isLoading: isLoading,
                      onPressed: () => context.read<AuthBloc>().add(
                        AuthResendVerificationPublicRequested(email: email),
                      ),
                    );
                  },
                ),
                const Spacer(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
