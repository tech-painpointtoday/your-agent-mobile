import 'package:youragent/domain/entities/booking.dart';
import 'package:youragent/services/api_client.dart';

class BookingApiService {
  final ApiClient _apiClient;

  BookingApiService({required ApiClient apiClient}) : _apiClient = apiClient;

  Future<PaginatedBookings> getBookings({
    int page = 1,
    int perPage = 15,
  }) async {
    final queryParams = <String, dynamic>{'page': page, 'per_page': perPage};

    final response = await _apiClient.dio.get(
      '/agent/bookings',
      queryParameters: queryParams,
    );

    // The API sends {"success": true, "data": [...]}
    // So response.data is the full JSON object.
    return PaginatedBookings.fromJson(response.data as Map<String, dynamic>);
  }
}
