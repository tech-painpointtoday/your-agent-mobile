import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:youragent/core/theme/app_colors.dart';
import 'package:youragent/domain/entities/user.dart';
import 'package:youragent/l10n/app_localizations.dart';

class AppSidebar extends StatelessWidget {
  final UserRole role;
  final String? currentRoute;

  const AppSidebar({super.key, required this.role, this.currentRoute});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final menuItems = _getMenuItems(role, l10n);

    return Container(
      width: 240,
      color: AppColors.white,
      child: Column(
        children: [
          const SizedBox(height: 16),
          ...menuItems.map(
            (item) => _buildMenuItem(
              context,
              item['route'] as String,
              item['icon'] as IconData,
              item['label'] as String,
              item['iconAsset'] as String?,
            ),
          ),
        ],
      ),
    );
  }

  List<Map<String, dynamic>> _getMenuItems(
    UserRole role,
    AppLocalizations l10n,
  ) {
    switch (role) {
      case UserRole.agent:
        return [
          {
            'route': '/dashboard/agent',
            'icon': Icons.dashboard_outlined,
            'label': l10n.dashboard,
            'iconAsset': 'assets/images/dashboard-icon.svg',
          },
          {
            'route': '/agent/properties',
            'icon': Icons.home_work_outlined,
            'label': l10n.my_properties,
            'iconAsset': 'assets/images/properties-icon.svg',
          },
          {
            'route': '/agent/properties/create',
            'icon': Icons.add_home_outlined,
            'label': l10n.create_property,
            'iconAsset': 'assets/images/properties-icon.svg',
          },
          {
            'route': '/agent/bookings',
            'icon': Icons.event_note_outlined,
            'label': l10n.bookings,
            'iconAsset': 'assets/images/calendar-icon.svg',
          },
          {
            'route': '/agent/chats',
            'icon': Icons.chat_bubble_outline,
            'label': l10n.chats,
            'iconAsset': 'assets/images/message-icon.svg',
          },
          {
            'route': '/agent/availability',
            'icon': Icons.access_time,
            'label': l10n.time_slots,
            'iconAsset': 'assets/images/clock-icon.svg',
          },
        ];
      case UserRole.agency:
        return [
          {
            'route': '/dashboard/agency',
            'icon': Icons.dashboard_outlined,
            'label': l10n.dashboard,
            'iconAsset': 'assets/images/dashboard-icon.svg',
          },
          {
            'route': '/agency/properties',
            'icon': Icons.home_work_outlined,
            'label': l10n.properties,
            'iconAsset': 'assets/images/properties-icon.svg',
          },
          {
            'route': '/agency/bookings',
            'icon': Icons.event_note_outlined,
            'label': l10n.bookings,
            'iconAsset': 'assets/images/calendar-icon.svg',
          },
          {
            'route': '/agency/support',
            'icon': Icons.support_agent,
            'label': l10n.support,
            'iconAsset': 'assets/images/bell-icon.svg',
          },
          {
            'route': '/agency/profile',
            'icon': Icons.person_outline,
            'label': l10n.profile,
            'iconAsset': 'assets/images/settings-icon.svg',
          },
          {
            'route': '/agent/chats',
            'icon': Icons.chat_bubble_outline,
            'label': l10n.chats,
            'iconAsset': 'assets/images/message-icon.svg',
          },
        ];
    }
  }

  Widget _buildMenuItem(
    BuildContext context,
    String route,
    IconData icon,
    String label,
    String? iconAsset,
  ) {
    final isSelected =
        currentRoute == route ||
        (currentRoute != null &&
            currentRoute!.startsWith(route) &&
            route != '/dashboard/agent' &&
            route != '/dashboard/agency');

    return InkWell(
      onTap: () {
        context.go(route);
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.blue100 : Colors.transparent,
          border: isSelected
              ? Border(left: BorderSide(color: AppColors.blue600, width: 3))
              : null,
        ),
        child: Row(
          children: [
            if (iconAsset != null)
              SvgPicture.asset(
                iconAsset,
                width: 24,
                height: 24,
                colorFilter: ColorFilter.mode(
                  isSelected ? AppColors.blue600 : AppColors.baseDarkGrey,
                  BlendMode.srcIn,
                ),
              )
            else
              Icon(
                icon,
                size: 24,
                color: isSelected ? AppColors.blue600 : AppColors.baseDarkGrey,
              ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: GoogleFonts.anuphan(
                  fontSize: 14,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                  color: isSelected
                      ? AppColors.blue600
                      : AppColors.baseDarkGrey,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
