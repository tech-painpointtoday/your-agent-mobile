import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:youragent/core/theme/app_colors.dart';
import 'package:youragent/widgets/buttons/app_button.dart';
import 'package:youragent/widgets/inputs/app_text_field.dart';

class OwnerRegistrationBottomSheet extends StatefulWidget {
  const OwnerRegistrationBottomSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => const OwnerRegistrationBottomSheet(),
    );
  }

  @override
  State<OwnerRegistrationBottomSheet> createState() =>
      _OwnerRegistrationBottomSheetState();
}

class _OwnerRegistrationBottomSheetState
    extends State<OwnerRegistrationBottomSheet> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
              'สร้างบัญชีใหม่',
              style: GoogleFonts.anuphan(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'ลงทะเบียนข้อมูลเจ้าของทรัพย์ เพื่อทำสัญญา',
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
                    label: 'ชื่อ - นามสกุล',
                    controller: _nameController,
                    isRequired: true,
                    hintText: 'ชื่อ - นามสกุล',
                  ),
                  const SizedBox(height: 20),
                  AppTextField(
                    label: 'หมายเลขโทรศัพท์',
                    controller: _phoneController,
                    isRequired: true,
                    hintText: 'หมายเลขโทรศัพท์',
                    keyboardType: TextInputType.phone,
                  ),
                  const SizedBox(height: 20),
                  AppTextField(
                    label: 'อีเมล',
                    controller: _emailController,
                    isRequired: true,
                    hintText: 'อีเมล',
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 20),
                  AppTextField(
                    label: 'รหัสผ่าน',
                    controller: _passwordController,
                    isRequired: true,
                    hintText: 'รหัสผ่าน',
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
                    label: 'ยืนยันรหัสผ่าน',
                    controller: _confirmPasswordController,
                    isRequired: true,
                    hintText: 'ยืนยันรหัสผ่าน',
                    obscureText: _obscureConfirmPassword,
                    suffix: IconButton(
                      icon: Icon(
                        _obscureConfirmPassword
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                        color: AppColors.baseGrey,
                        size: 20,
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
                text: 'สมัครสมาชิก',
                style: AppButtonStyle.primary,
                onPressed: () {
                  // TODO: Implement registration logic
                  Navigator.pop(context);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
