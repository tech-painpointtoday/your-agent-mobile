import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:youragent/core/theme/app_colors.dart';
import 'package:youragent/data/models/user_profile_model.dart';
import 'package:youragent/widgets/dialogs/status_dialog.dart';

import '../bloc/profile_bloc.dart';
import 'profile_edit_general_section.dart';
import 'profile_edit_professional_section.dart';
import 'profile_edit_compatibility_section.dart';
import 'profile_edit_service_area_section.dart';

/// Main profile edit form widget
class ProfileEditForm extends StatefulWidget {
  const ProfileEditForm({super.key});

  @override
  State<ProfileEditForm> createState() => _ProfileEditFormState();
}

class _ProfileEditFormState extends State<ProfileEditForm> {
  final _formKey = GlobalKey<FormState>();

  // General Information
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _bioController = TextEditingController();

  // Professional Information
  final _companyController = TextEditingController();
  final _licenseController = TextEditingController();
  final _experienceController = TextEditingController();
  final _languagesController = TextEditingController();
  final _socialLinksController = TextEditingController();

  // Compatibility
  final _compatibilityController = TextEditingController();

  // Service Area
  final _radiusController = TextEditingController();
  final _latitudeController = TextEditingController();
  final _longitudeController = TextEditingController();

  bool _isInitialized = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _bioController.dispose();
    _companyController.dispose();
    _licenseController.dispose();
    _experienceController.dispose();
    _languagesController.dispose();
    _socialLinksController.dispose();
    _compatibilityController.dispose();
    _radiusController.dispose();
    _latitudeController.dispose();
    _longitudeController.dispose();
    super.dispose();
  }

  void _initializeFromProfile(UserProfileModel profile) {
    if (_isInitialized) return;

    _nameController.text = profile.name;
    _emailController.text = profile.email;
    _phoneController.text = profile.mobileNumber ?? '';
    _bioController.text = profile.bio ?? '';
    _companyController.text = profile.companyName ?? '';
    _licenseController.text = profile.licenseNumber ?? '';
    _experienceController.text = profile.yearsOfExperience?.toString() ?? '';
    _languagesController.text = profile.languages?.join(', ') ?? '';
    _socialLinksController.text = profile.socialLinks?.join(', ') ?? '';
    _compatibilityController.text =
        profile.minCompatibilityScoreThreshold?.toString() ?? '';
    _radiusController.text = profile.reachableRadius?.toStringAsFixed(2) ?? '';
    _latitudeController.text =
        profile.serviceAreaCenterLat?.toStringAsFixed(8) ?? '';
    _longitudeController.text =
        profile.serviceAreaCenterLng?.toStringAsFixed(8) ?? '';

    _isInitialized = true;
  }

  void _handleSave() {
    if (_formKey.currentState?.validate() ?? false) {
      final profileData = <String, dynamic>{
        'name': _nameController.text.trim(),
        'mobile_number': _phoneController.text.trim().isEmpty
            ? null
            : _phoneController.text.trim(),
        'bio': _bioController.text.trim().isEmpty
            ? null
            : _bioController.text.trim(),
        'company_name': _companyController.text.trim().isEmpty
            ? null
            : _companyController.text.trim(),
        'license_number': _licenseController.text.trim().isEmpty
            ? null
            : _licenseController.text.trim(),
        'years_of_experience': _experienceController.text.trim().isEmpty
            ? null
            : int.tryParse(_experienceController.text.trim()),
        'languages': _languagesController.text.trim().isEmpty
            ? null
            : _languagesController.text
                  .trim()
                  .split(',')
                  .map((e) => e.trim())
                  .where((e) => e.isNotEmpty)
                  .toList(),
        'social_links': _socialLinksController.text.trim().isEmpty
            ? null
            : _socialLinksController.text
                  .trim()
                  .split(',')
                  .map((e) => e.trim())
                  .where((e) => e.isNotEmpty)
                  .toList(),
        'min_compatibility_score_threshold':
            _compatibilityController.text.trim().isEmpty
            ? null
            : double.tryParse(_compatibilityController.text.trim()),
        'reachable_radius': _radiusController.text.trim().isEmpty
            ? null
            : double.tryParse(_radiusController.text.trim()),
        'service_area_center_lat': _latitudeController.text.trim().isEmpty
            ? null
            : double.tryParse(_latitudeController.text.trim()),
        'service_area_center_lng': _longitudeController.text.trim().isEmpty
            ? null
            : double.tryParse(_longitudeController.text.trim()),
      };

      // Remove null values
      profileData.removeWhere((key, value) => value == null);

      context.read<ProfileBloc>().add(ProfileUpdateRequested(profileData));
    }
  }

  void _handleCancel() {
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocListener<ProfileBloc, ProfileState>(
      listener: (context, state) {
        if (state is ProfileUpdateSuccess) {
          // Show success dialog first
          StatusDialog.showSuccess(
            context: context,
            title: 'บันทึกสำเร็จ',
            message: 'อัปเดตโปรไฟล์เรียบร้อยแล้ว',
          ).then((_) {
            // Navigate back with success result after dialog closes
            if (context.mounted) {
              context.pop(true); // Return true to indicate success
            }
          });
        } else if (state is ProfileUpdateError) {
          StatusDialog.showError(
            context: context,
            title: 'เกิดข้อผิดพลาด',
            message: state.message,
          );
        }
      },
      child: BlocBuilder<ProfileBloc, ProfileState>(
        builder: (context, state) {
          if (state is ProfileLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is ProfileError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Error: ${state.message}'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      context.read<ProfileBloc>().add(
                        const ProfileLoadRequested(),
                      );
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          // Initialize form from profile data
          if (state is ProfileLoaded) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              _initializeFromProfile(state.profile);
            });
          } else if (state is ProfileUpdateSuccess) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              _initializeFromProfile(state.profile);
            });
          } else if (state is ProfileUpdating) {
            // Keep form visible while updating
          }

          return Padding(
            padding: const EdgeInsets.all(32),
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // Sticky header
                  _buildHeader(theme, state is ProfileUpdating),
                  // Form content (scrollable)
                  Expanded(
                    child: SingleChildScrollView(
                      child: Padding(
                        padding: const EdgeInsets.all(40),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ProfileEditGeneralSection(
                                nameController: _nameController,
                                emailController: _emailController,
                                phoneController: _phoneController,
                                bioController: _bioController,
                              ),
                              const SizedBox(height: 48),
                              ProfileEditProfessionalSection(
                                companyController: _companyController,
                                licenseController: _licenseController,
                                experienceController: _experienceController,
                                languagesController: _languagesController,
                                socialLinksController: _socialLinksController,
                              ),
                              const SizedBox(height: 48),
                              ProfileEditCompatibilitySection(
                                compatibilityController:
                                    _compatibilityController,
                              ),
                              const SizedBox(height: 48),
                              ProfileEditServiceAreaSection(
                                radiusController: _radiusController,
                                latitudeController: _latitudeController,
                                longitudeController: _longitudeController,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader(ThemeData theme, bool isSaving) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 32),
      decoration: BoxDecoration(
        color: AppColors.white,
        border: Border(
          bottom: BorderSide(color: AppColors.dividerLight, width: 1),
        ),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(12),
          topRight: Radius.circular(12),
        ),
      ),
      child: Row(
        children: [
          IconButton(
            icon: SvgPicture.asset(
              'assets/icons/profile/chevron-left.svg',
              width: 32,
              height: 32,
            ),
            onPressed: isSaving ? null : () => context.pop(),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'แก้ไขโปรไฟล์',
              style: theme.textTheme.headlineMedium?.copyWith(
                color: AppColors.cardLabelPrimary,
              ),
            ),
          ),
          const SizedBox(width: 16),

          SizedBox(
            height: 48,
            child: ElevatedButton.icon(
              onPressed: isSaving ? null : _handleSave,
              icon: isSaving
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          AppColors.white,
                        ),
                      ),
                    )
                  : SvgPicture.asset(
                      'assets/icons/form/save.svg',
                      width: 16,
                      height: 16,
                      colorFilter: const ColorFilter.mode(
                        AppColors.white,
                        BlendMode.srcIn,
                      ),
                    ),
              label: Text(
                'บันทึก',
                style: theme.textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.white,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.buttonPrimary,
                foregroundColor: AppColors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                minimumSize: const Size(0, 48),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
            ),
          ),
          const SizedBox(width: 16),
          SizedBox(
            height: 48,
            child: OutlinedButton(
              onPressed: isSaving ? null : _handleCancel,
              style: OutlinedButton.styleFrom(
                backgroundColor: AppColors.buttonContainerOutlinedDefault,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                side: const BorderSide(
                  color: AppColors.buttonStrokeOutlinedRdDefault,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                minimumSize: const Size(0, 48),
              ),
              child: Text(
                'ยกเลิก',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: AppColors.cardLabelSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
