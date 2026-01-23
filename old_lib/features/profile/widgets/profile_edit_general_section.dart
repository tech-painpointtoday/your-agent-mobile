import 'package:flutter/material.dart';
import 'package:youragent/widgets/form_fields/app_text_form_field.dart';
import 'package:youragent/widgets/profile/profile_section_header.dart';

/// General Information Section
class ProfileEditGeneralSection extends StatelessWidget {
  final TextEditingController nameController;
  final TextEditingController emailController;
  final TextEditingController phoneController;
  final TextEditingController bioController;

  const ProfileEditGeneralSection({
    super.key,
    required this.nameController,
    required this.emailController,
    required this.phoneController,
    required this.bioController,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const ProfileSectionHeader(
          iconAsset: 'assets/icons/profile/info.svg',
          title: 'ข้อมูลทั่วไป',
        ),
        const SizedBox(height: 24),
        Wrap(
          spacing: 16,
          runSpacing: 24,
          children: [
            SizedBox(
              width: 248,
              child: AppTextFormField(
                label: 'ชื่อ-นามสกุล',
                controller: nameController,
                isRequired: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'กรุณากรอกชื่อ-นามสกุล';
                  }
                  return null;
                },
              ),
            ),
            SizedBox(
              width: 248,
              child: AppTextFormField(
                label: 'อีเมล',
                hintText: 'olivia@painpointtoday.com',
                controller: emailController,
                keyboardType: TextInputType.emailAddress,
                isRequired: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'กรุณากรอกอีเมล';
                  }
                  if (!value.contains('@')) {
                    return 'กรุณากรอกอีเมลที่ถูกต้อง';
                  }
                  return null;
                },
              ),
            ),
            SizedBox(
              width: 248,
              child: AppTextFormField(
                label: 'หมายเลขโทรศัพท์',
                controller: phoneController,
                keyboardType: TextInputType.phone,
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        SizedBox(
          width: 1040,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppTextFormField(
                label: 'ประวัติส่วนตัว',
                controller: bioController,
                maxLines: 6,
                hintText: 'บอกเราเกี่ยวกับตัวคุณ...',
              ),
            ],
          ),
        ),
      ],
    );
  }
}
