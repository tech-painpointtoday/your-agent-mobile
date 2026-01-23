import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'api_client.dart';

/// Authentication API Service - handles all authentication endpoints
class AuthApiService {
  final ApiClient _apiClient;

  AuthApiService(this._apiClient);

  /// Agent Register
  /// POST /agent/register
  Future<Map<String, dynamic>> agentRegister({
    required String name,
    required String email,
    required String password,
    required String passwordConfirmation,
  }) async {
    try {
      final response = await _apiClient.post(
        '/agent/register',
        data: {
          'name': name,
          'email': email,
          'password': password,
          'password_confirmation': passwordConfirmation,
        },
      );
      final data = response.data as Map<String, dynamic>;

      // Save token if present - check multiple possible fields
      String? token;
      if (data['token'] != null) {
        token = data['token'] as String;
      } else if (data['access_token'] != null) {
        token = data['access_token'] as String;
      } else if (data['data'] != null && data['data'] is Map) {
        final dataMap = data['data'] as Map<String, dynamic>;
        token = dataMap['token'] as String? ?? dataMap['access_token'] as String?;
      }

      if (token != null && token.isNotEmpty) {
        await _apiClient.saveAuthToken(token);
        debugPrint('✅ Auth token saved successfully from registration');
      } else {
        debugPrint('⚠️ No token found in registration response');
      }

      return data;
    } catch (e) {
      if (e is DioException && e.response != null) {
        throw Exception(e.response?.data['message'] ?? 'Registration failed');
      }
      throw Exception('Failed to register agent: $e');
    }
  }

  /// Agent Login
  /// POST /agent/login
  Future<Map<String, dynamic>> agentLogin({required String email, required String password}) async {
    try {
      final response = await _apiClient.post('/agent/login', data: {'email': email, 'password': password});
      final data = response.data as Map<String, dynamic>;

      // Save token if present - check multiple possible fields
      String? token;
      if (data['token'] != null) {
        token = data['token'] as String;
      } else if (data['access_token'] != null) {
        token = data['access_token'] as String;
      } else if (data['data'] != null && data['data'] is Map) {
        final dataMap = data['data'] as Map<String, dynamic>;
        token = dataMap['token'] as String? ?? dataMap['access_token'] as String?;
      }

      if (token != null && token.isNotEmpty) {
        await _apiClient.saveAuthToken(token);
        debugPrint('✅ Auth token saved successfully');
      } else {
        debugPrint('⚠️ No token found in login response');
      }

      return data;
    } catch (e) {
      // Check for EMAIL_NOT_VERIFIED error and re-throw DioException to preserve error structure
      if (e is DioException && e.response != null) {
        final responseData = e.response?.data;
        if (responseData is Map<String, dynamic>) {
          // Check for EMAIL_NOT_VERIFIED error structure
          if (responseData['success'] == false && responseData['error'] != null) {
            final error = responseData['error'] as Map<String, dynamic>;
            final errorCode = error['code'] as String?;
            
            if (errorCode == 'EMAIL_NOT_VERIFIED') {
              // Re-throw DioException so repository can handle it properly
              // This preserves the error structure in e.response.data
              rethrow;
            }
          }
        }
        // For other errors, throw with message
        throw Exception(e.response?.data['message'] ?? 'Login failed');
      }
      throw Exception('Failed to login agent: $e');
    }
  }

  /// Get Current User
  /// GET /user
  /// Returns the user profile data from the API response
  Future<Map<String, dynamic>> getCurrentUser() async {
    try {
      final response = await _apiClient.get('/user');
      final data = response.data as Map<String, dynamic>;
      
      // Extract user data from response
      // Response format: { "success": true, "data": { ...user fields... } }
      if (data['data'] != null && data['data'] is Map<String, dynamic>) {
        return data['data'] as Map<String, dynamic>;
      }
      
      // Fallback: return the entire response if data structure is different
      return data;
    } catch (e) {
      if (e is DioException && e.response != null) {
        throw Exception(e.response?.data['message'] ?? 'Failed to get user');
      }
      throw Exception('Failed to get current user: $e');
    }
  }

  /// Logout
  /// POST /logout
  Future<void> logout() async {
    try {
      await _apiClient.post('/logout');
      await _apiClient.clearAuthToken();
    } catch (e) {
      // Clear token even if logout request fails
      await _apiClient.clearAuthToken();
      if (e is DioException && e.response != null) {
        throw Exception(e.response?.data['message'] ?? 'Logout failed');
      }
      throw Exception('Failed to logout: $e');
    }
  }

  /// Forgot Password
  /// POST /api/agent/forgot-password
  Future<Map<String, dynamic>> forgotPassword({required String email}) async {
    try {
      final response = await _apiClient.post(
        '/api/agent/forgot-password',
        data: {'email': email},
      );
      return response.data as Map<String, dynamic>;
    } catch (e) {
      if (e is DioException && e.response != null) {
        throw Exception(e.response?.data['message'] ?? 'Failed to send reset password email');
      }
      throw Exception('Failed to send reset password email: $e');
    }
  }

  /// Reset Password
  /// POST /api/agent/reset-password
  Future<Map<String, dynamic>> resetPassword({
    required String token,
    required String email,
    required String password,
    required String passwordConfirmation,
  }) async {
    try {
      final response = await _apiClient.post(
        '/api/agent/reset-password',
        data: {
          'token': token,
          'email': email,
          'password': password,
          'password_confirmation': passwordConfirmation,
        },
      );
      return response.data as Map<String, dynamic>;
    } catch (e) {
      if (e is DioException && e.response != null) {
        throw Exception(e.response?.data['message'] ?? 'Failed to reset password');
      }
      throw Exception('Failed to reset password: $e');
    }
  }

  /// Resend Verification Email (Public - no auth required)
  /// POST /api/agent/resend-verification-email
  Future<Map<String, dynamic>> resendVerificationPublic({required String email}) async {
    try {
      final response = await _apiClient.post(
        '/api/agent/resend-verification-email',
        data: {'email': email},
      );
      return response.data as Map<String, dynamic>;
    } catch (e) {
      if (e is DioException && e.response != null) {
        throw Exception(e.response?.data['message'] ?? 'Failed to resend verification email');
      }
      throw Exception('Failed to resend verification email: $e');
    }
  }

  /// Resend Verification Email Public (Public - no auth required)
  /// POST /api/agent/resend-verification-email
  /// This method matches the requested signature: Future<void> resendVerificationEmailPublic(String email)
  Future<void> resendVerificationEmailPublic(String email) async {
    try {
      await _apiClient.post(
        '/api/agent/resend-verification-email',
        data: {'email': email},
      );
    } catch (e) {
      if (e is DioException && e.response != null) {
        throw Exception(e.response?.data['message'] ?? 'Failed to resend verification email');
      }
      throw Exception('Failed to resend verification email: $e');
    }
  }

  /// Resend Verification Email (Authenticated - requires Bearer token)
  /// POST /api/agent/email/verification-notification
  Future<Map<String, dynamic>> resendVerificationAuthenticated() async {
    try {
      final response = await _apiClient.post('/api/agent/email/verification-notification');
      return response.data as Map<String, dynamic>;
    } catch (e) {
      if (e is DioException && e.response != null) {
        throw Exception(e.response?.data['message'] ?? 'Failed to resend verification email');
      }
      throw Exception('Failed to resend verification email: $e');
    }
  }
}
