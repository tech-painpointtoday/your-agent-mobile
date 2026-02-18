import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:youragent/core/theme/app_colors.dart';
import 'package:youragent/widgets/buttons/app_button.dart';
import 'package:youragent/widgets/inputs/app_text_field.dart';
import 'package:youragent/core/di/dependency_injection.dart';
import 'package:youragent/widgets/dialogs/status_dialog.dart';
import 'package:youragent/core/extensions/l10n_extensions.dart';
import 'package:youragent/utils/thai_phone_input_formatter.dart';
import 'package:youragent/core/error/api_exception.dart';

enum RegistrationUserType { owner, buyer }

class RegistrationResult {
  final String name;
  final String email;
  final String phone;
  final String? address;
  final String password; // Added

  RegistrationResult({
    required this.name,
    required this.email,
    required this.phone,
    required this.password,
    this.address,
  });
}

class UserRegistrationBottomSheet extends StatefulWidget {
  final RegistrationUserType type;

  const UserRegistrationBottomSheet({super.key, required this.type});

  static Future<RegistrationResult?> show(
    BuildContext context,
    RegistrationUserType type,
  ) {
    return showModalBottomSheet<RegistrationResult>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => UserRegistrationBottomSheet(type: type),
    );
  }

  @override
  State<UserRegistrationBottomSheet> createState() =>
      _UserRegistrationBottomSheetState();
}

