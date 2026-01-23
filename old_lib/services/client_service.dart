import 'package:dio/dio.dart';
import 'package:youragent/services/api_client.dart';

/// Service for managing client (Buyer/Seller) operations
class ClientService {
  final ApiClient _apiClient = ApiClient();

  /// Register a new buyer
  /// 
  /// Body: { "name": "...", "email": "...", "phone": "...", "password": "...", "password_confirmation": "..." }
  Future<void> registerBuyer(Map<String, dynamic> data) async {
    try {
      await _apiClient.post(
        '/buyer/register',
        data: data,
      );
    } on DioException catch (e) {
      // Re-throw with error message for BLoC to handle
      final errorMessage = e.response?.data?['message']?.toString() ??
          e.response?.data?['error']?.toString() ??
          e.message ??
          'Failed to register buyer';
      throw Exception(errorMessage);
    } catch (e) {
      throw Exception('Failed to register buyer: ${e.toString()}');
    }
  }

  /// Register a new seller
  /// 
  /// Body: { "name": "...", "email": "...", "phone": "...", "password": "...", "password_confirmation": "..." }
  Future<void> registerSeller(Map<String, dynamic> data) async {
    try {
      await _apiClient.post(
        '/seller/register',
        data: data,
      );
    } on DioException catch (e) {
      // Re-throw with error message for BLoC to handle
      final errorMessage = e.response?.data?['message']?.toString() ??
          e.response?.data?['error']?.toString() ??
          e.message ??
          'Failed to register seller';
      throw Exception(errorMessage);
    } catch (e) {
      throw Exception('Failed to register seller: ${e.toString()}');
    }
  }
}
