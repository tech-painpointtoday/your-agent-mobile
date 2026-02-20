import 'package:equatable/equatable.dart';
import 'package:youragent/domain/entities/available_time.dart';

enum AvailabilityStatus { initial, loading, success, failure }

class AvailabilityState extends Equatable {
  final AvailabilityStatus status;
  final List<AvailableTime> times;
  final String? errorMessage;
  final DateTime? lastFetchedDate;

  const AvailabilityState({
    this.status = AvailabilityStatus.initial,
    this.times = const [],
    this.errorMessage,
    this.lastFetchedDate,
  });

  AvailabilityState copyWith({
    AvailabilityStatus? status,
    List<AvailableTime>? times,
    String? errorMessage,
    DateTime? lastFetchedDate,
  }) {
    return AvailabilityState(
      status: status ?? this.status,
      times: times ?? this.times,
      errorMessage: errorMessage,
      lastFetchedDate: lastFetchedDate ?? this.lastFetchedDate,
    );
  }

  Map<String, List<AvailableTime>> get groupedTimes {
    final map = <String, List<AvailableTime>>{};
    for (var time in times) {
      if (!map.containsKey(time.date)) {
        map[time.date] = [];
      }
      map[time.date]!.add(time);
    }
    // Optional: Sort each day's slots by start time
    for (var key in map.keys) {
      map[key]!.sort((a, b) => a.startTime.compareTo(b.startTime));
    }
    return map;
  }

  @override
  List<Object?> get props => [status, times, errorMessage, lastFetchedDate];
}
