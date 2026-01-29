import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:youragent/core/theme/app_colors.dart';
import 'package:youragent/domain/entities/property.dart';
import 'edit_property_form_screen.dart';

class EditPropertyMenuScreen extends StatelessWidget {
  final Property property;

  const EditPropertyMenuScreen({super.key, required this.property});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      appBar: AppBar(
        title: Text(
          'แก้ไขข้อมูล',
          style: GoogleFonts.anuphan(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),

        backgroundColor: AppColors.primary,
        elevation: 0,
        leading: IconButton(
          icon: SvgPicture.asset(
            'assets/icons/chevron-left.svg',
            colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Container(
        margin: EdgeInsets.only(top: 16),
        height: double.infinity,
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              _buildMenuItem(
                context,
                title: 'ข้อมูลทั่วไป',
                subtitle: 'ชื่ออสังหาริมทรัพย์ และที่อยู่',
                iconPath: 'assets/icons/info.svg',
                iconColor: AppColors.brandBlue,
                bgColor: AppColors.supportBlueLight,
                onTap: () {
                  context.push(
                    '/property/edit-form',
                    extra: {
                      'property': property,
                      'stepType': EditPropertyStepType.generalInfo,
                      'title': 'ข้อมูลทั่วไป',
                    },
                  );
                },
              ),
              // const SizedBox(height: 16),
              // _buildMenuItem(
              //   context,
              //   title: 'ตำแหน่งทรัพย์',
              //   subtitle: 'ตำแหน่งทรัพย์บนแผนที่',
              //   iconPath: 'assets/icons/map-pin.svg',
              //   iconColor: AppColors.brandGreen,
              //   bgColor: AppColors.supportGreenLight,
              //   onTap: () {
              //     context.push(
              //       '/property/edit-form',
              //       extra: {
              //         'property': property,
              //         'stepType': EditPropertyStepType.generalInfo,
              //         'title': 'ตำแหน่งทรัพย์',
              //       },
              //     );
              //   },
              // ),
              const SizedBox(height: 16),
              _buildMenuItem(
                context,
                title: 'รายละเอียดทรัพย์',
                subtitle: 'รายละเอียดห้อง ขนาด และราคา',
                iconPath: 'assets/icons/menu.svg',
                iconColor: const Color(0xFF7F56D9), // Purple
                bgColor: const Color(0xFFF9F5FF), // Light Purple
                onTap: () {
                  context.push(
                    '/property/edit-form',
                    extra: {
                      'property': property,
                      'stepType': EditPropertyStepType.propertyDetail,
                      'title': 'รายละเอียดทรัพย์',
                    },
                  );
                },
              ),
              const SizedBox(height: 16),
              _buildMenuItem(
                context,
                title: 'รายละเอียดเพิ่มเติม',
                subtitle: 'สไตล์การตกแต่ง จุดเด่น และส่วนกลาง',
                iconPath: 'assets/icons/star-moving.svg',
                iconColor: const Color(0xFFE94A88), // Pink
                bgColor: const Color(0xFFFDF2FA), // Light Pink
                onTap: () {
                  context.push(
                    '/property/edit-form',
                    extra: {
                      'property': property,
                      'stepType': EditPropertyStepType.additionalInfo,
                      'title': 'รายละเอียดเพิ่มเติม',
                    },
                  );
                },
              ),
              const SizedBox(height: 16),
              _buildMenuItem(
                context,
                title: 'รูปภาพทรัพย์',
                subtitle: 'อัปโหลดรูปภาพอย่างน้อย 5 รูป',
                iconPath: 'assets/icons/image.svg',
                iconColor: AppColors.supportOrangeDark,
                bgColor: AppColors.supportOrangeLight,
                onTap: () {
                  context.push(
                    '/property/edit-form',
                    extra: {
                      'property': property,
                      'stepType': EditPropertyStepType.propertyImages,
                      'title': 'รูปภาพทรัพย์',
                    },
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMenuItem(
    BuildContext context, {
    required String title,
    required String subtitle,
    required String iconPath,
    required Color iconColor,
    required Color bgColor,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          // No border in screenshot, just clean list. Maybe separate screens usually have standard list look.
          // Screenshot shows no borders or shadow, effectively "flat" or subtle.
          // I'll add a very subtle transparent border to keep spacing if needed, but standard Row is fine.
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: bgColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: SvgPicture.asset(
                iconPath,
                colorFilter: ColorFilter.mode(iconColor, BlendMode.srcIn),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.anuphan(
                      color: AppColors.baseBlack,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: GoogleFonts.anuphan(
                      color: AppColors.baseDarkGrey,
                      fontSize: 10,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),
            SvgPicture.asset(
              'assets/icons/chevron-right.svg',
              colorFilter: const ColorFilter.mode(
                AppColors.baseGrey,
                BlendMode.srcIn,
              ),
              width: 20,
              height: 20,
            ),
          ],
        ),
      ),
    );
  }
}
