import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import '../../../core/di/dependency_injection.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/models/user_profile_model.dart';
import '../../../domain/entities/user.dart';
import '../../../l10n/app_localizations.dart';
import '../../../services/credentials_storage_service.dart';
import '../../../widgets/dialogs/status_dialog.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';
import '../../../widgets/form_fields/social_login_section.dart';

class LoginScreen extends StatefulWidget {
  final Function(Locale) changeLocale;

  const LoginScreen({super.key, required this.changeLocale});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  UserRole _role = UserRole.agent;
  bool _rememberMe = false;
  bool _obscurePassword = true;

  @override
  void initState() {
    super.initState();
    context.read<AuthBloc>().add(SetRoleEvent(role: _role));
    _loadSaved();
  }

  Future<void> _loadSaved() async {
    final service = CredentialsStorageService();
    final enabled = await service.isRememberMeEnabled();
    if (!enabled) return;
    final email = await service.getSavedEmail();
    if (!mounted) return;
    if (email != null) {
      setState(() {
        _rememberMe = true;
        _emailController.text = email;
      });
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleRoleChange(UserRole newRole) {
    if (newRole == _role) return;
    setState(() => _role = newRole);
    context.read<AuthBloc>().add(SetRoleEvent(role: _role));
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    context.read<AuthBloc>().add(
      SignInWithEmailEvent(
        email: _emailController.text.trim(),
        password: _passwordController.text,
        role: _role,
        rememberMe: _rememberMe,
      ),
    );
  }

  Future<void> _listener(BuildContext context, AuthState state) async {
    if (state is EmailNotVerified) {
      context.go(
        '/email-verification-pending?email=${Uri.encodeComponent(state.email)}',
      );
      return;
    }

    if (state is AuthError) {
      final l10n = AppLocalizations.of(context)!;
      await StatusDialog.showError(
        context: context,
        title: l10n.login_error,
        message: state.message,
      );
      return;
    }

    if (state is AuthOperationState) {
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

    if (state is Authenticated) {
      // Additional email verification check (matches old behavior)
      try {
        await Future.delayed(const Duration(milliseconds: 300));
        final userData = await DependencyInjection.authApiService
            .getCurrentUser();
        final profile = UserProfileModel.fromJson(userData);
        if (!profile.isEmailVerified) {
          if (!context.mounted) return;
          context.go(
            '/email-verification-pending?email=${Uri.encodeComponent(_emailController.text.trim())}',
          );
        }
      } catch (_) {
        // ignore and allow router redirect
      }
    }
  }

  String get _title {
    // Match screenshot title (same for both roles)
    return 'เข้าสู่ระบบ';
  }

  String get _subtitle {
    // From screenshot
    return 'ยินดีต้อนรับเข้าสู่คู่มือใหม่ของเอเจนต์';
  }

  Widget _roleSegment(AppLocalizations l10n) {
    Widget buildChip({required UserRole role, required bool selected}) {
      return Expanded(
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () => _handleRoleChange(role),
          child: Container(
            height: 44,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: selected ? AppColors.buttonLightGreen : AppColors.white,
              borderRadius: BorderRadius.circular(12),
              border: role == UserRole.agent
                  ? Border.all(color: const Color(0xFF32A792))
                  : null,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SvgPicture.asset(
                  role == UserRole.agent
                      ? 'assets/icons/user.svg'
                      : 'assets/icons/building.svg',
                  width: 16,
                  height: 16,
                  colorFilter: ColorFilter.mode(
                    selected ? AppColors.jungleGreen : AppColors.baseDarkGrey,
                    BlendMode.srcIn,
                  ),
                ),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    role == UserRole.agent ? 'สำหรับเอเจนต์' : 'สำหรับบริษัท',
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: selected
                          ? AppColors.jungleGreen
                          : AppColors.baseDarkGrey,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Row(
      children: [
        buildChip(role: UserRole.agent, selected: _role == UserRole.agent),
        const SizedBox(width: 12),
        buildChip(role: UserRole.agency, selected: _role == UserRole.agency),
      ],
    );
  }

  InputDecoration _inputDecoration({
    required String hint,
    required Widget prefix,
    Widget? suffix,
  }) {
    return InputDecoration(
      hintText: hint,
      prefixIcon: prefix,
      suffixIcon: suffix,
      filled: true,
      fillColor: AppColors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.baseGrey),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.baseGrey),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.primary),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

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
                // Illustration (placeholder using existing asset)
                Center(
                  child: SvgPicture.asset(
                    'assets/images/undraw-business-call-w1gr-1.svg',
                    width: 180,
                    height: 180,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    color: AppColors.baseDarkGrey,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  _subtitle,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.baseGrey,
                  ),
                ),
                const SizedBox(height: 20),
                _roleSegment(l10n),
                const SizedBox(height: 18),
                Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextFormField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: _inputDecoration(
                          hint: l10n.email,
                          prefix: Padding(
                            padding: const EdgeInsets.all(16),
                            child: SvgPicture.asset(
                              'assets/icons/email.svg',
                              width: 16,
                              height: 16,
                              colorFilter: const ColorFilter.mode(
                                AppColors.primary,
                                BlendMode.srcIn,
                              ),
                            ),
                          ),
                        ),
                        validator: (v) {
                          if (v == null || v.isEmpty) return l10n.enter_email;
                          if (!v.contains('@')) return l10n.enter_valid_email;
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _passwordController,
                        obscureText: _obscurePassword,
                        decoration: _inputDecoration(
                          hint: l10n.password,
                          prefix: Padding(
                            padding: const EdgeInsets.all(16),
                            child: SvgPicture.asset(
                              'assets/icons/key.svg',
                              width: 16,
                              height: 16,
                              colorFilter: const ColorFilter.mode(
                                AppColors.primary,
                                BlendMode.srcIn,
                              ),
                            ),
                          ),
                          suffix: IconButton(
                            onPressed: () => setState(
                              () => _obscurePassword = !_obscurePassword,
                            ),
                            icon: SvgPicture.asset(
                              _obscurePassword
                                  ? 'assets/icons/form/eye-off.svg'
                                  : 'assets/icons/form/eye.svg',
                              width: 16,
                              height: 16,
                              colorFilter: const ColorFilter.mode(
                                AppColors.baseGrey,
                                BlendMode.srcIn,
                              ),
                            ),
                          ),
                        ),
                        validator: (v) {
                          if (v == null || v.isEmpty) {
                            return l10n.enter_password;
                          }
                          if (v.length < 6) return l10n.password_length_error;
                          return null;
                        },
                      ),
                      const SizedBox(height: 4),
                      GestureDetector(
                        onTap: () {
                          setState(() => _rememberMe = !_rememberMe);
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Row(
                                children: [
                                  Checkbox(
                                    materialTapTargetSize:
                                        MaterialTapTargetSize.shrinkWrap,
                                    visualDensity: const VisualDensity(
                                      horizontal: VisualDensity.minimumDensity,
                                      vertical: VisualDensity.minimumDensity,
                                    ),

                                    value: _rememberMe,
                                    onChanged: (v) => setState(
                                      () => _rememberMe = v ?? false,
                                    ),
                                    side: const BorderSide(
                                      color: AppColors.baseGrey,
                                    ),
                                    activeColor: AppColors.primary,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                  ),
                                  SizedBox(width: 8),
                                  Flexible(
                                    child: Text(
                                      l10n.remember_me,
                                      style: const TextStyle(
                                        fontSize: 14,
                                        color: AppColors.baseDarkGrey,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            TextButton(
                              onPressed: () => context.push('/forgot-password'),
                              child: Text(
                                l10n.forgot_password,
                                style: const TextStyle(
                                  color: AppColors.baseGrey,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                      BlocBuilder<AuthBloc, AuthState>(
                        builder: (context, state) {
                          final loading = state is AuthLoading;
                          return SizedBox(
                            width: double.infinity,
                            height: 52,
                            child: ElevatedButton(
                              onPressed: loading ? null : _submit,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                disabledBackgroundColor: AppColors.disabledBg,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                elevation: 0,
                              ),
                              child: loading
                                  ? const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                              AppColors.white,
                                            ),
                                      ),
                                    )
                                  : Text(
                                      l10n.login_button,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.white,
                                      ),
                                    ),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 18),
                      SocialLoginSection(role: _role),
                      const SizedBox(height: 14),
                      const SizedBox(height: 14),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            l10n.don_t_have_account,
                            style: const TextStyle(color: AppColors.baseGrey),
                          ),
                          TextButton(
                            onPressed: () => context.go('/register'),
                            child: Text(
                              l10n.register_now,
                              style: const TextStyle(color: AppColors.primary),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
