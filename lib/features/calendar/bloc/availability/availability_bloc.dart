import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:youragent/services/available_time_api_service.dart';
import 'availability_event.dart';
import 'availability_state.dart';
import 'package:intl/intl.dart';

class AvailabilityBloc extends Bloc<AvailabilityEvent, AvailabilityState> {
  final AvailableTimeApiService _apiService;

  AvailabilityBloc({required AvailableTimeApiService apiService})
    : _apiService = apiService,
      super(const AvailabilityState()) {
    on<FetchAvailability>(_onFetch);
    on<CreateAvailability>(_onCreate);
    on<UpdateAvailability>(_onUpdate);
    on<DeleteAvailability>(_onDelete);
  }

  Future<void> _onFetch(
    FetchAvailability event,
    Emitter<AvailabilityState> emit,
  ) async {
    // If we've already fetched recently and it's the exact same month/year, we could cache.
    // For simplicity, let's fetch roughly the full month around the given date.

    emit(
      state.copyWith(status: AvailabilityStatus.loading, errorMessage: null),
    );

    try {
      // Calculate start and end date (e.g. 1st of month to end of month)
      final start = DateTime(event.date.year, event.date.month, 1);
      final end = DateTime(event.date.year, event.date.month + 1, 0);

      final startDateStr = DateFormat('yyyy-MM-dd').format(start);
      final endDateStr = DateFormat('yyyy-MM-dd').format(end);

      // Fetch from API
      // In a real app we might handle pagination or fetch all to display on calendar
      final response = await _apiService.getAvailableTimes(
        startDate: startDateStr,
        endDate: endDateStr,
        isAvailable: true,
        perPage: 100, // Fetch a large chunk for the calendar view
      );

      emit(
        state.copyWith(
          status: AvailabilityStatus.success,
          times: response.times,
          lastFetchedDate: event.date,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: AvailabilityStatus.failure,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  Future<void> _onCreate(
    CreateAvailability event,
    Emitter<AvailabilityState> emit,
  ) async {
    final currentTimes = List.of(state.times);
    emit(
      state.copyWith(status: AvailabilityStatus.loading, errorMessage: null),
    );

    try {
      final dateStr = DateFormat('yyyy-MM-dd').format(event.date);
      final newTime = await _apiService.createAvailableTime(
        date: dateStr,
        startTime: event.startTime,
        endTime: event.endTime,
      );

      emit(
        state.copyWith(
          status: AvailabilityStatus.success,
          times: [...currentTimes, newTime],
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: AvailabilityStatus.failure,
          errorMessage: e.toString(),
          times: currentTimes, // Restore on failure
        ),
      );
    }
  }

  Future<void> _onUpdate(
    UpdateAvailability event,
    Emitter<AvailabilityState> emit,
  ) async {
    final currentTimes = List.of(state.times);
    emit(
      state.copyWith(status: AvailabilityStatus.loading, errorMessage: null),
    );

    try {
      final updatedTime = await _apiService.updateAvailableTime(
        id: event.id,
        startTime: event.startTime,
        endTime: event.endTime,
        isAvailable: event.isAvailable,
      );

      final index = currentTimes.indexWhere((t) => t.id == event.id);
      if (index >= 0) {
        currentTimes[index] = updatedTime;
      }

      emit(
        state.copyWith(status: AvailabilityStatus.success, times: currentTimes),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: AvailabilityStatus.failure,
          errorMessage: e.toString(),
          times: currentTimes, // Restore
        ),
      );
    }
  }

  Future<void> _onDelete(
    DeleteAvailability event,
    Emitter<AvailabilityState> emit,
  ) async {
    final currentTimes = List.of(state.times);
    emit(
      state.copyWith(status: AvailabilityStatus.loading, errorMessage: null),
    );

    try {
      await _apiService.deleteAvailableTime(event.id);

      currentTimes.removeWhere((t) => t.id == event.id);

      emit(
        state.copyWith(status: AvailabilityStatus.success, times: currentTimes),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: AvailabilityStatus.failure,
          errorMessage: e.toString(),
          times: currentTimes, // Restore
        ),
      );
    }
  }
}
