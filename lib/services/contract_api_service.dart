import 'package:dio/dio.dart';
import '../domain/entities/contract.dart';
import '../domain/entities/contract_create_data.dart';
import 'api_client.dart';
import 'api_response_service.dart';

/// Contract API Service - handles all contract-related API endpoints
class ContractApiService {
  final ApiClient _apiClient;

  ContractApiService(this._apiClient);

  /// Get Contracts (paginated)
  /// GET /agent/contracts?page={page}
  Future<List<Contract>> getContracts({int page = 1}) async {
    try {
      final response = await _apiClient.get(
        '/agent/contracts',
        queryParameters: {'page': page},
      );

      final apiResponse =
          ApiResponseService.parseResponse<Map<String, dynamic>>(
            response,
            (json) => json is Map<String, dynamic> ? json : <String, dynamic>{},
          );

      if (!apiResponse.success || apiResponse.data == null) {
        throw Exception(apiResponse.message ?? 'Failed to get contracts');
      }

      final data = apiResponse.data!;
      final List<dynamic> contractsJson = data['contracts'] is List
          ? data['contracts']
          : (data['data'] is List ? data['data'] : []);

      return contractsJson
          .map((json) => Contract.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      if (e is DioException && e.response != null) {
        final errorMessage = ApiResponseService.getErrorMessage(e);
        throw Exception(errorMessage);
      }
      throw Exception('Failed to get contracts: $e');
    }
  }

  /// Delete Contract
  /// DELETE /agent/contracts/{id}
  Future<void> deleteContract({required String contractId}) async {
    try {
      final response = await _apiClient.delete('/agent/contracts/$contractId');

      final apiResponse = ApiResponseService.parseResponse<void>(
        response,
        null,
      );

      if (!apiResponse.success) {
        throw Exception(apiResponse.message ?? 'Failed to delete contract');
      }
    } catch (e) {
      if (e is DioException && e.response != null) {
        final errorMessage = ApiResponseService.getErrorMessage(e);
        throw Exception(errorMessage);
      }
      throw Exception('Failed to delete contract: $e');
    }
  }

  /// Get Contract Create Data
  /// GET /agent/contracts/properties/{id}/create
  Future<ContractCreateData> getContractCreateData({
    required int propertyId,
  }) async {
    try {
      final response = await _apiClient.get(
        '/agent/contracts/properties/$propertyId/create',
      );

      final apiResponse =
          ApiResponseService.parseResponse<Map<String, dynamic>>(
            response,
            (json) => json is Map<String, dynamic> ? json : <String, dynamic>{},
          );

      if (!apiResponse.success || apiResponse.data == null) {
        throw Exception(
          apiResponse.message ?? 'Failed to get contract create data',
        );
      }

      return ContractCreateData.fromJson(apiResponse.data!);
    } catch (e) {
      if (e is DioException && e.response != null) {
        final errorMessage = ApiResponseService.getErrorMessage(e);
        throw Exception(errorMessage);
      }
      throw Exception('Failed to get contract create data: $e');
    }
  }
}
