import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:youragent/core/theme/app_colors.dart';
import 'package:youragent/data/models/user_profile_model.dart';

import 'profile_left_panel.dart';
import 'profile_right_panel.dart';
import 'profile_constants.dart';

class ProfileCard extends StatefulWidget {
  final UserProfileModel profile;

  const ProfileCard({super.key, required this.profile});

  @override
  State<ProfileCard> createState() => _ProfileCardState();
}

class _ProfileCardState extends State<ProfileCard> {
  final ImagePicker _imagePicker = ImagePicker();
  XFile? _selectedImage;

  Future<void> _handleAvatarEdit() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );
      if (image != null && mounted) {
        setState(() {
          _selectedImage = image;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('อัปโหลดรูปภาพสำเร็จ'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('เกิดข้อผิดพลาด: $e'),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(
          maxWidth: ProfileConstants.maxContentWidth,
        ),
        child: Material(
          color: AppColors.white,
          elevation: 2,
          shadowColor: theme.shadowColor.withValues(alpha: 0.08),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(ProfileConstants.cardRadius),
            side: BorderSide(
              color: AppColors.dividerLight.withValues(alpha: 0.5),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(32),
                child: Text(
                  'โปรไฟล์ของฉัน',
                  style: theme.textTheme.headlineMedium?.copyWith(
                    color: AppColors.cardLabelPrimary,
                  ),
                ),
              ),
              Divider(height: 1, color: AppColors.dividerLight),
              const SizedBox(height: 24),
              Padding(
                padding: const EdgeInsets.all(32),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final isNarrow = constraints.maxWidth < 860;

                    if (isNarrow) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ProfileLeftPanel(
                            profile: widget.profile,
                            onAvatarEdit: _handleAvatarEdit,
                            selectedImage: _selectedImage,
                          ),
                          const SizedBox(height: 28),
                          Divider(height: 1, color: AppColors.dividerLight),
                          const SizedBox(height: 28),
                          ProfileRightPanel(profile: widget.profile),
                        ],
                      );
                    }

                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          width: ProfileConstants.leftPanelWidth,
                          child: ProfileLeftPanel(
                            profile: widget.profile,
                            onAvatarEdit: _handleAvatarEdit,
                            selectedImage: _selectedImage,
                          ),
                        ),
                        const SizedBox(width: 40),
                        Expanded(
                          child: ProfileRightPanel(profile: widget.profile),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
