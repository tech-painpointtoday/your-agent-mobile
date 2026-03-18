import 'package:intl/intl.dart';
import 'package:youragent/core/enums/booking_status.dart';
import 'package:youragent/domain/entities/booking.dart';
import 'package:youragent/l10n/app_localizations.dart';
import 'package:youragent/widgets/badges/app_badge.dart';

class BookingConfirmFlowUi {
  final String badgeLabel;
  final BadgeColor badgeColor;
  final String? statusLine;

  const BookingConfirmFlowUi({
    required this.badgeLabel,
    required this.badgeColor,
    this.statusLine,
  });
}

extension BookingDateTimeX on Booking {
  DateTime get bookingDateTime {
    try {
      DateTime? d = DateTime.tryParse(ymd);

      // Fallback for YYYYMMDD format
      if (d == null && ymd.length == 8) {
        final year = int.tryParse(ymd.substring(0, 4));
        final month = int.tryParse(ymd.substring(4, 6));
        final day = int.tryParse(ymd.substring(6, 8));
        if (year != null && month != null && day != null) {
          d = DateTime(year, month, day);
        }
      }

      d ??= DateTime.now();

      final parts = time.split(':');
      final h = parts.isNotEmpty ? int.tryParse(parts[0]) ?? 0 : 0;
      final m = parts.length > 1 ? int.tryParse(parts[1]) ?? 0 : 0;
      return DateTime(d.year, d.month, d.day, h, m);
    } catch (_) {
      return DateTime.now();
    }
  }
}

bool isBookingAppointmentDay({
  required Booking booking,
  required DateTime now,
}) {
  final bookingDateTime = booking.bookingDateTime;
  final bookingDate = DateTime(
    bookingDateTime.year,
    bookingDateTime.month,
    bookingDateTime.day,
  );
  return bookingDate.isBefore(now) &&
      now.isBefore(bookingDate.add(const Duration(days: 1)));
}

BookingConfirmFlowUi computeAgentConfirmFlowUi({
  required Booking booking,
  required AppLocalizations l10n,
  required DateTime now,
}) {
  final sellerAttendance = booking.attendance?.seller;
  final buyerAttendance = booking.attendance?.buyer;

  final isAppointmentDay = isBookingAppointmentDay(booking: booking, now: now);
  final isPastAppointmentDay = booking.bookingDateTime.isBefore(now);
  final sellerConfirmed = sellerAttendance?.confirmedOnDateAt != null;
  final buyerConfirmed = buyerAttendance?.confirmedOnDateAt != null;

  String? statusLine;
  if (booking.status == BookingStatus.confirm) {
    if (!isAppointmentDay && !isPastAppointmentDay) {
      statusLine = l10n.not_yet_appointment_day;
    } else if (!isAppointmentDay) {
      statusLine = null;
    } else if (!sellerConfirmed) {
      statusLine = l10n.booking_status_agent_please_confirm_line_detail(
        l10n.booking_confirm_booking,
      );
    } else if (sellerConfirmed) {
      if (!buyerConfirmed) {
        statusLine = l10n.booking_status_waiting_client_confirm_badge;
      } else if (buyerAttendance?.arrivedAt != null) {
        statusLine = null;
      } else if (buyerAttendance?.travelingAt != null) {
        final travelTime = DateFormat(
          'HH:mm',
        ).format(buyerAttendance!.travelingAt!.toLocal());
        statusLine =
            '${l10n.buyer_traveling} (${l10n.booking_start_traveling} $travelTime)';
      } else {
        statusLine = l10n.calendar_not_started_status;
      }
    }

    if (!isAppointmentDay && !isPastAppointmentDay) {
      return BookingConfirmFlowUi(
        badgeLabel: l10n.not_yet_appointment_day,
        badgeColor: BadgeColor.default_,
        statusLine: statusLine,
      );
    } else if (!sellerConfirmed) {
      return BookingConfirmFlowUi(
        badgeLabel: l10n.booking_unconfirmed_on_date,
        badgeColor: BadgeColor.yellow,
        statusLine: statusLine,
      );
    } else if (sellerConfirmed && !buyerConfirmed) {
      return BookingConfirmFlowUi(
        badgeLabel: l10n.booking_status_pending_client,
        badgeColor: BadgeColor.yellow,
        statusLine: statusLine,
      );
    }

    final traveling =
        buyerAttendance?.travelingAt != null &&
        buyerAttendance?.arrivedAt == null;
    final arrived = buyerAttendance?.arrivedAt != null;

    if (arrived) {
      final timeStr = DateFormat.Hm().format(
        buyerAttendance!.arrivedAt!.toLocal(),
      );
      return BookingConfirmFlowUi(
        badgeLabel: '${l10n.calendar_status_arrived} ($timeStr)',
        badgeColor: BadgeColor.purple,
        statusLine: statusLine,
      );
    } else if (traveling) {
      return BookingConfirmFlowUi(
        badgeLabel: l10n.booking_status_traveling_client,
        badgeColor: BadgeColor.blue,
        statusLine: statusLine,
      );
    }

    return BookingConfirmFlowUi(
      badgeLabel: l10n.calendar_status_confirmed,
      badgeColor: BadgeColor.green,
      statusLine: statusLine,
    );
  }

  return BookingConfirmFlowUi(
    badgeLabel: l10n.booking_unconfirmed_on_date,
    badgeColor: BadgeColor.default_,
  );
}
