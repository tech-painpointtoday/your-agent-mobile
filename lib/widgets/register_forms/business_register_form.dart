import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_colors.dart';
import '../../domain/entities/user.dart';
import '../../l10n/app_localizations.dart';
import '../form_fields/labeled_dropdown_field.dart';
import '../form_fields/labeled_password_field.dart';
import '../form_fields/labeled_text_form_field.dart';

class BusinessRegisterForm extends StatefulWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController nameController;
  final TextEditingController emailController;
  final TextEditingController phoneController;
  final TextEditingController companyController;
  final TextEditingController passwordController;
  final TextEditingController confirmPasswordController;
  final Function(String businessType) onRegister;
  final UserRole role;
  final bool termsAccepted;
  final bool privacyAccepted;
  final ValueChanged<bool> onTermsChanged;
  final ValueChanged<bool> onPrivacyChanged;

  const BusinessRegisterForm({
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
  });

  @override
  State<BusinessRegisterForm> createState() => _BusinessRegisterFormState();
}

class _BusinessRegisterFormState extends State<BusinessRegisterForm> {
  String? _selectedBusinessType;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    final canSubmit = _selectedBusinessType != null &&
        widget.termsAccepted &&
        widget.privacyAccepted;

    return Form(
      key: widget.formKey,
      child: Column(
        children: [
          LabeledTextFormField(
            label: l10n.full_name_hint,
            controller: widget.nameController,
            prefixIcon: Icons.person_outline,
            validator: (v) => (v == null || v.isEmpty) ? l10n.enter_name : null,
          ),
          LabeledTextFormField(
            label: l10n.email,
            controller: widget.emailController,
            prefixIcon: Icons.email_outlined,
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
            prefixIcon: Icons.phone_outlined,
            keyboardType: TextInputType.phone,
            validator: (v) => (v == null || v.isEmpty) ? 'กรุณากรอก${l10n.phone_number}' : null,
          ),
          LabeledDropdownField<String>(
            label: l10n.business_type_hint,
            value: _selectedBusinessType,
            prefixIcon: Icons.business_center_outlined,
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
            onChanged: (v) {
              setState(() {
                _selectedBusinessType = v;
                if (v == 'Independent Agent') {
                  widget.companyController.clear();
                }
              });
            },
          ),
          if (_selectedBusinessType != 'Independent Agent')
            LabeledTextFormField(
              label: l10n.company_name_hint,
              controller: widget.companyController,
              prefixIcon: Icons.apartment_outlined,
              validator: (v) {
                if (_selectedBusinessType != 'Independent Agent') {
                  if (v == null || v.isEmpty) return l10n.enter_company_name;
                }
                return null;
              },
            ),
          LabeledPasswordField(
            label: l10n.password,
            controller: widget.passwordController,
            validator: (v) {
              if (v == null || v.isEmpty) return l10n.enter_password;
              if (v.length < 6) return l10n.password_length_error;
              return null;
            },
          ),
          LabeledPasswordField(
            label: l10n.confirm_password,
            controller: widget.confirmPasswordController,
            compareController: widget.passwordController,
            validator: (v) {
              if (v == null || v.isEmpty) return l10n.enter_confirm_password;
              if (v != widget.passwordController.text) return l10n.passwords_do_not_match;
              return null;
            },
          ),
          const SizedBox(height: 8),
          _policyCheckbox(
            context,
            checked: widget.termsAccepted,
            onChanged: widget.onTermsChanged,
            linkText: l10n.link_terms_and_conditions,
            onLinkTap: () => context.push('/policy?type=terms'),
          ),
          const SizedBox(height: 12),
          _policyCheckbox(
            context,
            checked: widget.privacyAccepted,
            onChanged: widget.onPrivacyChanged,
            linkText: l10n.link_privacy_policy,
            onLinkTap: () => context.push('/policy?type=privacy'),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: () {
                if (_selectedBusinessType == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(l10n.select_business_type)),
                  );
                  return;
                }
                if (!canSubmit) return;
                widget.onRegister(_selectedBusinessType!);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: canSubmit ? AppColors.primary : const Color(0xFFE9E9EB),
              ),
              child: Text(
                l10n.register_button,
                style: const TextStyle(color: AppColors.white, fontWeight: FontWeight.w700),
              ),
            ),
          ),
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
  }) {
    final l10n = AppLocalizations.of(context);
    return Row(
      children: [
        Checkbox(
          value: checked,
          onChanged: (v) => onChanged(v ?? false),
          activeColor: AppColors.primary,
        ),
        Expanded(
          child: GestureDetector(
            onTap: () => onChanged(!checked),
            child: RichText(
              text: TextSpan(
                style: const TextStyle(color: AppColors.eerieBlack),
                children: [
                  TextSpan(text: l10n.i_have_read_and_accept),
                  WidgetSpan(
                    child: InkWell(
                      onTap: onLinkTap,
                      child: Text(
                        linkText,
                        style: const TextStyle(decoration: TextDecoration.underline),
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

