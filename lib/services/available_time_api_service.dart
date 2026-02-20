import 'package:youragent/domain/entities/available_time.dart';
import 'package:youragent/services/api_client.dart';

class AvailableTimeApiService {
  final ApiClient _apiClient;

  AvailableTimeApiService({required ApiClient apiClient})
    : _apiClient = apiClient;

  Future<PaginatedAvailableTimes> getAvailableTimes({
    required String startDate,
    required String endDate,
    bool? isAvailable,
    int page = 1,
    int perPage = 15,
  }) async {
    final queryParams = <String, dynamic>{
      'start_date': startDate,
      'end_date': endDate,
      'page': page,
      'per_page': perPage,
    };
    if (isAvailable != null) {
      queryParams['is_available'] = isAvailable;
    }

    final response = await _apiClient.dio.get(
      '/agent/available-times',
      queryParameters: queryParams,
    );
    final data = response.data['data'] as Map<String, dynamic>;
    return PaginatedAvailableTimes.fromJson(data);
  }

  Future<AvailableTime> createAvailableTime({
    required String date,
    required String startTime,
    required String endTime,
  }) async {
    final response = await _apiClient.dio.post(
      '/agent/available-times',
      data: {'date': date, 'start_time': startTime, 'end_time': endTime},
    );
    return AvailableTime.fromJson(
      response.data['data'] as Map<String, dynamic>,
    );
  }

  Future<AvailableTime> updateAvailableTime({
    required int id,
    required String startTime,
    required String endTime,
    required bool isAvailable,
  }) async {
    final response = await _apiClient.dio.put(
      '/agent/available-times/$id',
      data: {
        'start_time': startTime,
        'end_time': endTime,
        'is_available': isAvailable,
      },
    );
    return AvailableTime.fromJson(
      response.data['data'] as Map<String, dynamic>,
    );
  }

  Future<void> deleteAvailableTime(int id) async {
    await _apiClient.dio.delete('/agent/available-times/$id');
  }
}
