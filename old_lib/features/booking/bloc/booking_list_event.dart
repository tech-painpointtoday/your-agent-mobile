import 'package:equatable/equatable.dart';

import 'booking_list_sort.dart';

abstract class BookingListEvent extends Equatable {
  const BookingListEvent();

  @override
  List<Object?> get props => [];
}

class BookingListLoadRequested extends BookingListEvent {
  const BookingListLoadRequested();
}

class BookingListSortChanged extends BookingListEvent {
  final BookingSort sort;

  const BookingListSortChanged(this.sort);

  @override
  List<Object?> get props => [sort];
}


