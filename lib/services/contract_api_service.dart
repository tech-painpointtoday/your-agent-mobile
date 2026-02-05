import 'package:dio/dio.dart';
import '../domain/entities/contract.dart';
import '../domain/entities/contract_create_data.dart';
import '../domain/entities/contract_edit_data.dart';
import '../domain/entities/contract_attachment.dart';
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
      final List<dynamic> contractsJson = data['data'] is List
          ? data['data']
          : [];

      return contractsJson
          .map(
            (json) => Contract.fromJson(Map<String, dynamic>.from(json as Map)),
          )
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
  Future<void> deleteContract({required int contractId}) async {
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

  /// Get Contract Detail
  /// GET /agent/contracts/{id}
  Future<Contract> getContractDetail({required int contractId}) async {
    try {
      final response = await _apiClient.get('/agent/contracts/$contractId');

      final apiResponse =
          ApiResponseService.parseResponse<Map<String, dynamic>>(
            response,
            (json) => json is Map<String, dynamic> ? json : <String, dynamic>{},
          );

      if (!apiResponse.success || apiResponse.data == null) {
        throw Exception(apiResponse.message ?? 'Failed to get contract detail');
      }

      return Contract.fromJson(apiResponse.data!);
    } catch (e) {
      if (e is DioException && e.response != null) {
        final errorMessage = ApiResponseService.getErrorMessage(e);
        throw Exception(errorMessage);
      }
      throw Exception('Failed to get contract detail: $e');
    }
  }

  /// Get Contract PDF
  /// GET /agent/contracts/{id}/pdf
  Future<List<int>> getContractPdf({required int contractId}) async {
    try {
      final response = await _apiClient.get(
        '/agent/contracts/$contractId/pdf',
        options: Options(responseType: ResponseType.bytes),
      );

      if (response.statusCode == 200 && response.data != null) {
        return response.data as List<int>;
      } else {
        throw Exception('Failed to fetch PDF: ${response.statusMessage}');
      }
    } catch (e) {
      if (e is DioException && e.response != null) {
        final errorMessage = ApiResponseService.getErrorMessage(e);
        throw Exception(errorMessage);
      }
      throw Exception('Failed to fetch PDF: $e');
    }
  }

  /// Send Contract to Seller
  /// POST /agent/contracts/{id}/send-to-seller
  Future<void> sendToSeller({required int contractId}) async {
    try {
      final response = await _apiClient.post(
        '/agent/contracts/$contractId/send-to-seller',
      );

      final apiResponse = ApiResponseService.parseResponse<void>(
        response,
        null,
      );

      if (!apiResponse.success) {
        throw Exception(apiResponse.message ?? 'Failed to send to seller');
      }
    } catch (e) {
      if (e is DioException && e.response != null) {
        final errorMessage = ApiResponseService.getErrorMessage(e);
        throw Exception(errorMessage);
      }
      throw Exception('Failed to send to seller: $e');
    }
  }

  /// Send Contract to Buyer
  /// POST /agent/contracts/{id}/send-to-buyer
  Future<void> sendToBuyer({required int contractId}) async {
    try {
      final response = await _apiClient.post(
        '/agent/contracts/$contractId/send-to-buyer',
      );

      final apiResponse = ApiResponseService.parseResponse<void>(
        response,
        null,
      );

      if (!apiResponse.success) {
        throw Exception(apiResponse.message ?? 'Failed to send to buyer');
      }
    } catch (e) {
      if (e is DioException && e.response != null) {
        final errorMessage = ApiResponseService.getErrorMessage(e);
        throw Exception(errorMessage);
      }
      throw Exception('Failed to send to buyer: $e');
    }
  }

  Future<void> updateContract({
    required int id,
    required Map<String, dynamic> data,
  }) async {
    try {
      final response = await _apiClient.post(
        '/agent/contracts/$id',
        data: data,
      );

      final apiResponse = ApiResponseService.parseResponse<void>(
        response,
        null,
      );

      if (!apiResponse.success) {
        throw Exception(apiResponse.message ?? 'Failed to update contract');
      }
    } catch (e) {
      if (e is DioException && e.response != null) {
        final errorMessage = ApiResponseService.getErrorMessage(e);
        throw Exception(errorMessage);
      }
      throw Exception('Failed to update contract: $e');
    }
  }

  Future<int> createContract({required Map<String, dynamic> data}) async {
    try {
      final response = await _apiClient.post('/agent/contracts', data: data);

      final apiResponse =
          ApiResponseService.parseResponse<Map<String, dynamic>>(
            response,
            (json) => json as Map<String, dynamic>,
          );

      if (!apiResponse.success || apiResponse.data == null) {
        throw Exception(apiResponse.message ?? 'Failed to create contract');
      }

      final id = apiResponse.data!['id'] ?? apiResponse.data!['data']?['id'];
      if (id == null) {
        throw Exception('Contract ID not found in response');
      }

      return id is int ? id : int.parse(id.toString());
    } catch (e) {
      if (e is DioException && e.response != null) {
        final errorMessage = ApiResponseService.getErrorMessage(e);
        throw Exception(errorMessage);
      }
      throw Exception('Failed to create contract: $e');
    }
  }

  /// Get Contract Edit Data
  /// GET /agent/contracts/{id}/edit
  Future<ContractEditData> getContractEditData(dynamic id) async {
    try {
      final response = await _apiClient.get('/agent/contracts/$id/edit');
      final apiResponse =
          ApiResponseService.parseResponse<Map<String, dynamic>>(
            response,
            (json) => json as Map<String, dynamic>,
          );

      if (!apiResponse.success || apiResponse.data == null) {
        throw Exception(
          apiResponse.message ?? 'Failed to load contract edit data',
        );
      }

      return ContractEditData.fromJson(apiResponse.data!);
    } catch (e) {
      if (e is DioException && e.response != null) {
        final errorMessage = ApiResponseService.getErrorMessage(e);
        throw Exception(errorMessage);
      }
      throw Exception('Failed to load contract edit data: $e');
    }
  }

  /// Upload Contract Document
  /// POST /agent/contracts/{id}/documents
  Future<void> uploadContractDocument({
    required int contractId,
    required String name,
    required String filePath,
  }) async {
    try {
      final fileName = filePath.split('/').last;
      final formData = FormData.fromMap({
        'name': name,
        'document': await MultipartFile.fromFile(filePath, filename: fileName),
      });

      final response = await _apiClient.post(
        '/agent/contracts/$contractId/documents',
        data: formData,
      );

      final apiResponse = ApiResponseService.parseResponse<void>(
        response,
        null,
      );

      if (!apiResponse.success) {
        throw Exception(
          apiResponse.message ?? 'Failed to upload contract document',
        );
      }
    } catch (e) {
      if (e is DioException && e.response != null) {
        final errorMessage = ApiResponseService.getErrorMessage(e);
        throw Exception(errorMessage);
      }
      throw Exception('Failed to upload contract document: $e');
    }
  }

  /// Get Contract Documents
  /// GET /agent/contracts/{id}/documents
  Future<List<ContractAttachment>> getContractDocuments(int contractId) async {
    try {
      final response = await _apiClient.get(
        '/agent/contracts/$contractId/documents',
      );
      final apiResponse = ApiResponseService.parseResponse<List<dynamic>>(
        response,
        (json) => json as List<dynamic>,
      );

      if (!apiResponse.success || apiResponse.data == null) {
        throw Exception(
          apiResponse.message ?? 'Failed to get contract documents',
        );
      }

      return apiResponse.data!
          .map(
            (json) => ContractAttachment.fromJson(json as Map<String, dynamic>),
          )
          .toList();
    } catch (e) {
      if (e is DioException && e.response != null) {
        final errorMessage = ApiResponseService.getErrorMessage(e);
        throw Exception(errorMessage);
      }
      throw Exception('Failed to get contract documents: $e');
    }
  }

  /// Delete Contract Document
  /// DELETE /agent/contracts/{id}/documents/{document_id}
  Future<void> deleteContractDocument(int contractId, int documentId) async {
    try {
      final response = await _apiClient.delete(
        '/agent/contracts/$contractId/documents/$documentId',
      );
      final apiResponse = ApiResponseService.parseResponse<void>(
        response,
        null,
      );

      if (!apiResponse.success) {
        throw Exception(
          apiResponse.message ?? 'Failed to delete contract document',
        );
      }
    } catch (e) {
      if (e is DioException && e.response != null) {
        final errorMessage = ApiResponseService.getErrorMessage(e);
        throw Exception(errorMessage);
      }
      throw Exception('Failed to delete contract document: $e');
    }
  }
}
