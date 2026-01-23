import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:youragent/core/theme/app_colors.dart';
import 'package:youragent/domain/entities/booking.dart';
import 'package:youragent/data/models/property_model.dart';
import 'package:youragent/features/dashboard/bloc/dashboard_state.dart';
import 'package:youragent/l10n/app_localizations.dart';
import 'package:youragent/widgets/badges/app_badge.dart';

class StatsWrapperSubsection extends StatelessWidget {
  final int propertyCount;
  final int monthlyAppointments;
  final Map<String, int>? propertyTypeBreakdown;
  final bool isMobile;
  final List<BookingWithContact>? bookings;
  final Map<int, dynamic>? propertyById; // PropertyModel or Property

  // Color mapping for property types (from CSS)
  static final Map<String, Color> _colorMap = {
    'บ้าน': AppColors.chartTeal,
    'บ้านแฝด': AppColors.chartPurple,
    'คอนโด': AppColors.chartCyan,
    'อื่น ๆ': AppColors.chartOrange,
  };

  const StatsWrapperSubsection({
    super.key,
    required this.propertyCount,
    required this.monthlyAppointments,
    this.propertyTypeBreakdown,
    this.isMobile = false,
    this.bookings,
    this.propertyById,
  });

  @override
  Widget build(BuildContext context) {
    // Mock property type breakdown if not provided
    final breakdown = propertyTypeBreakdown ?? {'บ้าน': 80, 'บ้านแฝด': 40, 'คอนโด': 60, 'อื่น ๆ': 100};

    final maxValue = breakdown.values.reduce((a, b) => a > b ? a : b);

    if (isMobile) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Property Breakdown Card
          Container(
            decoration: BoxDecoration(
              color: AppColors.white,
              border: Border.all(color: const Color(0xFFE9E9EB)),
              borderRadius: BorderRadius.circular(24),
            ),
            padding: const EdgeInsets.all(24),
            child: _buildPropertyBreakdown(context, breakdown, maxValue, propertyCount),
          ),
          const SizedBox(height: 16),
          // Monthly Appointments Card
          Container(
            decoration: BoxDecoration(
              color: AppColors.white,
              border: Border.all(color: const Color(0xFFE9E9EB)),
              borderRadius: BorderRadius.circular(24),
            ),
            padding: const EdgeInsets.all(24),
            child: _buildAppointmentsCard(context, bookings, propertyById),
          ),
        ],
      );
    }

    return IntrinsicHeight(
      child: Row(
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Property Breakdown Card
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.white,
                border: Border.all(color: const Color(0xFFE9E9EB)),
                borderRadius: BorderRadius.circular(24),
              ),
              padding: const EdgeInsets.all(40),
              child: _buildPropertyBreakdown(context, breakdown, maxValue, propertyCount),
            ),
          ),
          const SizedBox(width: 16),
          // Monthly Appointments Card
          SizedBox(
            width: 348,
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.white,
                border: Border.all(color: const Color(0xFFE9E9EB)),
                borderRadius: BorderRadius.circular(24),
              ),
              padding: const EdgeInsets.all(40),
              child: _buildAppointmentsCard(context, bookings, propertyById),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPropertyBreakdown(BuildContext context, Map<String, int> breakdown, int maxValue, int propertyCount) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppLocalizations.of(context)!.my_properties,
              style: GoogleFonts.anuphan(fontSize: 14, fontWeight: FontWeight.w400, color: const Color(0xFF717680)),
            ),
            const SizedBox(height: 8),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '$propertyCount',
                  style: GoogleFonts.anuphan(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.eerieBlack),
                ),
                const SizedBox(width: 8),
                Text(
                  'รายการ',
                  style: GoogleFonts.anuphan(fontSize: 16, fontWeight: FontWeight.w400, color: AppColors.eerieBlack),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 24),
        // Chart
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Labels
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisSize: MainAxisSize.min,
              children: breakdown.entries.map((entry) {
                return SizedBox(
                  height: 32,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: Text(
                        entry.key,
                        style: GoogleFonts.anuphan(
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                          color: AppColors.eerieBlack,
                        ),
                        textAlign: TextAlign.right,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(width: 12),
            // Bars
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Bar Chart
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    decoration: const BoxDecoration(
                      border: Border(
                        bottom: BorderSide(color: Color(0xFFA4A7AE), width: 1),
                        left: BorderSide(color: Color(0xFFA4A7AE), width: 1),
                      ),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: breakdown.entries.map((entry) {
                        final percentage = maxValue > 0 ? entry.value / maxValue : 0.0;
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: Row(
                            children: [
                              Expanded(
                                child: SizedBox(
                                  height: 32,
                                  child: FractionallySizedBox(
                                    alignment: Alignment.centerLeft,
                                    widthFactor: percentage,
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: _colorMap[entry.key] ?? AppColors.eerieBlack,
                                        borderRadius: const BorderRadius.only(
                                          topRight: Radius.circular(8),
                                          bottomRight: Radius.circular(8),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Text(
                                '${entry.value}',
                                style: GoogleFonts.anuphan(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w400,
                                  color: const Color(0xFF717680),
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  // Scale
                  Padding(
                    padding: const EdgeInsets.only(top: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: List.generate(6, (index) {
                        return Flexible(
                          child: Text(
                            '${index * 20}',
                            style: GoogleFonts.anuphan(
                              fontSize: 12,
                              fontWeight: FontWeight.w400,
                              color: AppColors.eerieBlack,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        );
                      }),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildAppointmentsCard(
    BuildContext context,
    List<BookingWithContact>? bookings,
    Map<int, dynamic>? propertyById,
  ) {
    final bookingsList = bookings ?? [];
    final totalCount = bookingsList.length;

    // Get first few bookings to display (up to 3)
    final displayBookings = bookingsList.take(3).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Header with title and "View All" link
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'การนัดหมายของคุณ',
                    style: GoogleFonts.anuphan(
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: const Color(0xFF717680),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '$totalCount',
                        style: GoogleFonts.anuphan(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: AppColors.eerieBlack,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'นัดหมาย',
                        style: GoogleFonts.anuphan(
                          fontSize: 16,
                          fontWeight: FontWeight.w400,
                          color: AppColors.eerieBlack,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            InkWell(
              onTap: () {
                context.go('/agent/bookings');
              },
              child: Text(
                'ดูทั้งหมด',
                style: GoogleFonts.anuphan(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: const Color(0xFF717680),
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
          ],
        ),
        // Appointment cards list
        if (displayBookings.isNotEmpty) ...[
          const SizedBox(height: 24),
          ...displayBookings.map(
            (booking) =>
                Padding(padding: const EdgeInsets.only(bottom: 12), child: _buildAppointmentCard(context, booking)),
          ),
        ],
      ],
    );
  }

  Widget _buildAppointmentCard(BuildContext context, BookingWithContact bookingWithContact) {
    final booking = bookingWithContact.booking;
    final property = propertyById?[booking.propertyId];
    final propertyModel = property is PropertyModel ? property : null;

    // Format date/time from created_at
    String dateTimeStr = '';
    if (booking.createdAt != null) {
      try {
        final date = booking.createdAt!;
        final year = date.year;
        final month = date.month;
        final day = date.day;
        final hour = date.hour;
        final minute = date.minute;

        // Format in Thai: "25 ธันวาคม 2568, 12:00"
        final thaiMonths = [
          'มกราคม',
          'กุมภาพันธ์',
          'มีนาคม',
          'เมษายน',
          'พฤษภาคม',
          'มิถุนายน',
          'กรกฎาคม',
          'สิงหาคม',
          'กันยายน',
          'ตุลาคม',
          'พฤศจิกายน',
          'ธันวาคม',
        ];

        final thaiYear = year + 543; // Convert to Buddhist era
        final monthName = thaiMonths[month - 1];
        final timeStr = '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';
        dateTimeStr = '$day $monthName $thaiYear, $timeStr';
      } catch (e) {
        dateTimeStr = booking.createdAt.toString();
      }
    }

    // Get contact name from API response
    final contactName = bookingWithContact.contactName != null ? 'คุณ ${bookingWithContact.contactName}' : 'คุณลูกค้า';

    // Get property location/address
    // Only show address when status is confirmed (not pending)
    String location = '';
    if (booking.status == BookingStatus.confirmed && propertyModel?.specs != null) {
      location = propertyModel!.specs!.address ?? '';
    }

    // If no address from specs, try property location (only for confirmed)
    if (location.isEmpty && booking.status == BookingStatus.confirmed) {
      location = propertyModel?.location ?? '';
      if (location.isEmpty && propertyModel?.propertyLocation != null) {
        final loc = propertyModel!.propertyLocation!;
        final parts = <String>[];
        if (loc.number != null && loc.number!.isNotEmpty) {
          parts.add(loc.number!);
        }
        if (loc.city != null && loc.city!.isNotEmpty) parts.add(loc.city!);
        if (loc.state != null && loc.state!.isNotEmpty) parts.add(loc.state!);
        location = parts.join(' ');
      }
    }

    // Status badge - use correct status logic
    final isConfirmed = booking.status == BookingStatus.confirmed;
    final isCancelled = booking.status == BookingStatus.cancelled;

    String statusText;
    Color statusBgColor;
    Color statusTextColor;
    Color textColor; // Text color for the card content
    double fontSize; // Font size for text (smaller for pending/cancelled)

    if (isCancelled) {
      statusText = 'Cancelled';
      statusBgColor = AppColors.statusCancelledBg;
      statusTextColor = AppColors.statusCancelledText;
      textColor = AppColors.statusCardTextInactive; // Same as pending
      fontSize = 13; // 1 level lower than confirmed (14)
    } else if (isConfirmed) {
      statusText = 'Confirmed';
      statusBgColor = AppColors.statusConfirmedBg;
      statusTextColor = AppColors.statusConfirmedText;
      textColor = AppColors.statusCardTextActive;
      fontSize = 14; // Normal size
    } else {
      statusText = 'Pending';
      statusBgColor = AppColors.statusPendingBg;
      statusTextColor = AppColors.statusPendingText;
      textColor = AppColors.statusCardTextInactive; // Same as cancelled
      fontSize = 13; // 1 level lower than confirmed (14)
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        border: Border.all(color: const Color(0xFFE9EAEB)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Name and status
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  contactName,
                  style: GoogleFonts.anuphan(
                    fontSize: isConfirmed ? 16 : 15, // 1 level lower for pending/cancelled
                    fontWeight: FontWeight.w600,
                    color: textColor,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              AppBadge(
                label: statusText,
                style: BadgeStyle.plain,
                customBackgroundColor: statusBgColor,
                customTextColor: statusTextColor,
                fontSize: 12,
              ),
            ],
          ),
          // Date/time
          if (dateTimeStr.isNotEmpty) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                SvgPicture.asset(
                  'assets/icons/clock.svg',
                  width: 16,
                  height: 16,
                  colorFilter: const ColorFilter.mode(AppColors.gray500, BlendMode.srcIn),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    dateTimeStr,
                    style: GoogleFonts.anuphan(fontSize: fontSize, fontWeight: FontWeight.w400, color: textColor),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ],
          // Location (only show when confirmed, not pending)
          if (location.isNotEmpty && booking.status == BookingStatus.confirmed) ...[
            const SizedBox(height: 8),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SvgPicture.asset(
                  'assets/icons/map-pin.svg',
                  width: 16,
                  height: 16,
                  colorFilter: const ColorFilter.mode(AppColors.gray500, BlendMode.srcIn),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    location,
                    style: GoogleFonts.anuphan(fontSize: fontSize, fontWeight: FontWeight.w400, color: textColor),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
