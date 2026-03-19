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

/// Status line below the badge for the **agent** side, adapted from the
/// buyer-facing logic and wired to the new attendance model.
String? bookingStatusLineForAgent({
  required AppLocalizations l10n,
  required Booking booking,
  required DateTime now,
}) {
  final today = DateTime(now.year, now.month, now.day);

  // Use bookingDateTime but strip time to compare on date-only level.
  final bookingDateTime = booking.bookingDateTime;
  final appointmentDate = DateTime(
    bookingDateTime.year,
    bookingDateTime.month,
    bookingDateTime.day,
  );

  final isBeforeDate = appointmentDate.isAfter(today);
  final isPastAppointmentDay = appointmentDate.isBefore(now);

  final sellerAttendance = booking.attendance?.seller;
  final buyerAttendance = booking.attendance?.buyer;

  final buyerArrived = buyerAttendance?.arrivedAt != null;
  final sellerArrived = sellerAttendance?.arrivedAt != null;

  final isMet = buyerArrived && sellerArrived;
  final buyerConfirmedOnDate = buyerAttendance?.confirmedOnDateAt != null;
  final sellerTravelingAt = sellerAttendance?.travelingAt;
  final sellerArrivedAt = sellerAttendance?.arrivedAt;

  if (booking.status == BookingStatus.cancelled) {
    return null;
  } else if (isPastAppointmentDay && !isMet) {
    return l10n.booking_status_past_appointment_day;
  } else if (booking.status == BookingStatus.confirm) {
    if (isBeforeDate) {
      // Future appointment day – waiting period.
      return l10n.booking_status_before_appointment;
    } else if (!buyerConfirmedOnDate) {
      // Appointment day but buyer has not confirmed yet.
      return l10n.booking_status_agent_please_confirm_line_detail(
        l10n.booking_confirm_booking,
      );
    } else if (buyerConfirmedOnDate) {
      // Buyer confirmed on date, show seller/agent travel state.
      if (sellerArrivedAt != null) {
        return l10n.booking_status_arrived_client;
      } else if (sellerTravelingAt != null) {
        final travelTime = DateFormat(
          'HH:mm',
        ).format(sellerTravelingAt.toLocal());
        return '${l10n.booking_status_traveling_client} (${l10n.booking_start_traveling} $travelTime)';
      }

      // Confirmed but not started traveling/arrived yet.
      return l10n.calendar_not_started_status;
    }
  }

  return null;
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

  final statusLine = bookingStatusLineForAgent(
    l10n: l10n,
    booking: booking,
    now: now,
  );
  if (booking.status == BookingStatus.confirm) {
    if (!isAppointmentDay && !isPastAppointmentDay) {
      return BookingConfirmFlowUi(
        badgeLabel: l10n.not_yet_appointment_day,
        badgeColor: BadgeColor.default_,
        statusLine: statusLine,
      );
    } else if (!sellerConfirmed) {
      return BookingConfirmFlowUi(
        badgeLabel: l10n.calendar_unconfirmed_on_date,
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
    badgeLabel: l10n.calendar_unconfirmed_on_date,
    badgeColor: BadgeColor.default_,
  );
}
