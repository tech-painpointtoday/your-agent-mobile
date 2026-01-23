import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:youragent/l10n/app_localizations.dart';
import 'package:youragent/core/theme/app_colors.dart';
import 'package:youragent/domain/entities/user.dart';
import 'package:youragent/features/auth/bloc/auth_bloc.dart';
import 'package:youragent/features/auth/bloc/auth_event.dart';
import 'package:youragent/features/auth/bloc/auth_state.dart';
import 'package:youragent/utils/auth_landing_mixin.dart';
import 'package:go_router/go_router.dart';

import 'package:youragent/features/auth/widgets/auth_header.dart';
// import 'package:youragent/widgets/footer.dart';
import 'package:youragent/services/credentials_storage_service.dart';
import 'package:youragent/widgets/dialogs/status_dialog.dart';
import 'package:youragent/core/di/dependency_injection.dart';
import 'package:youragent/data/models/user_profile_model.dart';

class LoginScreen extends StatefulWidget {
  final UserRole role;
  final Function(Locale) changeLocale;

  const LoginScreen({
    super.key,
    required this.role,
    required this.changeLocale,
  });

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with AuthLandingMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _rememberMe = false;
  bool _obscurePassword = true;

  @override
  void initState() {
    super.initState();
    // Set the role for next sign-in
    context.read<AuthBloc>().add(SetRoleEvent(role: widget.role));

    // Load saved credentials if remember me was enabled
    _loadSavedCredentials();

    // Check authentication status on app landing (like app landing logic)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      checkAuthStatusOnLanding();
    });
  }

  /// Load saved credentials from secure storage
  Future<void> _loadSavedCredentials() async {
    try {
      final credentialsService = CredentialsStorageService();
      final rememberMeEnabled = await credentialsService.isRememberMeEnabled();

      if (rememberMeEnabled) {
        final email = await credentialsService.getSavedEmail();

        // Only load email, password is never stored for security
        if (mounted && email != null) {
          setState(() {
            _emailController.text = email;
            // Password field is intentionally left empty
            _passwordController.clear();
            _rememberMe = true;
          });
        }
      }
    } catch (e) {
      debugPrint('Error loading saved credentials: $e');
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  String get _title {
    final l10n = AppLocalizations.of(context)!;
    switch (widget.role) {
      case UserRole.agent:
        return l10n.login_agent_title;
      case UserRole.agency:
        return l10n.login_agency_title;
    }
  }

  void _handleEmailSignIn() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    context.read<AuthBloc>().add(
      SignInWithEmailEvent(
        email: _emailController.text.trim(),
        password: _passwordController.text,
        role: widget.role,
        rememberMe: _rememberMe,
      ),
    );
  }

  /// Check if both email and password fields have values
  bool _canSubmit() {
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    return email.isNotEmpty && password.isNotEmpty;
  }

  /// Handle field submission - submit login if both fields have values
  void _handleFieldSubmitted(String value) {
    if (_canSubmit()) {
      _handleEmailSignIn();
    }
  }

  /// Debug mode: Quick login with mock credentials
  void _handleDebugLogin() {
    _emailController.text = 'agent@example.com';
    _passwordController.text = 'password123';
    // _handleEmailSignIn();
  }

  void _handleRoleChange(UserRole newRole) {
    if (newRole != widget.role) {
      context.go('/login/${newRole.name}');
    }
  }

  void _handleNavigation(BuildContext context, AuthState state) async {
    // Handle navigation after authentication events
    // Note: Router redirect will handle navigation automatically, so we don't navigate here
    // This prevents double navigation (router + manual navigation)
    
    // Handle email not verified - redirect to verification pending screen
    if (state is EmailNotVerified && mounted) {
      context.go('/email-verification-pending?email=${state.email}');
      return;
    }
    
    if (state is AuthError && mounted) {
      final l10n = AppLocalizations.of(context)!;
      await StatusDialog.showError(
        context: context,
        title: l10n.login_error,
        message: state.message,
      );
    }

    // Handle forgot password status
    if (state is AuthOperationState && mounted) {
      if (state.forgotPasswordStatus == ForgotPasswordStatus.success) {
        await StatusDialog.showSuccess(
          context: context,
          title: 'ส่งอีเมลสำเร็จ',
          message: 'กรุณาตรวจสอบอีเมลของคุณเพื่อรีเซ็ตรหัสผ่าน',
        );
      } else if (state.forgotPasswordStatus == ForgotPasswordStatus.failure) {
        await StatusDialog.showError(
          context: context,
          title: 'เกิดข้อผิดพลาด',
          message: state.errorMessage ?? 'ไม่สามารถส่งอีเมลได้',
        );
      }
    }

    // Clear password field after successful login and check email verification
    if (state is Authenticated && mounted) {
      _passwordController.clear();
      
      // Check if email is verified
      try {
        // Wait a bit for profile to be saved after login
        await Future.delayed(const Duration(milliseconds: 500));
        
        // Fetch user profile to check email verification status
        final userData = await DependencyInjection.authApiService.getCurrentUser();
        final userProfile = UserProfileModel.fromJson(userData);
        
        // If email is not verified, redirect to email verification pending screen
        if (!userProfile.isEmailVerified && mounted) {
          final email = _emailController.text.trim();
          context.go('/email-verification-pending?email=$email');
          return;
        }
      } catch (e) {
        // If we can't fetch profile, proceed with normal navigation
        // The router will handle navigation to dashboard
        debugPrint('⚠️ Failed to check email verification status: $e');
      }
    }
    // Note: Navigation is handled by router redirect logic in app/router.dart
    // The checkAuthStatusOnLanding() method (from AuthLandingMixin) handles app landing logic
  }

  void _showForgotPasswordDialog(BuildContext context) {
    final emailController = TextEditingController();
    final formKey = GlobalKey<FormState>();
    final l10n = AppLocalizations.of(context)!;

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppColors.white,
        title: Text('ลืมรหัสผ่าน'),
        content: Form(
          key: formKey,
          child: TextFormField(
            controller: emailController,
            keyboardType: TextInputType.emailAddress,
            decoration: InputDecoration(
              labelText: l10n.email,
              hintText: 'กรุณากรอกอีเมลของคุณ',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return l10n.enter_email;
              }
              if (!value.contains('@')) {
                return l10n.enter_valid_email;
              }
              return null;
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: Text('ยกเลิก'),
          ),
          ElevatedButton(
            onPressed: () {
              if (formKey.currentState!.validate()) {
                Navigator.of(dialogContext).pop();
                context.read<AuthBloc>().add(
                  AuthForgotPasswordRequested(
                    email: emailController.text.trim(),
                  ),
                );
              }
            },
            child: Text('ส่งอีเมล'),
          ),
        ],
      ),
    );
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
              AuthHeader(
                changeLocale: widget.changeLocale,
                currentRole: widget.role,
                onRoleChanged: _handleRoleChange,
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

                          // Login Form
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(
                              0,
                            ), // Removed padding/card style to match design cleaner look?
                            // Actually design shows a clean form, maybe no white card background?
                            // The image shows a white background for the whole page (or very light grey), and the inputs are on it.
                            // It doesn't look like a card.
                            child: Form(
                              key: _formKey,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Email Field
                                  TextFormField(
                                    controller: _emailController,
                                    keyboardType: TextInputType.emailAddress,
                                    textInputAction: TextInputAction.next,
                                    onFieldSubmitted: (value) {
                                      // Move focus to password field
                                      FocusScope.of(context).nextFocus();
                                    },
                                    decoration: InputDecoration(
                                      hintText: l10n.email,
                                      prefixIcon: const Icon(
                                        Icons.email_outlined,
                                        color: AppColors.shadyLady,
                                      ),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: const BorderSide(
                                          color: AppColors.bonJour,
                                        ),
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: const BorderSide(
                                          color: AppColors.bonJour,
                                        ),
                                      ),
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                            horizontal: 16,
                                            vertical: 12,
                                          ),
                                      filled: true,
                                      fillColor: AppColors.white,
                                    ),
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return l10n.enter_email;
                                      }
                                      if (!value.contains('@')) {
                                        return l10n.enter_valid_email;
                                      }
                                      return null;
                                    },
                                  ),
                                  const SizedBox(height: 16),

                                  // Password Field
                                  TextFormField(
                                    controller: _passwordController,
                                    obscureText: _obscurePassword,
                                    textInputAction: TextInputAction.done,
                                    onFieldSubmitted: _handleFieldSubmitted,
                                    decoration: InputDecoration(
                                      hintText: l10n.password,
                                      prefixIcon: Padding(
                                        padding: const EdgeInsets.all(12),
                                        child: SvgPicture.asset(
                                          'assets/icons/key.svg',
                                          width: 20,
                                          height: 20,
                                          colorFilter: const ColorFilter.mode(
                                            AppColors.shadyLady,
                                            BlendMode.srcIn,
                                          ),
                                        ),
                                      ),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: const BorderSide(
                                          color: AppColors.bonJour,
                                        ),
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: const BorderSide(
                                          color: AppColors.bonJour,
                                        ),
                                      ),
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                            horizontal: 16,
                                            vertical: 12,
                                          ),
                                      filled: true,
                                      fillColor: AppColors.white,
                                      suffixIcon: IconButton(
                                        icon: SvgPicture.asset(
                                          _obscurePassword
                                              ? 'assets/icons/form/eye-off.svg'
                                              : 'assets/icons/form/eye.svg',
                                          colorFilter: const ColorFilter.mode(
                                            AppColors.shadyLady,
                                            BlendMode.srcIn,
                                          ),
                                          width: 24,
                                          height: 24,
                                        ),
                                        onPressed: () {
                                          setState(() {
                                            _obscurePassword =
                                                !_obscurePassword;
                                          });
                                        },
                                      ),
                                    ),
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return l10n.enter_password;
                                      }
                                      if (value.length < 6) {
                                        return l10n.password_length_error;
                                      }
                                      return null;
                                    },
                                  ),
                                  const SizedBox(height: 16),

                                  // Remember me and Forgot password row
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      InkWell(
                                        onTap: () {
                                          setState(() {
                                            _rememberMe = !_rememberMe;
                                          });
                                        },
                                        child: Row(
                                          children: [
                                            SizedBox(
                                              width: 24,
                                              height: 24,
                                              child: Checkbox(
                                                value: _rememberMe,
                                                onChanged: (value) {
                                                  setState(() {
                                                    _rememberMe =
                                                        value ?? false;
                                                  });
                                                },
                                                activeColor: AppColors.primary,
                                                side: const BorderSide(
                                                  color: AppColors.bonJour,
                                                ),
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(4),
                                                ),
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            Text(
                                              l10n.remember_me,
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .titleSmall
                                                  ?.copyWith(
                                                    color: AppColors.eerieBlack,
                                                  ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      TextButton(
                                        onPressed: () =>
                                            _showForgotPasswordDialog(context),
                                        child: Text(
                                          l10n.forgot_password,
                                          style: Theme.of(context)
                                              .textTheme
                                              .titleSmall
                                              ?.copyWith(
                                                color: AppColors.jungleGreen,
                                                decoration:
                                                    TextDecoration.underline,
                                                decorationColor:
                                                    AppColors.jungleGreen,
                                              ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 24),

                                  // Login Button
                                  BlocBuilder<AuthBloc, AuthState>(
                                    builder: (context, state) {
                                      final isLoading = state is AuthLoading;
                                      return SizedBox(
                                        width: double.infinity,
                                        height: 52,
                                        child: ElevatedButton(
                                          onPressed: isLoading
                                              ? null
                                              : _handleEmailSignIn,
                                          style: ElevatedButton.styleFrom(
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                            ),
                                            elevation: 0,
                                          ),
                                          child: isLoading
                                              ? const SizedBox(
                                                  width: 20,
                                                  height: 20,
                                                  child: CircularProgressIndicator(
                                                    strokeWidth: 2,
                                                    valueColor:
                                                        AlwaysStoppedAnimation<
                                                          Color
                                                        >(AppColors.white),
                                                  ),
                                                )
                                              : Text(
                                                  l10n.login_button,
                                                  style: GoogleFonts.anuphan(
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.bold,
                                                    color: AppColors.white,
                                                  ),
                                                ),
                                        ),
                                      );
                                    },
                                  ),
                                  const SizedBox(height: 24),

                                  // OR Divider
                                  Row(
                                    children: [
                                      const Expanded(
                                        child: Divider(
                                          color: AppColors.bonJour,
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 16,
                                        ),
                                        child: Text(
                                          l10n.or,
                                          style: GoogleFonts.anuphan(
                                            fontSize: 14,
                                            color: AppColors.shadyLady,
                                          ),
                                        ),
                                      ),
                                      const Expanded(
                                        child: Divider(
                                          color: AppColors.bonJour,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 24),

                                  // TMP close // Social Buttons
                                  // Row(
                                  //   children: [
                                  //     Expanded(
                                  //       child: GoogleSignInButton(
                                  //         role: widget.role,
                                  //         isCompact:
                                  //             false, // Always show full button
                                  //       ),
                                  //     ),
                                  //     const SizedBox(width: 16),
                                  //     Expanded(
                                  //       child: FacebookSignInButton(
                                  //         role: widget.role,
                                  //         isCompact:
                                  //             false, // Always show full button
                                  //       ),
                                  //     ),
                                  //   ],
                                  // ),

                                  // const SizedBox(height: 24),

                                  // Register Link
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        l10n.don_t_have_account,
                                        style: GoogleFonts.anuphan(
                                          fontSize: 14,
                                          color: AppColors.shadyLady,
                                        ),
                                      ),
                                      TextButton(
                                        onPressed: () {
                                          // Navigate to register screen based on role
                                          final roleParam = widget.role.name;
                                          context.go('/register/$roleParam');
                                        },
                                        child: Text(
                                          l10n.register_now,
                                          style: GoogleFonts.anuphan(
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                            color: AppColors.alizarinCrimson,
                                            decoration:
                                                TextDecoration.underline,
                                            decorationColor:
                                                AppColors.alizarinCrimson,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),

                                  // // TMP Debug Mode: Quick Login Button
                                  // if (kDebugMode) ...[
                                  //   const SizedBox(height: 24),
                                  //   OutlinedButton(
                                  //     onPressed: _handleDebugLogin,
                                  //     style: OutlinedButton.styleFrom(
                                  //       side: const BorderSide(
                                  //         color: AppColors.gray400,
                                  //       ),
                                  //       shape: RoundedRectangleBorder(
                                  //         borderRadius: BorderRadius.circular(
                                  //           12,
                                  //         ),
                                  //       ),
                                  //     ),
                                  //     child: Padding(
                                  //       padding: const EdgeInsets.symmetric(
                                  //         vertical: 12,
                                  //       ),
                                  //       child: Text(
                                  //         'Debug: Quick Login',
                                  //         style: GoogleFonts.anuphan(
                                  //           fontSize: 14,
                                  //           fontWeight: FontWeight.w500,
                                  //           color: AppColors.gray600,
                                  //         ),
                                  //       ),
                                  //     ),
                                  //   ),
                                  // ],
                                ],
                              ),
                            ),
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
