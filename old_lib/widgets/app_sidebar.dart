import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:youragent/core/theme/app_colors.dart';
import 'package:youragent/domain/entities/user.dart';
import 'package:youragent/services/role_service.dart';
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
              item['hasBadge'] as bool? ?? false,
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
            'route': RoleService.getDashboardRoute(role),
            'icon': Icons.dashboard_outlined,
            'label': l10n.dashboard_overview,
            'iconAsset': 'assets/icons/sidebar/dashboard-icon.svg',
            'hasBadge': false,
          },
          {
            'route': '/agent/properties',
            'icon': Icons.home_work_outlined,
            'label': l10n.properties,
            'iconAsset': 'assets/icons/sidebar/map-pin.svg',
            'hasBadge': false,
          },
          // Tmp close
          // {
          //   'route': '/agent/bookings',
          //   'icon': Icons.event_note_outlined,
          //   'label': 'การนัดหมาย',
          //   'iconAsset': 'assets/icons/sidebar/clock.svg',
          //   'hasBadge': true,
          // },
          // {
          //   'route': '/agent/chats',
          //   'icon': Icons.chat_bubble_outline,
          //   'label': 'การสนทนา',
          //   'iconAsset': 'assets/icons/sidebar/message-square.svg',
          //   'hasBadge': true,
          // },
          {
            'route': '/agent/contracts',
            'icon': Icons.description_outlined,
            'label': l10n.contracts,
            'iconAsset': 'assets/icons/sidebar/feather.svg',
            'hasBadge': false,
          },
          {
            'route': '/agent/availability',
            'icon': Icons.calendar_today,
            'label': l10n.availability,
            'iconAsset': 'assets/icons/sidebar/calendar.svg',
            'hasBadge': false,
          },
          // Tmp close
          // {
          //   'route': '/agent/management',
          //   'icon': Icons.people_outline,
          //   'label': 'การจัดการตัวแทน',
          //   'iconAsset': 'assets/icons/sidebar/users.svg',
          //   'hasBadge': false,
          // },
          // Debug Logs menu item removed - now using floating button overlay
        ];
      case UserRole.agency:
        return [
          // Tmp close
          // {
          //   'route': RoleService.getDashboardRoute(role),
          //   'icon': Icons.dashboard_outlined,
          //   'label': 'แดชบอร์ด',
          //   'iconAsset': 'assets/images/dashboard-icon.svg',
          // },
          // {
          //   'route': '/agency/properties',
          //   'icon': Icons.home_work_outlined,
          //   'label': 'อสังหาริมทรัพย์',
          //   'iconAsset': 'assets/images/properties-icon.svg',
          // },
          // {
          //   'route': '/agency/bookings',
          //   'icon': Icons.event_note_outlined,
          //   'label': 'การจอง',
          //   'iconAsset': 'assets/images/calendar-icon.svg',
          // },
          // {
          //   'route': '/agency/support',
          //   'icon': Icons.support_agent,
          //   'label': 'สนับสนุน',
          //   'iconAsset': 'assets/images/bell-icon.svg',
          // },
          // {
          //   'route': '/agency/profile',
          //   'icon': Icons.person_outline,
          //   'label': 'โปรไฟล์',
          //   'iconAsset': 'assets/images/settings-icon.svg',
          // },
          // {
          //   'route': '/agent/chats',
          //   'icon': Icons.chat_bubble_outline,
          //   'label': 'แชท',
          //   'iconAsset': 'assets/images/message-icon.svg',
          // },
        ];
    }
  }

  Widget _buildMenuItem(
    BuildContext context,
    String route,
    IconData icon,
    String label,
    String? iconAsset,
    bool hasBadge,
  ) {
    final isSelected =
        currentRoute == route ||
        (currentRoute != null &&
            currentRoute!.startsWith(route) &&
            route != RoleService.getDashboardRoute(UserRole.agent) &&
            route != RoleService.getDashboardRoute(UserRole.agency));

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
            // Icon with badge
            Stack(
              clipBehavior: Clip.none,
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
                    color: isSelected
                        ? AppColors.blue600
                        : AppColors.baseDarkGrey,
                  ),
                // Badge indicator
                if (hasBadge)
                  Positioned(
                    top: -2,
                    right: -2,
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: Color(0xFFEF4444), // Red badge
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
              ],
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
