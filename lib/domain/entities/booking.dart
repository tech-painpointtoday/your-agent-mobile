import 'package:equatable/equatable.dart';
import 'package:yourhome/domain/entities/buyer.dart';
import 'package:yourhome/domain/entities/property.dart';
import 'package:yourhome/domain/entities/pagination.dart';
import 'package:yourhome/core/enums/booking_status.dart';

class BookingAttendanceParty extends Equatable {
  final String? status;
  final DateTime? confirmedOnDateAt;
  final DateTime? travelingAt;
  final DateTime? arrivedAt;

  const BookingAttendanceParty({
    this.status,
    this.confirmedOnDateAt,
    this.travelingAt,
    this.arrivedAt,
  });

  factory BookingAttendanceParty.fromJson(Map<String, dynamic> json) {
    return BookingAttendanceParty(
      status: json['status']?.toString(),
      confirmedOnDateAt: json['confirmed_on_date_at'] != null
          ? DateTime.tryParse(json['confirmed_on_date_at'].toString())
          : null,
      travelingAt: json['traveling_at'] != null
          ? DateTime.tryParse(json['traveling_at'].toString())
          : null,
      arrivedAt: json['arrived_at'] != null
          ? DateTime.tryParse(json['arrived_at'].toString())
          : null,
    );
  }

  @override
  List<Object?> get props => [
    status,
    confirmedOnDateAt,
    travelingAt,
    arrivedAt,
  ];
}

class BookingAttendance extends Equatable {
  final BookingAttendanceParty? buyer;
  final BookingAttendanceParty? seller;

  const BookingAttendance({this.buyer, this.seller});

  factory BookingAttendance.fromJson(Map<String, dynamic> json) {
    return BookingAttendance(
      buyer: json['buyer'] is Map<String, dynamic>
          ? BookingAttendanceParty.fromJson(
              json['buyer'] as Map<String, dynamic>,
            )
          : null,
      seller: json['seller'] is Map<String, dynamic>
          ? BookingAttendanceParty.fromJson(
              json['seller'] as Map<String, dynamic>,
            )
          : null,
    );
  }

  @override
  List<Object?> get props => [buyer, seller];
}

class Booking extends Equatable {
  final int id;
  final int propertyId;
  final int buyerId;
  final int? agentId;
  final int? sellerId;
  final String ymd;
  final String time;
  final BookingStatus status;
  final String statusLabel;
  final bool autoMatched;
  final DateTime? cancelledAt;
  final DateTime? confirmedAt;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final int? timeUntilBookingSeconds;
  final Property? property;
  final Buyer? buyer;

  /// Individual attendance status/timestamps for buyer and seller/agent.
  final BookingAttendance? attendance;

  /// Cached travel-time information, when provided by the API.
  final int? travelTimeSeconds;
  final String? travelTimeFormatted;
  final int? timeUntilAppointmentSeconds;
  final String? timeUntilAppointmentFormatted;
  final int? requiredTimeSeconds;

  const Booking({
    required this.id,
    required this.propertyId,
    required this.buyerId,
    this.agentId,
    this.sellerId,
    required this.ymd,
    required this.time,
    required this.status,
    required this.statusLabel,
    required this.autoMatched,
    this.cancelledAt,
    this.confirmedAt,
    this.createdAt,
    this.updatedAt,
    this.timeUntilBookingSeconds,
    this.property,
    this.buyer,
    this.attendance,
    this.travelTimeSeconds,
    this.travelTimeFormatted,
    this.timeUntilAppointmentSeconds,
    this.timeUntilAppointmentFormatted,
    this.requiredTimeSeconds,
  });

