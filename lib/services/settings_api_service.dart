import 'package:dio/dio.dart';
import 'package:youragent/core/di/dependency_injection.dart';
import 'package:youragent/services/api_client.dart';

class SettingsApiService {
  final ApiClient _apiClient;

  SettingsApiService(this._apiClient);

  /// Fetch the LINE Authorization URL
  Future<String> getLineAuthorizationUrl() async {
    try {
      final response = await _apiClient.get(
        '/agent/settings/line/authorization-url',
      );
      final data = response.data as Map<String, dynamic>;

      // Assuming the API returns { "success": true, "data": { "url": "..." } }
      // or similar based on standard project patterns
      if (data['data'] != null && data['data']['authorization_url'] != null) {
        return data['data']['authorization_url'] as String;
      } else if (data['authorization_url'] != null) {
        return data['authorization_url'] as String;
      }

      throw Exception('URL not found in response');
    } catch (e) {
      if (e is DioException && e.response != null) {
        final message = (e.response?.data is Map<String, dynamic>)
            ? (e.response?.data['message']?.toString())
            : null;
        throw Exception(message ?? 'Failed to fetch LINE authorization URL');
      }
      throw Exception('Failed to fetch LINE authorization URL: $e');
    }
  }

  /// Check the status of LINE subscription
  Future<bool> getLineStatus() async {
    try {
      final response = await _apiClient.get('/agent/settings/line/status');
      final data = response.data as Map<String, dynamic>;

      if (data['data'] != null && data['data']['is_subscribed'] != null) {
        return data['data']['is_subscribed'] as bool;
      }
      return false;
    } catch (e) {
      DependencyInjection.talker?.error('Failed to get line status: $e');
      return false;
    }
  }

  /// Unsubscribe from LINE
  Future<bool> unsubscribeLine() async {
    try {
      final response = await _apiClient.get('/agent/settings/line/unsubscribe');
      final data = response.data as Map<String, dynamic>;
      return data['success'] == true;
    } catch (e) {
      if (e is DioException && e.response != null) {
        final message = (e.response?.data is Map<String, dynamic>)
            ? (e.response?.data['message']?.toString())
            : null;
        throw Exception(message ?? 'Failed to unsubscribe from LINE');
      }
      throw Exception('Failed to unsubscribe from LINE: $e');
    }
  }
}
