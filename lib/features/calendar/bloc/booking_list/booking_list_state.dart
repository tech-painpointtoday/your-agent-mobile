import 'package:equatable/equatable.dart';
import 'package:youragent/domain/entities/booking.dart';
import 'package:youragent/domain/entities/pagination.dart';

enum BookingListStatus { initial, loading, success, failure }

class BookingListState extends Equatable {
  final BookingListStatus status;
  final List<Booking> bookings;
  final String? errorMessage;
  final Pagination? pagination;
  final int currentPage;
  final bool hasReachedMax;

  /// To handle different tabs (e.g. pending, confirmed), we might either filter
  /// the single `bookings` list on the UI side, or maintain separate lists/states.
  /// Given the API provides a single `/agent/bookings` endpoint, we might just fetch
  /// all and filter in UI, or pass status filters to the API if supported.
  /// The provided API snippet doesn't show status filtering, so we'll filter locally
  /// or just hold all bookings.

  const BookingListState({
    this.status = BookingListStatus.initial,
    this.bookings = const [],
    this.errorMessage,
    this.pagination,
    this.currentPage = 1,
    this.hasReachedMax = false,
  });

  BookingListState copyWith({
    BookingListStatus? status,
    List<Booking>? bookings,
    String? errorMessage,
    Pagination? pagination,
    int? currentPage,
    bool? hasReachedMax,
  }) {
    return BookingListState(
      status: status ?? this.status,
      bookings: bookings ?? this.bookings,
      errorMessage: errorMessage ?? this.errorMessage,
      pagination: pagination ?? this.pagination,
      currentPage: currentPage ?? this.currentPage,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
    );
  }

  @override
  List<Object?> get props => [
    status,
    bookings,
    errorMessage,
    pagination,
    currentPage,
    hasReachedMax,
  ];
}
