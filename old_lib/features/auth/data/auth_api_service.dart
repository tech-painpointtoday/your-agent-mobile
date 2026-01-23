import 'package:dio/dio.dart';

import 'package:youragent/services/api_client.dart';

class AuthApiService {
  final ApiClient _api;

  AuthApiService(this._api);

  Future<void> agentLogin({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _api.post(
        '/agent/login',
        data: {'email': email, 'password': password},
      );
      final data = response.data as Map<String, dynamic>;

      String? token;
      if (data['token'] != null) {
        token = data['token'] as String?;
      } else if (data['access_token'] != null) {
        token = data['access_token'] as String?;
      } else if (data['data'] is Map<String, dynamic>) {
        final d = data['data'] as Map<String, dynamic>;
        token = d['token'] as String? ?? d['access_token'] as String?;
      }

      if (token == null || token.isEmpty) {
        throw Exception('No token returned from login');
      }

      await _api.saveAuthToken(token);
    } on DioException catch (e) {
      final msg = (e.response?.data is Map<String, dynamic>)
          ? ((e.response!.data as Map<String, dynamic>)['message']?.toString())
          : null;
      throw Exception(msg ?? 'Login failed');
    }
  }

  Future<void> agentRegister({
    required String name,
    required String email,
    required String password,
    required String passwordConfirmation,
  }) async {
    try {
      await _api.post(
        '/agent/register',
        data: {
          'name': name,
          'email': email,
          'password': password,
          'password_confirmation': passwordConfirmation,
        },
      );
    } on DioException catch (e) {
      final msg = (e.response?.data is Map<String, dynamic>)
          ? ((e.response!.data as Map<String, dynamic>)['message']?.toString())
          : null;
      throw Exception(msg ?? 'Registration failed');
    }
  }

  Future<void> logout() async {
    try {
      await _api.post('/logout');
    } finally {
      await _api.clearAuthToken();
    }
  }
}
