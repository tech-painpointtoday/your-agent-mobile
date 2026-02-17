import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:youragent/l10n/app_localizations.dart';

import '../core/theme/app_colors.dart';

class AppBottomNavigationBar extends StatelessWidget {
  final int currentIndex;
  final Function(int)? onTabTapped;

  const AppBottomNavigationBar({
    super.key,
    required this.currentIndex,
    this.onTabTapped,
  });

  void _onTap(BuildContext context, int index) {
    // Use callback if provided (for PageView), otherwise use GoRouter (legacy)
    if (onTabTapped != null) {
      onTabTapped!(index);
    } else {
      // Fallback to GoRouter for backward compatibility
      switch (index) {
        case 0:
          context.go('/');
          break;
        case 1:
          context.go('/property');
          break;
        case 2:
          context.go('/money');
          break;
        case 3:
          context.go('/calendar');
          break;
        case 4:
          context.go('/contact');
          break;
      }
    }
  }

  BottomNavigationBarItem _buildBottomNavItem({
    required String iconPath,
    required String unselectedIconPath,
    required String label,
    required bool isSelected,
  }) {
    return BottomNavigationBarItem(
      icon: SvgPicture.asset(
        unselectedIconPath,
        width: 24,
        height: 24,
        colorFilter: const ColorFilter.mode(
          AppColors.baseGrey,
          BlendMode.srcIn,
        ),
      ),
      activeIcon: SvgPicture.asset(
        iconPath,
        width: 24,
        height: 24,
        colorFilter: const ColorFilter.mode(AppColors.primary, BlendMode.srcIn),
      ),
      label: label,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.only(top: 8),
        child: BottomNavigationBar(
          currentIndex: currentIndex,
          onTap: (i) => _onTap(context, i),
          type: BottomNavigationBarType.fixed,
          selectedItemColor: AppColors.primary,
          unselectedItemColor: AppColors.baseGrey,
          backgroundColor: AppColors.white,
          selectedFontSize: 12,
          unselectedFontSize: 12,
          elevation: 0, // Remove default elevation since we added custom shadow
          items: [
            _buildBottomNavItem(
              iconPath: 'assets/icons/home-2-filled.svg',
              unselectedIconPath: 'assets/icons/home.svg',
              label: AppLocalizations.of(context).home,
              isSelected: currentIndex == 0,
            ),
            _buildBottomNavItem(
              iconPath: 'assets/icons/building-filled.svg',
              unselectedIconPath: 'assets/icons/building.svg',
              label: AppLocalizations.of(context).navProperty,
              isSelected: currentIndex == 1,
            ),
            _buildBottomNavItem(
              iconPath: 'assets/icons/wallet-filled.svg',
              unselectedIconPath: 'assets/icons/wallet.svg',
              label: AppLocalizations.of(context).navMoney,
              isSelected: currentIndex == 2,
            ),
            _buildBottomNavItem(
              iconPath: 'assets/icons/calendar-filled.svg',
              unselectedIconPath: 'assets/icons/calendar.svg',
              label: AppLocalizations.of(context).navCalendar,
              isSelected: currentIndex == 3,
            ),
            _buildBottomNavItem(
              iconPath: 'assets/icons/contact-book-filled.svg',
              unselectedIconPath: 'assets/icons/contact-book.svg',
              label: AppLocalizations.of(context).navContact,
              isSelected: currentIndex == 4,
            ),
          ],
        ),
      ),
    );
  }
}
