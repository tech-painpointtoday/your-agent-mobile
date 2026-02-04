import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/theme/app_colors.dart';
import '../../../widgets/buttons/app_button.dart';
import '../../../widgets/dialogs/status_dialog.dart';
import '../../../widgets/form_fields/labeled_password_field.dart';
import '../../../widgets/modals/app_confirmation_bottom_sheet.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';
import 'package:youragent/l10n/app_localizations.dart';

class ResetPasswordScreen extends StatefulWidget {
  final String token;
  final String email;

  const ResetPasswordScreen({
    super.key,
    required this.token,
    required this.email,
  });

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _passwordController = TextEditingController();
  final _passwordConfirmationController = TextEditingController();

  @override
  void dispose() {
    _passwordController.dispose();
    _passwordConfirmationController.dispose();
    super.dispose();
  }

  void _onConfirmPressed() {
    if (!_formKey.currentState!.validate()) return;

    AppConfirmationBottomSheet.show(
      context: context,
      title: AppLocalizations.of(context)!.confirmPassword,
      description: AppLocalizations.of(context)!.confirmPasswordUseQuestion,
      confirmLabel: AppLocalizations.of(context)!.confirm,
      cancelLabel: AppLocalizations.of(context)!.statusCancelled,
      style: ConfirmationStyle.normal,
      onConfirm: () {
        context.read<AuthBloc>().add(
              AuthResetPasswordRequested(
                token: widget.token,
                email: widget.email,
                password: _passwordController.text,
                passwordConfirmation: _passwordConfirmationController.text,
              ),
            );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) async {
        if (state is AuthOperationState) {
          if (state.resetPasswordStatus == ResetPasswordStatus.success) {
            StatusDialog.showSuccess(
              context: context,
              title: AppLocalizations.of(context)!.successTitle,
              message: AppLocalizations.of(context)!.passwordSuccess,
              onDismiss: () {
                if (!mounted) return;
                context.go('/login');
              },
            );
          } else if (state.resetPasswordStatus == ResetPasswordStatus.failure) {
            StatusDialog.showError(
              context: context,
              title: AppLocalizations.of(context)!.errorOccurredTitle,
              message: state.errorMessage ?? AppLocalizations.of(context)!.resetPasswordFailed,
            );
          }
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.white,
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: IconButton(
                      onPressed: () => context.pop(),
                      icon: const Icon(Icons.arrow_back_ios_new_rounded),
                    ),
                  ),
                  SizedBox(height: 24),
                  // Illustration
                  Center(
                    child: Image.asset(
                      'assets/images/auth/password_reset.png',
                      width: 150,
                      height: 150,
                    ),
                  ),
                  SizedBox(height: 32),
                  // Title
                  Text(
                    AppLocalizations.of(context)!.resetPasswordTitle,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.anuphan(
                      fontSize: 28,
                      fontWeight: FontWeight.w700,
                      color: AppColors.baseDarkGrey,
                    ),
                  ),
                  SizedBox(height: 8),
                  // Subtitle
                  Text(
                    AppLocalizations.of(context)!.setNewPasswordPrompt,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.anuphan(
                      fontSize: 14,
                      color: AppColors.baseDarkGrey,
                    ),
                  ),
                  SizedBox(height: 32),
                  // Password Fields
                  LabeledPasswordField(
                    label: AppLocalizations.of(context)!.newPasswordLabel,
                    controller: _passwordController,
                    validator: (v) {
                      if (v == null || v.isEmpty) {
                        return AppLocalizations.of(context)!.enterNewPasswordPrompt;
                      }
                      if (v.length < 6) {
                        return AppLocalizations.of(context)!.enterNewPasswordPrompt;
                      }
                      return null;
                    },
                  ),
                  LabeledPasswordField(
                    label: AppLocalizations.of(context)!.confirmNewPasswordHint,
                    controller: _passwordConfirmationController,
                    compareController: _passwordController,
                    validator: (v) {
                      if (v == null || v.isEmpty) {
                        return AppLocalizations.of(context)!.confirmNewPasswordHint;
                      }
                      if (v != _passwordController.text) {
                        return AppLocalizations.of(context)!.passwordMismatchTitle;
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 32),
                  // Submit Button
                  AppButton(
                    text:
                        AppLocalizations.of(context)!.sendResetPasswordLink, // Using exact text from image
                    style: AppButtonStyle.primary,
                    onPressed: _onConfirmPressed,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
