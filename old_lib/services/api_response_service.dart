import 'package:dio/dio.dart';
import 'package:youragent/data/models/api_response.dart';

/// Global API Response Service
/// Handles standard API response parsing and error handling
class ApiResponseService {
  /// Parse API response to ApiResponse model
  static ApiResponse<T> parseResponse<T>(Response response, T Function(dynamic)? fromJson) {
    try {
      final data = response.data;

      if (data is Map<String, dynamic>) {
        return ApiResponse.fromJson(data, fromJson);
      } else {
        // If response is not a map, wrap it
        return ApiResponse<T>(success: true, data: data as T?);
      }
    } catch (e) {
      return ApiResponse<T>(success: false, message: 'Failed to parse response: $e');
    }
  }

  /// Extract data from API response
  /// Handles both {success: true, data: {...}} and direct data responses
  static T? extractData<T>(Response response, T Function(dynamic)? fromJson) {
    try {
      final data = response.data;

      if (data is Map<String, dynamic>) {
        // Check if it's a standard API response
        if (data.containsKey('success') && data.containsKey('data')) {
          final apiResponse = ApiResponse.fromJson(data, fromJson);
          return apiResponse.data;
        } else {
          // Direct data response
          return fromJson != null ? fromJson(data) : data as T?;
        }
      } else {
        // Direct data (not a map)
        return fromJson != null ? fromJson(data) : data as T?;
      }
    } catch (e) {
      return null;
    }
  }

  /// Handle API errors with user-friendly messages
  /// Returns context-aware error messages based on status codes
  static String getErrorMessage(dynamic error) {
    // Handle DioException (network errors)
    if (error is DioException) {
      // Handle connection timeout
      if (error.type == DioExceptionType.connectionTimeout ||
          error.type == DioExceptionType.receiveTimeout ||
          error.type == DioExceptionType.sendTimeout) {
        return 'กรุณาตรวจสอบการเชื่อมต่ออินเทอร์เน็ต';
      }
      
      // Handle no internet connection
      if (error.type == DioExceptionType.connectionError) {
        return 'ไม่สามารถเชื่อมต่อกับเซิร์ฟเวอร์ได้ กรุณาตรวจสอบการเชื่อมต่ออินเทอร์เน็ต';
      }
      
      // Handle response errors with status codes
      if (error.response != null) {
        final data = error.response?.data;
        final statusCode = error.response?.statusCode;
        
        // Extract message from response data
        String? apiMessage;
        if (data is Map<String, dynamic>) {
          // Try multiple possible message fields
          apiMessage = data['message'] as String? ??
              data['error'] as String? ??
              (data['error'] is Map<String, dynamic>
                  ? (data['error'] as Map<String, dynamic>)['message'] as String?
                  : null) ??
              data['msg'] as String?;
          
          // For validation errors (422), extract field-specific errors
          if (statusCode == 422 && data['errors'] is Map<String, dynamic>) {
            final errors = data['errors'] as Map<String, dynamic>;
            final errorMessages = <String>[];
            errors.forEach((field, messages) {
              if (messages is List) {
                errorMessages.addAll(messages.map((m) => m.toString()));
              } else if (messages is String) {
                errorMessages.add(messages);
              }
            });
            if (errorMessages.isNotEmpty) {
              return errorMessages.join('\n');
            }
          }
        }
        
        // Context-aware messages based on status code
        if (statusCode == 400 || statusCode == 422) {
          // Bad Request / Validation Error: Show specific API message
          return apiMessage ?? 'ข้อมูลไม่ถูกต้อง กรุณาตรวจสอบและลองใหม่';
        } else if (statusCode == 401) {
          return 'กรุณาเข้าสู่ระบบอีกครั้ง';
        } else if (statusCode == 403) {
          return 'คุณไม่มีสิทธิ์เข้าถึงข้อมูลนี้';
        } else if (statusCode == 404) {
          return 'ไม่พบข้อมูลที่ต้องการ';
        } else if (statusCode == 500 || statusCode == 502 || statusCode == 503) {
          // Server Error: Show generic friendly message (don't show stack trace)
          return 'ระบบขัดข้องชั่วคราว กรุณาลองใหม่อีกครั้ง';
        } else if (apiMessage != null && apiMessage.isNotEmpty) {
          // If we have an API message, use it
          return apiMessage;
        } else {
          // Fallback to status message
          return error.response?.statusMessage ?? 'เกิดข้อผิดพลาด กรุณาลองใหม่';
        }
      }
      
      // Handle DioException without response
      return error.message ?? 'เกิดข้อผิดพลาดในการเชื่อมต่อ กรุณาลองใหม่';
    }
    
    // Handle error strings (from BLoCs that convert errors to strings)
    final errorString = error.toString();
    
    // Try to extract DioException information from string
    if (errorString.contains('DioException')) {
      // Check for timeout patterns
      if (errorString.contains('timeout') || errorString.contains('Timeout')) {
        return 'กรุณาตรวจสอบการเชื่อมต่ออินเทอร์เน็ต';
      }
      // Check for connection error patterns
      if (errorString.contains('connection') || errorString.contains('Connection')) {
        return 'ไม่สามารถเชื่อมต่อกับเซิร์ฟเวอร์ได้ กรุณาตรวจสอบการเชื่อมต่ออินเทอร์เน็ต';
      }
    }
    
    // Remove "Exception: " prefix if present
    if (errorString.startsWith('Exception: ')) {
      final cleanMessage = errorString.substring(11).trim();
      // If the remaining message is still technical, provide a generic message
      if (cleanMessage.contains('DioException') || 
          cleanMessage.contains('SocketException') ||
          cleanMessage.startsWith('Failed')) {
        return 'เกิดข้อผิดพลาด กรุณาลองใหม่';
      }
      return cleanMessage;
    }
    
    // For other error types, provide a generic message if it looks technical
    if (errorString.contains('Exception') || 
        errorString.contains('Error') ||
        errorString.contains('Failed')) {
      return 'เกิดข้อผิดพลาด กรุณาลองใหม่';
    }
    
    // Return the error string as-is if it looks user-friendly
    return errorString;
  }

  /// Check if response is successful
  static bool isSuccess(Response response) {
    final statusCode = response.statusCode;
    return statusCode != null && statusCode >= 200 && statusCode < 300;
  }
}
