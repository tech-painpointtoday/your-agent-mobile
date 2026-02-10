import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:talker_dio_logger/talker_dio_logger.dart';

import '../core/config/app_config.dart';
import '../core/di/dependency_injection.dart';
import '../features/auth/bloc/auth_event.dart';
import 'session_service.dart';

class ApiClient {
  static final ApiClient _instance = ApiClient._internal();
  factory ApiClient() => _instance;

  ApiClient._internal() {
    dio = Dio(
      BaseOptions(
        baseUrl: AppConfig.baseUrl,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        sendTimeout: const Duration(seconds: 30),
        headers: const {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    // Add TalkerDioLogger interceptor ONLY in DEV environment
    if (AppConfig.isDev && DependencyInjection.talker != null) {
      dio.interceptors.add(
        TalkerDioLogger(
          talker: DependencyInjection.talker!,
          // Avoid logging binary (bytes) responses such as PDFs to keep
          // logs readable and prevent slowdowns when downloading files.
          settings: TalkerDioLoggerSettings(
            responseFilter: (response) =>
                response.requestOptions.responseType != ResponseType.bytes,
          ),
        ),
      );
    }

    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          await SessionService().updateActivity();

          final isPublicEndpoint =
              options.path.contains('/login') ||
              options.path.contains('/register') ||
              options.path.contains('/forgot-password') ||
              options.path.contains('/reset-password') ||
              options.path.contains('/resend-verification-email');

          if (!isPublicEndpoint) {
            final token = await _getAuthToken();
            if (token != null && token.isNotEmpty) {
              options.headers['Authorization'] = 'Bearer $token';
            }
          }
          handler.next(options);
        },
        onError: (error, handler) async {
          // Handle 401 Unauthorized
          if (error.response?.statusCode == 401) {
            final isLogoutRequest = error.requestOptions.path.contains(
              '/logout',
            );
            if (!isLogoutRequest) {
              final authRepo = DependencyInjection.authRepository;
              if (authRepo.isAuthenticated) {
                // Trigger global logout via Bloc to ensure state consistency
                debugPrint(
                  'Unauthorized access detected (401). Logging out...',
                );
                DependencyInjection.authBloc.add(const SignOutEvent());
              }
            }
          }
          handler.next(error);
        },
      ),
    );
  }

  late final Dio dio;
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  Future<String?> _getAuthToken() async {
    try {
      return _storage.read(key: 'auth_token');
    } catch (e) {
      debugPrint('Error reading auth token: $e');
      return null;
    }
  }

  Future<void> saveAuthToken(String token) async {
    await _storage.write(key: 'auth_token', value: token);
  }

  Future<void> clearAuthToken() async {
    await _storage.delete(key: 'auth_token');
  }

  Future<Response> get(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) {
    return dio.get(path, queryParameters: queryParameters, options: options);
  }

  Future<Response> post(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) {
    return dio.post(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
    );
  }

  Future<Response> put(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) {
    return dio.put(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
    );
  }

  Future<Response> patch(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) {
    return dio.patch(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
    );
  }

  Future<Response> delete(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) {
    return dio.delete(path, queryParameters: queryParameters, options: options);
  }
}
