import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:youragent/l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:youragent/core/theme/app_colors.dart';
import 'package:youragent/domain/entities/user.dart';
import 'package:youragent/widgets/form_fields/labeled_text_form_field.dart';
import 'package:youragent/widgets/form_fields/labeled_password_field.dart';
import 'package:youragent/widgets/form_fields/labeled_dropdown_field.dart';

/// Business registration form for agent and agency roles
/// Includes: Name, Email, Phone Number, Business Type, Company Name, Password, Confirm Password
class BusinessRegisterForm extends StatefulWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController nameController;
  final TextEditingController emailController;
  final TextEditingController phoneController;
  final TextEditingController companyController;
  final TextEditingController passwordController;
  final TextEditingController confirmPasswordController;
  final Function(String businessType) onRegister;
  final bool isAgent; // true for agent, false for agency
  final UserRole role;
  final bool? termsAccepted;
  final bool? privacyAccepted;
  final ValueChanged<bool>? onTermsChanged;
  final ValueChanged<bool>? onPrivacyChanged;

  const BusinessRegisterForm({
    required this.role,
    super.key,
    required this.formKey,
    required this.nameController,
    required this.emailController,
    required this.phoneController,
    required this.companyController,
    required this.passwordController,
    required this.confirmPasswordController,
    required this.onRegister,
    this.isAgent = true,
    this.termsAccepted,
    this.privacyAccepted,
    this.onTermsChanged,
    this.onPrivacyChanged,
  });

  @override
  State<BusinessRegisterForm> createState() => _BusinessRegisterFormState();
}

class _BusinessRegisterFormState extends State<BusinessRegisterForm> {
  String? _selectedBusinessType;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return SizedBox(
      width: double.infinity,
      child: Form(
        key: widget.formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Name Field
            LabeledTextFormField(
              label: l10n.full_name_hint,
              controller: widget.nameController,
              prefixIcon: Icons.person_outline,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return l10n.enter_name;
                }
                return null;
              },
            ),

            // Email Field
            LabeledTextFormField(
              label: l10n.email,
              controller: widget.emailController,
              keyboardType: TextInputType.emailAddress,
              prefixIcon: Icons.email_outlined,
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

            // Phone Number Field
            LabeledTextFormField(
              label: l10n.phone_number,
              controller: widget.phoneController,
              keyboardType: TextInputType.phone,
              prefixIcon: Icons.phone_outlined,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'กรุณากรอก${l10n.phone_number}';
                }
                return null;
              },
            ),

            // Business Type Dropdown
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
              onChanged: (value) {
                setState(() {
                  _selectedBusinessType = value;
                  // Clear company name if Independent Agent is selected
                  if (value == 'Independent Agent') {
                    widget.companyController.clear();
                  }
                });
              },
            ),

            // Company Name (hidden for Independent Agent)
            if (_selectedBusinessType != 'Independent Agent')
              LabeledTextFormField(
                label: l10n.company_name_hint,
                controller: widget.companyController,
                prefixIcon: Icons.apartment_outlined,
                validator: (value) {
                  if (_selectedBusinessType != 'Independent Agent') {
                    if (value == null || value.isEmpty) {
                      return l10n.enter_company_name;
                    }
                  }
                  return null;
                },
              ),

            // Password Field
            LabeledPasswordField(
              label: l10n.password,
              controller: widget.passwordController,
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

            // Confirm Password Field
            LabeledPasswordField(
              label: l10n.confirm_password,
              controller: widget.confirmPasswordController,
              compareController: widget.passwordController,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return l10n.enter_confirm_password;
                }
                if (value != widget.passwordController.text) {
                  return l10n.passwords_do_not_match;
                }
                return null;
              },
            ),

            const SizedBox(height: 8),

            // Terms and Privacy Checkboxes
            ...[
              _buildPolicyCheckbox(
                context,
                checked: widget.termsAccepted ?? false,
                onChanged: widget.onTermsChanged,
                fullText: AppLocalizations.of(context)!.i_have_read_and_accept,
                linkText: AppLocalizations.of(
                  context,
                )!.link_terms_and_conditions,
                onLinkTap: () {
                  context.push('/policy?type=terms');
                },
              ),
              const SizedBox(height: 12),
              _buildPolicyCheckbox(
                context,
                checked: widget.privacyAccepted ?? false,
                onChanged: widget.onPrivacyChanged,
                fullText: AppLocalizations.of(context)!.i_have_read_and_accept,
                linkText: AppLocalizations.of(context)!.link_privacy_policy,
                onLinkTap: () {
                  context.push('/policy?type=privacy');
                },
              ),
              const SizedBox(height: 24),
            ],

            // Register Button
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
                  if (!(widget.termsAccepted ?? false) ||
                      !(widget.privacyAccepted ?? false)) {
                    return;
                  }
                  widget.onRegister(_selectedBusinessType!);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      (_selectedBusinessType == null ||
                          (!(widget.termsAccepted ?? false) ||
                              !(widget.privacyAccepted ?? false)))
                      ? const Color(0xFFE9E9EB)
                      : const Color(0xFFE23E28),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  l10n.register_button,
                  style: GoogleFonts.anuphan(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.white,
                  ),
                ),
              ),
            ),

            // Tmp close // Social Login Section
            // SocialLoginSection(role: widget.role),
          ],
        ),
      ),
    );
  }

  Widget _buildPolicyCheckbox(
    BuildContext context, {
    required bool checked,
    required ValueChanged<bool>? onChanged,
    required String fullText,
    required String linkText,
    required VoidCallback onLinkTap,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Checkbox(
          value: checked,
          onChanged: onChanged != null
              ? (value) => onChanged(value ?? false)
              : null,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
          side: BorderSide(
            color: checked
                ? AppColors.alizarinCrimson
                : const Color(0xFFE9E9EB),
            width: 2,
          ),
          activeColor: AppColors.alizarinCrimson,
        ),
        Expanded(
          child: GestureDetector(
            onTap: onChanged != null ? () => onChanged(!checked) : null,
            child: RichText(
              text: TextSpan(
                style: GoogleFonts.anuphan(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: const Color(0xFF181D27),
                ),
                children: [
                  TextSpan(text: fullText),
                  WidgetSpan(
                    child: InkWell(
                      onTap: onLinkTap,
                      child: Text(
                        linkText,
                        style: GoogleFonts.anuphan(
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                          color: const Color(0xFF181D27),
                          decoration: TextDecoration.underline,
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
