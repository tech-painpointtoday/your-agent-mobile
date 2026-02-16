import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../l10n/app_localizations.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';
import 'package:youragent/widgets/buttons/app_button.dart';
import 'package:youragent/widgets/inputs/app_text_field.dart';
import 'package:youragent/widgets/dialogs/status_dialog.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    context.read<AuthBloc>().add(
      AuthForgotPasswordRequested(email: _emailController.text.trim()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthOperationState) {
          if (state.forgotPasswordStatus == ForgotPasswordStatus.success) {
            StatusDialog.showSuccess(
              context: context,
              title: AppLocalizations.of(context).submitPassword,
            );
          } else if (state.forgotPasswordStatus ==
              ForgotPasswordStatus.failure) {
            StatusDialog.showError(
              context: context,
              title: AppLocalizations.of(context).errorOccurredTitle,
              message:
                  state.errorMessage ??
                  AppLocalizations.of(context).submitEmail,
            );
          }
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.white,
        body: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          behavior: HitTestBehavior.translucent,
          child: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
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
                  const SizedBox(height: 8),
                  Center(
                    child: Image.asset(
                      'assets/images/sign_in/YA_Illustration_ForgotPassword.png',
                      width: 160,
                      height: 160,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    AppLocalizations.of(context).forgot_password,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      color: AppColors.baseDarkGrey,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    AppLocalizations.of(context).enterRegisteredEmailHint,
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 14, color: AppColors.baseGrey),
                  ),
                  const SizedBox(height: 20),
                  Form(
                    key: _formKey,
                    child: AppTextField(
                      label: l10n.email,
                      hintText: l10n.email,
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      prefix: Padding(
                        padding: const EdgeInsets.all(16),
                        child: SvgPicture.asset(
                          'assets/icons/email.svg',
                          width: 16,
                          height: 16,
                          fit: BoxFit.scaleDown,
                          colorFilter: const ColorFilter.mode(
                            AppColors.baseGrey,
                            BlendMode.srcIn,
                          ),
                        ),
                      ),
                      validator: (v) {
                        if (v == null || v.isEmpty) return l10n.enter_email;
                        if (!v.contains('@')) return l10n.enter_valid_email;
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(height: 16),
                  BlocBuilder<AuthBloc, AuthState>(
                    builder: (context, state) {
                      final loading =
                          state is AuthOperationState &&
                          state.forgotPasswordStatus ==
                              ForgotPasswordStatus.loading;
                      return AppButton(
                        width: double.infinity,
                        height: 52,
                        isLoading: loading,
                        style: AppButtonStyle.primary,
                        text: AppLocalizations.of(
                          context,
                        ).sendResetPasswordLink,
                        onPressed: _submit,
                      );
                    },
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
