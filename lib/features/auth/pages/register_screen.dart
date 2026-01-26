import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../domain/entities/user.dart';
import '../../../l10n/app_localizations.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';

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
  String? _selectedBusinessType;
  bool _termsAccepted = false;
  bool _privacyAccepted = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

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

  void _register() {
    if (!_formKey.currentState!.validate()) return;
    if (!_termsAccepted || !_privacyAccepted) return;
    if (_selectedBusinessType == null) {
      final l10n = AppLocalizations.of(context)!;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.select_business_type),
        ),
      );
      return;
    }
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
                Center(
                  child: SvgPicture.asset(
                    'assets/images/undraw-business-call-w1gr-1.svg',
                    width: 180,
                    height: 180,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'ลงทะเบียน',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    color: AppColors.eerieBlack,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'ลงทะเบียนเพื่อเริ่มต้นใช้งานระบบ',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14, color: AppColors.gray400),
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
                            border: Border.all(
                              color: AppColors.buttonBorderGray,
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.person_outline,
                                size: 18,
                                color: _role == UserRole.agent
                                    ? AppColors.jungleGreen
                                    : AppColors.gray500,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'สำหรับเอเจนต์',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: _role == UserRole.agent
                                      ? AppColors.jungleGreen
                                      : AppColors.eerieBlack,
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
                            border: Border.all(
                              color: AppColors.buttonBorderGray,
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.business_center_outlined,
                                size: 18,
                                color: _role == UserRole.agency
                                    ? AppColors.jungleGreen
                                    : AppColors.gray500,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'สำหรับบริษัท',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: _role == UserRole.agency
                                      ? AppColors.jungleGreen
                                      : AppColors.eerieBlack,
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
                Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      TextFormField(
                        controller: _nameController,
                        decoration: InputDecoration(
                          hintText: l10n.full_name_hint,
                          prefixIcon: const Icon(
                            Icons.person_outline,
                            color: AppColors.gray400,
                          ),
                          filled: true,
                          fillColor: AppColors.white,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 14,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                              color: AppColors.grayBorder,
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                              color: AppColors.grayBorder,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                        validator: (v) =>
                            (v == null || v.isEmpty) ? l10n.enter_name : null,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: InputDecoration(
                          hintText: l10n.email,
                          prefixIcon: const Icon(
                            Icons.email_outlined,
                            color: AppColors.gray400,
                          ),
                          filled: true,
                          fillColor: AppColors.white,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 14,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                              color: AppColors.grayBorder,
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                              color: AppColors.grayBorder,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                              color: AppColors.primary,
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
                        controller: _phoneController,
                        keyboardType: TextInputType.phone,
                        decoration: InputDecoration(
                          hintText: l10n.phone_number,
                          prefixIcon: const Icon(
                            Icons.phone_outlined,
                            color: AppColors.gray400,
                          ),
                          filled: true,
                          fillColor: AppColors.white,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 14,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                              color: AppColors.grayBorder,
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                              color: AppColors.grayBorder,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                        validator: (v) {
                          if (v == null || v.isEmpty) {
                            return 'กรุณากรอก${l10n.phone_number}';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<String>(
                        initialValue: _selectedBusinessType,
                        decoration: InputDecoration(
                          hintText: l10n.business_type_hint,
                          prefixIcon: const Icon(
                            Icons.business_center_outlined,
                            color: AppColors.gray400,
                          ),
                          filled: true,
                          fillColor: AppColors.white,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 14,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                              color: AppColors.grayBorder,
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                              color: AppColors.grayBorder,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                        items: [
                          DropdownMenuItem(
                            value: 'Real Estate Agency',
                            child: Text(l10n.business_type_agency),
                          ),
                          DropdownMenuItem(
                            value: 'Property Developer',
                            child: Text(l10n.business_type_developer),
                          ),
                          DropdownMenuItem(
                            value: 'Independent Agent',
                            child: Text(l10n.business_type_independent),
                          ),
                          DropdownMenuItem(
                            value: 'Brokerage Firm',
                            child: Text(l10n.business_type_brokerage),
                          ),
                        ],
                        onChanged: (value) {
                          setState(() {
                            _selectedBusinessType = value;
                            if (value == 'Independent Agent') {
                              _companyController.clear();
                            }
                          });
                        },
                        validator: (v) {
                          if (v == null || v.isEmpty) {
                            return l10n.select_business_type;
                          }
                          return null;
                        },
                      ),
                      if (_selectedBusinessType != null &&
                          _selectedBusinessType != 'Independent Agent') ...[
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _companyController,
                          decoration: InputDecoration(
                            hintText: l10n.company_name_hint,
                            prefixIcon: const Icon(
                              Icons.apartment_outlined,
                              color: AppColors.gray400,
                            ),
                            filled: true,
                            fillColor: AppColors.white,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 14,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(
                                color: AppColors.grayBorder,
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(
                                color: AppColors.grayBorder,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                          validator: (v) {
                            if (_selectedBusinessType != 'Independent Agent') {
                              if (v == null || v.isEmpty) {
                                return l10n.enter_company_name;
                              }
                            }
                            return null;
                          },
                        ),
                      ],
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _passwordController,
                        obscureText: _obscurePassword,
                        decoration: InputDecoration(
                          hintText: l10n.password,
                          prefixIcon: Padding(
                            padding: const EdgeInsets.all(12),
                            child: SvgPicture.asset(
                              'assets/icons/key.svg',
                              width: 20,
                              height: 20,
                              colorFilter: const ColorFilter.mode(
                                AppColors.gray400,
                                BlendMode.srcIn,
                              ),
                            ),
                          ),
                          suffixIcon: IconButton(
                            onPressed: () => setState(
                              () => _obscurePassword = !_obscurePassword,
                            ),
                            icon: SvgPicture.asset(
                              _obscurePassword
                                  ? 'assets/icons/form/eye-off.svg'
                                  : 'assets/icons/form/eye.svg',
                              width: 22,
                              height: 22,
                              colorFilter: const ColorFilter.mode(
                                AppColors.gray400,
                                BlendMode.srcIn,
                              ),
                            ),
                          ),
                          filled: true,
                          fillColor: AppColors.white,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 14,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                              color: AppColors.grayBorder,
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                              color: AppColors.grayBorder,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                              color: AppColors.primary,
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
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _confirmPasswordController,
                        obscureText: _obscureConfirmPassword,
                        decoration: InputDecoration(
                          hintText: l10n.confirm_password,
                          prefixIcon: Padding(
                            padding: const EdgeInsets.all(12),
                            child: SvgPicture.asset(
                              'assets/icons/key.svg',
                              width: 20,
                              height: 20,
                              colorFilter: const ColorFilter.mode(
                                AppColors.gray400,
                                BlendMode.srcIn,
                              ),
                            ),
                          ),
                          suffixIcon: IconButton(
                            onPressed: () => setState(
                              () => _obscureConfirmPassword =
                                  !_obscureConfirmPassword,
                            ),
                            icon: SvgPicture.asset(
                              _obscureConfirmPassword
                                  ? 'assets/icons/form/eye-off.svg'
                                  : 'assets/icons/form/eye.svg',
                              width: 22,
                              height: 22,
                              colorFilter: const ColorFilter.mode(
                                AppColors.gray400,
                                BlendMode.srcIn,
                              ),
                            ),
                          ),
                          filled: true,
                          fillColor: AppColors.white,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 14,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                              color: AppColors.grayBorder,
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                              color: AppColors.grayBorder,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                        validator: (v) {
                          if (v == null || v.isEmpty) {
                            return l10n.enter_confirm_password;
                          }
                          if (v != _passwordController.text) {
                            return l10n.passwords_do_not_match;
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 8),
                      _policyRow(
                        checked: _termsAccepted,
                        onChanged: (v) => setState(() => _termsAccepted = v),
                        linkText: l10n.link_terms_and_conditions,
                        onLinkTap: () async {
                          final accepted = await context.push<bool>(
                            '/policy?type=terms',
                          );
                          if (!mounted) return;
                          if (accepted == true) {
                            setState(() => _termsAccepted = true);
                          }
                        },
                      ),
                      const SizedBox(height: 6),
                      _policyRow(
                        checked: _privacyAccepted,
                        onChanged: (v) => setState(() => _privacyAccepted = v),
                        linkText: l10n.link_privacy_policy,
                        onLinkTap: () async {
                          final accepted = await context.push<bool>(
                            '/policy?type=privacy',
                          );
                          if (!mounted) return;
                          if (accepted == true) {
                            setState(() => _privacyAccepted = true);
                          }
                        },
                      ),
                      const SizedBox(height: 14),
                      BlocBuilder<AuthBloc, AuthState>(
                        builder: (context, state) {
                          final loading = state is AuthLoading;
                          final canSubmit = _termsAccepted && _privacyAccepted;
                          return SizedBox(
                            width: double.infinity,
                            height: 52,
                            child: ElevatedButton(
                              onPressed: (loading || !canSubmit)
                                  ? null
                                  : _register,
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
                                      l10n.register_button,
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
                      const SizedBox(height: 14),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            l10n.already_have_account,
                            style: const TextStyle(color: AppColors.gray400),
                          ),
                          TextButton(
                            onPressed: () => context.go('/login'),
                            child: Text(
                              l10n.login_now,
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                                decoration: TextDecoration.underline,
                              ),
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

  Widget _policyRow({
    required bool checked,
    required ValueChanged<bool> onChanged,
    required String linkText,
    required VoidCallback onLinkTap,
  }) {
    final l10n = AppLocalizations.of(context)!;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Checkbox(
          value: checked,
          onChanged: (v) => onChanged(v ?? false),
          side: const BorderSide(color: AppColors.grayBorder),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
        ),
        Expanded(
          child: GestureDetector(
            onTap: () => onChanged(!checked),
            child: RichText(
              text: TextSpan(
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.eerieBlack,
                ),
                children: [
                  TextSpan(text: l10n.i_have_read_and_accept),
                  WidgetSpan(
                    child: InkWell(
                      onTap: onLinkTap,
                      child: Text(
                        linkText,
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppColors.eerieBlack,
                          decoration: TextDecoration.underline,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
