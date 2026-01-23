import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:youragent/core/theme/app_colors.dart';
import 'package:youragent/data/models/user_profile_model.dart';
import 'package:youragent/widgets/dialogs/status_dialog.dart';
import 'package:youragent/features/auth/bloc/auth_bloc.dart';
import 'package:youragent/features/auth/bloc/auth_event.dart';
import 'package:youragent/features/auth/bloc/auth_state.dart';

import 'profile_account_action_tile.dart';
import 'profile_info_row.dart';
import '../bloc/profile_bloc.dart';

class ProfileRightPanel extends StatelessWidget {
  final UserProfileModel profile;

  const ProfileRightPanel({super.key, required this.profile});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final credentialCode = profile.agentCredential ?? '-';

    return MultiBlocListener(
      listeners: [
        BlocListener<ProfileBloc, ProfileState>(
          listener: (context, state) {
            // Handle other profile states if needed
          },
        ),
        BlocListener<AuthBloc, AuthState>(
          listener: (context, state) {
            if (state is AuthOperationState) {
              if (state.resendVerificationStatus == ResendVerificationStatus.success) {
                StatusDialog.showSuccess(
                  context: context,
                  title: 'ส่งอีเมลยืนยันแล้ว',
                  message: 'กรุณาตรวจสอบอีเมลของคุณ',
                );
              } else if (state.resendVerificationStatus == ResendVerificationStatus.failure) {
                StatusDialog.showError(
                  context: context,
                  title: 'เกิดข้อผิดพลาด',
                  message: state.errorMessage ?? 'ไม่สามารถส่งอีเมลยืนยันได้',
                );
              }
            }
          },
        ),
      ],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'บัญชีของคุณ',
            style: theme.textTheme.titleLarge?.copyWith(
              color: AppColors.cardLabelPrimary,
            ),
          ),
          const SizedBox(height: 14),
          Divider(height: 1, color: AppColors.dividerLight),
          const SizedBox(height: 18),
          ProfileAccountActionTile(
            title: 'ข้อมูลโปรไฟล์',
            subtitle: profile.name,
            actionText: 'แก้ไขข้อมูล',
            onActionPressed: () async {
              final result = await context.push('/profile/edit');
              // If edit was successful, refresh the profile
              if (result == true && context.mounted) {
                context.read<ProfileBloc>().add(const ProfileLoadRequested());
              }
            },
          ),
          const SizedBox(height: 20),
          ProfileAccountActionTile(
            title: 'รหัสผ่าน',
            subtitle:
                'กรุณาเปลี่ยนรหัสผ่านทุก 3-6 เดือน เพื่อความปลอดภัยของบัญชี',
            actionText: 'เปลี่ยนรหัสผ่าน',
            onActionPressed: () =>
                StatusDialog.showChangePassword(context: context),
          ),
          if (!profile.isEmailVerified) ...[
            const SizedBox(height: 20),
            ProfileAccountActionTile(
              title: 'ยืนยันอีเมล',
              subtitle: 'กรุณายืนยันอีเมลเพื่อใช้งานระบบได้อย่างสมบูรณ์',
              actionText: 'ส่งอีเมลยืนยัน',
              onActionPressed: () => _handleResendVerification(context),
            ),
          ],
          const SizedBox(height: 26),
          Text(
            'รหัสประจำตัว',
            style: theme.textTheme.titleLarge?.copyWith(
              color: AppColors.cardLabelPrimary,
            ),
          ),
          const SizedBox(height: 14),
          Divider(height: 1, color: AppColors.dividerLight),
          const SizedBox(height: 18),
          Text(
            'รหัสเพื่อเชื่อมต่อกับบริษัท',
            style: theme.textTheme.bodyLarge?.copyWith(
              color: AppColors.cardLabelPrimary,
            ),
          ),
          const SizedBox(height: 10),
          _CredentialRow(code: credentialCode),
          const SizedBox(height: 10),
          const ProfileSmallHintText(
            text:
                'รหัสนี้สามารถใช้ได้เพียงครั้งเดียวเท่านั้น แชร์รหัสประจำตัวของคุณ\n'
                'กับบริษัทเพื่อให้สามารถเพิ่มคุณในรายชื่อของพวกเขาได้',
          ),
        ],
      ),
    );
  }

  void _handleResendVerification(BuildContext context) {
    context.read<AuthBloc>().add(const AuthResendVerificationRequested());
  }
}

class _CredentialRow extends StatelessWidget {
  final String code;

  const _CredentialRow({required this.code});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      children: [
        Expanded(
          child: Text(
            code,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: AppColors.cardLabelPrimary,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const SizedBox(width: 16),
        OutlinedButton.icon(
          onPressed: () {
            Clipboard.setData(ClipboardData(text: code));
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('คัดลอกแล้ว'),
                duration: Duration(seconds: 2),
              ),
            );
          },
          icon: SvgPicture.asset(
            'assets/icons/profile/copy-1.svg',
            width: 18,
            height: 18,
            colorFilter: ColorFilter.mode(
              theme.colorScheme.onSurface.withValues(alpha: 0.75),
              BlendMode.srcIn,
            ),
          ),
          label: Text(
            'คัดลอก',
            style: theme.textTheme.labelLarge?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.75),
            ),
          ),
          style: OutlinedButton.styleFrom(
            backgroundColor: AppColors.buttonContainerOutlinedDefault,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 18),
            side: const BorderSide(
              color: AppColors.buttonStrokeOutlinedRdDefault,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ],
    );
  }
}
