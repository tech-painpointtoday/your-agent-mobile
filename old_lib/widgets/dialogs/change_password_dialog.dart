import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:youragent/core/theme/app_colors.dart';

/// Change Password Dialog
/// Displays a modal dialog for changing user password
class ChangePasswordDialog extends StatefulWidget {
  const ChangePasswordDialog({super.key});

  @override
  State<ChangePasswordDialog> createState() => _ChangePasswordDialogState();

  /// Show the change password dialog
  static Future<bool?> show(BuildContext context) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: true,
      builder: (context) => const ChangePasswordDialog(),
    );
  }
}

class _ChangePasswordDialogState extends State<ChangePasswordDialog> {
  final _formKey = GlobalKey<FormState>();
  final _oldPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _obscureOldPassword = true;
  bool _obscureNewPassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    _oldPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _handleSubmit() {
    if (_formKey.currentState?.validate() ?? false) {
      Navigator.of(context).pop(true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Dialog(
      backgroundColor: AppColors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(40),
            child: Form(
              key: _formKey,
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 360),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SvgPicture.asset(
                      'assets/icons/key.svg',
                      width: 48,
                      height: 48,
                    ),
                    const SizedBox(height: 32),
                    _buildTitle(theme),
                    const SizedBox(height: 8),
                    _buildDescription(theme),
                    const SizedBox(height: 32),
                    _PasswordInputField(
                      label: 'รหัสผ่านเดิม',
                      controller: _oldPasswordController,
                      obscureText: _obscureOldPassword,
                      onToggleVisibility: () {
                        setState(
                          () => _obscureOldPassword = !_obscureOldPassword,
                        );
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'กรุณากรอกรหัสผ่านเดิม';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    _PasswordInputField(
                      label: 'รหัสผ่านใหม่',
                      controller: _newPasswordController,
                      obscureText: _obscureNewPassword,
                      onToggleVisibility: () {
                        setState(
                          () => _obscureNewPassword = !_obscureNewPassword,
                        );
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'กรุณากรอกรหัสผ่านใหม่';
                        }
                        if (value.length < 8) {
                          return 'รหัสผ่านต้องมีอย่างน้อย 8 ตัวอักษร';
                        }
                        if (!RegExp(
                          r'^(?=.*[a-zA-Z])(?=.*\d)',
                        ).hasMatch(value)) {
                          return 'รหัสผ่านต้องประกอบด้วยตัวอักษรและตัวเลข';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    _PasswordInputField(
                      label: 'ยืนยันรหัสผ่านใหม่',
                      controller: _confirmPasswordController,
                      obscureText: _obscureConfirmPassword,
                      onToggleVisibility: () {
                        setState(
                          () => _obscureConfirmPassword =
                              !_obscureConfirmPassword,
                        );
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'กรุณายืนยันรหัสผ่านใหม่';
                        }
                        if (value != _newPasswordController.text) {
                          return 'รหัสผ่านไม่ตรงกัน';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 32),
                    _buildSubmitButton(theme),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            top: 32,
            right: 32,
            child: IconButton(
              icon: SvgPicture.asset(
                'assets/icons/x.svg',
                width: 24,
                height: 24,
                colorFilter: ColorFilter.mode(
                  theme.colorScheme.onSurface.withValues(alpha: 0.75),
                  BlendMode.srcIn,
                ),
              ),
              onPressed: () => Navigator.of(context).pop(false),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTitle(ThemeData theme) {
    return Text(
      'เปลี่ยนรหัสผ่าน',
      style: theme.textTheme.headlineLarge?.copyWith(
        fontWeight: FontWeight.w600,
        color: AppColors.cardLabelPrimary,
      ),
      textAlign: TextAlign.center,
    );
  }

  Widget _buildDescription(ThemeData theme) {
    return Text(
      'รหัสผ่านของคุณต้องมีอย่างน้อย 8 ตัวอักษร\nและประกอบด้วยตัวอักษรและตัวเลข',
      style: theme.textTheme.bodyLarge?.copyWith(
        color: AppColors.avatarLabelSecondary,
      ),
      textAlign: TextAlign.center,
    );
  }

  Widget _buildSubmitButton(ThemeData theme) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _handleSubmit,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.buttonPrimary,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          minimumSize: const Size(double.infinity, 48),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Text(
          'เปลี่ยนรหัสผ่าน',
          style: theme.textTheme.bodyLarge?.copyWith(
            fontWeight: FontWeight.w600,
            color: AppColors.white,
          ),
        ),
      ),
    );
  }
}

class _PasswordInputField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final bool obscureText;
  final VoidCallback onToggleVisibility;
  final String? Function(String?)? validator;

  const _PasswordInputField({
    required this.label,
    required this.controller,
    required this.obscureText,
    required this.onToggleVisibility,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              label,
              style: theme.textTheme.titleSmall?.copyWith(
                color: AppColors.cardLabelPrimary,
              ),
            ),
            const SizedBox(width: 4),
            Text(
              '*',
              style: theme.textTheme.titleSmall?.copyWith(
                color: AppColors.ruby500,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          obscureText: obscureText,
          validator: validator,
          decoration: InputDecoration(
            hintText: label,
            hintStyle: theme.textTheme.bodyLarge?.copyWith(
              color: AppColors.cardLabelSecondary,
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
            filled: true,
            fillColor: AppColors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: AppColors.buttonStrokeOutlinedRdDefault,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: AppColors.buttonStrokeOutlinedRdDefault,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.primary),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.supportRedDeep),
            ),
            suffixIcon: IconButton(
              icon: SvgPicture.asset(
                obscureText
                    ? 'assets/icons/form/eye-off.svg'
                    : 'assets/icons/form/eye.svg',
                width: 14,
                height: 14,
                colorFilter: ColorFilter.mode(
                  AppColors.avatarLabelSecondary,
                  BlendMode.srcIn,
                ),
              ),
              onPressed: onToggleVisibility,
            ),
          ),
        ),
      ],
    );
  }
}
