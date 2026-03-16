import 'package:dio/dio.dart';
import 'package:youragent/domain/entities/booking.dart';
import 'package:youragent/services/api_client.dart';

class TravelTimeResult {
  final bool? feasible;
  final int? travelTimeSeconds;
  final String? travelTimeFormatted;
  final int? timeUntilAppointmentSeconds;
  final String? timeUntilAppointmentFormatted;
  final int? requiredTimeSeconds;
  final String? message;

  const TravelTimeResult({
    this.feasible,
    this.travelTimeSeconds,
    this.travelTimeFormatted,
    this.timeUntilAppointmentSeconds,
    this.timeUntilAppointmentFormatted,
    this.requiredTimeSeconds,
    this.message,
  });

  factory TravelTimeResult.fromJson(Map<String, dynamic> json) {
    return TravelTimeResult(
      feasible: json['feasible'] as bool?,
      travelTimeSeconds: json['travel_time_seconds'] as int?,
      travelTimeFormatted: json['travel_time_formatted']?.toString(),
      timeUntilAppointmentSeconds:
          json['time_until_appointment_seconds'] as int?,
      timeUntilAppointmentFormatted:
          json['time_until_appointment_formatted']?.toString(),
      requiredTimeSeconds: json['required_time_seconds'] as int?,
      message: json['message']?.toString(),
    );
  }
}

class BookingApiService {
  final ApiClient _apiClient;

  BookingApiService({required ApiClient apiClient}) : _apiClient = apiClient;

  Future<PaginatedBookings> getBookings({
    int page = 1,
    int perPage = 15,
    String? from,
    String? to,
    String? search,
  }) async {
    final queryParams = <String, dynamic>{
      'page': page,
      'per_page': perPage,
      if (from != null) 'from': from,
      if (to != null) 'to': to,
      if (search != null && search.isNotEmpty) 'q': search,
    };

    final response = await _apiClient.dio.get(
      '/agent/bookings',
      queryParameters: queryParams,
    );

    return PaginatedBookings.fromJson(response.data as Map<String, dynamic>);
  }

  Future<Booking> getBookingById(int id) async {
    final response = await _apiClient.dio.get('/agent/bookings/$id');
    final data = response.data['data'] as Map<String, dynamic>;
    return Booking.fromJson(data);
  }

  Future<void> updateBookingStatus(int id, int status) async {
    await _apiClient.dio.patch(
      '/agent/bookings/$id/status',
      data: {'status': status},
    );
  }

  Future<void> cancelBooking(int id) async {
    await _apiClient.dio.post('/agent/bookings/cancel', data: {'id': '$id'});
  }

  /// Agent confirms the booking with current GPS location.
  ///
  /// This wraps `POST /api/bookings/{id}/confirm` and returns the updated
  /// booking entity as parsed from the response.
  Future<Booking> confirmBooking({
    required int id,
    required double currentLat,
    required double currentLng,
  }) async {
    final response = await _apiClient.dio.post(
      '/api/bookings/$id/confirm',
      data: {
        'current_lat': currentLat,
        'current_lng': currentLng,
      },
      options: Options(headers: {'Accept': 'application/json'}),
    );

    final data = response.data['data'] as Map<String, dynamic>? ??
        response.data as Map<String, dynamic>;
    return Booking.fromJson(data);
  }

  /// Updates individual attendance status for the current user (agent).
  ///
  /// Wraps `POST /api/bookings/{id}/attendance-status`.
  Future<Booking> updateAttendanceStatus({
    required int id,
    required String status,
  }) async {
    final response = await _apiClient.dio.post(
      '/api/bookings/$id/attendance-status',
      data: {'status': status},
      options: Options(headers: {'Accept': 'application/json'}),
    );

    final data = response.data['data'] as Map<String, dynamic>? ??
        response.data as Map<String, dynamic>;
    return Booking.fromJson(data);
  }

  /// Calculates travel time from the agent's current location to the property.
  ///
  /// Wraps `POST /api/bookings/{id}/calculate-travel-time`.
  Future<TravelTimeResult> calculateTravelTime({
    required int id,
    required double currentLat,
    required double currentLng,
  }) async {
    final response = await _apiClient.dio.post(
      '/api/bookings/$id/calculate-travel-time',
      data: {
        'current_lat': currentLat,
        'current_lng': currentLng,
      },
      options: Options(headers: {'Accept': 'application/json'}),
    );

    final data = response.data['data'] as Map<String, dynamic>? ??
        response.data as Map<String, dynamic>;
    return TravelTimeResult.fromJson(data);
  }

  /// Requests an agent substitution for the given booking.
  ///
  /// Wraps `POST /api/bookings/{id}/request-substitution`.
  Future<void> requestSubstitution({required int id}) async {
    await _apiClient.dio.post(
      '/api/bookings/$id/request-substitution',
      data: const {},
      options: Options(headers: {'Accept': 'application/json'}),
    );
  }
}
