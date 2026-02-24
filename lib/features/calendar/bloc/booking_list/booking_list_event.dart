import 'package:equatable/equatable.dart';
import 'booking_date_filter.dart';

abstract class BookingListEvent extends Equatable {
  const BookingListEvent();

  @override
  List<Object?> get props => [];
}

class FetchBookings extends BookingListEvent {
  final bool refresh; // To force refresh

  const FetchBookings({this.refresh = false});

  @override
  List<Object?> get props => [refresh];
}

class LoadMoreBookings extends BookingListEvent {
  const LoadMoreBookings();
}

class FilterBookings extends BookingListEvent {
  final BookingDateFilter filter;

  const FilterBookings(this.filter);

  @override
  List<Object?> get props => [filter];
}

class SetCustomDateRange extends BookingListEvent {
  final DateTime from;
  final DateTime to;

  const SetCustomDateRange(this.from, this.to);

  @override
  List<Object?> get props => [from, to];
}

class SearchBookings extends BookingListEvent {
  final String query;

  const SearchBookings(this.query);

  @override
  List<Object?> get props => [query];
}
