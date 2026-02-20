import 'package:equatable/equatable.dart';

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
