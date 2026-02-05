import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:youragent/core/theme/app_colors.dart';
import 'package:youragent/features/profile/widgets/account_action_sheets.dart';
import 'package:youragent/l10n/app_localizations.dart';

class AccountManagementScreen extends StatelessWidget {
  const AccountManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        elevation: 0,
        centerTitle: false,
        title: Text(
          AppLocalizations.of(context).accountManagementTitle,
          style: GoogleFonts.anuphan(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        leading: IconButton(
          icon: SvgPicture.asset(
            'assets/icons/chevron-left.svg',
            colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
          ),
          onPressed: () => context.pop(),
        ),
      ),
      body: Container(
        margin: const EdgeInsets.only(top: 16),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
          child: ListView(
            physics: const ClampingScrollPhysics(),
            padding: const EdgeInsets.symmetric(vertical: 24),
            children: [
              _AccountItem(
                icon: 'assets/icons/email.svg',
                label: AppLocalizations.of(context).requestChangeEmailLabel,
                onTap: () => AccountActionSheets.showChangeEmail(context),
              ),
              _AccountItem(
                icon: 'assets/icons/phone.svg',
                label: AppLocalizations.of(context).requestChangePhoneLabel,
                onTap: () => AccountActionSheets.showChangePhone(context),
              ),
              const SizedBox(height: 8),
              _AccountItem(
                icon: 'assets/icons/user.svg',
                label: AppLocalizations.of(context).deleteAccountLabel,
                labelColor: AppColors.supportRedDark,
                iconColor: AppColors.supportRedDark,
                backgroundColor: AppColors.supportRedLight.withValues(
                  alpha: 0.5,
                ),
                showChevron: false,
                onTap: () => AccountActionSheets.showDeleteAccount(context),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AccountItem extends StatelessWidget {
  final String icon;
  final String label;
  final VoidCallback onTap;
  final Color? labelColor;
  final Color? iconColor;
  final Color? backgroundColor;
  final bool showChevron;

  const _AccountItem({
    required this.icon,
    required this.label,
    required this.onTap,
    this.labelColor,
    this.iconColor,
    this.backgroundColor,
    this.showChevron = true,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color:
                    backgroundColor ?? AppColors.basePaleGrey.withOpacity(0.5),
                borderRadius: BorderRadius.circular(8),
              ),
              child: SvgPicture.asset(
                icon,
                colorFilter: ColorFilter.mode(
                  iconColor ?? AppColors.baseGrey,
                  BlendMode.srcIn,
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                label,
                style: GoogleFonts.anuphan(
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                  color: labelColor ?? AppColors.baseBlack,
                ),
              ),
            ),
            if (showChevron)
              const Icon(
                Icons.chevron_right,
                color: AppColors.baseLightGrey,
                size: 24,
              ),
          ],
        ),
      ),
    );
  }
}
