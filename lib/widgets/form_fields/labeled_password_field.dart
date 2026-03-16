import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:yourhome/l10n/app_localizations.dart';
import 'package:yourhome/core/theme/app_colors.dart';

/// Reusable labeled password field with visibility toggle
class LabeledPasswordField extends StatefulWidget {
  final String label;
  final String? hintText;
  final TextEditingController controller;
  final String? Function(String?)? validator;
  final TextEditingController?
  compareController; // For confirm password validation

  const LabeledPasswordField({
    super.key,
    required this.label,
    this.hintText,
    required this.controller,
    this.validator,
    this.compareController,
  });

  @override
  State<LabeledPasswordField> createState() => _LabeledPasswordFieldState();
}

class _LabeledPasswordFieldState extends State<LabeledPasswordField> {
  bool _obscureText = true;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          controller: widget.controller,
          obscureText: _obscureText,
          decoration: _buildInputDecoration(),
          validator: widget.validator ?? _defaultValidator,
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  InputDecoration _buildInputDecoration() {
    return InputDecoration(
      hintText: widget.hintText ?? widget.label,
      hintStyle: GoogleFonts.anuphan(color: AppColors.baseGrey),
      prefixIcon: Padding(
        padding: const EdgeInsets.all(16),
        child: SvgPicture.asset(
          'assets/icons/security-shield.svg',
          width: 16,
          height: 16,
          colorFilter: const ColorFilter.mode(
            AppColors.primary,
            BlendMode.srcIn,
          ),
        ),
      ),
      suffixIcon: IconButton(
        icon: SvgPicture.asset(
          _obscureText
              ? 'assets/icons/form/eye-off.svg'
              : 'assets/icons/form/eye.svg',
          width: 16,
          height: 16,
          colorFilter: const ColorFilter.mode(
            AppColors.baseGrey,
            BlendMode.srcIn,
          ),
        ),
        onPressed: () {
          setState(() {
            _obscureText = !_obscureText;
          });
        },
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.baseLightGrey),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.baseLightGrey),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.primary),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      filled: true,
      fillColor: AppColors.white,
    );
  }

  String? _defaultValidator(String? value) {
    final l10n = AppLocalizations.of(context);
    if (value == null || value.isEmpty) {
      return l10n.enter_password ?? 'กรุณากรอก${widget.label}';
    }
    if (widget.compareController != null &&
        value != widget.compareController!.text) {
      return l10n.passwords_do_not_match ?? 'รหัสผ่านไม่ตรงกัน';
    }
    return null;
  }
}
