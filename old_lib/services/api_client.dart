import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:talker_dio_logger/talker_dio_logger.dart';
import 'package:youragent/features/auth/bloc/auth_event.dart';
import 'package:youragent/flavors.dart';
import 'package:youragent/core/config/app_config.dart';
import 'session_service.dart';
import 'package:youragent/core/di/dependency_injection.dart';

class ApiClient {
  static final ApiClient _instance = ApiClient._internal();
  late final Dio dio;
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  // Track retry attempts per request
  final Map<String, int> _retryCounts = {};
  static const int _maxRetries = 3;

  factory ApiClient() {
    return _instance;
  }

  ApiClient._internal() {
    dio = Dio(
      BaseOptions(
        baseUrl: F.baseUrl,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        sendTimeout: const Duration(seconds: 30),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    // Add interceptors
    _addInterceptors();
  }

  void _addInterceptors() {
    // Add TalkerDioLogger interceptor ONLY in DEV environment
    if (AppConfig.isDev && DependencyInjection.talker != null) {
      dio.interceptors.add(
        TalkerDioLogger(talker: DependencyInjection.talker!),
      );
    }

    // Logging interceptor (debug mode only)
    if (kDebugMode) {
      dio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            // Skip verbose logging for compatibility analysis endpoint (too long)
            final isCompatibilityEndpoint = options.path.contains(
              '/comprehensive-compatibility/analyze',
            );

            if (!isCompatibilityEndpoint) {
              // Log request for all other endpoints
              debugPrint('🌐 API Request: ${options.method} ${options.uri}');
              if (options.headers.isNotEmpty) {
                debugPrint('🌐 API Request Headers: ${options.headers}');
              }
              if (options.data != null) {
                debugPrint('🌐 API Request Body: ${options.data}');
              }
            } else {
              // For compatibility endpoint, log headers only
              debugPrint('🌐 API Request: ${options.method} ${options.uri}');
              if (options.headers.isNotEmpty) {
                debugPrint('🌐 API Request Headers: ${options.headers}');
              }
            }
            handler.next(options);
          },
          onResponse: (response, handler) {
            // Skip all logging for compatibility analysis endpoint (response too long)
            final isCompatibilityEndpoint = response.requestOptions.path
                .contains('/comprehensive-compatibility/analyze');

            if (!isCompatibilityEndpoint) {
              debugPrint(
                '🌐 API Response: ${response.statusCode} ${response.requestOptions.uri}',
              );
              // Truncate long response bodies (e.g., lists) to avoid cluttering logs
              final responseBody = response.data.toString();
              if (responseBody.length > 500) {
                debugPrint(
                  '🌐 API Response Body: ${responseBody.substring(0, 500)}... (truncated, ${responseBody.length} chars)',
                );
              } else {
                debugPrint('🌐 API Response Body: $responseBody');
              }
            }
            handler.next(response);
          },
          onError: (error, handler) {
            debugPrint('🌐 API Error: ${error.requestOptions.uri}');
            debugPrint('🌐 API Error: ${error.message}');
            if (error.response != null) {
              debugPrint(
                '🌐 API Error Response: ${error.response?.statusCode}',
              );
              // Truncate long error data to avoid cluttering logs
              final errorData = error.response?.data.toString() ?? '';
              if (errorData.length > 500) {
                debugPrint(
                  '🌐 API Error Data: ${errorData.substring(0, 500)}... (truncated, ${errorData.length} chars)',
                );
              } else {
                debugPrint('🌐 API Error Data: $errorData');
              }
            }
            handler.next(error);
          },
        ),
      );
    }

    // Auth interceptor
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          // Update session activity on each API request
          await SessionService().updateActivity();

          // Skip auth token for public endpoints
          final isPublicEndpoint =
              options.path.startsWith('/public/') ||
              options.path.startsWith('public/') ||
              options.path.contains('/login') ||
              options.path.contains('/register');

