import 'api_client.dart';

/// Feng Shui API Service - handles all Feng Shui calculation endpoints
/// Matches the old Laravel FengShuiItemsController
class FengShuiApiService {
  final ApiClient _apiClient;

  FengShuiApiService(this._apiClient);

  /// Calculate Eight Mansions Feng Shui
  /// POST /api/fengshui/eight-mansions
  Future<Map<String, dynamic>> calculateEightMansions({
    required Map<String, dynamic> data,
  }) async {
    try {
      final response = await _apiClient.post(
        '/api/fengshui/eight-mansions',
        data: data,
      );
      return response.data as Map<String, dynamic>;
    } catch (e) {
      throw Exception('Failed to calculate Eight Mansions: $e');
    }
  }

  /// Calculate Flying Stars Feng Shui
  /// POST /api/fengshui/flying-stars
  Future<Map<String, dynamic>> calculateFlyingStars({
    required Map<String, dynamic> data,
  }) async {
    try {
      final response = await _apiClient.post(
        '/api/fengshui/flying-stars',
        data: data,
      );
      return response.data as Map<String, dynamic>;
    } catch (e) {
      throw Exception('Failed to calculate Flying Stars: $e');
    }
  }

  /// Calculate Form School Feng Shui
  /// POST /api/fengshui/form-school
  Future<Map<String, dynamic>> calculateFormSchool({
    required Map<String, dynamic> data,
  }) async {
    try {
      final response = await _apiClient.post(
        '/api/fengshui/form-school',
        data: data,
      );
      return response.data as Map<String, dynamic>;
    } catch (e) {
      throw Exception('Failed to calculate Form School: $e');
    }
  }
}


