import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:youragent/l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:youragent/core/theme/app_colors.dart';
import 'package:youragent/domain/entities/user.dart';
import 'package:youragent/widgets/form_fields/labeled_text_form_field.dart';
import 'package:youragent/widgets/form_fields/labeled_password_field.dart';
import 'package:youragent/widgets/form_fields/social_login_section.dart';

/// Standard registration form for agency, agent roles
class StandardRegisterForm extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController nameController;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final TextEditingController confirmPasswordController;
  final VoidCallback onRegister;
  final bool isLoading;
  final UserRole role;
  final bool? termsAccepted;
  final bool? privacyAccepted;
  final ValueChanged<bool>? onTermsChanged;
  final ValueChanged<bool>? onPrivacyChanged;

  const StandardRegisterForm({
    required this.role,
    required this.isLoading,
    super.key,
    required this.formKey,
    required this.nameController,
    required this.emailController,
    required this.passwordController,
    required this.confirmPasswordController,
    required this.onRegister,
    this.termsAccepted,
    this.privacyAccepted,
    this.onTermsChanged,
    this.onPrivacyChanged,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return SizedBox(
      width: double.infinity,
      child: Form(
        key: formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Name Field
            LabeledTextFormField(
              label: l10n.full_name_hint,
              controller: nameController,
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
              controller: emailController,
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

            // Password Field
            LabeledPasswordField(
              label: l10n.password,
              controller: passwordController,
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
              controller: confirmPasswordController,
              compareController: passwordController,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return l10n.enter_confirm_password;
                }
                if (value != passwordController.text) {
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
                checked: termsAccepted ?? false,
                onChanged: onTermsChanged,
                fullText: AppLocalizations.of(context)!.i_have_read_and_accept,
                linkText: AppLocalizations.of(context)!.link_terms_and_conditions,
                onLinkTap: () {
                  context.push('/policy?type=terms');
                },
              ),
              const SizedBox(height: 12),
              _buildPolicyCheckbox(
                context,
                checked: privacyAccepted ?? false,
                onChanged: onPrivacyChanged,
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
                onPressed: (isLoading || (!(termsAccepted ?? false) || !(privacyAccepted ?? false)))
                    ? null
                    : onRegister,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFE23E28),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 0,
                ),
                child: isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(AppColors.white),
                        ),
                      )
                    : Text(
                        l10n.register_button,
                        style: GoogleFonts.anuphan(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.white),
                      ),
              ),
            ),

            // Social Login Section
            SocialLoginSection(role: role),
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
          onChanged: onChanged != null ? (value) => onChanged(value ?? false) : null,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
          side: BorderSide(color: checked ? AppColors.alizarinCrimson : const Color(0xFFE9E9EB), width: 2),
          activeColor: AppColors.alizarinCrimson,
        ),
        Expanded(
          child: GestureDetector(
            onTap: onChanged != null ? () => onChanged(!checked) : null,
            child: RichText(
              text: TextSpan(
                style: GoogleFonts.anuphan(fontSize: 14, fontWeight: FontWeight.w400, color: const Color(0xFF181D27)),
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
