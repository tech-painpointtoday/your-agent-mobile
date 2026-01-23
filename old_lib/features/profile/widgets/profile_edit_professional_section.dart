import 'package:flutter/material.dart';
import 'package:youragent/widgets/form_fields/app_text_form_field.dart';
import 'package:youragent/widgets/profile/profile_section_header.dart';

/// Professional Information Section
class ProfileEditProfessionalSection extends StatelessWidget {
  final TextEditingController companyController;
  final TextEditingController licenseController;
  final TextEditingController experienceController;
  final TextEditingController languagesController;
  final TextEditingController socialLinksController;

  const ProfileEditProfessionalSection({
    super.key,
    required this.companyController,
    required this.licenseController,
    required this.experienceController,
    required this.languagesController,
    required this.socialLinksController,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const ProfileSectionHeader(
          iconAsset: 'assets/icons/profile/briefcase-2.svg',
          title: 'ข้อมูลอาชีพ',
        ),
        const SizedBox(height: 24),
        Wrap(
          spacing: 16,
          runSpacing: 24,
          children: [
            SizedBox(
              width: 248,
              child: AppTextFormField(
                label: 'ชื่อบริษัท',
                controller: companyController,
              ),
            ),
            SizedBox(
              width: 248,
              child: AppTextFormField(
                label: 'หมายเลขใบอนุญาต',
                controller: licenseController,
                hintText: 'หมายเลขใบอนุญาต',
              ),
            ),
            SizedBox(
              width: 248,
              child: AppTextFormField(
                label: 'ประสบการณ์ทำงาน (ปี)',
                controller: experienceController,
                keyboardType: TextInputType.number,
                hintText: '0',
              ),
            ),
            SizedBox(
              width: 248,
              child: AppTextFormField(
                label: 'ความถนัดด้านภาษา',
                controller: languagesController,
                hintText: 'เช่น ไทย, อังกฤษ, จีน',
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        SizedBox(
          width: 1040,
          child: AppTextFormField(
            label: 'ลิงก์โซเชียล',
            controller: socialLinksController,
            maxLines: 3,
            hintText: 'เช่น LinkedIn, Facebook, Instagram, ...',
          ),
        ),
      ],
    );
  }
}
