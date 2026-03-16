import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:yourhome/core/theme/app_colors.dart';
import 'package:yourhome/l10n/app_localizations.dart';

/// Reusable section container widget for general form usage
class AppFormSection extends StatelessWidget {
  final String title;
  final Widget? titleWidget;
  final String icon;
  final Color iconColor;
  final Widget child;
  final AppLocalizations l10n;
  final Widget? statusBadge;
  final Widget? rightWidget;

  const AppFormSection({
    super.key,
    required this.title,
    this.titleWidget,
    required this.icon,
    required this.iconColor,
    required this.child,
    required this.l10n,
    this.statusBadge,
    this.rightWidget,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    padding: const EdgeInsets.all(8),
                    decoration: ShapeDecoration(
                      color: const Color(0xFFEFF8FF),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: SvgPicture.asset(
                      icon,
                      width: 16,
                      height: 16,
                      colorFilter: ColorFilter.mode(iconColor, BlendMode.srcIn),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child:
                        titleWidget ??
                        Text(
                          title,
                          style: GoogleFonts.anuphan(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primary,
                          ),
                        ),
                  ),
                  if (rightWidget != null) rightWidget!,
                ],
              ),
              if (statusBadge != null)
                Positioned(right: 0, top: 0, child: statusBadge!),
            ],
          ),
          const SizedBox(height: 20),
          child,
        ],
      ),
    );
  }
}
