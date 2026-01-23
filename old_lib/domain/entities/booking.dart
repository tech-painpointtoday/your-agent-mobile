import 'package:equatable/equatable.dart';

/// Booking entity matching the old Laravel Booking model
enum BookingStatus { pending, confirmed, cancelled }

class Booking extends Equatable {
  final int? id;
  final int propertyId;
  final int? buyerId;
  final int? agentId;
  final String ymd; // Date in YYYY-MM-DD format
  final String time; // Time string
  final BookingStatus status;
  final bool autoMatched;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final DateTime? cancelledAt;
  final DateTime? confirmedAt;

  const Booking({
    this.id,
    required this.propertyId,
    this.buyerId,
    this.agentId,
    required this.ymd,
    required this.time,
    required this.status,
    this.autoMatched = false,
    this.createdAt,
    this.updatedAt,
    this.cancelledAt,
    this.confirmedAt,
  });

  factory Booking.fromJson(Map<String, dynamic> json) {
    final cancelledAt = json['cancelled_at'] != null
        ? DateTime.parse(json['cancelled_at'])
        : null;
    final confirmedAt = json['confirmed_at'] != null
        ? DateTime.parse(json['confirmed_at'])
        : null;
    
    return Booking(
      id: json['id'] as int?,
      propertyId: _parseInt(json['property_id']) ?? 0,
      buyerId: json['buyer_id'] as int?,
      agentId: json['agent_id'] as int?,
      ymd: _normalizeYmd(json['ymd']),
      time: (json['time'] ?? '').toString(),
      status: _parseStatus(
        json['status'],
        cancelledAt: cancelledAt,
        confirmedAt: confirmedAt,
      ),
      autoMatched: json['auto_matched'] as bool? ?? false,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : null,
      cancelledAt: cancelledAt,
      confirmedAt: confirmedAt,
    );
  }

  static int? _parseInt(dynamic v) {
    if (v is int) return v;
    if (v is String) return int.tryParse(v);
    return null;
  }

  /// Backend sometimes returns `ymd` as `20241215` (int or string).
  /// Normalize into `YYYY-MM-DD` so DateTime.parse/tryParse works.
  static String _normalizeYmd(dynamic ymd) {
    if (ymd == null) return '';
    final raw = ymd.toString().trim();
    if (raw.isEmpty) return '';
    // If already looks like ISO date, keep as-is.
    if (raw.contains('-') && raw.length >= 10) return raw;
    // If it's YYYYMMDD (8 digits), convert to YYYY-MM-DD
    if (RegExp(r'^\d{8}$').hasMatch(raw)) {
      final yyyy = raw.substring(0, 4);
      final mm = raw.substring(4, 6);
      final dd = raw.substring(6, 8);
      return '$yyyy-$mm-$dd';
    }
    return raw;
  }

  static BookingStatus _parseStatus(
    dynamic status, {
    DateTime? cancelledAt,
    DateTime? confirmedAt,
  }) {
    // Status logic:
    // - status = 2 & cancelled_at not null = cancelled
    // - status = 1 & confirmed_at not null = confirmed
    // - status = 0 & both null = pending
    
    if (status is int) {
      // Check cancelled first
      if (status == 2 && cancelledAt != null) {
        return BookingStatus.cancelled;
      }
      // Check confirmed
      if (status == 1 && confirmedAt != null) {
        return BookingStatus.confirmed;
      }
      // Check pending
      if (status == 0 && cancelledAt == null && confirmedAt == null) {
        return BookingStatus.pending;
      }
      // Fallback based on status value if conditions don't match
      switch (status) {
        case 0:
          return BookingStatus.pending;
        case 1:
          return BookingStatus.confirmed;
        case 2:
          return BookingStatus.cancelled;
        default:
          return BookingStatus.pending;
      }
    }
    if (status is String) {
      switch (status.toLowerCase()) {
        case 'pending':
          return BookingStatus.pending;
        case 'confirmed':
          return BookingStatus.confirmed;
        case 'cancelled':
          return BookingStatus.cancelled;
        default:
          return BookingStatus.pending;
      }
    }
    return BookingStatus.pending;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'property_id': propertyId,
      'buyer_id': buyerId,
      'agent_id': agentId,
      'ymd': ymd,
      'time': time,
      'status': status.name,
      'auto_matched': autoMatched,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'cancelled_at': cancelledAt?.toIso8601String(),
      'confirmed_at': confirmedAt?.toIso8601String(),
    };
  }

  bool get isPending => status == BookingStatus.pending;
  bool get isConfirmed => status == BookingStatus.confirmed;
  bool get isCancelled => status == BookingStatus.cancelled;

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
    createdAt,
    updatedAt,
    cancelledAt,
    confirmedAt,
  ];
}
