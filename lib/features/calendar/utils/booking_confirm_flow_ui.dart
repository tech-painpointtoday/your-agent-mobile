import 'package:intl/intl.dart';
import 'package:yourhome/core/enums/booking_status.dart';
import 'package:yourhome/domain/entities/booking.dart';
import 'package:yourhome/l10n/app_localizations.dart';
import 'package:yourhome/widgets/badges/app_badge.dart';

class BookingConfirmFlowUi {
  final String badgeLabel;
  final BadgeColor badgeColor;
  final String? statusLine;

  const BookingConfirmFlowUi({
    required this.badgeLabel,
    required this.badgeColor,
    required this.statusLine,
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
  final sellerConfirmed = sellerAttendance?.confirmedOnDateAt != null;
  final buyerConfirmed = buyerAttendance?.confirmedOnDateAt != null;

  String? statusLine;
  if (booking.status == BookingStatus.confirm) {
    if (!isAppointmentDay) {
      statusLine = null;
    } else if (!sellerConfirmed) {
      statusLine = l10n.booking_confirm_booking_title;
    } else if (sellerConfirmed) {
      if (!buyerConfirmed) {
        statusLine = l10n.booking_status_pending_client;
      } else if (buyerAttendance?.arrivedAt != null) {
        statusLine = l10n.booking_status_arrived_client;
      } else if (buyerAttendance?.travelingAt != null) {
        final travelTime = DateFormat(
          'HH:mm',
        ).format(buyerAttendance!.travelingAt!.toLocal());
        statusLine =
            '${l10n.booking_status_traveling_client} (${l10n.booking_start_traveling} $travelTime)';
      } else {
        statusLine = l10n.calendar_not_started_status;
      }
    }
  }

  if (!isAppointmentDay) {
    return BookingConfirmFlowUi(
      badgeLabel: l10n.calendar_status_confirmed,
      badgeColor: BadgeColor.default_,
      statusLine: statusLine,
    );
  }

  if (!sellerConfirmed) {
    return BookingConfirmFlowUi(
      badgeLabel: l10n.calendar_status_confirmed,
      badgeColor: BadgeColor.yellow,
      statusLine: statusLine,
    );
  }

  if (sellerConfirmed && !buyerConfirmed) {
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
    final timeStr =
        DateFormat.Hm().format(buyerAttendance!.arrivedAt!.toLocal());
    return BookingConfirmFlowUi(
      badgeLabel: '${l10n.calendar_status_arrived} ($timeStr)',
      badgeColor: BadgeColor.purple,
      statusLine: statusLine,
    );
  }

  if (traveling) {
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

