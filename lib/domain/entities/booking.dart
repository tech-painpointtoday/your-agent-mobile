import 'package:equatable/equatable.dart';
import 'package:youragent/domain/entities/buyer.dart';
import 'package:youragent/domain/entities/property.dart';
import 'package:youragent/domain/entities/pagination.dart';

class Booking extends Equatable {
  final int id;
  final int propertyId;
  final int buyerId;
  final int? agentId;
  final String ymd;
  final String time;
  final int status;
  final bool autoMatched;
  final DateTime? cancelledAt;
  final DateTime? confirmedAt;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final int? timeUntilBookingSeconds;
  final Property? property;
  final Buyer? buyer;

  const Booking({
    required this.id,
    required this.propertyId,
    required this.buyerId,
    this.agentId,
    required this.ymd,
    required this.time,
    required this.status,
    required this.autoMatched,
    this.cancelledAt,
    this.confirmedAt,
    this.createdAt,
    this.updatedAt,
    this.timeUntilBookingSeconds,
    this.property,
    this.buyer,
  });

  factory Booking.fromJson(Map<String, dynamic> json) {
    return Booking(
      id: json['id'] as int,
      propertyId: json['property_id'] as int,
      buyerId: json['buyer_id'] as int,
      agentId: json['agent_id'] as int?,
      ymd: json['ymd'] as String,
      time: json['time'] as String,
      status: json['status'] as int? ?? 0,
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
    );
  }

  @override
  List<Object?> get props => [
    id,
    propertyId,
    buyerId,
    agentId,
    ymd,
    time,
    status,
    autoMatched,
    cancelledAt,
    confirmedAt,
    createdAt,
    updatedAt,
    timeUntilBookingSeconds,
    property,
    buyer,
  ];
}

class PaginatedBookings extends Equatable {
  final List<Booking> bookings;
  final Pagination pagination;

  const PaginatedBookings({required this.bookings, required this.pagination});

  factory PaginatedBookings.fromJson(Map<String, dynamic> json) {
    final List<dynamic> data = json['data'] ?? [];
    return PaginatedBookings(
      bookings: data.map((e) => Booking.fromJson(e)).toList(),
      pagination: Pagination.fromJson(json['meta'] ?? json['pagination'] ?? {}),
    );
  }

  @override
  List<Object?> get props => [bookings, pagination];
}