  factory Booking.fromJson(Map<String, dynamic> json) {
    return Booking(
      id: json['id'] as int,
      propertyId: json['property_id'] as int,
      buyerId: json['buyer_id'] as int,
      agentId: json['agent_id'] as int?,
      sellerId: json['seller_id'] as int?,
      ymd: json['ymd'] as String,
      time: json['time'] as String,
      status: BookingStatus.fromInt(json['status'] as int? ?? 0),
      statusLabel: json['status_label']?.toString() ?? '',
      autoMatched: json['auto_matched'] as bool? ?? false,
      cancelledAt: json['cancelled_at'] != null
          ? DateTime.tryParse(json['cancelled_at'].toString())
          : null,
      confirmedAt: json['confirmed_at'] != null
          ? DateTime.tryParse(json['confirmed_at'].toString())
          : null,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString())
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'].toString())
          : null,
      timeUntilBookingSeconds: json['time_until_booking_seconds'] as int?,
      property: json['property'] != null
          ? Property.fromJson(json['property'] as Map<String, dynamic>)
          : null,
      buyer: json['buyer'] != null
          ? Buyer.fromJson(json['buyer'] as Map<String, dynamic>)
          : null,
      attendance: json['attendance'] is Map<String, dynamic>
          ? BookingAttendance.fromJson(
              json['attendance'] as Map<String, dynamic>,
            )
          : null,
      travelTimeSeconds: json['travel_time_seconds'] as int?,
      travelTimeFormatted: json['travel_time_formatted']?.toString(),
      timeUntilAppointmentSeconds:
          json['time_until_appointment_seconds'] as int?,
      timeUntilAppointmentFormatted: json['time_until_appointment_formatted']
          ?.toString(),
      requiredTimeSeconds: json['required_time_seconds'] as int?,
    );
  }

  @override
  List<Object?> get props => [
    id,
    propertyId,
    buyerId,
    agentId,
    sellerId,
    ymd,
    time,
    status,
    statusLabel,
    autoMatched,
    cancelledAt,
    confirmedAt,
    createdAt,
    updatedAt,
    timeUntilBookingSeconds,
    property,
    buyer,
    attendance,
    travelTimeSeconds,
    travelTimeFormatted,
    timeUntilAppointmentSeconds,
    timeUntilAppointmentFormatted,
    requiredTimeSeconds,
  ];

  /// Returns the booking's datetime as a [DateTime] object.
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

  /// Returns true if the booking is in the future (upcoming)
  bool get isUpcoming {
    final now = DateTime.now();
    if (bookingDateTime.isAfter(now)) return true;

    // If same day and status is confirm, keep it in upcoming/active
    if (status == BookingStatus.confirm) {
      final today = DateTime(now.year, now.month, now.day);
      final bookingDate = DateTime(
        bookingDateTime.year,
        bookingDateTime.month,
        bookingDateTime.day,
      );
      if (bookingDate.isAtSameMomentAs(today)) return true;
    }
    return false;
  }

  /// Returns true if the booking is in the past (history)
  bool get isPast => !isUpcoming;
}

class PaginatedBookings extends Equatable {
  final List<Booking> bookings;
  final Pagination pagination;

  const PaginatedBookings({required this.bookings, required this.pagination});

  factory PaginatedBookings.fromJson(Map<String, dynamic> json) {
    final rawData = json['data'];
    List<dynamic> list;
    Map<String, dynamic> metaJson;
    if (rawData is List<dynamic>) {
      list = rawData;
      metaJson = _metaMap(json['meta']) ?? _metaMap(json['pagination']) ?? {};
    } else if (rawData is Map<String, dynamic>) {
      list =
          rawData['data'] as List<dynamic>? ??
          rawData['bookings'] as List<dynamic>? ??
          <dynamic>[];
      metaJson =
          _metaMap(rawData['meta']) ??
          _metaMap(rawData['pagination']) ??
          _metaMap(json['meta']) ??
          _metaMap(json['pagination']) ??
          {};
    } else {
      list = <dynamic>[];
      metaJson = _metaMap(json['meta']) ?? _metaMap(json['pagination']) ?? {};
    }
    return PaginatedBookings(
      bookings: list
          .map((e) => Booking.fromJson(e as Map<String, dynamic>))
          .toList(),
      pagination: Pagination.fromJson(metaJson),
    );
  }

  static Map<String, dynamic>? _metaMap(dynamic value) {
    if (value is Map<String, dynamic>) return value;
    return null;
  }

  @override
  List<Object?> get props => [bookings, pagination];
}
