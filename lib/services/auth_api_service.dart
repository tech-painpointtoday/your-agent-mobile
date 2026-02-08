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
      if (e is DioException) {
        // Preserve EMAIL_NOT_VERIFIED for Repository handling
        if (e.response?.data is Map<String, dynamic>) {
          final responseData = e.response!.data as Map<String, dynamic>;
          if (responseData['success'] == false &&
              responseData['error'] is Map<String, dynamic>) {
            final err = responseData['error'] as Map<String, dynamic>;
            if (err['code'] == 'EMAIL_NOT_VERIFIED') {
              rethrow;
            }
          }
        }
        throw Exception(_extractErrorMessage(e));
      }
      throw Exception('Failed to login: $e');
    }
  }

  String _extractErrorMessage(DioException e) {
    if (e.response?.data is Map<String, dynamic>) {
      final data = e.response!.data as Map<String, dynamic>;

      // Check for structured error object first
      if (data['error'] is Map<String, dynamic>) {
        final error = data['error'] as Map<String, dynamic>;

        // Handle VALIDATION_ERROR specifically
        if (error['code'] == 'VALIDATION_ERROR' &&
            error['details'] is Map<String, dynamic>) {
          final details = error['details'] as Map<String, dynamic>;
          if (details.isNotEmpty) {
            // Get the first error message from the first field
            final firstFieldErrors = details.values.first;
            if (firstFieldErrors is List && firstFieldErrors.isNotEmpty) {
              return firstFieldErrors.first.toString();
            }
          }
        }

        // Fallback to error object message
        if (error['message'] != null) {
          return error['message'].toString();
        }
      }

      // Top level message fallback
      if (data['message'] != null) {
        return data['message'].toString();
      }
    }

    return e.message ?? 'Unknown error occurred';
  }

  Future<Map<String, dynamic>> sellerRegister({
    required String name,
    required String email,
    required String password,
    required String passwordConfirmation,
    required String address,
  }) async {
    try {
      final response = await _apiClient.post(
        '/seller/register',
        data: {
          'name': name,
          'email': email,
          'password': password,
          'password_confirmation': passwordConfirmation,
          'address': address,
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
      if (e is DioException) {
        throw Exception(_extractErrorMessage(e));
      }
      throw Exception('Failed to register seller: $e');
    }
  }

  Future<Map<String, dynamic>> buyerRegister({
    required String name,
    required String email,
    required String password,
    required String passwordConfirmation,
  }) async {
    try {
      final response = await _apiClient.post(
        '/buyer/register',
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
      if (e is DioException) {
        throw Exception(_extractErrorMessage(e));
      }
      throw Exception('Failed to register buyer: $e');
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
      if (e is DioException) {
        throw Exception(_extractErrorMessage(e));
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
      if (e is DioException) {
        throw Exception(_extractErrorMessage(e));
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
      if (e is DioException) {
        throw Exception(_extractErrorMessage(e));
      }
      throw Exception('Failed to send reset password email: $e');
    }
  }

  /// Reset Password
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
      if (e is DioException) {
        throw Exception(_extractErrorMessage(e));
      }
      throw Exception('Failed to reset password: $e');
    }
  }

  /// Resend Verification Email (Public)
  Future<void> resendVerificationEmailPublic(String email) async {
    try {
      await _apiClient.post(
        '/api/agent/resend-verification-email',
        data: {'email': email},
      );
    } catch (e) {
      if (e is DioException) {
        throw Exception(_extractErrorMessage(e));
      }
      throw Exception('Failed to resend verification email: $e');
    }
  }

  /// Resend Verification Email (Authenticated)
  Future<void> resendVerificationAuthenticated() async {
    try {
      await _apiClient.post('/api/agent/email/verification-notification');
    } catch (e) {
      if (e is DioException) {
        throw Exception(_extractErrorMessage(e));
      }
      throw Exception('Failed to resend verification email: $e');
    }
  }

  Future<Map<String, dynamic>> getAgentProfile() async {
    final response = await _apiClient.get('/agent/profile');
    return response.data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> updateAgentProfile(
    Map<String, dynamic> data,
  ) async {
    final response = await _apiClient.put('/agent/profile', data: data);
    return response.data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> changePassword({
    required String currentPassword,
    required String newPassword,
    required String confirmPassword,
  }) async {
    final response = await _apiClient.post(
      '/api/agent/password',
      data: {
        'current_password': currentPassword,
        'password': newPassword,
        'password_confirmation': confirmPassword,
      },
    );
    return response.data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> updateProfilePhoto(String filePath) async {
    final formData = FormData.fromMap({
      'profile_photo': await MultipartFile.fromFile(filePath),
    });

    final response = await _apiClient.post(
      '/agent/profile/update-photo',
      data: formData,
    );
    return response.data as Map<String, dynamic>;
  }
}
