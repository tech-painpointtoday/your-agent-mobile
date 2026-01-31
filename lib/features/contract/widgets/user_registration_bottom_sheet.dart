import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:youragent/core/theme/app_colors.dart';
import 'package:youragent/widgets/buttons/app_button.dart';
import 'package:youragent/widgets/inputs/app_text_field.dart';
import 'package:youragent/core/di/dependency_injection.dart';
import 'package:youragent/widgets/dialogs/status_dialog.dart';

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
          title: 'ลงทะเบียนสำเร็จ',
          message: 'บัญชีถูกสร้างเรียบร้อยแล้ว',
        );
      }
    } catch (e) {
      if (mounted) {
        StatusDialog.showError(
          context: context,
          title: 'เกิดข้อผิดพลาด',
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
    final title = 'สร้างบัญชีใหม่';
    final subtitle = widget.type == RegistrationUserType.owner
        ? 'ลงทะเบียนข้อมูลเจ้าของทรัพย์ เพื่อทำสัญญา'
        : 'ลงทะเบียนข้อมูลผู้ซื้อ เพื่อทำสัญญา';

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
                  if (widget.type == RegistrationUserType.owner) ...[
                    AppTextField(
                      label: 'ที่อยู่',
                      controller: _addressController,
                      isRequired: true,
                      hintText: 'ที่อยู่ปัจจุบัน',
                    ),
                    const SizedBox(height: 20),
                  ],
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
                text: _isLoading ? 'กำลังสมัคร...' : 'สมัครสมาชิก',
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
