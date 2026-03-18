import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/theme/app_colors.dart';
import '../../domain/entities/user.dart';
import '../../utils/thai_phone_input_formatter.dart';
import '../../l10n/app_localizations.dart';
import '../buttons/app_button.dart';
import '../modals/app_confirmation_bottom_sheet.dart';
import '../form_fields/labeled_password_field.dart';
import '../form_fields/labeled_text_form_field.dart';

class RegisterForm extends StatefulWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController nameController;
  final TextEditingController emailController;
  final TextEditingController phoneController;
  final TextEditingController companyController;
  final TextEditingController passwordController;
  final TextEditingController confirmPasswordController;
  final Function(String? businessType) onRegister;
  final UserRole role;
  final bool termsAccepted;
  final bool privacyAccepted;
  final ValueChanged<bool> onTermsChanged;
  final ValueChanged<bool> onPrivacyChanged;
  final bool isLoading;

  const RegisterForm({
    super.key,
    required this.formKey,
    required this.nameController,
    required this.emailController,
    required this.phoneController,
    required this.companyController,
    required this.passwordController,
    required this.confirmPasswordController,
    required this.onRegister,
    required this.role,
    required this.termsAccepted,
    required this.privacyAccepted,
    required this.onTermsChanged,
    required this.onPrivacyChanged,
    this.isLoading = false,
  });

  @override
  State<RegisterForm> createState() => _RegisterFormState();
}

class _RegisterFormState extends State<RegisterForm> {
  String? _selectedBusinessType;
  bool _hasOpenedTermsPolicy = false;
  bool _hasOpenedPrivacyPolicy = false;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    final canSubmit =
        // _selectedBusinessType != null &&
        widget.termsAccepted && widget.privacyAccepted;

