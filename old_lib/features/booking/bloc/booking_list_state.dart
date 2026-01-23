import 'package:equatable/equatable.dart';

import 'package:youragent/data/models/property_model.dart';
import 'package:youragent/domain/entities/booking.dart';
import 'package:youragent/domain/entities/user.dart';
import 'booking_list_sort.dart';

abstract class BookingListState extends Equatable {
  final BookingSort sort;
  final UserRole? role;

  const BookingListState({
    required this.sort,
    required this.role,
  });

  @override
  List<Object?> get props => [sort, role];
}

class BookingListLoading extends BookingListState {
  const BookingListLoading({
    required super.sort,
    required super.role,
  });
}

class BookingListLoaded extends BookingListState {
  final List<Booking> bookings;
  final Map<int, PropertyModel> propertyById;

  const BookingListLoaded({
    required super.sort,
    required super.role,
    required this.bookings,
    required this.propertyById,
  });

  @override
  List<Object?> get props => [sort, role, bookings, propertyById];
}

class BookingListError extends BookingListState {
  final String message;

  const BookingListError({
    required super.sort,
    required super.role,
    required this.message,
  });

  @override
  List<Object?> get props => [sort, role, message];
}


