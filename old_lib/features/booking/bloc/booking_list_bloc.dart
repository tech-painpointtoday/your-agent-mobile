import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:youragent/core/di/dependency_injection.dart';
import 'package:youragent/data/models/property_model.dart';
import 'package:youragent/domain/entities/booking.dart';
import 'package:youragent/domain/entities/user.dart';
import 'booking_list_event.dart';
import 'booking_list_sort.dart';
import 'booking_list_state.dart';

class BookingListBloc extends Bloc<BookingListEvent, BookingListState> {
  final UserRole? _role;

  BookingListBloc({UserRole? role})
    : _role = role,
      super(
        BookingListLoading(
          sort: BookingSort.compatibilityHighToLow,
          role: role,
        ),
      ) {
    on<BookingListLoadRequested>(_onLoad);
    on<BookingListSortChanged>(_onSortChanged);
  }

  Future<void> _onLoad(
    BookingListLoadRequested event,
    Emitter<BookingListState> emit,
  ) async {
    emit(BookingListLoading(sort: state.sort, role: _role));

    try {
      final role = _role ?? DependencyInjection.authRepository.currentRole;
      List<Booking> bookings;

      // Booking list for agent/agency
      if (role == UserRole.agent || role == UserRole.agency) {
        bookings = await DependencyInjection.bookingApiService.getBookings(
          role: role == UserRole.agency ? 'agency' : 'agent',
        );
      } else {
        // Default to agent
        bookings = await DependencyInjection.bookingApiService.getBookings(
          role: 'agent',
        );
      }

      final roleString = (role == UserRole.agency ? 'agency' : 'agent');
      final propertyById = await _loadPropertiesFor(bookings, roleString);

      emit(
        BookingListLoaded(
          sort: state.sort,
          role: role,
          bookings: _applySort(bookings, propertyById, state.sort),
          propertyById: propertyById,
        ),
      );
    } catch (e) {
      emit(
        BookingListError(sort: state.sort, role: _role, message: e.toString()),
      );
    }
  }

  void _onSortChanged(
    BookingListSortChanged event,
    Emitter<BookingListState> emit,
  ) {
    final current = state;
    if (current is BookingListLoaded) {
      emit(
        BookingListLoaded(
          sort: event.sort,
          role: current.role,
          bookings: _applySort(
            current.bookings,
            current.propertyById,
            event.sort,
          ),
          propertyById: current.propertyById,
        ),
      );
      return;
    }

    // Not loaded yet; just update sort so it applies after load.
    if (current is BookingListLoading) {
      emit(BookingListLoading(sort: event.sort, role: current.role));
    } else if (current is BookingListError) {
      emit(
        BookingListError(
          sort: event.sort,
          role: current.role,
          message: current.message,
        ),
      );
    }
  }

  Future<Map<int, PropertyModel>> _loadPropertiesFor(
    List<Booking> bookings,
    String role,
  ) async {
    final uniqueIds = bookings.map((b) => b.propertyId).toSet();
    final futures = uniqueIds.map((id) async {
      try {
        return await DependencyInjection.propertyApiService.getPropertyStatus(
          role: role,
          propertyId: id,
        );
      } catch (_) {
        return null;
      }
    }).toList();

    final props = await Future.wait(futures);
    final map = <int, PropertyModel>{};
    for (final p in props) {
      if (p?.id != null) map[p!.id!] = p;
    }
    return map;
  }

  List<Booking> _applySort(
    List<Booking> bookings,
    Map<int, PropertyModel> propertyById,
    BookingSort sort,
  ) {
    final items = [...bookings];
    switch (sort) {
      case BookingSort.compatibilityHighToLow:
        items.sort((a, b) {
          final ca = propertyById[a.propertyId]?.compatibility ?? 0.0;
          final cb = propertyById[b.propertyId]?.compatibility ?? 0.0;
          return cb.compareTo(ca);
        });
        break;
      case BookingSort.newest:
        items.sort((a, b) {
          final aa = a.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
          final bb = b.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
          return bb.compareTo(aa);
        });
        break;
      case BookingSort.soonest:
        items.sort((a, b) {
          final aa = _parseBookingDateTime(a);
          final bb = _parseBookingDateTime(b);
          return aa.compareTo(bb);
        });
        break;
    }
    return items;
  }

  DateTime _parseBookingDateTime(Booking b) {
    try {
      final d = DateTime.tryParse(b.ymd) ?? DateTime.now();
      final parts = b.time.split(':');
      final h = parts.isNotEmpty ? int.tryParse(parts[0]) ?? 0 : 0;
      final m = parts.length > 1 ? int.tryParse(parts[1]) ?? 0 : 0;
      return DateTime(d.year, d.month, d.day, h, m);
    } catch (_) {
      return DateTime.now();
    }
  }
}
