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
    on<LoadMoreAvailability>(_onLoadMore);
    on<CreateAvailability>(_onCreate);
    on<UpdateAvailability>(_onUpdate);
    on<DeleteAvailability>(_onDelete);
  }

  Future<void> _onFetch(
    FetchAvailability event,
    Emitter<AvailabilityState> emit,
  ) async {
    emit(
      state.copyWith(
        status: AvailabilityStatus.loading,
        errorMessage: null,
        hasReachedMax: false,
        currentPage: 1,
        isLoadingMore: false,
        action: AvailabilityAction.fetch,
      ),
    );

    try {
      final start = DateTime(event.date.year, event.date.month, 1);
      final end = DateTime(event.date.year, event.date.month + 1, 0);

      final startDateStr = DateFormat('yyyy-MM-dd').format(start);
      final endDateStr = DateFormat('yyyy-MM-dd').format(end);

      final response = await _apiService.getAvailableTimes(
        startDate: startDateStr,
        endDate: endDateStr,
        isAvailable: true,
        page: 1,
        perPage: 10,
      );

      final bool hasReachedMax =
          response.pagination.currentPage >= response.pagination.lastPage;

      emit(
        state.copyWith(
          status: AvailabilityStatus.success,
          times: response.times,
          lastFetchedDate: event.date,
          hasReachedMax: hasReachedMax,
          currentPage: 1,
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

  Future<void> _onLoadMore(
    LoadMoreAvailability event,
    Emitter<AvailabilityState> emit,
  ) async {
    if (state.hasReachedMax ||
        state.isLoadingMore ||
        state.status != AvailabilityStatus.success ||
        state.lastFetchedDate == null) {
      return;
    }

    emit(state.copyWith(isLoadingMore: true));

    try {
      final date = state.lastFetchedDate!;
      final start = DateTime(date.year, date.month, 1);
      final end = DateTime(date.year, date.month + 1, 0);

      final startDateStr = DateFormat('yyyy-MM-dd').format(start);
      final endDateStr = DateFormat('yyyy-MM-dd').format(end);

      final nextPage = state.currentPage + 1;

      final response = await _apiService.getAvailableTimes(
        startDate: startDateStr,
        endDate: endDateStr,
        isAvailable: true,
        page: nextPage,
        perPage: 10,
      );

      final bool hasReachedMax =
          response.pagination.currentPage >= response.pagination.lastPage;

      emit(
        state.copyWith(
          times: List.of(state.times)..addAll(response.times),
          hasReachedMax: hasReachedMax,
          currentPage: nextPage,
          isLoadingMore: false,
        ),
      );
    } catch (e) {
      emit(state.copyWith(isLoadingMore: false, errorMessage: e.toString()));
    }
  }

  Future<void> _onCreate(
    CreateAvailability event,
    Emitter<AvailabilityState> emit,
  ) async {
    final currentTimes = List.of(state.times);
    emit(
      state.copyWith(
        status: AvailabilityStatus.loading,
        errorMessage: null,
        action: AvailabilityAction.create,
      ),
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
          action: AvailabilityAction.create,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: AvailabilityStatus.failure,
          errorMessage: e.toString(),
          times: currentTimes, // Restore on failure
          action: AvailabilityAction.create,
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
      state.copyWith(
        status: AvailabilityStatus.loading,
        errorMessage: null,
        action: AvailabilityAction.update,
      ),
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
        state.copyWith(
          status: AvailabilityStatus.success,
          times: currentTimes,
          action: AvailabilityAction.update,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: AvailabilityStatus.failure,
          errorMessage: e.toString(),
          times: currentTimes, // Restore
          action: AvailabilityAction.update,
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
      state.copyWith(
        status: AvailabilityStatus.loading,
        errorMessage: null,
        action: AvailabilityAction.delete,
      ),
    );

    try {
      await _apiService.deleteAvailableTime(event.id);

      currentTimes.removeWhere((t) => t.id == event.id);

      emit(
        state.copyWith(
          status: AvailabilityStatus.success,
          times: currentTimes,
          action: AvailabilityAction.delete,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: AvailabilityStatus.failure,
          errorMessage: e.toString(),
          times: currentTimes, // Restore
          action: AvailabilityAction.delete,
        ),
      );
    }
  }
}
