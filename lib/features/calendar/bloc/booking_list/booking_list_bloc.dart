import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:yourhome/services/booking_api_service.dart';
import 'package:intl/intl.dart';
import 'booking_list_event.dart';
import 'booking_list_state.dart';
import 'booking_date_filter.dart';

class BookingListBloc extends Bloc<BookingListEvent, BookingListState> {
  final BookingApiService _apiService;
  static const int _perPage = 10;
  Timer? _debounce;

  BookingListBloc({required BookingApiService apiService})
    : _apiService = apiService,
      super(const BookingListState()) {
    on<FetchBookings>(_onFetchBookings);
    on<LoadMoreBookings>(_onLoadMoreBookings);
    on<FilterBookings>(_onFilterBookings);
    on<SetCustomDateRange>(_onSetCustomDateRange);
    on<SearchBookings>(_onSearchBookings);
  }

  void _onSearchBookings(SearchBookings event, Emitter<BookingListState> emit) {
    emit(state.copyWith(searchQuery: event.query));
  }

  @override
  Future<void> close() {
    _debounce?.cancel();
    return super.close();
  }

  void _onSetCustomDateRange(
    SetCustomDateRange event,
    Emitter<BookingListState> emit,
  ) {
    emit(
      state.copyWith(
        customFromDate: event.from,
        customToDate: event.to,
        clearCustomDates: false,
      ),
    );
    add(const FetchBookings(refresh: true));
  }

  void _onFilterBookings(FilterBookings event, Emitter<BookingListState> emit) {
    if (state.selectedFilter != event.filter || state.customFromDate != null) {
      emit(
        state.copyWith(selectedFilter: event.filter, clearCustomDates: true),
      );
      add(const FetchBookings(refresh: true));
    }
  }

  (String?, String?) _getDateBounds(BookingListState state) {
    final DateFormat formatter = DateFormat('yyyy-MM-dd');
    if (state.customFromDate != null && state.customToDate != null) {
      return (
        formatter.format(state.customFromDate!),
        formatter.format(state.customToDate!),
      );
    }

    final now = DateTime.now();
    switch (state.selectedFilter) {
      case BookingDateFilter.all:
        return (null, null);
      case BookingDateFilter.today:
        final todayStr = formatter.format(now);
        return (todayStr, todayStr);
      case BookingDateFilter.tomorrow:
        final tomorrowStr = formatter.format(now.add(const Duration(days: 1)));
        return (tomorrowStr, tomorrowStr);
      case BookingDateFilter.week:
        final int currentWeekday = now.weekday; // 1 = Mon, 7 = Sun
        final DateTime startOfWeek = now.subtract(
          Duration(days: currentWeekday - 1),
        );
        final DateTime endOfWeek = startOfWeek.add(const Duration(days: 6));
        final fromStr = formatter.format(startOfWeek);
        final toStr = formatter.format(endOfWeek);
        return (fromStr, toStr);
    }
  }

  Future<void> _onFetchBookings(
    FetchBookings event,
    Emitter<BookingListState> emit,
  ) async {
    if (event.refresh || state.status == BookingListStatus.initial) {
      emit(
        state.copyWith(status: BookingListStatus.loading, errorMessage: null),
      );

      try {
        final (from, to) = _getDateBounds(state);
        final response = await _apiService.getBookings(
          page: 1,
          perPage: _perPage,
          from: from,
          to: to,
        );

        emit(
          state.copyWith(
            status: BookingListStatus.success,
            bookings: response.bookings,
            pagination: response.pagination,
            currentPage: 1,
            hasReachedMax:
                response.bookings.length < _perPage ||
                response.pagination.currentPage >= response.pagination.lastPage,
          ),
        );
      } catch (e) {
        emit(
          state.copyWith(
            status: BookingListStatus.failure,
            errorMessage: e.toString(),
          ),
        );
      }
    }
  }

  Future<void> _onLoadMoreBookings(
    LoadMoreBookings event,
    Emitter<BookingListState> emit,
  ) async {
    if (state.hasReachedMax ||
        state.status != BookingListStatus.success ||
        state.isLoadingMore) {
      return;
    }

    emit(state.copyWith(isLoadingMore: true));
    final nextPage = state.currentPage + 1;

    try {
      final (from, to) = _getDateBounds(state);
      final response = await _apiService.getBookings(
        page: nextPage,
        perPage: _perPage,
        from: from,
        to: to,
      );

      final newBookings = List.of(state.bookings)..addAll(response.bookings);

      emit(
        state.copyWith(
          status: BookingListStatus.success,
          bookings: newBookings,
          pagination: response.pagination,
          currentPage: nextPage,
          hasReachedMax:
              response.bookings.isEmpty ||
              response.pagination.currentPage >= response.pagination.lastPage,
        ),
      );
    } catch (e) {
      emit(state.copyWith(errorMessage: e.toString(), isLoadingMore: false));
    }
  }
}
