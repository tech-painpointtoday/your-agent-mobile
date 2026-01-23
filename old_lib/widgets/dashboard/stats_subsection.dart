import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:youragent/core/theme/app_colors.dart';
import 'package:youragent/l10n/app_localizations.dart';

class StatsSubsection extends StatelessWidget {
  final String userName;
  final VoidCallback? onCreateProperty;
  final VoidCallback? onViewProperties;
  final bool isMobile;

  const StatsSubsection({
    super.key,
    required this.userName,
    this.onCreateProperty,
    this.onViewProperties,
    this.isMobile = false,
  });

  @override
  Widget build(BuildContext context) {
    if (isMobile) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Welcome Card
          Container(
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [AppColors.white, Color(0xFFE9F5FF)],
              ),
              border: Border.all(color: const Color(0xFFE9E9EB)),
              borderRadius: BorderRadius.circular(24),
            ),
            padding: const EdgeInsets.all(24),
            child: Stack(
              children: [
                // Illustration (smaller on mobile)
                Positioned(
                  right: 16,
                  top: 16,
                  child: SvgPicture.asset(
                    'assets/images/undraw-business-call-w1gr-1.svg',
                    width: 150,
                    height: 136,
                  ),
                ),
                // Content
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Welcome Text
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'ยินดีต้อนรับ',
                          style: GoogleFonts.anuphan(
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                            color: const Color(0xFF717680),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'คุณ $userName',
                          style: GoogleFonts.anuphan(
                            fontSize: 20,
                            fontWeight: FontWeight.w500,
                            color: AppColors.eerieBlack,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    // Buttons (stacked on mobile) - swapped order
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        ElevatedButton(
                          onPressed:
                              onViewProperties ??
                              () => context.go('/agent/properties'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF1743C7),
                            foregroundColor: AppColors.white,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 12,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: Text(
                            AppLocalizations.of(context)!.my_properties,
                            style: GoogleFonts.anuphan(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        ElevatedButton(
                          onPressed:
                              onCreateProperty ??
                              () => context.go('/agent/properties/create'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.alizarinCrimson,
                            foregroundColor: AppColors.white,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 12,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: Text(
                            AppLocalizations.of(
                              context,
                            )!.create_property_button,
                            style: GoogleFonts.anuphan(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // Stats Cards (stacked on mobile)
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _StatCard(
                title: 'อัตราความสำเร็จ',
                value: '30.68%',
                change: '+1.25%',
                iconPath: 'assets/images/trending-up-icon.svg',
                iconBgColor: const Color(0xFFF3F3FF),
                iconColor: const Color(0xFF7A5AF8),
              ),
              const SizedBox(height: 16),
              _StatCard(
                title: 'ค่าคอมมิชชั่นเดือนนี้',
                value: '128,000',
                unit: 'บาท',
                iconPath: 'assets/images/coin-stack-icon.svg',
                iconBgColor: const Color(0xFFFFF5ED),
                iconColor: const Color(0xFFFB6514),
              ),
            ],
          ),
        ],
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Welcome Card
        Expanded(
          child: Container(
            constraints: const BoxConstraints(
              minHeight: 312,
              maxHeight: 312,
              minWidth: 310,
            ),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [AppColors.white, Color(0xFFE9F5FF)],
              ),
              border: Border.all(color: const Color(0xFFE9E9EB)),
              borderRadius: BorderRadius.circular(24),
            ),
            padding: EdgeInsets.zero,
            child: Stack(
              children: [
                // Illustration
                Positioned(
                  right: 38,
                  top: 39,
                  child: SvgPicture.asset(
                    'assets/images/undraw-business-call-w1gr-1.svg',
                    width: 301,
                    fit: BoxFit.fitWidth,
                  ),
                ),
                // Content
                Padding(
                  padding: const EdgeInsets.all(40),
                  child: Container(
                    constraints: const BoxConstraints(minHeight: 224),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Welcome Text
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'ยินดีต้อนรับ',
                              style: GoogleFonts.anuphan(
                                fontSize: 14,
                                fontWeight: FontWeight.w400,
                                color: const Color(0xFF717680),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'คุณ $userName',
                              style: GoogleFonts.anuphan(
                                fontSize: 20,
                                fontWeight: FontWeight.w500,
                                color: AppColors.eerieBlack,
                              ),
                            ),
                          ],
                        ),
                        // Buttons - swapped order
                        Row(
                          children: [
                            Flexible(
                              child: ElevatedButton(
                                onPressed:
                                    onViewProperties ??
                                    () => context.go('/agent/properties'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF1743C7),
                                  foregroundColor: AppColors.white,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 12,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                child: Text(
                                  AppLocalizations.of(context)!.my_properties,
                                  style: GoogleFonts.anuphan(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Flexible(
                              child: ElevatedButton(
                                onPressed:
                                    onCreateProperty ??
                                    () =>
                                        context.go('/agent/properties/create'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.alizarinCrimson,
                                  foregroundColor: AppColors.white,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 12,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                child: Text(
                                  AppLocalizations.of(
                                    context,
                                  )!.create_property_button,
                                  style: GoogleFonts.anuphan(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 16),
        // Stats Cards
        SizedBox(
          width: 348,
          child: Column(
            children: [
              // Success Rate Card
              _StatCard(
                title: 'อัตราความสำเร็จ',
                value: '30.68%',
                change: '+1.25%',
                iconPath: 'assets/images/trending-up-icon.svg',
                iconBgColor: const Color(0xFFF3F3FF),
                iconColor: const Color(0xFF7A5AF8),
              ),
              const SizedBox(height: 16),
              // Commission Card
              _StatCard(
                title: 'ค่าคอมมิชชั่นเดือนนี้',
                value: '128,000',
                unit: 'บาท',
                iconPath: 'assets/images/coin-stack-icon.svg',
                iconBgColor: const Color(0xFFFFF5ED),
                iconColor: const Color(0xFFFB6514),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final String? change;
  final String? unit;
  final String iconPath;
  final Color iconBgColor;
  final Color iconColor;

  const _StatCard({
    required this.title,
    required this.value,
    this.change,
    this.unit,
    required this.iconPath,
    required this.iconBgColor,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minWidth: 300, maxWidth: 348),
      decoration: BoxDecoration(
        color: AppColors.white,
        border: Border.all(color: const Color(0xFFE9E9EB)),
        borderRadius: BorderRadius.circular(24),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: GoogleFonts.anuphan(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: AppColors.eerieBlack,
                ),
              ),
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: iconBgColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: SvgPicture.asset(
                    iconPath,
                    width: 18,
                    height: 18,
                    colorFilter: ColorFilter.mode(iconColor, BlendMode.srcIn),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                value,
                style: GoogleFonts.anuphan(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.eerieBlack,
                ),
              ),
              if (unit != null) ...[
                const SizedBox(width: 8),
                Text(
                  unit!,
                  style: GoogleFonts.anuphan(
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                    color: AppColors.eerieBlack,
                  ),
                ),
              ],
              if (change != null) ...[
                const SizedBox(width: 8),
                Text(
                  change!,
                  style: GoogleFonts.anuphan(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF12B669),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}
