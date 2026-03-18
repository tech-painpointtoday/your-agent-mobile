import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:yourhome/core/enums/booking_status.dart';
import 'package:yourhome/core/theme/app_colors.dart';
import 'package:yourhome/domain/entities/booking.dart';
import 'package:yourhome/widgets/badges/app_badge.dart';
import 'package:yourhome/widgets/buttons/app_button.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:go_router/go_router.dart';
import 'package:yourhome/l10n/app_localizations.dart';
import 'package:yourhome/widgets/modals/app_call_bottom_sheet.dart';
import 'package:yourhome/widgets/modals/app_confirmation_bottom_sheet.dart';
import 'package:yourhome/features/calendar/utils/booking_confirm_flow_ui.dart';

class BookingCard extends StatelessWidget {
  final Booking booking;

  // Additional callbacks will be added later for button actions
  final VoidCallback? onCoAgentTap;
  final Function(int status)? onStatusAction;
  final VoidCallback? onCancelTap;
  final VoidCallback? onStartTravelTap;
  final VoidCallback? onArrivedTap;
  final VoidCallback? onConfirmAppointmentTap;
  final VoidCallback? onRouteMapTap;

  const BookingCard({
    super.key,
    required this.booking,
    this.onCoAgentTap,
    this.onStatusAction,
    this.onCancelTap,
    this.onStartTravelTap,
    this.onArrivedTap,
    this.onConfirmAppointmentTap,
    this.onRouteMapTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => context.push('/booking/${booking.id}'),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: ShapeDecoration(
          color: AppColors.baseWhite,
          shape: RoundedRectangleBorder(
            side: const BorderSide(width: 1, color: AppColors.baseOffWhite),
            borderRadius: BorderRadius.circular(12),
          ),
          shadows: const [
            BoxShadow(
              color: Color(0x0A000000),
              blurRadius: 16,
              offset: Offset(0, 4),
              spreadRadius: 0,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(context),
            const SizedBox(height: 16),
            _buildStatusAndSubtext(context),
            _buildWarningSection(context),
            const SizedBox(height: 16),
            _buildActions(context),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final locationInfo = [
      booking.property?.title ?? booking.property?.name,
      booking.property?.subdistrict,
      booking.property?.district,
      booking.property?.city,
    ].where((e) => e != null && e.isNotEmpty).join(' ');

    final buyerName = booking.buyer?.name ?? l10n.calendar_unspecified_name;

    // Format Date: e.g. 20251127 -> 27 พ.ย. 2568
    String displayDate = '';
    try {
      final ymd = booking.ymd;
      if (ymd.length == 8) {
        final year = int.parse(ymd.substring(0, 4));
        final month = int.parse(ymd.substring(4, 6));
        final day = int.parse(ymd.substring(6, 8));
        final dt = DateTime(year, month, day);

        final locale = Localizations.localeOf(context).languageCode;
        if (locale == 'th') {
          final thaiYear = year + 543;
          final formatter = DateFormat('d MMM', 'th');
          displayDate =
              '${formatter.format(dt)} $thaiYear, ${booking.time} ${l10n.now.contains('น') ? 'น.' : ''}';
        } else {
          final formatter = DateFormat('d MMM yyyy', 'en');
          displayDate = '${formatter.format(dt)}, ${booking.time}';
        }
      } else {
        displayDate = '${booking.ymd}, ${booking.time}';
      }
    } catch (_) {
      displayDate = '${booking.ymd}, ${booking.time}';
    }

    final imageUrl = booking.property?.imageUrl;

    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                displayDate,
                style: GoogleFonts.anuphan(
                  color: AppColors.baseBlack,
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                ),
              ),
              const SizedBox(height: 4),
              Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SvgPicture.asset(
                    'assets/icons/user.svg',
                    width: 12,
                    height: 12,
                    colorFilter: const ColorFilter.mode(
                      AppColors.baseBlack,
                      BlendMode.srcIn,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    buyerName,
                    style: GoogleFonts.anuphan(
                      color: AppColors.baseBlack,
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: SvgPicture.asset(
                      'assets/icons/map-pin.svg',
                      width: 12,
                      height: 12,
                      colorFilter: const ColorFilter.mode(
                        AppColors.baseDarkGrey,
                        BlendMode.srcIn,
                      ),
                    ),
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      locationInfo.isEmpty
                          ? l10n.calendar_unspecified_location
                          : locationInfo,
                      style: GoogleFonts.anuphan(
                        color: AppColors.baseDarkGrey,
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(width: 16),
        CachedNetworkImage(
          imageUrl: imageUrl ?? '',
          width: 70,
          height: 70,
          fit: BoxFit.cover,
          imageBuilder: (context, imageProvider) => Container(
            width: 70,
            height: 70,
            decoration: ShapeDecoration(
              color: AppColors.basePaleGrey,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            clipBehavior: Clip.hardEdge,
            child: Image(image: imageProvider, fit: BoxFit.cover),
          ),
          placeholder: (context, url) => Container(
            width: 70,
            height: 70,
            decoration: ShapeDecoration(
              color: AppColors.basePaleGrey,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Center(
              child: SpinKitFadingCircle(color: AppColors.primary, size: 24),
            ),
          ),
          errorWidget: (context, url, error) => Container(
            width: 70,
            height: 70,
            decoration: ShapeDecoration(
              color: AppColors.basePaleGrey,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: SvgPicture.asset(
                'assets/icons/image.svg',
                width: 16,
                height: 16,
                colorFilter: const ColorFilter.mode(
                  AppColors.baseGrey,
                  BlendMode.srcIn,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatusAndSubtext(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    if (booking.status == BookingStatus.confirm) {
      final ui = computeAgentConfirmFlowUi(
        booking: booking,
        l10n: l10n,
        now: DateTime.now(),
      );

      return _buildBadgeWithStatusLine(
        label: ui.badgeLabel,
        color: ui.badgeColor,
        statusLine: ui.statusLine,
      );
    }

    BadgeColor badgeColor = BadgeColor.default_;

    switch (booking.status) {
      case BookingStatus.pending:
        badgeColor = BadgeColor.yellow;
        break;
      case BookingStatus.confirm:
      case BookingStatus.closeDeal:
        badgeColor = BadgeColor.green;
        break;
      case BookingStatus.reject:
      case BookingStatus.cancelled:
        badgeColor = BadgeColor.red;
        break;
      case BookingStatus.expired:
        badgeColor = BadgeColor.orange;
        break;
      case BookingStatus.met:
        badgeColor = BadgeColor.purple;
        break;
      case BookingStatus.offer:
      case BookingStatus.contract:
        badgeColor = BadgeColor.blue;
        break;
    }

    return AppBadge(
      label: booking.statusLabel,
      color: badgeColor,
      style: BadgeStyle.dot,
    );
  }

  DateTime get bookingDateTime {
    return booking.bookingDateTime;
  }

  Widget _buildBadgeWithStatusLine({
    required String label,
    required BadgeColor color,
    required String? statusLine,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppBadge(label: label, color: color, style: BadgeStyle.dot),
        if (statusLine != null && statusLine.isNotEmpty) ...[
          const SizedBox(height: 6),
          Text(
            statusLine,
            style: GoogleFonts.anuphan(
              color: AppColors.baseDarkGrey,
              fontSize: 12,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildWarningSection(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    // Mocking delay warning for now. In reality, check booking data.
    final hasDelay =
        booking.timeUntilBookingSeconds != null &&
        booking.timeUntilBookingSeconds! < 0;

    if (!hasDelay) return const SizedBox.shrink();

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 12),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: ShapeDecoration(
        color: AppColors.supportOrangeLight,
        shape: RoundedRectangleBorder(
          side: const BorderSide(width: 1, color: AppColors.supportOrangeDark),
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SvgPicture.asset(
            'assets/icons/alert-triangle.svg',
            width: 16,
            height: 16,
            colorFilter: const ColorFilter.mode(
              AppColors.supportOrangeDark,
              BlendMode.srcIn,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            l10n.calendar_delay_warning(10),
            style: GoogleFonts.anuphan(
              color: AppColors.supportOrangeDark,
              fontSize: 12,
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActions(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isLate = DateTime.now().isAfter(booking.bookingDateTime);

    void showCancelConfirm() {
      AppConfirmationBottomSheet.show(
        context: context,
        title: l10n.calendar_confirm_cancel_title,
        description: l10n.calendar_confirm_cancel_desc,
        confirmLabel: l10n.calendar_cancel_label,
        style: ConfirmationStyle.destructive,
        onConfirm: () => onCancelTap?.call(),
      );
    }

    if (booking.status == BookingStatus.pending) {
      if (isLate) return const SizedBox.shrink();
      return AppButton(
        width: double.infinity,
        height: 32,
        textSize: 12,
        text: l10n.calendar_cancel_label,
        style: AppButtonStyle.outline,
        onPressed: showCancelConfirm,
      );
    } else if (booking.status == BookingStatus.confirm) {
      final sellerAttendance = booking.attendance?.seller;
      final buyerAttendance = booking.attendance?.buyer;

      final sellerAllAttendanceCompleted =
          sellerAttendance?.confirmedOnDateAt != null &&
          sellerAttendance?.travelingAt != null &&
          sellerAttendance?.arrivedAt != null;
      if (sellerAllAttendanceCompleted) {
        final phone = booking.buyer?.phone?.trim() ?? '';
        return AppButton(
          width: double.infinity,
          height: 36,
          textSize: 14,
          text: l10n.calendar_history_contact_button,
          style: AppButtonStyle.outline,
          onPressed: phone.isEmpty
              ? null
              : () {
                  AppCallBottomSheet.show(
                    context: context,
                    options: [
                      CallOption(
                        label: booking.buyer?.name ?? '',
                        phone: phone,
                      ),
                    ],
                  );
                },
        );
      }

      final sellerTraveling =
          sellerAttendance?.travelingAt != null &&
          sellerAttendance?.arrivedAt == null;
      final sellerArrived = sellerAttendance?.arrivedAt != null;

      DateTime? appointmentDate;
      try {
        final ymd = booking.ymd;
        if (ymd.length == 8) {
          final year = int.parse(ymd.substring(0, 4));
          final month = int.parse(ymd.substring(4, 6));
          final day = int.parse(ymd.substring(6, 8));
          appointmentDate = DateTime(year, month, day);
        }
      } catch (_) {}

      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final isNotYetAppointmentDay = appointmentDate?.isAfter(today) ?? false;

      final sellerConfirmed = sellerAttendance?.confirmedOnDateAt != null;
      final buyerConfirmed = buyerAttendance?.confirmedOnDateAt != null;

      if (!sellerConfirmed && !buyerConfirmed && isNotYetAppointmentDay) {
        return const SizedBox.shrink();
      }

      if (!sellerConfirmed) {
        return AppButton(
          width: double.infinity,
          height: 36,
          textSize: 14,
          text: l10n.booking_confirm_booking,
          style: AppButtonStyle.primary,
          onPressed: onConfirmAppointmentTap,
        );
      }

      if (sellerConfirmed && !buyerConfirmed) {
        if (isLate) {
          return AppButton(
            width: double.infinity,
            height: 36,
            textSize: 14,
            text: l10n.booking_start_traveling,
            style: AppButtonStyle.primary,
            onPressed: onStartTravelTap,
          );
        }
        return Row(
          children: [
            Expanded(
              child: AppButton(
                width: double.infinity,
                height: 36,
                textSize: 14,
                text: l10n.calendar_cancel_label,
                style: AppButtonStyle.outline,
                onPressed: showCancelConfirm,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: AppButton(
                width: double.infinity,
                height: 36,
                textSize: 14,
                text: l10n.booking_start_traveling,
                style: AppButtonStyle.primary,
                onPressed: onStartTravelTap,
              ),
            ),
          ],
        );
      }

      if (sellerTraveling && !sellerArrived) {
        return Row(
          children: [
            Expanded(
              child: AppButton(
                width: double.infinity,
                height: 36,
                textSize: 14,
                text: l10n.calendar_view,
                style: AppButtonStyle.outline,
                onPressed: onRouteMapTap,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: AppButton(
                width: double.infinity,
                height: 36,
                textSize: 14,
                text: l10n.calendar_status_arrived,
                style: AppButtonStyle.primary,
                onPressed: onArrivedTap,
              ),
            ),
          ],
        );
      }

      final traveling =
          buyerAttendance?.travelingAt != null &&
          buyerAttendance?.arrivedAt == null;
      final arrived = buyerAttendance?.arrivedAt != null;

      if (arrived || traveling) {
        return AppButton(
          width: double.infinity,
          height: 36,
          textSize: 14,
          text: l10n.calendar_status_arrived,
          style: AppButtonStyle.primary,
          onPressed: onArrivedTap,
        );
      }

      return AppButton(
        width: double.infinity,
        height: 36,
        textSize: 14,
        text: l10n.booking_start_traveling,
        style: AppButtonStyle.primary,
        onPressed: onStartTravelTap,
      );
    } else {
      return const SizedBox.shrink();
    }
  }
}
