import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:youragent/core/theme/app_colors.dart';
import 'package:youragent/domain/entities/booking.dart';
import 'package:youragent/widgets/badges/app_badge.dart';
import 'package:youragent/widgets/buttons/app_button.dart';
import 'package:cached_network_image/cached_network_image.dart';

class BookingCard extends StatelessWidget {
  final Booking booking;

  // Additional callbacks will be added later for button actions
  final VoidCallback? onCoAgentTap;
  final VoidCallback? onPrimaryActionTap;

  const BookingCard({
    super.key,
    required this.booking,
    this.onCoAgentTap,
    this.onPrimaryActionTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          const SizedBox(height: 12),
          _buildStatusSection(),
          _buildWarningSection(),
          const SizedBox(height: 16),
          _buildActions(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    final title =
        booking.property?.title ??
        booking.property?.name ??
        'อสังหาริมทรัพย์ที่ ${booking.propertyId}';

    final locationInfo = [
      booking.property?.subdistrict,
      booking.property?.district,
      booking.property?.city,
    ].where((e) => e != null && e.isNotEmpty).join(', ');

    final buyerName = booking.buyer?.name ?? 'ไม่ระบุชื่อ';

    // Format Date: e.g. 20251127 -> 27 พ.ย. 2568
    String displayDate = '';
    try {
      final ymd = booking.ymd;
      if (ymd.length == 8) {
        final year = int.parse(ymd.substring(0, 4));
        final month = int.parse(ymd.substring(4, 6));
        final day = int.parse(ymd.substring(6, 8));
        final dt = DateTime(year, month, day);
        final thaiYear = year + 543;
        final formatter = DateFormat('d MMM');
        displayDate = '${formatter.format(dt)} $thaiYear, ${booking.time} น.';
      } else {
        displayDate = '${booking.ymd}, ${booking.time} น.';
      }
    } catch (_) {
      displayDate = '${booking.ymd}, ${booking.time} น.';
    }

    final imageUrl = booking.property?.imageUrl;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.anuphan(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.baseDarkGrey,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),

              // Location
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: SvgPicture.asset(
                      'assets/icons/map-pin.svg', // Ensure you have this icon
                      width: 14,
                      colorFilter: const ColorFilter.mode(
                        AppColors.baseGrey,
                        BlendMode.srcIn,
                      ),
                    ),
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      locationInfo.isEmpty ? 'ไม่ระบุตำแหน่ง' : locationInfo,
                      style: GoogleFonts.anuphan(
                        fontSize: 12,
                        color: AppColors.baseGrey,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),

              // Buyer & Time
              Row(
                children: [
                  SvgPicture.asset(
                    'assets/icons/user.svg', // Ensure icon exists
                    width: 14,
                    colorFilter: const ColorFilter.mode(
                      AppColors.baseGrey,
                      BlendMode.srcIn,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      buyerName,
                      style: GoogleFonts.anuphan(
                        fontSize: 12,
                        color: AppColors.baseGrey,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  SvgPicture.asset(
                    'assets/icons/clock.svg', // Ensure icon exists
                    width: 14,
                    colorFilter: const ColorFilter.mode(
                      AppColors.baseGrey,
                      BlendMode.srcIn,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    displayDate,
                    style: GoogleFonts.anuphan(
                      fontSize: 12,
                      color: AppColors.baseGrey,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        if (imageUrl != null)
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: CachedNetworkImage(
              imageUrl: imageUrl,
              width: 80,
              height: 80,
              fit: BoxFit.cover,
              errorWidget: (context, url, err) => Container(
                width: 80,
                height: 80,
                color: AppColors.baseLightGrey,
                child: const Icon(
                  Icons.broken_image,
                  color: AppColors.baseGrey,
                ),
              ),
            ),
          )
        else
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppColors.baseLightGrey,
              borderRadius: BorderRadius.circular(8),
            ),
            child: SvgPicture.asset(
              'assets/icons/home.svg',
              width: 80,
              height: 80,
              colorFilter: const ColorFilter.mode(
                AppColors.baseGrey,
                BlendMode.srcIn,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildStatusSection() {
    // Determine status badge based on booking status
    // 0: Pending, 1: Confirmed, etc.
    String statusLabel = 'ลูกค้ารอยืนยัน';
    BadgeColor badgeColor = BadgeColor.blue;
    String subtext = '';

    if (booking.status == 1) {
      statusLabel = 'ยืนยันนัดแล้ว';
      badgeColor = BadgeColor.green;
      // Depending on other fields, it could be travelling, viewing etc.
      // We'll mock the subtext for now based on UI design
      subtext = 'ผู้จองเข้าชมบ้านยังไม่เริ่มเดินทาง';
    } else if (booking.status == 2) {
      statusLabel = 'ยกเลิกนัดหมาย';
      badgeColor = BadgeColor.red;
      subtext = 'เหตุผล : ผู้จองเข้าชมไม่มาตามนัด';
    } else if (booking.status == 3) {
      statusLabel = 'เสร็จสิ้น';
      badgeColor = BadgeColor.green;
      subtext = 'เวลา 11:55 - 12:30 --- ระยะเวลา 35 นาที';
    } else {
      statusLabel = 'ลูกค้ารอยืนยัน';
      badgeColor = BadgeColor.blue;
      subtext = 'รอการยืนยันจากตัวแทน';
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppBadges.status(label: statusLabel, color: badgeColor),
        if (subtext.isNotEmpty) ...[
          const SizedBox(height: 8),
          Text(
            subtext,
            style: GoogleFonts.anuphan(fontSize: 12, color: AppColors.baseGrey),
          ),
        ],
      ],
    );
  }

  Widget _buildWarningSection() {
    // If there's a specific logic for warning (e.g. late), render this
    // For now we simulate it by returning empty
    return const SizedBox.shrink();
  }

  Widget _buildActions() {
    if (booking.status == 0) {
      return Row(
        children: [
          Expanded(
            child: AppButton(
              height: 32,
              textSize: 12,
              text: 'ปฏิเสธ',
              style: AppButtonStyle.outline,
              onPressed: () {},
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: AppButton(
              height: 32,
              textSize: 12,
              text: 'ยืนยันนัด',
              style: AppButtonStyle.primary,
              onPressed: onPrimaryActionTap,
            ),
          ),
        ],
      );
    } else if (booking.status == 1) {
      return Row(
        children: [
          Expanded(
            child: AppButton(
              height: 32,
              textSize: 12,
              text: 'ต้องการ Co-agent',
              style: AppButtonStyle.outline,
              onPressed: onCoAgentTap,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: AppButton(
              height: 32,
              textSize: 12,
              text: 'เริ่มเดินทาง',
              style: AppButtonStyle.primary,
              onPressed: onPrimaryActionTap,
            ),
          ),
        ],
      );
    } else if (booking.status == 3) {
      return const SizedBox.shrink(); // completed no buttons
    } else {
      return const SizedBox.shrink();
    }
  }
}
