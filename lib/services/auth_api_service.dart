import 'package:dio/dio.dart';

import 'api_client.dart';

class AuthApiService {
  final ApiClient _apiClient;
  AuthApiService(this._apiClient);

  Future<Map<String, dynamic>> _login({
    required String path,
    required String email,
    required String password,
  }) async {
    try {
      final response = await _apiClient.post(
        path,
        data: {'email': email, 'password': password},
      );
      final data = response.data as Map<String, dynamic>;

      // Save token if present
      String? token;
      if (data['token'] != null) {
        token = data['token'] as String?;
      } else if (data['access_token'] != null) {
        token = data['access_token'] as String?;
      } else if (data['data'] is Map<String, dynamic>) {
        final dataMap = data['data'] as Map<String, dynamic>;
        token =
            dataMap['token'] as String? ?? dataMap['access_token'] as String?;
      }

      if (token != null && token.isNotEmpty) {
        await _apiClient.saveAuthToken(token);
      }

      return data;
    } catch (e) {
      // Preserve EMAIL_NOT_VERIFIED structured error by rethrowing DioException
      if (e is DioException && e.response != null) {
        final responseData = e.response?.data;
        if (responseData is Map<String, dynamic>) {
          if (responseData['success'] == false &&
              responseData['error'] != null) {
            final errorMap = responseData['error'] as Map<String, dynamic>;
            if (errorMap['code'] == 'EMAIL_NOT_VERIFIED') {
              rethrow;
            }
          }
        }
        final message = (e.response?.data is Map<String, dynamic>)
            ? (e.response?.data['message']?.toString())
            : null;
        throw Exception(message ?? 'Login failed');
      }
      throw Exception('Failed to login: $e');
    }
  }

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

      // Save token if present
      String? token;
      if (data['token'] != null) {
        token = data['token'] as String?;
      } else if (data['access_token'] != null) {
        token = data['access_token'] as String?;
      } else if (data['data'] is Map<String, dynamic>) {
        final dataMap = data['data'] as Map<String, dynamic>;
        token =
            dataMap['token'] as String? ?? dataMap['access_token'] as String?;
      }
      if (token != null && token.isNotEmpty) {
        await _apiClient.saveAuthToken(token);
      }

      return data;
    } catch (e) {
      if (e is DioException && e.response != null) {
        final message = (e.response?.data is Map<String, dynamic>)
            ? (e.response?.data['message']?.toString())
            : null;
        throw Exception(message ?? 'Registration failed');
      }
      throw Exception('Failed to register: $e');
    }
  }

  Future<Map<String, dynamic>> agentLogin({
    required String email,
    required String password,
  }) async {
    return _login(path: '/agent/login', email: email, password: password);
  }

  Future<Map<String, dynamic>> agencyLogin({
    required String email,
    required String password,
  }) async {
    return _login(path: '/agency/login', email: email, password: password);
  }

  Future<Map<String, dynamic>> socialLogin({
    required String provider,
    required String token,
    required String role,
  }) async {
    try {
      final response = await _apiClient.post(
        '/auth/social-login',
        data: {'provider': provider, 'token': token, 'role': role},
      );
      final data = response.data as Map<String, dynamic>;

      // Save token logic similar to _login
      String? authToken;
      if (data['token'] != null) {
        authToken = data['token'] as String?;
      } else if (data['access_token'] != null) {
        authToken = data['access_token'] as String?;
      } else if (data['data'] is Map<String, dynamic>) {
        final dataMap = data['data'] as Map<String, dynamic>;
        authToken =
            dataMap['token'] as String? ?? dataMap['access_token'] as String?;
      }

      if (authToken != null && authToken.isNotEmpty) {
        await _apiClient.saveAuthToken(authToken);
      }

      return data;
    } catch (e) {
      if (e is DioException && e.response != null) {
        final message = (e.response?.data is Map<String, dynamic>)
            ? (e.response?.data['message']?.toString())
            : null;
        throw Exception(message ?? 'Social login failed');
      }
      throw Exception('Failed to login with $provider: $e');
    }
  }

  Future<Map<String, dynamic>> getCurrentUser() async {
    final response = await _apiClient.get('/user');
    final data = response.data as Map<String, dynamic>;
    if (data['data'] is Map<String, dynamic>) {
      return data['data'] as Map<String, dynamic>;
    }
    return data;
  }

  Future<void> logout() async {
    try {
      await _apiClient.post('/logout');
    } finally {
      await _apiClient.clearAuthToken();
    }
  }

  /// Forgot Password
  /// NOTE: This path matches `old_lib/` exactly.
  Future<void> forgotPassword({required String email}) async {
    try {
      await _apiClient.post(
        '/api/agent/forgot-password',
        data: {'email': email},
      );
    } catch (e) {
      if (e is DioException && e.response != null) {
        throw Exception(
          e.response?.data['message'] ?? 'Failed to send reset password email',
        );
      }
      throw Exception('Failed to send reset password email: $e');
    }
  }

  /// Reset Password
  /// NOTE: This path matches `old_lib/` exactly.
  Future<void> resetPassword({
    required String token,
    required String email,
    required String password,
    required String passwordConfirmation,
  }) async {
    try {
      await _apiClient.post(
        '/api/agent/reset-password',
        data: {
          'token': token,
          'email': email,
          'password': password,
          'password_confirmation': passwordConfirmation,
        },
      );
    } catch (e) {
      if (e is DioException && e.response != null) {
        throw Exception(
          e.response?.data['message'] ?? 'Failed to reset password',
        );
      }
      throw Exception('Failed to reset password: $e');
    }
  }

  /// Resend Verification Email (Public)
  /// NOTE: This path matches `old_lib/` exactly.
  Future<void> resendVerificationEmailPublic(String email) async {
    try {
      await _apiClient.post(
        '/api/agent/resend-verification-email',
        data: {'email': email},
      );
    } catch (e) {
      if (e is DioException && e.response != null) {
        throw Exception(
          e.response?.data['message'] ?? 'Failed to resend verification email',
        );
      }
      throw Exception('Failed to resend verification email: $e');
    }
  }

  /// Resend Verification Email (Authenticated)
  /// NOTE: This path matches `old_lib/` exactly.
  Future<void> resendVerificationAuthenticated() async {
    try {
      await _apiClient.post('/api/agent/email/verification-notification');
    } catch (e) {
      if (e is DioException && e.response != null) {
        throw Exception(
          e.response?.data['message'] ?? 'Failed to resend verification email',
        );
      }
      throw Exception('Failed to resend verification email: $e');
    }
  }
}
