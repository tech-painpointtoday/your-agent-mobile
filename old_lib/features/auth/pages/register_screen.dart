import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:youragent/l10n/app_localizations.dart';
import 'package:youragent/core/theme/app_colors.dart';
import 'package:youragent/domain/entities/user.dart';
import 'package:youragent/features/auth/bloc/auth_bloc.dart';
import 'package:youragent/features/auth/bloc/auth_event.dart';
import 'package:youragent/features/auth/bloc/auth_state.dart';
import 'package:youragent/utils/auth_landing_mixin.dart';
import 'package:youragent/widgets/register_forms/standard_register_form.dart';
import 'package:youragent/widgets/register_forms/business_register_form.dart';
import 'package:go_router/go_router.dart';
import 'package:youragent/features/auth/widgets/auth_header.dart';
// import 'package:youragent/widgets/footer.dart';

class RegisterScreen extends StatefulWidget {
  final UserRole role;
  final Function(Locale) changeLocale;

  const RegisterScreen({
    super.key,
    required this.role,
    required this.changeLocale,
  });

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> with AuthLandingMixin {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  // Business-specific controllers (for agent and agency)
  final _phoneController = TextEditingController();
  final _companyController = TextEditingController();
  // Policy checkboxes state (only for non-admin roles)
  bool _termsAccepted = false;
  bool _privacyAccepted = false;

  @override
  void initState() {
    super.initState();
    // Set the role for next sign-in
    context.read<AuthBloc>().add(SetRoleEvent(role: widget.role));

    // Check authentication status on app landing (like app landing logic)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      checkAuthStatusOnLanding();
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _phoneController.dispose();
    _companyController.dispose();
    super.dispose();
  }

  String get _title {
    final l10n = AppLocalizations.of(context)!;
    switch (widget.role) {
      case UserRole.agent:
        return l10n.register_agent_title;
      case UserRole.agency:
        return l10n.register_agency_title;
    }
  }

  void _handleRegister() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Agency uses standard registration
    if (widget.role == UserRole.agency) {
      context.read<AuthBloc>().add(
        RegisterWithEmailEvent(
          name: _nameController.text.trim(),
          email: _emailController.text.trim(),
          password: _passwordController.text,
          role: widget.role,
        ),
      );
    }
  }

  void _handleBusinessRegister(String businessType) {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Agent registration - only requires name, email, password, password_confirmation
    if (widget.role == UserRole.agent) {
      context.read<AuthBloc>().add(
        RegisterAgentEvent(
          name: _nameController.text.trim(),
          email: _emailController.text.trim(),
          password: _passwordController.text,
          passwordConfirmation: _confirmPasswordController.text,
        ),
      );
    } else if (widget.role == UserRole.agency) {
      // Agency uses standard registration for now (can be extended later)
      context.read<AuthBloc>().add(
        RegisterWithEmailEvent(
          name: _nameController.text.trim(),
          email: _emailController.text.trim(),
          password: _passwordController.text,
          role: widget.role,
        ),
      );
    }
  }

  void _handleNavigation(BuildContext context, AuthState state) {
    // Handle navigation after authentication events
    if (state is Authenticated && mounted) {
      // After registration, redirect to email verification pending screen
      final email = _emailController.text.trim();
      context.go('/email-verification-pending?email=$email');
    } else if (state is AuthError && mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(state.message)));
    }
    // Note: Unauthenticated state is handled by router redirect logic
    // The checkAuthStatusOnLanding() method (from AuthLandingMixin) handles app landing logic
  }

  void _handleRoleChange(UserRole newRole) {
    if (newRole != widget.role) {
      context.go('/register/${newRole.name}');
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return BlocListener<AuthBloc, AuthState>(
      listener: _handleNavigation,
      child: Scaffold(
        backgroundColor: AppColors.white,
        body: SafeArea(
          child: Column(
            children: [
              // Header with shadow
              Card(
                elevation: 8,
                margin: EdgeInsets.zero,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.zero,
                ),
                child: AuthHeader(
                  changeLocale: widget.changeLocale,
                  currentRole: widget.role,
                  onRoleChanged: _handleRoleChange,
                ),
              ),

              // Main Content
              Expanded(
                child: Center(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(24),
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 500),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Icon above title
                          Image.asset(
                            'assets/icons/${widget.role.name}_profile.png',
                            width: 80,
                            height: 80,
                          ),
                          const SizedBox(height: 24),

                          // Title
                          Text(
                            _title,
                            style: GoogleFonts.anuphan(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              color: AppColors.eerieBlack,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 32),

                          // Register Form - Use role-specific form widget
                          (widget.role == UserRole.agent ||
                                  widget.role == UserRole.agency)
                              ? BusinessRegisterForm(
                                  formKey: _formKey,
                                  nameController: _nameController,
                                  emailController: _emailController,
                                  phoneController: _phoneController,
                                  companyController: _companyController,
                                  passwordController: _passwordController,
                                  confirmPasswordController:
                                      _confirmPasswordController,
                                  onRegister: _handleBusinessRegister,
                                  isAgent: widget.role == UserRole.agent,
                                  role: widget.role,
                                  termsAccepted: _termsAccepted,
                                  privacyAccepted: _privacyAccepted,
                                  onTermsChanged: (value) {
                                    setState(() {
                                      _termsAccepted = value;
                                    });
                                  },
                                  onPrivacyChanged: (value) {
                                    setState(() {
                                      _privacyAccepted = value;
                                    });
                                  },
                                )
                              : BlocBuilder<AuthBloc, AuthState>(
                                  builder: (context, state) {
                                    final isLoading = state is AuthLoading;
                                    return StandardRegisterForm(
                                      formKey: _formKey,
                                      nameController: _nameController,
                                      emailController: _emailController,
                                      passwordController: _passwordController,
                                      confirmPasswordController:
                                          _confirmPasswordController,
                                      onRegister: _handleRegister,
                                      isLoading: isLoading,
                                      role: widget.role,
                                      termsAccepted: _termsAccepted,
                                      privacyAccepted: _privacyAccepted,
                                      onTermsChanged: (value) {
                                        setState(() {
                                          _termsAccepted = value;
                                        });
                                      },
                                      onPrivacyChanged: (value) {
                                        setState(() {
                                          _privacyAccepted = value;
                                        });
                                      },
                                    );
                                  },
                                ),
                          const SizedBox(height: 24),

                          // Login Link
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                l10n.already_have_account,
                                style: GoogleFonts.anuphan(
                                  fontSize: 14,
                                  color: AppColors.shadyLady,
                                ),
                              ),
                              TextButton(
                                onPressed: () {
                                  final roleParam = widget.role.name;
                                  context.go('/login/$roleParam');
                                },
                                child: Text(
                                  l10n.login_now,
                                  style: GoogleFonts.anuphan(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.alizarinCrimson,
                                    decoration: TextDecoration.underline,
                                    decorationColor: AppColors.alizarinCrimson,
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
              ),

              // Footer
              // const Footer(bgColor: AppColors.white),
            ],
          ),
        ),
      ),
    );
  }
}
