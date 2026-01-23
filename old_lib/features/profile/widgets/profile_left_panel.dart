import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:image_picker/image_picker.dart';
import 'package:youragent/core/theme/app_colors.dart';
import 'package:youragent/data/models/user_profile_model.dart';
import 'package:youragent/widgets/dialogs/status_dialog.dart';

import 'profile_avatar.dart';
import 'profile_info_row.dart';
import 'profile_section_chip.dart';
import '../bloc/profile_bloc.dart';

class ProfileLeftPanel extends StatelessWidget {
  final UserProfileModel profile;
  final VoidCallback onAvatarEdit;
  final XFile? selectedImage;

  const ProfileLeftPanel({
    super.key,
    required this.profile,
    required this.onAvatarEdit,
    this.selectedImage,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Format phone number
    final phoneText = profile.mobileNumber ?? '-';

    // Format company name
    final companyText = profile.companyName ?? '-';

    // Format radius
    final radiusText = profile.reachableRadius != null
        ? 'รัศมีการทำงาน ${profile.reachableRadius!.toStringAsFixed(2)} ก.ม.'
        : '-';

    // Format bio
    final bioText = profile.bio ?? '-';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ProfileAvatar(
          name: profile.name,
          onEditPressed: onAvatarEdit,
          selectedImage: selectedImage,
          profilePhoto: profile.profilePhoto,
        ),
        const SizedBox(height: 18),
        Text(
          profile.name,
          style: theme.textTheme.headlineMedium?.copyWith(
            color: AppColors.avatarLabelPrimary,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          profile.email,
          style: theme.textTheme.bodyLarge?.copyWith(
            color: AppColors.avatarLabelSecondary,
          ),
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 14),
        _EmailVerifiedChip(
          isVerified: profile.isEmailVerified,
          email: profile.email,
        ),
        const SizedBox(height: 18),
        ProfileInfoRow(
          svgAsset: 'assets/icons/profile/phone-2.svg',
          text: phoneText,
        ),
        const SizedBox(height: 12),
        ProfileInfoRow(
          svgAsset: 'assets/icons/profile/briefcase-2.svg',
          text: companyText,
        ),
        const SizedBox(height: 12),
        ProfileInfoRow(
          svgAsset: 'assets/icons/profile/radius-2.svg',
          text: radiusText,
        ),
        const SizedBox(height: 22),
        const ProfileSectionChip(text: 'ประวัติส่วนตัว'),
        const SizedBox(height: 12),
        Text(
          bioText,
          style: theme.textTheme.bodyLarge?.copyWith(
            color: AppColors.baseLabelSecondary,
          ),
        ),
      ],
    );
  }
}

class _EmailVerifiedChip extends StatelessWidget {
  final bool isVerified;
  final String email;

  const _EmailVerifiedChip({required this.isVerified, required this.email});

  Future<void> _handleResendVerification(BuildContext context) async {
    final confirmed = await StatusDialog.showConfirmation(
      context: context,
      title: 'ส่งอีเมลยืนยัน',
      message: 'คุณต้องการส่งอีเมลยืนยันไปยัง $email หรือไม่?',
      confirmText: 'ส่งอีเมล',
      cancelText: 'ยกเลิก',
    );

    if (confirmed && context.mounted) {
      context.read<ProfileBloc>().add(
        const ProfileResendVerificationRequested(),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Warning styling when not verified
    if (!isVerified) {
      const warningColor = AppColors.warning600;
      final bg = warningColor.withValues(alpha: 0.12);
      const fg = warningColor;

      return Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _handleResendVerification(context),
          borderRadius: BorderRadius.circular(999),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: bg,
              borderRadius: BorderRadius.circular(999),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                SvgPicture.asset(
                  'assets/icons/alert-triangle.svg',
                  width: 12,
                  height: 12,
                  colorFilter: const ColorFilter.mode(fg, BlendMode.srcIn),
                ),
                const SizedBox(width: 8),
                Text(
                  'ยังไม่ยืนยันอีเมล',
                  style: theme.textTheme.bodyMedium?.copyWith(color: fg),
                ),
              ],
            ),
          ),
        ),
      );
    }

    // Success styling when verified
    const greenColor = AppColors.statusConfirmedText;
    final bg = greenColor.withValues(alpha: 0.12);
    const fg = greenColor;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SvgPicture.asset(
            'assets/icons/profile/check-2.svg',
            width: 12,
            height: 12,
          ),
          const SizedBox(width: 8),
          Text(
            'ยืนยันอีเมลแล้ว',
            style: theme.textTheme.bodyMedium?.copyWith(color: fg),
          ),
        ],
      ),
    );
  }
}
