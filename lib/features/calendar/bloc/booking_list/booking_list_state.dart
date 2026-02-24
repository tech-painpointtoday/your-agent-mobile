import 'package:equatable/equatable.dart';
import 'package:youragent/domain/entities/booking.dart';
import 'package:youragent/domain/entities/pagination.dart';
import 'booking_date_filter.dart';

enum BookingListStatus { initial, loading, success, failure }

class BookingListState extends Equatable {
  final BookingListStatus status;
  final List<Booking> bookings;
  final String? errorMessage;
  final Pagination? pagination;
  final int currentPage;
  final bool hasReachedMax;
  final BookingDateFilter selectedFilter;
  final bool isLoadingMore;
  final DateTime? customFromDate;
  final DateTime? customToDate;
  final String searchQuery;

  const BookingListState({
    this.status = BookingListStatus.initial,
    this.bookings = const [],
    this.errorMessage,
    this.pagination,
    this.currentPage = 1,
    this.hasReachedMax = false,
    this.selectedFilter = BookingDateFilter.all,
    this.isLoadingMore = false,
    this.customFromDate,
    this.customToDate,
    this.searchQuery = '',
  });

  BookingListState copyWith({
    BookingListStatus? status,
    List<Booking>? bookings,
    String? errorMessage,
    Pagination? pagination,
    int? currentPage,
    bool? hasReachedMax,
    BookingDateFilter? selectedFilter,
    bool? isLoadingMore,
    DateTime? customFromDate,
    DateTime? customToDate,
    String? searchQuery,
    bool clearCustomDates = false,
  }) {
    return BookingListState(
      status: status ?? this.status,
      bookings: bookings ?? this.bookings,
      errorMessage: errorMessage ?? this.errorMessage,
      pagination: pagination ?? this.pagination,
      currentPage: currentPage ?? this.currentPage,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      selectedFilter: selectedFilter ?? this.selectedFilter,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      customFromDate: clearCustomDates
          ? null
          : (customFromDate ?? this.customFromDate),
      customToDate: clearCustomDates
          ? null
          : (customToDate ?? this.customToDate),
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }

  List<Booking> get filteredBookings {
    if (searchQuery.isEmpty) return bookings;
    final query = searchQuery.toLowerCase();
    return bookings.where((b) {
      final buyerName = b.buyer?.name.toLowerCase() ?? '';
      final propertyTitle = b.property?.title.toLowerCase() ?? '';
      final propertyName = b.property?.name?.toLowerCase() ?? '';
      final propertyAddress = b.property?.address?.toLowerCase() ?? '';
      return buyerName.contains(query) ||
          propertyTitle.contains(query) ||
          propertyName.contains(query) ||
          propertyAddress.contains(query);
    }).toList();
  }

  @override
  List<Object?> get props => [
    status,
    bookings,
    errorMessage,
    pagination,
    currentPage,
    hasReachedMax,
    selectedFilter,
    isLoadingMore,
    customFromDate,
    customToDate,
    searchQuery,
  ];
}
