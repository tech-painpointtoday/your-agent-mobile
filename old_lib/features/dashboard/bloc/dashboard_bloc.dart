import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:youragent/core/di/dependency_injection.dart';
import 'package:youragent/data/models/user_profile_model.dart';
import 'package:youragent/data/models/property_model.dart';
import 'package:youragent/domain/entities/booking.dart';
import 'package:youragent/domain/entities/user.dart';
import 'package:youragent/services/role_service.dart';
import 'dashboard_event.dart';
import 'dashboard_state.dart';

class DashboardBloc extends Bloc<DashboardEvent, DashboardState> {
  DashboardBloc() : super(DashboardInitial()) {
    on<DashboardLoadRequested>(_onLoad);
  }

  Future<void> _onLoad(
    DashboardLoadRequested event,
    Emitter<DashboardState> emit,
  ) async {
    emit(DashboardLoading());

    try {
      // Get current role for booking API call
      final roleService = RoleService();
      final role = roleService.currentRole;
      final roleString = role == UserRole.agent ? 'agent' : 'agency';

      // Load all dashboard data in parallel
      final results = await Future.wait([
        DependencyInjection.agentApiService.getProfile(),
        DependencyInjection.propertyApiService.getProperties(role: roleString),
        DependencyInjection.bookingApiService.getBookings(role: roleString),
        DependencyInjection.chatApiService.getUnreadBookings(role: roleString),
      ]);

      final profile = results[0] as UserProfileModel;
      final properties = results[1] as List;

      // Handle bookings - convert to List<BookingWithContact> if needed
      // API response includes nested buyer and property objects
      final bookingsRaw = results[2];
      final List<BookingWithContact> bookings;
      final Map<int, dynamic> propertyByIdFromBookings = {};

      if (bookingsRaw is List) {
        bookings = bookingsRaw
            .map((item) {
              if (item is Map<String, dynamic>) {
                // Extract buyer name from nested buyer object
                final buyer = item['buyer'] as Map<String, dynamic>?;
                final contactName = buyer?['name'] as String?;

                // Extract property from nested property object and store it
                final propertyData = item['property'] as Map<String, dynamic>?;
                if (propertyData != null) {
                  try {
                    final propertyModel = PropertyModel.fromJson(propertyData);
                    if (propertyModel.id != null) {
                      propertyByIdFromBookings[propertyModel.id!] =
                          propertyModel;
                    }
                  } catch (e) {
                    // Silently fail - property parsing is optional
                  }
                }

                // Parse booking (without nested objects)
                final booking = Booking.fromJson(item);

                return BookingWithContact(
                  booking: booking,
                  contactName: contactName,
                );
              }
              return null;
            })
            .whereType<BookingWithContact>()
            .toList();
      } else {
        bookings = [];
      }

      // Handle unreadBookings - it returns List<Map<String, dynamic>>, not List<Booking>
      final unreadBookingsRaw = results[3];
      final List<Map<String, dynamic>> unreadBookings;
      if (unreadBookingsRaw is List<Map<String, dynamic>>) {
        unreadBookings = unreadBookingsRaw;
      } else if (unreadBookingsRaw is List) {
        unreadBookings = unreadBookingsRaw
            .whereType<Map<String, dynamic>>()
            .toList();
      } else {
        unreadBookings = [];
      }

      // Count upcoming bookings (parsing ymd and time to create DateTime)
      final now = DateTime.now();
      final upcomingBookings = bookings.where((bookingWithContact) {
        final booking = bookingWithContact.booking;
        if (booking.ymd.isEmpty) return false;
        try {
          // Parse ymd (YYYY-MM-DD) and combine with time if available
          final dateParts = booking.ymd.split('-');
          if (dateParts.length != 3) return false;
          final year = int.parse(dateParts[0]);
          final month = int.parse(dateParts[1]);
          final day = int.parse(dateParts[2]);

          // Try to parse time if available
          int hour = 0, minute = 0;
          if (booking.time.isNotEmpty) {
            final timeParts = booking.time.split(':');
            if (timeParts.length >= 2) {
              hour = int.tryParse(timeParts[0]) ?? 0;
              minute = int.tryParse(timeParts[1]) ?? 0;
            }
          }

          final bookingDate = DateTime(year, month, day, hour, minute);
          return bookingDate.isAfter(now);
        } catch (e) {
          return false;
        }
      }).length;

      // Merge properties from booking responses with separately loaded properties
      // Load properties for bookings that weren't in the response (extract Booking list)
      final bookingList = bookings.map((b) => b.booking).toList();
      final propertyByIdFromApi = await _loadPropertiesFor(
        bookingList,
        roleString,
      );

      // Merge both maps (properties from booking responses take precedence)
      final propertyById = {
        ...propertyByIdFromApi,
        ...propertyByIdFromBookings,
      };

      emit(
        DashboardLoaded(
          userName: profile.name,
          propertyCount: properties.length,
          upcomingBookingCount: upcomingBookings,
          unreadChatCount: unreadBookings.length,
          bookings: bookings,
          propertyById: propertyById,
        ),
      );
    } catch (e) {
      emit(DashboardError(e.toString()));
    }
  }

  Future<Map<int, dynamic>> _loadPropertiesFor(
    List<Booking> bookings,
    String role,
  ) async {
    final Map<int, dynamic> propertyById = {};

    // Get unique property IDs
    final propertyIds = bookings
        .map((b) => b.propertyId)
        .where((id) => id > 0)
        .toSet()
        .toList();

    if (propertyIds.isEmpty) return propertyById;

    try {
      // Load properties in parallel
      final propertyFutures = propertyIds.map((id) async {
        try {
          final property = await DependencyInjection.propertyApiService
              .getPropertyStatus(role: role, propertyId: id);
          return MapEntry(id, property);
        } catch (e) {
          return null;
        }
      });

      final results = await Future.wait(propertyFutures);
      for (final result in results) {
        if (result != null) {
          propertyById[result.key] = result.value;
        }
      }
    } catch (e) {
      // Silently fail - properties are optional
    }

    return propertyById;
  }
}
