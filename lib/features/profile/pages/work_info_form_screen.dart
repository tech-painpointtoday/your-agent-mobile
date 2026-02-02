import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/theme/app_colors.dart';
import '../../../widgets/badges/app_badge.dart';
import '../../../widgets/buttons/app_button.dart';
import '../../../widgets/inputs/app_text_field.dart';
import '../../../widgets/dialogs/status_dialog.dart';
import '../bloc/profile_bloc.dart';
import '../models/agent_profile.dart';
import 'profile_screen.dart';

class WorkInfoFormScreen extends StatefulWidget {
  final AgentDetails? agent;

  const WorkInfoFormScreen({super.key, this.agent});

  @override
  State<WorkInfoFormScreen> createState() => _WorkInfoFormScreenState();
}

class _WorkInfoFormScreenState extends State<WorkInfoFormScreen> {
  late final TextEditingController _companyController;
  late final TextEditingController _licenseController;
  late final TextEditingController _experienceController;
  late final TextEditingController _languagesController;
  late final TextEditingController _socialLinksController;

  @override
  void initState() {
    super.initState();
    _companyController = TextEditingController(text: widget.agent?.companyName);
    _licenseController = TextEditingController(
      text: widget.agent?.licenseNumber,
    );
    _experienceController = TextEditingController(
      text: widget.agent?.yearsOfExperience?.toString() ?? '0',
    );
    _languagesController = TextEditingController(
      text: widget.agent?.languages?.join(', ') ?? '',
    );
    _socialLinksController = TextEditingController(
      text: widget.agent?.socialLinks?.values.join(', ') ?? '',
    );
  }

  @override
  void dispose() {
    _companyController.dispose();
    _licenseController.dispose();
    _experienceController.dispose();
    _languagesController.dispose();
    _socialLinksController.dispose();
    super.dispose();
  }

  void _onSave() {
    final data = {
      'company_name': _companyController.text.trim(),
      'license_number': _licenseController.text.trim(),
      'years_of_experience':
          int.tryParse(_experienceController.text.trim()) ?? 0,
      'languages': _languagesController.text
          .split(',')
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .toList(),
      'social_links': {'links': _socialLinksController.text.trim()},
    };

    StatusDialog.confirm(
      context: context,
      title: 'บันทึกข้อมูลการทำงาน?',
      message: 'คุณต้องการบันทึกข้อมูลการทำงานนี้ใช่หรือไม่?',
      actionLabel: 'บันทึก',
      onAction: () {
        context.read<ProfileBloc>().add(UpdateWorkInfo(data));
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: context.read<ProfileBloc>(),
      child: BlocListener<ProfileBloc, ProfileState>(
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
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const AppBadge(
                          label: 'ข้อมูลการทำงาน',
                          color: BadgeColor.blue,
                          style: BadgeStyle.plain,
                        ),
                        const SizedBox(height: 24),
                        AppTextField(
                          label: 'ชื่อบริษัท',
                          hintText: 'ชื่อบริษัท',
                          controller: _companyController,
                        ),
                        const SizedBox(height: 16),
                        AppTextField(
                          label: 'หมายเลขใบอนุญาต',
                          hintText: 'หมายเลขใบอนุญาต',
                          controller: _licenseController,
                        ),
                        const SizedBox(height: 16),
                        AppTextField(
                          label: 'ประสบการณ์ทำงาน (ปี)',
                          hintText: '0',
                          controller: _experienceController,
                          keyboardType: TextInputType.number,
                        ),
                        const SizedBox(height: 16),
                        AppTextField(
                          label: 'ความถนัดด้านภาษา',
                          hintText: 'เช่น ไทย, อังกฤษ, จีน',
                          controller: _languagesController,
                        ),
                        const SizedBox(height: 16),
                        AppTextField(
                          label: 'ลิงก์โซเชียล',
                          hintText: 'เช่น LinkedIn, Facebook, Instagram, ...',
                          controller: _socialLinksController,
                          maxLines: 4,
                        ),
                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
                ),
                _buildBottomButtons(context),
              ],
            ),
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
        'เพิ่มข้อมูลการทำงาน',
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
            color: Colors.black.withOpacity(0.05),
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
