import 'package:yourhome/domain/entities/booking.dart';
import 'package:yourhome/services/api_client.dart';

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
      '/seller/bookings',
      queryParameters: queryParams,
    );

    return PaginatedBookings.fromJson(response.data as Map<String, dynamic>);
  }

  Future<Booking> getBookingById(int id) async {
    final response = await _apiClient.dio.get('/seller/bookings/$id');
    final data = response.data['data'] as Map<String, dynamic>;
    return Booking.fromJson(data);
  }

  Future<void> updateBookingStatus(int id, int status) async {
    await _apiClient.dio.patch(
      '/seller/bookings/$id/status',
      data: {'status': status},
    );
  }

  Future<void> cancelBooking(int id) async {
    await _apiClient.dio.post('/seller/bookings/cancel', data: {'id': '$id'});
  }
}

