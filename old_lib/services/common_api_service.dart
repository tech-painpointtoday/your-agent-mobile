import 'package:dio/dio.dart';
import 'api_client.dart';

/// Common API Service - handles authenticated common endpoints
class CommonApiService {
  final ApiClient _apiClient;

  CommonApiService(this._apiClient);

  // ==================== Pusher ====================

  /// Authenticate Pusher
  /// POST /pusher/auth
  Future<Map<String, dynamic>> authenticatePusher({
    required String socketId,
    required String channelName,
  }) async {
    try {
      final response = await _apiClient.post(
        '/pusher/auth',
        data: {
          'socket_id': socketId,
          'channel_name': channelName,
        },
      );
      return response.data as Map<String, dynamic>;
    } catch (e) {
      if (e is DioException && e.response != null) {
        throw Exception(e.response?.data['message'] ?? 'Failed to authenticate pusher');
      }
      throw Exception('Failed to authenticate pusher: $e');
    }
  }

  // ==================== Tracking ====================

  /// Track Property Click
  /// POST /tracking/properties/{id}/click
  Future<void> trackPropertyClick(int propertyId) async {
    try {
      await _apiClient.post('/tracking/properties/$propertyId/click');
    } catch (e) {
      // Silently fail tracking - don't throw errors
      if (e is DioException) {
        // Log but don't throw
        return;
      }
    }
  }

  /// Track Property View
  /// POST /tracking/properties/{id}/view
  Future<void> trackPropertyView(int propertyId) async {
    try {
      await _apiClient.post('/tracking/properties/$propertyId/view');
    } catch (e) {
      // Silently fail tracking - don't throw errors
      if (e is DioException) {
        // Log but don't throw
        return;
      }
    }
  }

  // ==================== Activity Logs ====================

  /// List Activity Logs
  /// GET /activity-logs
  Future<List<Map<String, dynamic>>> listActivityLogs({
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      final response = await _apiClient.get(
        '/activity-logs',
        queryParameters: queryParameters,
      );
      final responseData = response.data;
      if (responseData is Map<String, dynamic>) {
        if (responseData['logs'] != null) {
          return List<Map<String, dynamic>>.from(responseData['logs'] as List);
        }
      }
      if (responseData is List) {
        return List<Map<String, dynamic>>.from(
          responseData.map((item) => item as Map<String, dynamic>),
        );
      }
      return [];
    } catch (e) {
      if (e is DioException && e.response != null) {
        throw Exception(e.response?.data['message'] ?? 'Failed to get activity logs');
      }
      throw Exception('Failed to list activity logs: $e');
    }
  }

  /// Get Activity Log
  /// GET /activity-logs/{id}
  Future<Map<String, dynamic>> getActivityLog(int logId) async {
    try {
      final response = await _apiClient.get('/activity-logs/$logId');
      return response.data as Map<String, dynamic>;
    } catch (e) {
      if (e is DioException && e.response != null) {
        throw Exception(e.response?.data['message'] ?? 'Failed to get activity log');
      }
      throw Exception('Failed to get activity log: $e');
    }
  }

  /// Get Model History
  /// GET /activity-logs/model/{model}/{id}
  Future<List<Map<String, dynamic>>> getModelHistory({
    required String model, // e.g., "App\\Models\\Property"
    required int id,
  }) async {
    try {
      // URL encode the model path
      final encodedModel = Uri.encodeComponent(model);
      final response = await _apiClient.get(
        '/activity-logs/model/$encodedModel/$id',
      );
      final responseData = response.data;
      if (responseData is Map<String, dynamic>) {
        if (responseData['history'] != null) {
          return List<Map<String, dynamic>>.from(responseData['history'] as List);
        }
      }
      if (responseData is List) {
        return List<Map<String, dynamic>>.from(
          responseData.map((item) => item as Map<String, dynamic>),
        );
      }
      return [];
    } catch (e) {
      if (e is DioException && e.response != null) {
        throw Exception(e.response?.data['message'] ?? 'Failed to get model history');
      }
      throw Exception('Failed to get model history: $e');
    }
  }

  /// Get User History
  /// GET /activity-logs/user/{id}
  Future<List<Map<String, dynamic>>> getUserHistory(int userId) async {
    try {
      final response = await _apiClient.get('/activity-logs/user/$userId');
      final responseData = response.data;
      if (responseData is Map<String, dynamic>) {
        if (responseData['history'] != null) {
          return List<Map<String, dynamic>>.from(responseData['history'] as List);
        }
      }
      if (responseData is List) {
        return List<Map<String, dynamic>>.from(
          responseData.map((item) => item as Map<String, dynamic>),
        );
      }
      return [];
    } catch (e) {
      if (e is DioException && e.response != null) {
        throw Exception(e.response?.data['message'] ?? 'Failed to get user history');
      }
      throw Exception('Failed to get user history: $e');
    }
  }
}

