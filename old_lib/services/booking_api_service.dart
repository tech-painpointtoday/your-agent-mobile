import 'api_client.dart';
import 'package:youragent/domain/entities/booking.dart';

/// Booking API Service - handles all booking-related API endpoints
class BookingApiService {
  static BookingApiService? _instance;
  final ApiClient _apiClient;

  BookingApiService._(this._apiClient);

  factory BookingApiService(ApiClient apiClient) {
    _instance ??= BookingApiService._(apiClient);
    return _instance!;
  }

  /// Get bookings for agent/seller
  /// GET /api/agent/bookings or /api/seller/bookings
  Future<List<Booking>> getBookings({
    required String role, // 'agent' or 'seller'
  }) async {
    try {
      final response = await _apiClient.get('/$role/bookings');
      final responseData = response.data as Map<String, dynamic>;

      final dynamic list = responseData['data'] ?? responseData['bookings'];
      if (list is List) {
        return list.whereType<Map<String, dynamic>>().map((json) => Booking.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      throw Exception('Failed to get bookings: $e');
    }
  }

  /// Confirm a booking
  /// POST /api/agent/confirm/booking or /api/seller/confirm/booking
  Future<Booking> confirmBooking({required String role, required int bookingId}) async {
    try {
      final response = await _apiClient.post('/$role/confirm/booking', data: {'booking_id': bookingId});
      final data = response.data as Map<String, dynamic>;
      return Booking.fromJson(data['booking'] ?? data);
    } catch (e) {
      throw Exception('Failed to confirm booking: $e');
    }
  }

  /// Create a new booking
  /// POST /api/agent/bookings/create
  Future<Booking> createBooking({required int propertyId, required String date, required String time}) async {
    try {
      final response = await _apiClient.post(
        '/agent/bookings/create',
        data: {'property_id': propertyId, 'date': date, 'time': time},
      );
      final responseData = response.data as Map<String, dynamic>;
      if (responseData['booking'] != null) {
        return Booking.fromJson(responseData['booking']);
      } else if (responseData['data'] != null) {
        return Booking.fromJson(responseData['data']);
      }
      throw Exception('Invalid response format');
    } catch (e) {
      throw Exception('Failed to create booking: $e');
    }
  }
}
