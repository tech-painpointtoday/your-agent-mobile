import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:youragent/core/theme/app_colors.dart';
import 'package:youragent/domain/entities/property.dart';
import 'package:youragent/core/di/dependency_injection.dart';
import 'edit_property_form_screen.dart';
import 'package:youragent/l10n/app_localizations.dart';

class EditPropertyMenuScreen extends StatefulWidget {
  final Property property;

  const EditPropertyMenuScreen({super.key, required this.property});

  @override
  State<EditPropertyMenuScreen> createState() => _EditPropertyMenuScreenState();
}

class _EditPropertyMenuScreenState extends State<EditPropertyMenuScreen> {
  late Property _property;
  bool _hasChanges = false;
  final _propertyApiService = DependencyInjection.propertyApiService;

  @override
  void initState() {
    super.initState();
    _property = widget.property;
  }

  Future<void> _refreshProperty() async {
    if (_property.id == null) return;
    try {
      final updated = await _propertyApiService.getPropertyById(_property.id!);
      if (updated != null && mounted) {
        setState(() {
          _property = updated;
          _hasChanges = true;
        });
      }
    } catch (e) {
      debugPrint('Error refreshing property: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      appBar: AppBar(
        title: Text(
          AppLocalizations.of(context).editDataTitle,
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
            width: 18,
            height: 18,
            fit: BoxFit.contain,
            colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
          ),
          onPressed: () => Navigator.of(context).pop(_hasChanges),
        ),
      ),
      body: Container(
        margin: const EdgeInsets.only(top: 16),
        height: double.infinity,
        decoration: const BoxDecoration(
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
                title: AppLocalizations.of(context).general_information,
                subtitle: AppLocalizations.of(context).generalInfoSubtitle,
                iconPath: 'assets/icons/info.svg',
                iconColor: AppColors.brandBlue,
                bgColor: AppColors.supportBlueLight,
                onTap: () async {
                  final result = await context.push(
                    '/property/edit-form',
                    extra: {
                      'property': _property,
                      'stepType': EditPropertyStepType.generalInfo,
                      'title': AppLocalizations.of(context).general_information,
                    },
                  );
                  if (result == true) {
                    _refreshProperty();
                  }
                },
              ),
              const SizedBox(height: 16),
              _buildMenuItem(
                context,
                title: AppLocalizations.of(context).property_details_section,
                subtitle: AppLocalizations.of(context).propertyDetailSubtitle,
                iconPath: 'assets/icons/menu.svg',
                iconColor: const Color(0xFF7F56D9), // Purple
                bgColor: const Color(0xFFF9F5FF), // Light Purple
                onTap: () async {
                  final result = await context.push(
                    '/property/edit-form',
                    extra: {
                      'property': _property,
                      'stepType': EditPropertyStepType.propertyDetail,
                      'title': AppLocalizations.of(
                        context,
                      ).property_details_section,
                    },
                  );
                  if (result == true) {
                    _refreshProperty();
                  }
                },
              ),
              const SizedBox(height: 16),
              _buildMenuItem(
                context,
                title: AppLocalizations.of(context).additional_details_section,
                subtitle: AppLocalizations.of(context).additionalInfoSubtitle,
                iconPath: 'assets/icons/star-moving.svg',
                iconColor: const Color(0xFFE94A88), // Pink
                bgColor: const Color(0xFFFDF2FA), // Light Pink
                onTap: () async {
                  final result = await context.push(
                    '/property/edit-form',
                    extra: {
                      'property': _property,
                      'stepType': EditPropertyStepType.additionalInfo,
                      'title': AppLocalizations.of(
                        context,
                      ).additional_details_section,
                    },
                  );
                  if (result == true) {
                    _refreshProperty();
                  }
                },
              ),
              const SizedBox(height: 16),
              _buildMenuItem(
                context,
                title: AppLocalizations.of(context).propertyImagesLabel,
                subtitle: AppLocalizations.of(context).propertyImagesSubtitle,
                iconPath: 'assets/icons/image.svg',
                iconColor: AppColors.supportOrangeDark,
                bgColor: AppColors.supportOrangeLight,
                onTap: () async {
                  final result = await context.push(
                    '/property/edit-form',
                    extra: {
                      'property': _property,
                      'stepType': EditPropertyStepType.propertyImages,
                      'title': AppLocalizations.of(context).propertyImagesLabel,
                    },
                  );
                  if (result == true) {
                    _refreshProperty();
                  }
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
