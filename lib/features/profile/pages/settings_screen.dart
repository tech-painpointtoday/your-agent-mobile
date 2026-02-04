import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:youragent/core/theme/app_colors.dart';
import 'package:youragent/features/auth/bloc/auth_bloc.dart';
import 'package:youragent/features/auth/bloc/auth_event.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:youragent/features/profile/widgets/language_selection_bottom_sheet.dart';
import 'package:youragent/widgets/dialogs/status_dialog.dart';
import 'package:youragent/l10n/app_localizations.dart';

class SettingsScreen extends StatelessWidget {
  final Function(Locale) changeLocale;
  const SettingsScreen({super.key, required this.changeLocale});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        elevation: 0,
        centerTitle: false,
        title: Text(
          AppLocalizations.of(context)!.settingsTitle,
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
              _SettingsItem(
                icon: 'assets/icons/user.svg',
                label: AppLocalizations.of(context)!.accountManagementTitle,
                onTap: () => context.push('/profile/settings/account'),
              ),
              _SettingsItem(
                icon: 'assets/icons/globe.svg',
                label: AppLocalizations.of(context)!.change_language,
                onTap: () {
                  LanguageSelectionBottomSheet.show(
                    context: context,
                    currentLocale: Localizations.localeOf(context),
                    onLanguageSelected: changeLocale,
                  );
                },
              ),
              _SettingsItem(
                icon: 'assets/icons/bell.svg',
                label: AppLocalizations.of(context)!.notificationSettingsLabel,
                onTap: () {},
              ),
              _SettingsItem(
                icon: 'assets/icons/settings.svg',
                label: AppLocalizations.of(context)!.matchingSettingsLabel,
                onTap: () {},
              ),
              _SettingsItem(
                icon: 'assets/icons/clipboard-2.svg',
                label: AppLocalizations.of(context)!.termsLabel,
                onTap: () {},
              ),
              _SettingsItem(
                icon: 'assets/icons/security-shield.svg',
                label: AppLocalizations.of(context)!.privacyLabel,
                onTap: () {},
              ),
              _SettingsItem(
                icon: 'assets/icons/message-information.svg',
                label: AppLocalizations.of(context)!.contactUsLabel,
                onTap: () {},
              ),
              const SizedBox(height: 8),
              _SettingsItem(
                icon: 'assets/icons/logout.svg',
                label: AppLocalizations.of(context)!.logout_button,
                labelColor: AppColors.supportRedDark,
                iconColor: AppColors.supportRedDark,
                backgroundColor: AppColors.supportRedLight.withValues(
                  alpha: 0.5,
                ),
                showChevron: false,
                onTap: () => _handleLogout(context),
              ),
              const SizedBox(height: 48),
              FutureBuilder<PackageInfo>(
                future: PackageInfo.fromPlatform(),
                builder: (context, snapshot) {
                  final version = snapshot.data?.version ?? '1.0.0';
                  return Center(
                    child: Text(
                      'Version $version',
                      style: GoogleFonts.anuphan(
                        fontSize: 14,
                        color: AppColors.baseGrey,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  void _handleLogout(BuildContext context) {
    StatusDialog.showDestructive(
      context: context,
      title: AppLocalizations.of(context)!.logoutConfirmTitle,
      message: AppLocalizations.of(context)!.logoutConfirmMessage,
      actionLabel: AppLocalizations.of(context)!.logout_button,
      onAction: () {
        context.read<AuthBloc>().add(const SignOutEvent());
      },
    );
  }
}

class _SettingsItem extends StatelessWidget {
  final String icon;
  final String label;
  final VoidCallback onTap;
  final Color? labelColor;
  final Color? iconColor;
  final Color? backgroundColor;
  final bool showChevron;

  const _SettingsItem({
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
              SvgPicture.asset(
                'assets/icons/chevron-right.svg',
                width: 18,
                height: 18,
                fit: BoxFit.scaleDown,
                colorFilter: ColorFilter.mode(
                  AppColors.baseGrey,
                  BlendMode.srcIn,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