          // Add authorization token if available and not a public endpoint
          if (!isPublicEndpoint) {
            final token = await _getAuthToken();
            if (token != null && token.isNotEmpty) {
              options.headers['Authorization'] = 'Bearer $token';
              if (kDebugMode) {
                debugPrint('🔑 Adding Bearer token to request: ${options.uri}');
              }
            } else {
              if (kDebugMode) {
                debugPrint(
                  '⚠️ No auth token available for request: ${options.uri}',
                );
              }
            }
          } else {
            if (kDebugMode) {
              debugPrint(
                '🌐 Public endpoint - skipping auth token: ${options.uri}',
              );
            }
          }
          handler.next(options);
        },
        onError: (error, handler) async {
          final requestKey = error.requestOptions.uri.toString();
          final retryCount = _retryCounts[requestKey] ?? 0;

          // Handle 401 Unauthorized errors with retry logic
          // Skip retry for login/register/logout endpoints
          // Logout endpoint should not be retried because:
          // 1. If token is invalid, logout will fail anyway
          // 2. Retrying logout creates an infinite loop
          final isAuthEndpoint =
              error.requestOptions.path.contains('/login') ||
              error.requestOptions.path.contains('/register') ||
              error.requestOptions.path.contains('/logout');

          if (error.response?.statusCode == 401 && !isAuthEndpoint) {
            if (retryCount < _maxRetries) {
              // Increment retry count
              _retryCounts[requestKey] = retryCount + 1;

              debugPrint(
                '🔒 Auth error (401): Retrying request (${retryCount + 1}/$_maxRetries): ${error.requestOptions.uri}',
              );

              // Wait a bit before retrying
              await Future.delayed(
                Duration(milliseconds: 500 * (retryCount + 1)),
              );

              // Retry the request
              try {
                final opts = error.requestOptions;
                final response = await dio.request(
                  opts.path,
                  options: Options(method: opts.method, headers: opts.headers),
                  data: opts.data,
                  queryParameters: opts.queryParameters,
                );
                // Remove retry count on success
                _retryCounts.remove(requestKey);
                handler.resolve(response);
                return;
              } catch (e) {
                // If retry also fails, continue to next retry or max retries
                if (retryCount + 1 >= _maxRetries) {
                  // Max retries reached - handle logout
                  _retryCounts.remove(requestKey);
                  await _handleMaxRetriesReached(
                    requestPath: error.requestOptions.path,
                  );
                }
                handler.next(error);
                return;
              }
            } else {
              // Max retries reached - handle logout
              _retryCounts.remove(requestKey);
              await _handleMaxRetriesReached(
                requestPath: error.requestOptions.path,
              );
            }
          } else if (error.response?.statusCode == 403) {
            debugPrint('🚫 Access denied');
          } else if (error.response?.statusCode == 500) {
            debugPrint('💥 Server error');
          }

          // Remove retry count for non-401 errors
          _retryCounts.remove(requestKey);
          handler.next(error);
        },
      ),
    );
  }

  // Get auth token from secure storage
  Future<String?> _getAuthToken() async {
    try {
      final token = await _storage.read(key: 'auth_token');
      if (kDebugMode && token != null) {
        debugPrint(
          '🔑 Auth token retrieved from storage (length: ${token.length})',
        );
      }
      return token;
    } catch (e) {
      debugPrint('❌ Error reading auth token: $e');
      return null;
    }
  }

  // Save auth token to secure storage
  Future<void> saveAuthToken(String token) async {
    try {
      await _storage.write(key: 'auth_token', value: token);
      if (kDebugMode) {
        debugPrint('💾 Auth token saved to secure storage');
      }
    } catch (e) {
      debugPrint('❌ Error saving auth token: $e');
    }
  }

  // Clear auth token from secure storage
  Future<void> clearAuthToken() async {
    try {
      await _storage.delete(key: 'auth_token');
      debugPrint('🔒 Auth token cleared from storage');
    } catch (e) {
      debugPrint('❌ Error clearing auth token: $e');
    }
  }

  // Handle max retries reached - logout and redirect
  Future<void> _handleMaxRetriesReached({String? requestPath}) async {
    debugPrint('🔒 Max retries ($_maxRetries) reached for 401 errors');

    // If this is a logout request, don't trigger another logout to avoid infinite loop
    if (requestPath != null && requestPath.contains('/logout')) {
      debugPrint(
        '🔒 Logout request failed - clearing token and session without retry',
      );
      await clearAuthToken();
      await SessionService().clearSession();
      return;
    }

    debugPrint('🔒 Clearing auth token and session');

    // Clear token and session
    await clearAuthToken();
    await SessionService().clearSession();

    // Trigger logout via AuthBloc (only if not already a logout request)
    try {
      DependencyInjection.authBloc.add(const SignOutEvent());
      debugPrint('🔒 SignOutEvent dispatched');
    } catch (e) {
      debugPrint('❌ Error dispatching SignOutEvent: $e');
    }
  }

  // Example GET request
  Future<Response> get(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    return await dio.get(
      path,
      queryParameters: queryParameters,
      options: options,
    );
  }

  // Example POST request
  Future<Response> post(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    return await dio.post(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
    );
  }

  // Example PUT request
  Future<Response> put(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    return await dio.put(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
    );
  }

  // Example DELETE request
  Future<Response> delete(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    return await dio.delete(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
    );
  }

  // POST request with form data (multipart/form-data)
  Future<Response> postFormData(
    String path, {
    required Map<String, dynamic> formData,
    Map<String, dynamic>? queryParameters,
  }) async {
    final data = FormData.fromMap(formData);
    return await dio.post(
      path,
      data: data,
      queryParameters: queryParameters,
      options: Options(contentType: 'multipart/form-data'),
    );
  }
}
