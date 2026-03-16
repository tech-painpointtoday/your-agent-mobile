import 'package:equatable/equatable.dart';
import 'package:yourhome/domain/entities/available_time.dart';

enum AvailabilityStatus { initial, loading, success, failure }

enum AvailabilityAction { none, fetch, loadMore, create, update, delete }

class AvailabilityState extends Equatable {
  final AvailabilityStatus status;
  final List<AvailableTime> times;
  final String? errorMessage;
  final DateTime? lastFetchedDate;
  final bool hasReachedMax;
  final int currentPage;
  final bool isLoadingMore;
  final AvailabilityAction action;

  const AvailabilityState({
    this.status = AvailabilityStatus.initial,
    this.times = const [],
    this.errorMessage,
    this.lastFetchedDate,
    this.hasReachedMax = false,
    this.currentPage = 1,
    this.isLoadingMore = false,
    this.action = AvailabilityAction.none,
  });

  AvailabilityState copyWith({
    AvailabilityStatus? status,
    List<AvailableTime>? times,
    String? errorMessage,
    DateTime? lastFetchedDate,
    bool? hasReachedMax,
    int? currentPage,
    bool? isLoadingMore,
    AvailabilityAction? action,
  }) {
    return AvailabilityState(
      status: status ?? this.status,
      times: times ?? this.times,
      errorMessage: errorMessage,
      lastFetchedDate: lastFetchedDate ?? this.lastFetchedDate,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      currentPage: currentPage ?? this.currentPage,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      action: action ?? this.action,
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
  List<Object?> get props => [
    status,
    times,
    errorMessage,
    lastFetchedDate,
    hasReachedMax,
    currentPage,
    isLoadingMore,
    action,
  ];
}
