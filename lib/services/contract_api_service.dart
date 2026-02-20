import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../domain/entities/contract.dart';
import '../domain/entities/contract_create_data.dart';
import '../domain/entities/contract_edit_data.dart';
import '../domain/entities/contract_attachment.dart';
import '../domain/entities/contract_item_definition.dart';
import '../domain/entities/buyer.dart';
import '../domain/entities/owner.dart';
import '../domain/entities/pagination.dart';
import '../domain/entities/contract_results.dart';
import 'api_client.dart';
import 'api_response_service.dart';

/// Contract API Service - handles all contract-related API endpoints
class ContractApiService {
  final ApiClient _apiClient;

  ContractApiService(this._apiClient);

  /// Get Contracts (paginated)
  Future<ContractResults> getContracts({int page = 1, int perPage = 10}) async {
    try {
      final response = await _apiClient.get(
        '/agent/contracts',
        queryParameters: {'page': page, 'per_page': perPage},
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
      List<dynamic> contractsJson = [];

      debugPrint(
        'ContractApiService: analyzing response data. data type is ${data.runtimeType}, data[\'data\'] type is ${data['data'].runtimeType}',
      );

      if (data['data'] != null && data['data'] is Map<String, dynamic>) {
        final dataValue = data['data'] as Map<String, dynamic>;
        if (dataValue['contracts'] != null && dataValue['contracts'] is List) {
          contractsJson = dataValue['contracts'] as List;
          debugPrint(
            'ContractApiService: Found ${contractsJson.length} contracts in data.contracts',
          );
        } else if (dataValue['data'] != null && dataValue['data'] is List) {
          contractsJson = dataValue['data'] as List;
          debugPrint(
            'ContractApiService: Found ${contractsJson.length} contracts in data.data',
          );
        }
      } else if (data['data'] != null && data['data'] is List) {
        contractsJson = data['data'] as List<dynamic>;
        debugPrint(
          'ContractApiService: Found ${contractsJson.length} contracts in direct data list',
        );
      } else if (data['contracts'] != null && data['contracts'] is List) {
        contractsJson = data['contracts'] as List;
        debugPrint(
          'ContractApiService: Found ${contractsJson.length} contracts in top-level contracts',
        );
      }

      final contracts = contractsJson
          .map(
            (json) => Contract.fromJson(Map<String, dynamic>.from(json as Map)),
          )
          .toList();

      Pagination pagination = Pagination(
        currentPage: page,
        lastPage: 1,
        perPage: perPage,
        total: contracts.length,
        from: 1,
        to: contracts.length,
      );

      if (data['pagination'] != null) {
        pagination = Pagination.fromJson(
          data['pagination'] as Map<String, dynamic>,
        );
      } else if (data['data'] != null && data['data'] is Map<String, dynamic>) {
        final dataValue = data['data'] as Map<String, dynamic>;
        if (dataValue['pagination'] != null) {
          pagination = Pagination.fromJson(
            dataValue['pagination'] as Map<String, dynamic>,
          );
        }
      }

      if (data['pagination'] != null) {
        pagination = Pagination.fromJson(
          data['pagination'] as Map<String, dynamic>,
        );
      } else if (data['data'] is Map<String, dynamic>) {
        final dataMap = data['data'] as Map<String, dynamic>;
        if (dataMap['pagination'] != null) {
          pagination = Pagination.fromJson(
            dataMap['pagination'] as Map<String, dynamic>,
          );
        }
      }

      return ContractResults(contracts: contracts, pagination: pagination);
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

  Future<void> updateContract({required int id, required dynamic data}) async {
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

  Future<int> createContract({
    required dynamic data,
    bool isFromProperty = true,
  }) async {
    try {
      final String apiPath = isFromProperty
          ? '/agent/contracts/from-property'
          : '/agent/contracts';

      final response = await _apiClient.post(apiPath, data: data);

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

  /// Save contract as draft
  /// POST /agent/contracts/draft
  Future<int> createContractDraft({required dynamic data}) async {
    try {
      final response = await _apiClient.post(
        '/agent/contracts/draft',
        data: data,
      );

      final apiResponse =
          ApiResponseService.parseResponse<Map<String, dynamic>>(
            response,
            (json) => json as Map<String, dynamic>,
          );

      if (!apiResponse.success || apiResponse.data == null) {
        throw Exception(apiResponse.message ?? 'Failed to save draft');
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
      throw Exception('Failed to save draft: $e');
    }
  }

  /// Update contract draft
  /// PUT /agent/contracts/{id}/draft
  Future<void> updateContractDraft({
    required int id,
    required dynamic data,
  }) async {
    try {
      final response = await _apiClient.post(
        '/agent/contracts/$id/draft',
        data: data,
      );

      final apiResponse = ApiResponseService.parseResponse<void>(
        response,
        null,
      );

      if (!apiResponse.success) {
        throw Exception(apiResponse.message ?? 'Failed to update draft');
      }
    } catch (e) {
      if (e is DioException && e.response != null) {
        final errorMessage = ApiResponseService.getErrorMessage(e);
        throw Exception(errorMessage);
      }
      throw Exception('Failed to update draft: $e');
    }
  }

  /// Publish contract
  /// POST /agent/contracts/{id}/publish
  Future<void> publishContract({required int id}) async {
    try {
      final response = await _apiClient.post('/agent/contracts/$id/publish');

      final apiResponse = ApiResponseService.parseResponse<void>(
        response,
        null,
      );

      if (!apiResponse.success) {
        throw Exception(apiResponse.message ?? 'Failed to publish contract');
      }
    } catch (e) {
      if (e is DioException && e.response != null) {
        final errorMessage = ApiResponseService.getErrorMessage(e);
        throw Exception(errorMessage);
      }
      throw Exception('Failed to publish contract: $e');
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

  /// Delete Appliance Photo
  /// DELETE /agent/contracts/{contract_id}/appliances/{appliance_id}/photo
  Future<void> deleteAppliancePhoto({
    required int contractId,
    required String applianceId,
  }) async {
    try {
      final response = await _apiClient.delete(
        '/agent/contracts/$contractId/appliances/$applianceId/photo',
      );

      final apiResponse = ApiResponseService.parseResponse<void>(
        response,
        null,
      );

      if (!apiResponse.success) {
        throw Exception(
          apiResponse.message ?? 'Failed to delete appliance photo',
        );
      }
    } catch (e) {
      if (e is DioException && e.response != null) {
        final errorMessage = ApiResponseService.getErrorMessage(e);
        throw Exception(errorMessage);
      }
      throw Exception('Failed to delete appliance photo: $e');
    }
  }

  /// Delete Furniture Photo
  /// DELETE /agent/contracts/{contract_id}/furniture/{furniture_id}/photo
  Future<void> deleteFurniturePhoto({
    required int contractId,
    required String furnitureId,
  }) async {
    try {
      final response = await _apiClient.delete(
        '/agent/contracts/$contractId/furniture/$furnitureId/photo',
      );

      final apiResponse = ApiResponseService.parseResponse<void>(
        response,
        null,
      );

      if (!apiResponse.success) {
        throw Exception(
          apiResponse.message ?? 'Failed to delete furniture photo',
        );
      }
    } catch (e) {
      if (e is DioException && e.response != null) {
        final errorMessage = ApiResponseService.getErrorMessage(e);
        throw Exception(errorMessage);
      }
      throw Exception('Failed to delete furniture photo: $e');
    }
  }

  /// Get Contract Item Definitions (Appliances & Furniture)
  /// GET /public/contracts/item-definitions
  Future<ContractItemDefinitions> getItemDefinitions() async {
    try {
      final response = await _apiClient.get(
        '/public/contracts/item-definitions',
      );

      final apiResponse =
          ApiResponseService.parseResponse<Map<String, dynamic>>(
            response,
            (json) => json as Map<String, dynamic>,
          );

      if (!apiResponse.success || apiResponse.data == null) {
        throw Exception(
          apiResponse.message ?? 'Failed to get contract item definitions',
        );
      }

      return ContractItemDefinitions.fromJson(apiResponse.data!);
    } catch (e) {
      if (e is DioException && e.response != null) {
        final errorMessage = ApiResponseService.getErrorMessage(e);
        throw Exception(errorMessage);
      }
      throw Exception('Failed to get contract item definitions: $e');
    }
  }

  /// Get Buyers
  /// GET /agent/contracts/buyers
  Future<List<Buyer>> getBuyers() async {
    try {
      final response = await _apiClient.get('/agent/contracts/buyers');

      final apiResponse = ApiResponseService.parseResponse<List<dynamic>>(
        response,
        (json) => json is List ? json : [],
      );

      if (!apiResponse.success || apiResponse.data == null) {
        throw Exception(apiResponse.message ?? 'Failed to get buyers');
      }

      final List<dynamic> data = apiResponse.data!;
      return data.map((json) => Buyer.fromJson(json)).toList();
    } catch (e) {
      if (e is DioException && e.response != null) {
        final errorMessage = ApiResponseService.getErrorMessage(e);
        throw Exception(errorMessage);
      }
      throw Exception('Failed to get buyers: $e');
    }
  }

  /// Get Sellers
  /// GET /agent/contracts/sellers
  Future<List<Owner>> getSellers() async {
    try {
      final response = await _apiClient.get('/agent/contracts/sellers');

      final apiResponse = ApiResponseService.parseResponse<List<dynamic>>(
        response,
        (json) => json is List ? json : [],
      );

      if (!apiResponse.success || apiResponse.data == null) {
        throw Exception(apiResponse.message ?? 'Failed to get sellers');
      }

      final List<dynamic> data = apiResponse.data!;
      return data.map((json) => Owner.fromJson(json)).toList();
    } catch (e) {
      if (e is DioException && e.response != null) {
        final errorMessage = ApiResponseService.getErrorMessage(e);
        throw Exception(errorMessage);
      }
      throw Exception('Failed to get sellers: $e');
    }
  }
}
