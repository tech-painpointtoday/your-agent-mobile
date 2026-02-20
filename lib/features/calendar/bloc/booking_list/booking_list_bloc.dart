import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:youragent/services/booking_api_service.dart';
import 'booking_list_event.dart';
import 'booking_list_state.dart';

class BookingListBloc extends Bloc<BookingListEvent, BookingListState> {
  final BookingApiService _apiService;
  static const int _perPage = 15;

  BookingListBloc({required BookingApiService apiService})
    : _apiService = apiService,
      super(const BookingListState()) {
    on<FetchBookings>(_onFetchBookings);
    on<LoadMoreBookings>(_onLoadMoreBookings);
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
        final response = await _apiService.getBookings(
          page: 1,
          perPage: _perPage,
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
    if (state.hasReachedMax || state.status != BookingListStatus.success)
      return;

    final nextPage = state.currentPage + 1;

    try {
      final response = await _apiService.getBookings(
        page: nextPage,
        perPage: _perPage,
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
      // Typically we don't transit to failure state for pagination errors
      // if we already have some data to prevent losing the list UI.
      // But we could keep an error message to show a snackbar.
      emit(state.copyWith(errorMessage: e.toString()));
    }
  }
}