    return Form(
      key: widget.formKey,
      child: Column(
        children: [
          LabeledTextFormField(
            label: l10n.full_name_hint,
            controller: widget.nameController,
            prefixIconSvg: 'assets/icons/user.svg',
            validator: (v) => (v == null || v.isEmpty) ? l10n.enter_name : null,
          ),
          LabeledTextFormField(
            label: l10n.email,
            controller: widget.emailController,
            prefixIconSvg: 'assets/icons/email.svg',
            keyboardType: TextInputType.emailAddress,
            validator: (v) {
              if (v == null || v.isEmpty) return l10n.enter_email;
              if (!v.contains('@')) return l10n.enter_valid_email;
              return null;
            },
          ),
          LabeledTextFormField(
            label: l10n.phone_number,
            controller: widget.phoneController,
            prefixIconSvg: 'assets/icons/phone.svg',
            keyboardType: TextInputType.phone,
            inputFormatters: [ThaiPhoneInputFormatter()],
            validator: (v) => (v == null || v.isEmpty)
                ? 'กรุณากรอก${l10n.phone_number}'
                : null,
          ),

          // tmp close
          // LabeledDropdownField<String>(
          //   label: l10n.business_type_hint,
          //   value: _selectedBusinessType,
          //   prefixIconSvg: 'assets/icons/briefcase.svg',
          //   items: [
          //     DropdownMenuItem(
          //       value: 'Real Estate Agency',
          //       child: Text(l10n.business_type_agency),
          //     ),
          //     DropdownMenuItem(
          //       value: 'Property Developer',
          //       child: Text(l10n.business_type_developer),
          //     ),
          //     DropdownMenuItem(
          //       value: 'Independent Agent',
          //       child: Text(l10n.business_type_independent),
          //     ),
          //     DropdownMenuItem(
          //       value: 'Brokerage Firm',
          //       child: Text(l10n.business_type_brokerage),
          //     ),
          //   ],
          //   onChanged: (v) {
          //     setState(() {
          //       _selectedBusinessType = v;
          //       if (v == 'Independent Agent') {
          //         widget.companyController.clear();
          //       }
          //     });
          //   },
          // ),
          // if (_selectedBusinessType != 'Independent Agent')
          //   LabeledTextFormField(
          //     label: l10n.company_name_hint,
          //     controller: widget.companyController,
          //     prefixIconSvg: 'assets/icons/building.svg',
          //     validator: (v) {
          //       if (_selectedBusinessType != 'Independent Agent') {
          //         if (v == null || v.isEmpty) return l10n.enter_company_name;
          //       }
          //       return null;
          //     },
          //   ),
          LabeledPasswordField(
            label: l10n.password,
            controller: widget.passwordController,
            validator: (v) {
              if (v == null || v.isEmpty) return l10n.enter_password;
              if (v.length < 8) return l10n.password_length_error;
              return null;
            },
          ),
          LabeledPasswordField(
            label: l10n.confirm_password,
            controller: widget.confirmPasswordController,
            compareController: widget.passwordController,
            validator: (v) {
              if (v == null || v.isEmpty) return l10n.enter_confirm_password;
              if (v != widget.passwordController.text) {
                return l10n.passwords_do_not_match;
              }
              return null;
            },
          ),
          const SizedBox(height: 8),
          _policyCheckbox(
            context,
            checked: widget.termsAccepted,
            onChanged: widget.onTermsChanged,
            linkText: l10n.link_terms_and_conditions,
            onLinkTap: () async {
              final accepted = await context.push<bool>('/policy?type=terms');
              if (accepted == true) {
                setState(() => _hasOpenedTermsPolicy = true);
                widget.onTermsChanged(true);
              }
            },
            hasReadPolicy: _hasOpenedTermsPolicy,
          ),
          const SizedBox(height: 8),
          _policyCheckbox(
            context,
            checked: widget.privacyAccepted,
            onChanged: widget.onPrivacyChanged,
            linkText: l10n.link_privacy_policy,
            onLinkTap: () async {
              final accepted = await context.push<bool>('/policy?type=privacy');
              if (accepted == true) {
                setState(() => _hasOpenedPrivacyPolicy = true);
                widget.onPrivacyChanged(true);
              }
            },
            hasReadPolicy: _hasOpenedPrivacyPolicy,
          ),
          const SizedBox(height: 24),
          AppButton(
            width: double.infinity,
            text: l10n.register_button,
            style: AppButtonStyle.primary,
            height: 52,
            onPressed: (canSubmit && !widget.isLoading)
                ? () {
                    AppConfirmationBottomSheet.show(
                      context: context,
                      title: l10n.confirm_register,
                      description: l10n.confirm_register_description,
                      confirmLabel: l10n.confirm,
                      cancelLabel: l10n.cancel_button,
                      style: ConfirmationStyle.normal,
                      onConfirm: () => widget.onRegister(_selectedBusinessType),
                    );
                  }
                : null,
          ),
          // tmp close
          // const SizedBox(height: 24),
          // SocialLoginSection(role: widget.role),
        ],
      ),
    );
  }

  Widget _policyCheckbox(
    BuildContext context, {
    required bool checked,
    required ValueChanged<bool> onChanged,
    required String linkText,
    required VoidCallback onLinkTap,
    required bool hasReadPolicy,
  }) {
    final l10n = AppLocalizations.of(context);
    // When user tries to check: open policy screen and require scroll-to-bottom + accept.
    // Only after they have accepted once (hasReadPolicy) can they check directly.
    void onTapToAccept() => onLinkTap();
    return Row(
      children: [
        Checkbox(
          value: checked,
          onChanged: (v) {
            if (v == true) {
              if (hasReadPolicy) {
                onChanged(true);
              } else {
                onTapToAccept();
              }
            } else {
              onChanged(false);
            }
          },
          activeColor: AppColors.primary,
          side: const BorderSide(color: AppColors.baseLightGrey),
        ),
        Expanded(
          child: GestureDetector(
            onTap: () {
              if (checked) {
                onChanged(false);
              } else {
                if (hasReadPolicy) {
                  onChanged(true);
                } else {
                  onTapToAccept();
                }
              }
            },
            child: Text.rich(
              TextSpan(
                style: GoogleFonts.anuphan(
                  color: AppColors.baseGrey,
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                ),
                children: [
                  TextSpan(text: l10n.i_have_read_and_accept),
                  WidgetSpan(
                    child: InkWell(
                      onTap: onLinkTap,
                      child: Text(
                        linkText,
                        style: GoogleFonts.anuphan(
                          color: AppColors.baseGrey,
                          decoration: TextDecoration.underline,
                          decorationColor: AppColors.baseGrey,
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
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
