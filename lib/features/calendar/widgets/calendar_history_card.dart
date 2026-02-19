import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:youragent/core/theme/app_colors.dart';

/// Outcome status of a past appointment
enum AppointmentHistoryStatus { visited, cancelled }

class CalendarHistoryCard extends StatelessWidget {
  final String propertyTitle;
  final String propertyAddress;
  final String? imageUrl;
  final String visitorName;
  final String dateTime;
  final AppointmentHistoryStatus status;

  const CalendarHistoryCard({
    super.key,
    required this.propertyTitle,
    required this.propertyAddress,
    required this.visitorName,
    required this.dateTime,
    this.imageUrl,
    this.status = AppointmentHistoryStatus.visited,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: ShapeDecoration(
        color: AppColors.white,
        shape: RoundedRectangleBorder(
          side: const BorderSide(width: 1, color: AppColors.baseOffWhite),
          borderRadius: BorderRadius.circular(12),
        ),
        shadows: const [
          BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 16,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Top: title + image ────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 16,
              children: [
                // Title + address
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    spacing: 8,
                    children: [
                      Text(
                        propertyTitle,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.anuphan(
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                          color: AppColors.baseBlack,
                        ),
                      ),
                      Text(
                        propertyAddress,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.anuphan(
                          fontSize: 10,
                          fontWeight: FontWeight.w400,
                          color: AppColors.baseDarkGrey,
                        ),
                      ),
                    ],
                  ),
                ),
                // Property image 70x70
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: imageUrl != null && imageUrl!.isNotEmpty
                      ? Image.network(
                          imageUrl!,
                          width: 70,
                          height: 70,
                          fit: BoxFit.cover,
                          errorBuilder: (ctx, err, stack) => _placeholder(),
                        )
                      : _placeholder(),
                ),
              ],
            ),
          ),

          // ── Divider ───────────────────────────────────────────────────
          Container(height: 1, color: AppColors.basePaleGrey),

          // ── Visitor + date + status badge ─────────────────────────────
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              spacing: 4,
              children: [
                // Left: visitor name + date/time
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: 8,
                  children: [
                    _SvgLabelRow(
                      iconPath: 'assets/icons/user.svg',
                      label: 'ผู้จองเข้าชม',
                      value: visitorName,
                    ),
                    _SvgLabelRow(
                      iconPath: 'assets/icons/calendar.svg',
                      label: 'วันที่และเวลา',
                      value: dateTime,
                    ),
                  ],
                ),
                // Right: status badge pill
                _buildStatusBadge(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge() {
    final isVisited = status == AppointmentHistoryStatus.visited;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: ShapeDecoration(
        color: isVisited
            ? AppColors.supportGreenLight
            : AppColors.supportRedLight,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      child: Text(
        isVisited ? 'เข้าชมแล้ว' : 'ยกเลิกนัดแล้ว',
        style: GoogleFonts.anuphan(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: isVisited
              ? AppColors.supportGreenDark
              : AppColors.supportRedDark,
        ),
      ),
    );
  }

  Widget _placeholder() {
    return Container(
      width: 70,
      height: 70,
      decoration: BoxDecoration(
        color: AppColors.basePaleGrey,
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Icon(
        Icons.home_outlined,
        color: Color(0xFFCBD0D8),
        size: 28,
      ),
    );
  }
}

/// Row with a small SVG icon, fixed-width grey label, then dark value
class _SvgLabelRow extends StatelessWidget {
  final String iconPath;
  final String label;
  final String value;

  const _SvgLabelRow({
    required this.iconPath,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      spacing: 4,
      children: [
        SvgPicture.asset(
          iconPath,
          width: 8,
          height: 8,
          colorFilter: const ColorFilter.mode(
            AppColors.baseDarkGrey,
            BlendMode.srcIn,
          ),
        ),
        SizedBox(
          width: 60,
          child: Text(
            label,
            style: GoogleFonts.anuphan(
              fontSize: 10,
              fontWeight: FontWeight.w400,
              color: AppColors.baseDarkGrey,
            ),
          ),
        ),
        Text(
          value,
          style: GoogleFonts.anuphan(
            fontSize: 10,
            fontWeight: FontWeight.w400,
            color: AppColors.baseBlack,
          ),
        ),
      ],
    );
  }
}
