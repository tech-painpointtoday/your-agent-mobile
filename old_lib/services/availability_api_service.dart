import 'package:dio/dio.dart';
import 'api_client.dart';
import 'package:youragent/core/errors/validation_exception.dart';

/// Availability API Service - handles all availability/available-times API endpoints
class AvailabilityApiService {
  static AvailabilityApiService? _instance;
  final ApiClient _apiClient;

  AvailabilityApiService._(this._apiClient);

  factory AvailabilityApiService(ApiClient apiClient) {
    _instance ??= AvailabilityApiService._(apiClient);
    return _instance!;
  }

  /// List Available Times
  /// GET /agent/available-times
  Future<List<Map<String, dynamic>>> listAvailableTimes() async {
    try {
      final response = await _apiClient.get('/agent/available-times');
      final data = response.data as Map<String, dynamic>;

      final responseData = data['data'] is Map<String, dynamic> ? data['data'] as Map<String, dynamic> : data;

      if (responseData['available_times'] != null) {
        return List<Map<String, dynamic>>.from(responseData['available_times']);
      }
      return [];
    } catch (e) {
      if (e is DioException && e.response != null) {
        throw Exception(e.response?.data['message'] ?? 'Failed to get available times');
      }
      throw Exception('Failed to list available times: $e');
    }
  }

  /// Create Available Time
  /// POST /agent/available-times
  Future<Map<String, dynamic>> createAvailableTime({
    required String date, // Format: "YYYY-MM-DD"
    required String startTime, // Format: "09:00"
    required String endTime, // Format: "17:00"
  }) async {
    try {
      final response = await _apiClient.post(
        '/agent/available-times',
        data: {'date': date, 'start_time': startTime, 'end_time': endTime},
      );
      return response.data as Map<String, dynamic>;
    } catch (e) {
      if (e is DioException && e.response != null) {
        final data = e.response?.data;
        if (data is Map<String, dynamic> && data['error'] is Map<String, dynamic>) {
          final errorData = data['error'] as Map<String, dynamic>;
          if (errorData['details'] != null) {
            throw ValidationException(
              errorData['message'] ?? 'Validation failed',
              errorData['details'] as Map<String, dynamic>,
            );
          }
          throw Exception(errorData['message'] ?? 'Failed to create available time');
        }
        throw Exception(e.response?.data['message'] ?? 'Failed to create available time');
      }
      throw Exception('Failed to create available time: $e');
    }
  }

  /// Update Available Time
  /// PUT /agent/available-times/{id}
  Future<Map<String, dynamic>> updateAvailableTime({
    required int availabilityId,
    String? date,
    String? startTime,
    String? endTime,
    bool? isAvailable,
  }) async {
    try {
      final data = <String, dynamic>{};
      if (date != null) data['date'] = date;
      if (startTime != null) data['start_time'] = startTime;
      if (endTime != null) data['end_time'] = endTime;
      if (isAvailable != null) data['is_available'] = isAvailable;

      final response = await _apiClient.put('/agent/available-times/$availabilityId', data: data);
      return response.data as Map<String, dynamic>;
    } catch (e) {
      if (e is DioException && e.response != null) {
        final data = e.response?.data;
        if (data is Map<String, dynamic> && data['error'] is Map<String, dynamic>) {
          final errorData = data['error'] as Map<String, dynamic>;
          if (errorData['details'] != null) {
            throw ValidationException(
              errorData['message'] ?? 'Validation failed',
              errorData['details'] as Map<String, dynamic>,
            );
          }
          throw Exception(errorData['message'] ?? 'Failed to update available time');
        }
        throw Exception(e.response?.data['message'] ?? 'Failed to update available time');
      }
      throw Exception('Failed to update available time: $e');
    }
  }

  /// Delete Available Time
  /// DELETE /agent/available-times/{id}
  Future<void> deleteAvailableTime(int availabilityId) async {
    try {
      await _apiClient.delete('/agent/available-times/$availabilityId');
    } catch (e) {
      if (e is DioException && e.response != null) {
        throw Exception(e.response?.data['message'] ?? 'Failed to delete available time');
      }
      throw Exception('Failed to delete available time: $e');
    }
  }

  /// Get Calendar View
  /// GET /agent/available-times/calendar
  Future<Map<String, dynamic>> getCalendarView({
    String? month, // Format: "2024-12"
  }) async {
    try {
      final queryParams = <String, dynamic>{};
      if (month != null) queryParams['month'] = month;

      final response = await _apiClient.get(
        '/agent/available-times/calendar',
        queryParameters: queryParams.isNotEmpty ? queryParams : null,
      );
      final data = response.data as Map<String, dynamic>;
      return data['data'] is Map<String, dynamic> ? data['data'] as Map<String, dynamic> : data;
    } catch (e) {
      if (e is DioException && e.response != null) {
        throw Exception(e.response?.data['message'] ?? 'Failed to get calendar');
      }
      throw Exception('Failed to get calendar view: $e');
    }
  }
}
