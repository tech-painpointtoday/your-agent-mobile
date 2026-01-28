import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/theme/app_colors.dart';
import '../../../widgets/buttons/app_button.dart';
import '../../../widgets/dialogs/status_dialog.dart';
import '../../../widgets/form_fields/labeled_password_field.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';

class ResetPasswordScreen extends StatefulWidget {
  final String token;
  final String email;

  const ResetPasswordScreen({
    super.key,
    required this.token,
    required this.email,
  });

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _passwordController = TextEditingController();
  final _passwordConfirmationController = TextEditingController();

  @override
  void dispose() {
    _passwordController.dispose();
    _passwordConfirmationController.dispose();
    super.dispose();
  }

  void _onConfirmPressed() {
    if (!_formKey.currentState!.validate()) return;

    StatusDialog.showConfirmation(
      context: context,
      title: 'ยืนยันการเปลี่ยนรหัสผ่าน',
      message: 'คุณแน่ใจหรือไม่ที่จะใช้รหัสผ่านนี้?',
      confirmText: 'ยืนยัน',
      cancelText: 'ยกเลิก',
      onConfirmed: () {
        context.read<AuthBloc>().add(
          AuthResetPasswordRequested(
            token: widget.token,
            email: widget.email,
            password: _passwordController.text,
            passwordConfirmation: _passwordConfirmationController.text,
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) async {
        if (state is AuthOperationState) {
          if (state.resetPasswordStatus == ResetPasswordStatus.success) {
            await StatusDialog.showSuccess(
              context: context,
              title: 'สำเร็จ',
              message: 'ตั้งรหัสผ่านใหม่สำเร็จ กรุณาเข้าสู่ระบบ',
              onDismiss: () {
                if (!mounted) return;
                context.go('/login');
              },
            );
          } else if (state.resetPasswordStatus == ResetPasswordStatus.failure) {
            await StatusDialog.showError(
              context: context,
              title: 'เกิดข้อผิดพลาด',
              message: state.errorMessage ?? 'ไม่สามารถตั้งรหัสผ่านใหม่ได้',
            );
          }
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.white,
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: IconButton(
                      onPressed: () => context.pop(),
                      icon: const Icon(Icons.arrow_back_ios_new_rounded),
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Illustration
                  Center(
                    child: Image.asset(
                      'assets/images/auth/password_reset.png',
                      width: 150,
                      height: 150,
                    ),
                  ),
                  const SizedBox(height: 32),
                  // Title
                  Text(
                    'รีเซ็ตรหัสผ่าน',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.anuphan(
                      fontSize: 28,
                      fontWeight: FontWeight.w700,
                      color: AppColors.baseDarkGrey,
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Subtitle
                  Text(
                    'กรุณาตั้งรหัสผ่านใหม่ของคุณ',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.anuphan(
                      fontSize: 14,
                      color: AppColors.baseDarkGrey,
                    ),
                  ),
                  const SizedBox(height: 32),
                  // Password Fields
                  LabeledPasswordField(
                    label: 'รหัสผ่านใหม่',
                    controller: _passwordController,
                    validator: (v) {
                      if (v == null || v.isEmpty) {
                        return 'กรุณากรอกรหัสผ่านใหม่';
                      }
                      if (v.length < 6) {
                        return 'รหัสผ่านต้องมีอย่างน้อย 6 ตัวอักษร';
                      }
                      return null;
                    },
                  ),
                  LabeledPasswordField(
                    label: 'ยืนยันรหัสผ่านใหม่',
                    controller: _passwordConfirmationController,
                    compareController: _passwordController,
                    validator: (v) {
                      if (v == null || v.isEmpty) {
                        return 'กรุณายืนยันรหัสผ่านใหม่';
                      }
                      if (v != _passwordController.text) {
                        return 'รหัสผ่านไม่ตรงกัน';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 32),
                  // Submit Button
                  AppButton(
                    text:
                        'ส่งลิงค์รีเซ็ตรหัสผ่าน', // Using exact text from image
                    style: AppButtonStyle.primary,
                    onPressed: _onConfirmPressed,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
