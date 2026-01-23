import 'package:dio/dio.dart';
import 'api_client.dart';
import 'api_response_service.dart';
import 'package:youragent/data/models/user_profile_model.dart';

/// Agent API Service - handles agent-specific profile and account endpoints
class AgentApiService {
  static AgentApiService? _instance;
  final ApiClient _apiClient;

  AgentApiService._(this._apiClient);

  factory AgentApiService(ApiClient apiClient) {
    _instance ??= AgentApiService._(apiClient);
    return _instance!;
  }

  // ==================== Profile ====================

  /// Get Profile
  /// GET /agent/profile
  Future<UserProfileModel> getProfile() async {
    try {
      final response = await _apiClient.get('/agent/profile');
      final data = response.data;

      if (data is Map<String, dynamic>) {
        final dataMap = data['data'] is Map<String, dynamic> ? data['data'] as Map<String, dynamic> : data;

        final rawProfile = (dataMap['agent'] is Map<String, dynamic>)
            ? dataMap['agent'] as Map<String, dynamic>
            : (dataMap['user'] is Map<String, dynamic>)
            ? dataMap['user'] as Map<String, dynamic>
            : dataMap;

        return UserProfileModel.fromJson(rawProfile);
      }

      final profileData = ApiResponseService.extractData<UserProfileModel>(
        response,
        (json) => UserProfileModel.fromJson(json as Map<String, dynamic>),
      );

      if (profileData != null) {
        return profileData;
      }

      throw Exception('Failed to parse profile data');
    } catch (e) {
      if (e is DioException && e.response != null) {
        final errorMessage = ApiResponseService.getErrorMessage(e);
        throw Exception(errorMessage);
      }
      throw Exception('Failed to get agent profile: $e');
    }
  }

  /// Update Profile
  /// PUT /agent/profile
  Future<Map<String, dynamic>> updateProfile({required Map<String, dynamic> data}) async {
    try {
      final response = await _apiClient.put('/agent/profile', data: data);
      return response.data as Map<String, dynamic>;
    } catch (e) {
      if (e is DioException && e.response != null) {
        throw Exception(e.response?.data['message'] ?? 'Failed to update profile');
      }
      throw Exception('Failed to update agent profile: $e');
    }
  }

  /// Resend Email Verification
  /// POST /agent/resend-verification
  Future<void> resendVerification() async {
    try {
      await _apiClient.post('/agent/resend-verification');
    } catch (e) {
      if (e is DioException && e.response != null) {
        throw Exception(e.response?.data['message'] ?? 'Failed to resend verification');
      }
      throw Exception('Failed to resend verification: $e');
    }
  }

  /// Delete Account
  /// DELETE /agent/account
  Future<void> deleteAccount() async {
    try {
      await _apiClient.delete('/agent/account');
    } catch (e) {
      if (e is DioException && e.response != null) {
        throw Exception(e.response?.data['message'] ?? 'Failed to delete account');
      }
      throw Exception('Failed to delete account: $e');
    }
  }
}
