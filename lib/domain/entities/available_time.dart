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

  factory AvailableTime.fromJson(Map<String, dynamic> json) {
    return AvailableTime(
      id: json['id'] as int,
      agentId: json['agent_id'] as int,
      sellerId: json['seller_id'] as int?,
      date: json['date'] as String,
      startTime: json['start_time'] as String,
      endTime: json['end_time'] as String,
      isAvailable: json['is_available'] as bool? ?? true,
      createdAt: DateTime.parse(json['created_at'] as String).toLocal(),
      updatedAt: DateTime.parse(json['updated_at'] as String).toLocal(),
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
