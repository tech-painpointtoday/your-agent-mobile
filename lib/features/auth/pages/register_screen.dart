import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../domain/entities/user.dart';
import '../../../l10n/app_localizations.dart';
import '../../../widgets/register_forms/register_form.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';
import 'package:youragent/l10n/app_localizations.dart';

class RegisterScreen extends StatefulWidget {
  final Function(Locale) changeLocale;

  const RegisterScreen({super.key, required this.changeLocale});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _companyController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  UserRole _role = UserRole.agent;
  bool _termsAccepted = false;
  bool _privacyAccepted = false;

  @override
  void initState() {
    super.initState();
    context.read<AuthBloc>().add(SetRoleEvent(role: _role));
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _companyController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _handleRoleChange(UserRole newRole) {
    if (newRole == _role) return;
    setState(() => _role = newRole);
    context.read<AuthBloc>().add(SetRoleEvent(role: _role));
  }

  void _register(String businessType) {
    if (!_formKey.currentState!.validate()) return;
    if (!_termsAccepted || !_privacyAccepted) return;
    // For now, API only accepts name, email, password, passwordConfirmation
    // Phone, business type, and company name are collected but not sent yet
    context.read<AuthBloc>().add(
      RegisterAgentEvent(
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
        password: _passwordController.text,
        passwordConfirmation: _confirmPasswordController.text,
      ),
    );
  }

  void _listener(BuildContext context, AuthState state) {
    if (state is Authenticated) {
      final email = _emailController.text.trim();
      context.go(
        '/email-verification-pending?email=${Uri.encodeComponent(email)}',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return BlocListener<AuthBloc, AuthState>(
      listener: _listener,
      child: Scaffold(
        backgroundColor: AppColors.white,
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 12),
                Center(
                  child: Image.asset(
                    'assets/images/sign_up/YA_Illustration_SignUp.png',
                    width: 180,
                    height: 180,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  AppLocalizations.of(context).register_button,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w600,
                    color: AppColors.baseBlack,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  AppLocalizations.of(context).registerToStart,
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14, color: AppColors.baseGrey),
                ),
                const SizedBox(height: 18),
                // Role segmented switch (same style as login)
                Row(
                  children: [
                    Expanded(
                      child: InkWell(
                        borderRadius: BorderRadius.circular(12),
                        onTap: () => _handleRoleChange(UserRole.agent),
                        child: Container(
                          height: 44,
                          decoration: BoxDecoration(
                            color: _role == UserRole.agent
                                ? AppColors.buttonLightGreen
                                : AppColors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: _role == UserRole.agent
                                ? Border.all(color: const Color(0xFF32A792))
                                : null,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SvgPicture.asset(
                                'assets/icons/user.svg',
                                width: 16,
                                height: 16,
                                colorFilter: ColorFilter.mode(
                                  _role == UserRole.agent
                                      ? AppColors.jungleGreen
                                      : AppColors.baseDarkGrey,
                                  BlendMode.srcIn,
                                ),
                              ),

                              const SizedBox(width: 8),
                              Text(
                                AppLocalizations.of(context).forAgent,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  color: _role == UserRole.agent
                                      ? AppColors.jungleGreen
                                      : AppColors.baseDarkGrey,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: InkWell(
                        borderRadius: BorderRadius.circular(12),
                        onTap: () => _handleRoleChange(UserRole.agency),
                        child: Container(
                          height: 44,
                          decoration: BoxDecoration(
                            color: _role == UserRole.agency
                                ? AppColors.buttonLightGreen
                                : AppColors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: _role == UserRole.agency
                                ? Border.all(color: const Color(0xFF32A792))
                                : null,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SvgPicture.asset(
                                'assets/icons/building.svg',
                                width: 16,
                                height: 16,
                                colorFilter: ColorFilter.mode(
                                  _role == UserRole.agency
                                      ? AppColors.jungleGreen
                                      : AppColors.baseDarkGrey,
                                  BlendMode.srcIn,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                AppLocalizations.of(context).forAgency,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  color: _role == UserRole.agency
                                      ? AppColors.jungleGreen
                                      : AppColors.baseDarkGrey,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                BlocBuilder<AuthBloc, AuthState>(
                  builder: (context, state) {
                    final loading = state is AuthLoading;
                    return RegisterForm(
                      formKey: _formKey,
                      nameController: _nameController,
                      emailController: _emailController,
                      phoneController: _phoneController,
                      companyController: _companyController,
                      passwordController: _passwordController,
                      confirmPasswordController: _confirmPasswordController,
                      onRegister: _register,
                      role: _role,
                      termsAccepted: _termsAccepted,
                      privacyAccepted: _privacyAccepted,
                      onTermsChanged: (v) => setState(() => _termsAccepted = v),
                      onPrivacyChanged: (v) =>
                          setState(() => _privacyAccepted = v),
                      isLoading: loading,
                    );
                  },
                ),
                const SizedBox(height: 36),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      l10n.already_have_account,
                      style: TextStyle(color: AppColors.baseGrey),
                    ),
                    TextButton(
                      onPressed: () => context.go('/login'),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: Text(
                        l10n.login_now,
                        style: TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
