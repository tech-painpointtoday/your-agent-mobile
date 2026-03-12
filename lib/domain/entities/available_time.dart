import 'package:equatable/equatable.dart';
import 'package:youragent/domain/entities/pagination.dart';

class AvailableTime extends Equatable {
  final int id;
  final int agentId;
  final int? sellerId;
  final String date;
  final String startTime;
  final String endTime;
  final bool isAvailable;
  final DateTime createdAt;
  final DateTime updatedAt;

  const AvailableTime({
    required this.id,
    required this.agentId,
    this.sellerId,
    required this.date,
    required this.startTime,
    required this.endTime,
    required this.isAvailable,
    required this.createdAt,
    required this.updatedAt,
  });

  static int _parseId(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is num) return value.toInt();
    return 0;
  }

  static int? _parseOptionalId(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is num) return value.toInt();
    return null;
  }

  factory AvailableTime.fromJson(Map<String, dynamic> json) {
    return AvailableTime(
      id: _parseId(json['id']),
      agentId: _parseId(json['agent_id']),
      sellerId: _parseOptionalId(json['seller_id']),
      date: json['date'] as String? ?? '',
      startTime: json['start_time'] as String? ?? '',
      endTime: json['end_time'] as String? ?? '',
      isAvailable: json['is_available'] as bool? ?? true,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String).toLocal()
          : DateTime.now(),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String).toLocal()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'agent_id': agentId,
      'seller_id': sellerId,
      'date': date,
      'start_time': startTime,
      'end_time': endTime,
      'is_available': isAvailable,
      'created_at': createdAt.toUtc().toIso8601String(),
      'updated_at': updatedAt.toUtc().toIso8601String(),
    };
  }

  AvailableTime copyWith({
    int? id,
    int? agentId,
    int? sellerId,
    String? date,
    String? startTime,
    String? endTime,
    bool? isAvailable,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return AvailableTime(
      id: id ?? this.id,
      agentId: agentId ?? this.agentId,
      sellerId: sellerId ?? this.sellerId,
      date: date ?? this.date,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      isAvailable: isAvailable ?? this.isAvailable,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
    id,
    agentId,
    sellerId,
    date,
    startTime,
    endTime,
    isAvailable,
    createdAt,
    updatedAt,
  ];
}

class PaginatedAvailableTimes extends Equatable {
  final List<AvailableTime> times;
  final Pagination pagination;

  const PaginatedAvailableTimes({
    required this.times,
    required this.pagination,
  });

  factory PaginatedAvailableTimes.fromJson(Map<String, dynamic> json) {
    return PaginatedAvailableTimes(
      times:
          (json['available_times'] as List<dynamic>?)
              ?.map((e) => AvailableTime.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      pagination: Pagination.fromJson(
        json['pagination'] as Map<String, dynamic>,
      ),
    );
  }

  @override
  List<Object?> get props => [times, pagination];
}
