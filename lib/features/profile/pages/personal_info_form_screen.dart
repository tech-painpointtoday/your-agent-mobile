import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../widgets/badges/app_badge.dart';
import '../../../widgets/buttons/app_button.dart';
import '../../../widgets/inputs/app_text_field.dart';
import '../../../widgets/dialogs/status_dialog.dart';
import '../../../widgets/modals/app_confirmation_bottom_sheet.dart';
import '../bloc/profile_bloc.dart';
import '../models/agent_profile.dart';
import 'profile_screen.dart';

class PersonalInfoFormScreen extends StatefulWidget {
  final AgentDetails? agent;

  const PersonalInfoFormScreen({super.key, this.agent});

  @override
  State<PersonalInfoFormScreen> createState() => _PersonalInfoFormScreenState();
}

class _PersonalInfoFormScreenState extends State<PersonalInfoFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _emailController;
  late final TextEditingController _phoneController;
  late final TextEditingController _bioController;
  late final TextEditingController _nationalIdController;
  late final TextEditingController _addressController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.agent?.name);
    _emailController = TextEditingController(text: widget.agent?.email);
    _phoneController = TextEditingController(text: widget.agent?.mobileNumber);
    _bioController = TextEditingController(text: widget.agent?.bio);
    _nationalIdController = TextEditingController(
      text: widget.agent?.nationalId,
    );
    _addressController = TextEditingController(text: widget.agent?.address);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _bioController.dispose();
    _nationalIdController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  void _onSave() {
    if (!_formKey.currentState!.validate()) return;

    final data = {
      'name': _nameController.text.trim(),
      'email': _emailController.text.trim(),
      'mobile_number': _phoneController.text.trim(),
      'bio': _bioController.text.trim(),
      'national_id': _nationalIdController.text.trim(),
      'address': _addressController.text.trim(),
    };

    AppConfirmationBottomSheet.show(
      context: context,
      title: 'บันทึกข้อมูลส่วนตัว?',
      description: 'คุณต้องการบันทึกการแก้ไขข้อมูลส่วนตัวใช่หรือไม่?',
      confirmLabel: 'บันทึก',
      onConfirm: () {
        context.read<ProfileBloc>().add(UpdateWorkInfo(data));
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ProfileBloc, ProfileState>(
      listener: (context, state) {
        if (state is ProfileUpdateSuccess) {
          ProfileScreen.needsRefresh = true;
          context.pop();
        } else if (state is ProfileError) {
          StatusDialog.showError(
            context: context,
            title: 'เกิดข้อผิดพลาด',
            message: state.message,
          );
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.primary,
        appBar: _buildAppBar(context),
        body: Container(
          margin: const EdgeInsets.only(top: 16),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
          ),
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const AppBadge(
                          label: 'ข้อมูลส่วนตัว',
                          color: BadgeColor.blue,
                          style: BadgeStyle.plain,
                        ),
                        const SizedBox(height: 24),
                        AppTextField(
                          label: 'ชื่อ-นามสกุล',
                          controller: _nameController,
                          hintText: 'กรอกชื่อ-นามสกุล',
                          isRequired: true,
                        ),
                        const SizedBox(height: 16),
                        AppTextField(
                          label: 'อีเมล',
                          controller: _emailController,
                          hintText: 'example@email.com',
                          isRequired: true,
                          keyboardType: TextInputType.emailAddress,
                        ),
                        const SizedBox(height: 16),
                        AppTextField(
                          label: 'หมายเลขโทรศัพท์',
                          controller: _phoneController,
                          hintText: '0xx-xxx-xxxx',
                          isRequired: true,
                          keyboardType: TextInputType.phone,
                        ),
                        const SizedBox(height: 16),
                        AppTextField(
                          label: 'ประวัติส่วนตัว',
                          controller: _bioController,
                          hintText: 'เล่ารายละเอียดเกี่ยวกับตัวคุณ...',
                          maxLines: 5,
                        ),
                        const SizedBox(height: 16),
                        AppTextField(
                          label: 'เลขบัตรประชาชน',
                          controller: _nationalIdController,
                          hintText: 'กรอกเลขบัตรประชาชน',
                          keyboardType: TextInputType.number,
                        ),
                        const SizedBox(height: 16),
                        AppTextField(
                          label: 'ที่อยู่',
                          controller: _addressController,
                          hintText: 'กรอกที่อยู่',
                          maxLines: 3,
                        ),
                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
                ),
              ),
              _buildBottomButtons(context),
            ],
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: AppColors.primary,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(
          Icons.arrow_back_ios_new,
          color: Colors.white,
          size: 20,
        ),
        onPressed: () => context.pop(),
      ),
      title: Text(
        'แก้ไขข้อมูลส่วนตัว',
        style: GoogleFonts.anuphan(
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.w700,
        ),
      ),
      centerTitle: false,
    );
  }

  Widget _buildBottomButtons(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        24,
        16,
        24,
        16 + MediaQuery.of(context).padding.bottom,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: AppButton(
              text: 'ยกเลิก',
              style: AppButtonStyle.outline,
              onPressed: () => context.pop(),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: BlocBuilder<ProfileBloc, ProfileState>(
              builder: (context, state) {
                return AppButton(
                  text: 'บันทึก',
                  style: AppButtonStyle.primary,
                  isLoading: state is ProfileUpdateLoading,
                  onPressed: _onSave,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
