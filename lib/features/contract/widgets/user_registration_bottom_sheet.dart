import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:youragent/core/theme/app_colors.dart';
import 'package:youragent/widgets/buttons/app_button.dart';
import 'package:youragent/widgets/inputs/app_text_field.dart';
import 'package:youragent/core/di/dependency_injection.dart';
import 'package:youragent/widgets/dialogs/status_dialog.dart';
import 'package:youragent/l10n/app_localizations.dart';
import 'package:youragent/utils/thai_phone_input_formatter.dart';

enum RegistrationUserType { owner, buyer }

class UserRegistrationBottomSheet extends StatefulWidget {
  final RegistrationUserType type;

  const UserRegistrationBottomSheet({super.key, required this.type});

  static Future<void> show(BuildContext context, RegistrationUserType type) {
    return showModalBottomSheet(
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
        Navigator.pop(context);
        StatusDialog.showSuccess(
          context: context,
          title: AppLocalizations.of(context).registrationSuccessTitle,
          message: AppLocalizations.of(context).accountCreatedMessage,
        );
      }
    } catch (e) {
      if (mounted) {
        StatusDialog.showError(
          context: context,
          title: AppLocalizations.of(context).errorOccurredTitle,
          message: e.toString().replaceFirst('Exception: ', ''),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final title = AppLocalizations.of(context).createNewAccountTitle;
    final subtitle = widget.type == RegistrationUserType.owner
        ? AppLocalizations.of(context).dataPropertyContract
        : AppLocalizations.of(context).registerBuyerToContract;

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
                    label: AppLocalizations.of(context).fullNameLabel,
                    controller: _nameController,
                    isRequired: true,
                    hintText: AppLocalizations.of(context).fullNameLabel,
                  ),
                  const SizedBox(height: 20),
                  AppTextField(
                    label: AppLocalizations.of(context).phone_number,
                    controller: _phoneController,
                    isRequired: true,
                    hintText: AppLocalizations.of(context).phone_number,
                    keyboardType: TextInputType.phone,
                    inputFormatters: [ThaiPhoneInputFormatter()],
                  ),
                  const SizedBox(height: 20),
                  AppTextField(
                    label: AppLocalizations.of(context).email,
                    controller: _emailController,
                    isRequired: true,
                    hintText: AppLocalizations.of(context).email,
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 20),
                  if (widget.type == RegistrationUserType.owner) ...[
                    AppTextField(
                      label: AppLocalizations.of(context).address,
                      controller: _addressController,
                      isRequired: true,
                      hintText: AppLocalizations.of(
                        context,
                      ).currentAddressLabel,
                    ),
                    const SizedBox(height: 20),
                  ],
                  AppTextField(
                    label: AppLocalizations.of(context).password,
                    controller: _passwordController,
                    isRequired: true,
                    hintText: AppLocalizations.of(context).password,
                    obscureText: _obscurePassword,
                    suffix: IconButton(
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                        color: AppColors.baseGrey,
                        size: 20,
                      ),
                      onPressed: () =>
                          setState(() => _obscurePassword = !_obscurePassword),
                    ),
                  ),
                  const SizedBox(height: 20),
                  AppTextField(
                    label: AppLocalizations.of(context).confirm_password_hint,
                    controller: _confirmPasswordController,
                    isRequired: true,
                    hintText: AppLocalizations.of(
                      context,
                    ).confirm_password_hint,
                    obscureText: _obscureConfirmPassword,
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
                        () =>
                            _obscureConfirmPassword = !_obscureConfirmPassword,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            SizedBox(
              width: double.infinity,
              child: AppButton(
                text: _isLoading
                    ? AppLocalizations.of(context).registering
                    : AppLocalizations.of(context).registerMember,
                style: AppButtonStyle.primary,
                onPressed: _isLoading ? null : _handleRegister,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
