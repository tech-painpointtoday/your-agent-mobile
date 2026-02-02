import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:youragent/core/theme/app_colors.dart';
import 'package:youragent/widgets/buttons/app_button.dart';
import 'package:youragent/widgets/inputs/app_text_field.dart';
import 'package:youragent/widgets/dialogs/status_dialog.dart';
import '../bloc/profile_bloc.dart';
import '../pages/profile_screen.dart';

class ChangePasswordBottomSheet extends StatefulWidget {
  const ChangePasswordBottomSheet({super.key});

  static Future<void> show(BuildContext context, ProfileBloc profileBloc) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => BlocProvider.value(
        value: profileBloc,
        child: const ChangePasswordBottomSheet(),
      ),
    );
  }

  @override
  State<ChangePasswordBottomSheet> createState() =>
      _ChangePasswordBottomSheetState();
}

class _ChangePasswordBottomSheetState extends State<ChangePasswordBottomSheet> {
  final _formKey = GlobalKey<FormState>();
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isFormValid = false;

  @override
  void initState() {
    super.initState();
    _currentPasswordController.addListener(_validateForm);
    _newPasswordController.addListener(_validateForm);
    _confirmPasswordController.addListener(_validateForm);
  }

  void _validateForm() {
    final isSame =
        _newPasswordController.text == _confirmPasswordController.text;
    final isValid =
        _currentPasswordController.text.isNotEmpty &&
        (_newPasswordController.text.isNotEmpty &&
            _confirmPasswordController.text.isNotEmpty) &&
        isSame;

    if (isValid != _isFormValid) {
      setState(() {
        _isFormValid = isValid;
      });
    }
  }

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _onSave() {
    if (!_formKey.currentState!.validate()) return;

    if (_newPasswordController.text != _confirmPasswordController.text) {
      StatusDialog.showError(
        context: context,
        title: 'รหัสผ่านไม่ตรงกัน',
        message: 'กรุณาตรวจสอบรหัสผ่านใหม่และยืนยันรหัสผ่านใหม่อีกครั้ง',
      );
      return;
    }

    context.read<ProfileBloc>().add(
      ChangePassword(
        currentPassword: _currentPasswordController.text,
        newPassword: _newPasswordController.text,
        confirmPassword: _confirmPasswordController.text,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ProfileBloc, ProfileState>(
      listener: (context, state) {
        if (state is ProfileUpdateSuccess) {
          ProfileScreen.needsRefresh = true;
          Navigator.pop(context);
          StatusDialog.showSuccess(
            context: context,
            title: 'เปลี่ยนรหัสผ่านสำเร็จ',
            message: 'รหัสผ่านของคุณได้รับการเปลี่ยนเรียบร้อยแล้ว',
          );
        } else if (state is ProfileError) {
          StatusDialog.showError(
            context: context,
            title: 'เกิดข้อผิดพลาด',
            message: state.message,
          );
        }
      },
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
        ),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 12, 24, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 48,
                        height: 6,
                        decoration: BoxDecoration(
                          color: AppColors.baseLightGrey,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'เปลี่ยนรหัสผ่าน',
                      style: GoogleFonts.anuphan(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'รหัสผ่านของคุณต้องมีอย่างน้อย 8 ตัวอักษร และประกอบ ด้วยตัวอักษรและตัวเลข',
                      style: GoogleFonts.anuphan(
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        color: AppColors.baseGrey,
                      ),
                    ),
                    const SizedBox(height: 24),
                    AppTextField(
                      label: 'รหัสผ่านปัจจุบัน',
                      controller: _currentPasswordController,
                      hintText: 'กรอกรหัสผ่านปัจจุบัน',
                      obscureText: true,
                      isRequired: true,
                    ),
                    const SizedBox(height: 24),
                    AppTextField(
                      label: 'รหัสผ่านใหม่',
                      controller: _newPasswordController,
                      hintText: 'กรอกรหัสผ่านใหม่',
                      obscureText: true,
                      isRequired: true,
                    ),
                    const SizedBox(height: 24),
                    AppTextField(
                      label: 'ยืนยันรหัสผ่านใหม่',
                      controller: _confirmPasswordController,
                      hintText: 'ยืนยันรหัสผ่านใหม่',
                      obscureText: true,

                      isRequired: true,
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
              BlocBuilder<ProfileBloc, ProfileState>(
                builder: (context, state) {
                  return Container(
                    padding: EdgeInsets.fromLTRB(
                      16,
                      16,
                      16,
                      MediaQuery.of(context).viewPadding.bottom,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          spreadRadius: 1,
                          blurRadius: 3,
                          offset: const Offset(0, 1),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: AppButton(
                            text: 'ยกเลิก',
                            style: AppButtonStyle.outline,
                            onPressed: () => Navigator.pop(context),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          flex: 4,
                          child: AppButton(
                            text: 'เปลี่ยนรหัสผ่าน',
                            style: AppButtonStyle.primary,
                            isLoading: state is ProfileUpdateLoading,
                            enabled: _isFormValid,
                            onPressed: _onSave,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
