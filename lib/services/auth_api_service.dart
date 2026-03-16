import 'package:dio/dio.dart';

import 'api_client.dart';
import '../domain/entities/device_info_model.dart';
import '../core/error/api_exception.dart';

class _ErrorData {
  final String message;
  final String? code;
  final Map<String, dynamic>? details;

  _ErrorData(this.message, {this.code, this.details});
}

class AuthApiService {
  final ApiClient _apiClient;
  AuthApiService(this._apiClient);

  /// Token we just saved (e.g. from login). Used by registerDeviceToken to avoid polling storage.
  String? _lastSavedAuthToken;

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
        _lastSavedAuthToken = token;
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

  _ErrorData _extractErrorData(DioException e) {
    if (e.response?.data is Map<String, dynamic>) {
      final data = e.response!.data as Map<String, dynamic>;

      if (data['error'] is Map<String, dynamic>) {
        final error = data['error'] as Map<String, dynamic>;
        final code = error['code']?.toString();
        final details = error['details'] is Map<String, dynamic>
            ? error['details'] as Map<String, dynamic>
            : null;

        String message = error['message']?.toString() ?? 'An error occurred';

        if (code == 'VALIDATION_ERROR' &&
            details != null &&
            details.isNotEmpty) {
          final firstFieldErrors = details.values.first;
          if (firstFieldErrors is List && firstFieldErrors.isNotEmpty) {
            message = firstFieldErrors.first.toString();
          }
        }

        return _ErrorData(message, code: code, details: details);
      }

      if (data['message'] != null) {
        return _ErrorData(data['message'].toString());
      }
    }

    return _ErrorData(e.message ?? 'Unknown error occurred');
  }

  String _extractErrorMessage(DioException e) {
    return _extractErrorData(e).message;
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
        _lastSavedAuthToken = token;
        await _apiClient.saveAuthToken(token);
      }

      return data;
    } catch (e) {
      if (e is DioException) {
        final errorData = _extractErrorData(e);
        throw ApiException(
          errorData.message,
          code: errorData.code,
          details: errorData.details,
        );
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
        _lastSavedAuthToken = token;
        await _apiClient.saveAuthToken(token);
      }

      return data;
    } catch (e) {
      if (e is DioException) {
        final errorData = _extractErrorData(e);
        throw ApiException(
          errorData.message,
          code: errorData.code,
          details: errorData.details,
        );
      }
      throw Exception('Failed to register buyer: $e');
    }
  }

  /// Seller register (no address). Used by auth repo for email signup.
  Future<Map<String, dynamic>> sellerRegisterAccount({
    required String name,
    required String email,
    required String password,
    required String passwordConfirmation,
  }) async {
    try {
      final response = await _apiClient.post(
        '/seller/register',
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
        _lastSavedAuthToken = token;
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

  /// Sign in with email/password for seller. Single role for this app.
  Future<Map<String, dynamic>> sellerLogin({
    required String email,
    required String password,
  }) async {
    return _login(path: '/seller/login', email: email, password: password);
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
        _lastSavedAuthToken = authToken;
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
      _lastSavedAuthToken = null;
      await _apiClient.clearAuthToken();
    }
  }

  /// Forgot Password
  /// NOTE: This path matches `old_lib/` exactly.
  Future<void> forgotPassword({required String email}) async {
    try {
      await _apiClient.post('/seller/forgot-password', data: {'email': email});
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
        '/api/seller/reset-password',
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
        '/seller/resend-verification-email',
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
      await _apiClient.post('/api/seller/email/verification-notification');
    } catch (e) {
      if (e is DioException) {
        throw Exception(_extractErrorMessage(e));
      }
      throw Exception('Failed to resend verification email: $e');
    }
  }

  Future<Map<String, dynamic>> getSellerProfile() async {
    final response = await _apiClient.get('/seller/profile');
    return response.data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> updateSellerProfile(
    Map<String, dynamic> data,
  ) async {
    final response = await _apiClient.put('/seller/profile', data: data);
    return response.data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> changePassword({
    required String currentPassword,
    required String newPassword,
    required String confirmPassword,
  }) async {
    try {
      final response = await _apiClient.post(
        '/seller/password',
        data: {
          'current_password': currentPassword,
          'password': newPassword,
          'password_confirmation': confirmPassword,
        },
      );

      // Normalize response format to include 'success' field
      final data = response.data as Map<String, dynamic>;
      if (!data.containsKey('success')) {
        return {'success': true, ...data};
      }
      return data;
    } catch (e) {
      if (e is DioException) {
        throw Exception(_extractErrorMessage(e));
      }
      throw Exception('Failed to change password: $e');
    }
  }

  Future<Map<String, dynamic>> updateProfilePhoto(String filePath) async {
    final formData = FormData.fromMap({
      'profile_photo': await MultipartFile.fromFile(filePath),
    });

    final response = await _apiClient.post('/seller/profile', data: formData);
    return response.data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> registerDeviceToken(DeviceInfoModel info) async {
    // Prefer token we just saved (login/social); else read from storage with one short wait
    String? authToken = _lastSavedAuthToken;
    if (authToken == null || authToken.isEmpty) {
      authToken = await _apiClient.getAuthToken();
      if (authToken == null || authToken.isEmpty) {
        await Future<void>.delayed(const Duration(milliseconds: 150));
        authToken = await _apiClient.getAuthToken();
      }
    }
    if (authToken == null || authToken.isEmpty) {
      throw Exception('Cannot register device: auth token not available');
    }
    final response = await _apiClient.post(
      '/device-tokens/register',
      data: info.toJson(),
      options: Options(headers: {'Authorization': 'Bearer $authToken'}),
    );
    return response.data as Map<String, dynamic>;
  }

  /// Unregister device (e.g. on logout). Call while still authenticated.
  Future<void> unregisterDeviceToken(DeviceInfoModel info) async {
    String? authToken = _lastSavedAuthToken;
    if (authToken == null || authToken.isEmpty) {
      authToken = await _apiClient.getAuthToken();
    }
    if (authToken == null || authToken.isEmpty) return;
    try {
      await _apiClient.post(
        '/device-tokens/unregister',
        data: {'token': info.token},
        options: Options(headers: {'Authorization': 'Bearer $authToken'}),
      );
    } on DioException catch (_) {
      // Best effort; do not block logout
    }
  }

  Future<void> deleteAccount({
    required String password,
    required String reason,
  }) async {
    try {
      await _apiClient.delete(
        '/seller/account',
        data: {'password': password, 'reason': reason},
      );
      // Clear auth token after successful deletion
      _lastSavedAuthToken = null;
      await _apiClient.clearAuthToken();
    } catch (e) {
      if (e is DioException) {
        throw Exception(_extractErrorMessage(e));
      }
      throw Exception('Failed to delete account: $e');
    }
  }
}