class _UserRegistrationBottomSheetState
    extends State<UserRegistrationBottomSheet> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _addressController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _isLoading = false;
  String? _errorCode;

  @override
  void initState() {
    super.initState();
    _nameController.addListener(_onFormFieldChanged);
    _phoneController.addListener(_onFormFieldChanged);
    _emailController.addListener(_onEmailFieldChanged);
    _addressController.addListener(_onFormFieldChanged);
    _passwordController.addListener(_onFormFieldChanged);
    _confirmPasswordController.addListener(_onFormFieldChanged);
  }

  void _onEmailFieldChanged() {
    if (_errorCode != null) {
      setState(() => _errorCode = null);
    }
    _onFormFieldChanged();
  }

  void _onFormFieldChanged() {
    setState(() {});
  }

  bool get _isFormValid {
    final name = _nameController.text.trim();
    final phone = _phoneController.text.trim().replaceAll('-', '');
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    final confirmPassword = _confirmPasswordController.text;

    if (name.isEmpty) return false;
    if (phone.isEmpty || phone.length < 10) return false;
    if (email.isEmpty ||
        !RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email)) {
      return false;
    }
    if (widget.type == RegistrationUserType.owner &&
        _addressController.text.trim().isEmpty) {
      return false;
    }
    if (password.isEmpty || password.length < 8) return false;
    if (confirmPassword.isEmpty || password != confirmPassword) return false;
    return true;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _addressController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final authService = DependencyInjection.authApiService;

      if (widget.type == RegistrationUserType.owner) {
        await authService.sellerRegister(
          name: _nameController.text,
          email: _emailController.text,
          password: _passwordController.text,
          passwordConfirmation: _confirmPasswordController.text,
          address: _addressController.text,
        );
      } else {
        await authService.buyerRegister(
          name: _nameController.text,
          email: _emailController.text,
          password: _passwordController.text,
          passwordConfirmation: _confirmPasswordController.text,
        );
      }

      if (mounted) {
        StatusDialog.showSuccess(
          context: context,
          title: context.l10n.registrationSuccessTitle,
          message: context.l10n.accountCreatedMessage,
        );
        Navigator.pop(
          context,
          RegistrationResult(
            name: _nameController.text,
            email: _emailController.text,
            phone: _phoneController.text,
            password: _passwordController.text,
            address: widget.type == RegistrationUserType.owner
                ? _addressController.text
                : null,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        if (e is ApiException) {
          setState(() => _errorCode = e.code);
          if (e.code != 'VALIDATION_ERROR') {
            StatusDialog.showError(
              context: context,
              title: context.l10n.errorOccurredTitle,
              message: e.message,
            );
          }
        } else {
          StatusDialog.showError(
            context: context,
            title: context.l10n.errorOccurredTitle,
            message: e.toString().replaceFirst('Exception: ', ''),
          );
        }
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final title = context.l10n.createNewAccountTitle;
    final subtitle = widget.type == RegistrationUserType.owner
        ? context.l10n.dataPropertyContract
        : context.l10n.registerBuyerToContract;

    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      padding: EdgeInsets.fromLTRB(
        24,
        12,
        24,
        MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.82,
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Handle bar
              Center(
                child: Container(
                  width: 48,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.baseLightGrey,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Title
              Text(
                title,
                style: GoogleFonts.anuphan(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: GoogleFonts.anuphan(
                  fontSize: 14,
                  color: AppColors.baseGrey,
                ),
              ),
              const SizedBox(height: 32),

              Form(
                key: _formKey,
                child: Column(
                  children: [
                    AppTextField(
                      label: context.l10n.fullNameLabel,
                      controller: _nameController,
                      isRequired: true,
                      hintText: context.l10n.fullNameLabel,
                    ),
                    const SizedBox(height: 20),
                    AppTextField(
                      label: context.l10n.phone_number,
                      controller: _phoneController,
                      isRequired: true,
                      hintText: context.l10n.phone_number,
                      keyboardType: TextInputType.phone,
                      inputFormatters: [ThaiPhoneInputFormatter()],
                      validator: (value) {
                        if (value == null || value.isEmpty) return null;
                        final phone = value.replaceAll('-', '');
                        if (phone.length < 10) {
                          return context.l10n.invalidPhoneNumberFormat;
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),
                    AppTextField(
                      label: context.l10n.email,
                      controller: _emailController,
                      isRequired: true,
                      hintText: context.l10n.email,
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) {
                        if (value == null || value.isEmpty) return null;
                        if (!RegExp(
                          r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                        ).hasMatch(value.trim())) {
                          return context.l10n.invalidEmailFormat;
                        }
                        return null;
                      },
                    ),
                    if (_errorCode == 'VALIDATION_ERROR') ...[
                      const SizedBox(height: 8),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          context.l10n.emailAlreadyRegistered,
                          style: GoogleFonts.anuphan(
                            color: AppColors.error,
                            fontSize: 14,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      AppButton(
                        width: double.infinity,
                        text: context.l10n.useThisEmailToContinue,
                        style: AppButtonStyle.outline,
                        backgroundColor: AppColors.brandLightGreen,
                        textColor: AppColors.brandGreen,
                        borderColor: AppColors.brandGreen.withValues(
                          alpha: 0.16,
                        ),
                        onPressed: () {
                          Navigator.pop(
                            context,
                            RegistrationResult(
                              name: _nameController.text,
                              email: _emailController.text,
                              phone: _phoneController.text,
                              password: _passwordController.text,
                              address: widget.type == RegistrationUserType.owner
                                  ? _addressController.text
                                  : null,
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 8),
                      Center(
                        child: Text(
                          context.l10n.registrationNote,
                          style: GoogleFonts.anuphan(
                            fontSize: 14,
                            color: AppColors.baseGrey,
                          ),
                        ),
                      ),
                    ],
                    const SizedBox(height: 20),
                    if (widget.type == RegistrationUserType.owner) ...[
                      AppTextField(
                        label: context.l10n.address,
                        controller: _addressController,
                        isRequired: true,
                        hintText: context.l10n.currentAddressLabel,
                      ),
                      const SizedBox(height: 20),
                    ],
                    AppTextField(
                      label: context.l10n.password,
                      controller: _passwordController,
                      isRequired: true,
                      hintText: context.l10n.password,
                      obscureText: _obscurePassword,
                      validator: (value) {
                        if (value == null || value.isEmpty) return null;
                        if (value.length < 8) {
                          return context.l10n.passwordMinLengthError;
                        }
                        return null;
                      },
                      suffix: IconButton(
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined,
                          color: AppColors.baseGrey,
                          size: 20,
                        ),
                        onPressed: () => setState(
                          () => _obscurePassword = !_obscurePassword,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    AppTextField(
                      label: context.l10n.confirm_password_hint,
                      controller: _confirmPasswordController,
                      isRequired: true,
                      hintText: context.l10n.confirm_password_hint,
                      obscureText: _obscureConfirmPassword,
                      validator: (value) {
                        if (value == null || value.isEmpty) return null;
                        if (value != _passwordController.text) {
                          return context.l10n.passwordMismatchError;
                        }
                        return null;
                      },
                      suffix: IconButton(
                        icon: SvgPicture.asset(
                          _obscureConfirmPassword
                              ? 'assets/icons/eye-off.svg'
                              : 'assets/icons/eye.svg',
                          colorFilter: const ColorFilter.mode(
                            AppColors.baseGrey,
                            BlendMode.srcIn,
                          ),
                          width: 20,
                          height: 20,
                        ),
                        onPressed: () => setState(
                          () => _obscureConfirmPassword =
                              !_obscureConfirmPassword,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              Row(
                children: [
                  Expanded(
                    child: AppButton(
                      text: context.l10n.cancel_button,
                      style: AppButtonStyle.outline,
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: AppButton(
                      text: context.l10n.createAccount,
                      style: AppButtonStyle.primary,
                      isLoading: _isLoading,
                      enabled: !_isLoading && _isFormValid,
                      onPressed: _handleRegister,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
