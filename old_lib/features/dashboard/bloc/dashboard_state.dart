import 'package:youragent/domain/entities/booking.dart';

sealed class DashboardState {
  const DashboardState();
}

class DashboardInitial extends DashboardState {
  const DashboardInitial();
}

class DashboardLoading extends DashboardState {
  const DashboardLoading();
}

/// Booking with contact information from API
class BookingWithContact {
  final Booking booking;
  final String? contactName;

  const BookingWithContact({required this.booking, this.contactName});
}

class DashboardLoaded extends DashboardState {
  final String userName;
  final int propertyCount;
  final int upcomingBookingCount;
  final int unreadChatCount;
  final List<BookingWithContact> bookings;
  final Map<int, dynamic> propertyById; // PropertyModel or Property

  const DashboardLoaded({
    required this.userName,
    required this.propertyCount,
    required this.upcomingBookingCount,
    required this.unreadChatCount,
    required this.bookings,
    required this.propertyById,
  });
}

class DashboardError extends DashboardState {
  final String message;

  const DashboardError(this.message);
}
