import 'package:dio/dio.dart';
import 'dart:typed_data';
import 'api_client.dart';
import 'api_response_service.dart';
import 'package:youragent/data/models/contract_create_data_model.dart';
import 'package:youragent/data/models/contract_edit_data_model.dart';
import 'package:youragent/data/models/contract_model.dart';
import 'package:youragent/data/models/contract_requests.dart';

/// Contract API Service - handles all contract-related API endpoints
class ContractApiService {
  static ContractApiService? _instance;
  final ApiClient _apiClient;

  ContractApiService._(this._apiClient);

  factory ContractApiService(ApiClient apiClient) {
    _instance ??= ContractApiService._(apiClient);
    return _instance!;
  }

  // ==================== List Contracts ====================

  /// Get Contracts (paginated)
  /// GET /agent/contracts?page={page}
  Future<Map<String, dynamic>> getContracts({int page = 1}) async {
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

      return apiResponse.data!;
    } catch (e) {
      if (e is DioException && e.response != null) {
        final errorMessage = ApiResponseService.getErrorMessage(e);
        throw Exception(errorMessage);
      }
      throw Exception('Failed to get contracts: $e');
    }
  }

  // ==================== Contract Creation Data ====================

  /// Get Create Data from Booking
  /// GET /agent/contracts/bookings/{bookingId}/create
  Future<ContractCreateData> getCreateDataFromBooking({
    required int bookingId,
  }) async {
    try {
      final response = await _apiClient.get(
        '/agent/contracts/bookings/$bookingId/create',
      );

      final createData = ApiResponseService.extractData<ContractCreateData>(
        response,
        (json) => ContractCreateData.fromJson(json as Map<String, dynamic>),
      );

      if (createData == null) {
        throw Exception('Failed to parse contract creation data from booking');
      }

      return createData;
    } catch (e) {
      if (e is DioException && e.response != null) {
        final errorMessage = ApiResponseService.getErrorMessage(e);
        throw Exception(errorMessage);
      }
      throw Exception('Failed to get contract creation data from booking: $e');
    }
  }

  /// Get Create Data from Property
  /// GET /agent/contracts/properties/{propertyId}/create
  Future<ContractCreateData> getCreateDataFromProperty({
    required int propertyId,
  }) async {
    try {
      final response = await _apiClient.get(
        '/agent/contracts/properties/$propertyId/create',
      );

      final createData = ApiResponseService.extractData<ContractCreateData>(
        response,
        (json) => ContractCreateData.fromJson(json as Map<String, dynamic>),
      );

      if (createData == null) {
        throw Exception('Failed to parse contract creation data from property');
      }

      return createData;
    } catch (e) {
      if (e is DioException && e.response != null) {
        final errorMessage = ApiResponseService.getErrorMessage(e);
        throw Exception(errorMessage);
      }
      throw Exception('Failed to get contract creation data from property: $e');
    }
  }

  // ==================== Contract CRUD ====================

  /// Get Contract Detail
  /// GET /agent/contracts/{id}
  /// Returns ContractModel (nested in `data`)
  Future<ContractModel> getContractDetail({required int contractId}) async {
    try {
      final response = await _apiClient.get('/agent/contracts/$contractId');

      final contractJson = ApiResponseService.extractData<Map<String, dynamic>>(
        response,
        (json) => (json as Map).cast<String, dynamic>(),
      );

      if (contractJson == null) {
        throw Exception('Failed to parse contract detail');
      }

      return ContractModel.fromJson(contractJson);
    } catch (e) {
      if (e is DioException && e.response != null) {
        final errorMessage = ApiResponseService.getErrorMessage(e);
        throw Exception(errorMessage);
      }
      throw Exception('Failed to get contract detail: $e');
    }
  }

  /// Get Contract Edit Data
  /// GET /agent/contracts/{id}/edit
  /// Returns `data.contract` (ContractModel), `data.banks` (List), `data.account_types` (Map)
  Future<ContractEditData> getEditData({required int contractId}) async {
    try {
      final response = await _apiClient.get(
        '/agent/contracts/$contractId/edit',
      );

      final dataJson = ApiResponseService.extractData<Map<String, dynamic>>(
        response,
        (json) => (json as Map).cast<String, dynamic>(),
      );

      if (dataJson == null) {
        throw Exception('Failed to parse contract edit data');
      }

      return ContractEditData.fromJson(dataJson);
    } catch (e) {
      if (e is DioException && e.response != null) {
        final errorMessage = ApiResponseService.getErrorMessage(e);
        throw Exception(errorMessage);
      }
      throw Exception('Failed to get contract edit data: $e');
    }
  }

  /// Get Contract PDF bytes
  /// GET /agent/contracts/{id}/pdf
  Future<Uint8List> getContractPdf({required int contractId}) async {
    try {
      final response = await _apiClient.get(
        '/agent/contracts/$contractId/pdf',
        options: Options(responseType: ResponseType.bytes),
      );

      if (response.data is! List<int>) {
        throw Exception('Invalid PDF response');
      }

      return Uint8List.fromList(response.data as List<int>);
    } catch (e) {
      if (e is DioException && e.response != null) {
        final errorMessage = ApiResponseService.getErrorMessage(e);
        throw Exception(errorMessage);
      }
      throw Exception('Failed to fetch contract PDF: $e');
    }
  }

  /// Create Contract from Booking
  /// POST /agent/contracts
  Future<Map<String, dynamic>> createContract(
    CreateContractRequest request,
  ) async {
    try {
      final response = await _apiClient.post(
        '/agent/contracts',
        data: request.toJson(),
      );

      final apiResponse =
          ApiResponseService.parseResponse<Map<String, dynamic>>(
            response,
            (json) => json is Map<String, dynamic> ? json : <String, dynamic>{},
          );

      if (!apiResponse.success || apiResponse.data == null) {
        throw Exception(apiResponse.message ?? 'Failed to create contract');
      }

      return apiResponse.data!;
    } catch (e) {
      if (e is DioException && e.response != null) {
        final errorMessage = ApiResponseService.getErrorMessage(e);
        throw Exception(errorMessage);
      }
      throw Exception('Failed to create contract: $e');
    }
  }

  /// Create Contract from Property (no booking)
  /// POST /agent/contracts/from-property
  Future<Map<String, dynamic>> createContractFromProperty(
    CreateContractFromPropertyRequest request,
  ) async {
    try {
      final response = await _apiClient.post(
        '/agent/contracts/from-property',
        data: request.toJson(),
      );

      final apiResponse =
          ApiResponseService.parseResponse<Map<String, dynamic>>(
            response,
            (json) => json is Map<String, dynamic> ? json : <String, dynamic>{},
          );

      if (!apiResponse.success || apiResponse.data == null) {
        throw Exception(
          apiResponse.message ?? 'Failed to create contract from property',
        );
      }

      return apiResponse.data!;
    } catch (e) {
      if (e is DioException && e.response != null) {
        final errorMessage = ApiResponseService.getErrorMessage(e);
        throw Exception(errorMessage);
      }
      throw Exception('Failed to create contract from property: $e');
    }
  }

  /// Get Contract by ID
  /// GET /agent/contracts/{id}
  Future<Map<String, dynamic>> getContract({required int contractId}) async {
    try {
      final response = await _apiClient.get('/agent/contracts/$contractId');

      final apiResponse =
          ApiResponseService.parseResponse<Map<String, dynamic>>(
            response,
            (json) => json is Map<String, dynamic> ? json : <String, dynamic>{},
          );

      if (!apiResponse.success || apiResponse.data == null) {
        throw Exception(apiResponse.message ?? 'Failed to get contract');
      }

      return apiResponse.data!;
    } catch (e) {
      if (e is DioException && e.response != null) {
        final errorMessage = ApiResponseService.getErrorMessage(e);
        throw Exception(errorMessage);
      }
      throw Exception('Failed to get contract: $e');
    }
  }

  /// Get Contract Edit Data
  /// GET /agent/contracts/{id}/edit
  Future<Map<String, dynamic>> getContractEditData({
    required int contractId,
  }) async {
    try {
      final response = await _apiClient.get(
        '/agent/contracts/$contractId/edit',
      );

      final apiResponse =
          ApiResponseService.parseResponse<Map<String, dynamic>>(
            response,
            (json) => json is Map<String, dynamic> ? json : <String, dynamic>{},
          );

      if (!apiResponse.success || apiResponse.data == null) {
        throw Exception(
          apiResponse.message ?? 'Failed to get contract edit data',
        );
      }

      return apiResponse.data!;
    } catch (e) {
      if (e is DioException && e.response != null) {
        final errorMessage = ApiResponseService.getErrorMessage(e);
        throw Exception(errorMessage);
      }
      throw Exception('Failed to get contract edit data: $e');
    }
  }

  /// Update Contract
  /// PUT /agent/contracts/{id}
  Future<Map<String, dynamic>> updateContract({
    required int contractId,
    required UpdateContractRequest request,
  }) async {
    try {
      final response = await _apiClient.post(
        '/agent/contracts/$contractId',
        data: request.toJson(),
      );

      final apiResponse =
          ApiResponseService.parseResponse<Map<String, dynamic>>(
            response,
            (json) => json is Map<String, dynamic> ? json : <String, dynamic>{},
          );

      if (!apiResponse.success || apiResponse.data == null) {
        throw Exception(apiResponse.message ?? 'Failed to update contract');
      }

      return apiResponse.data!;
    } catch (e) {
      if (e is DioException && e.response != null) {
        final errorMessage = ApiResponseService.getErrorMessage(e);
        throw Exception(errorMessage);
      }
      throw Exception('Failed to update contract: $e');
    }
  }

  /// Create Contract from Booking (raw payload)
  /// POST /agent/contracts
  Future<Map<String, dynamic>> createContractFromBookingRaw({
    required Map<String, dynamic> payload,
  }) async {
    try {
      final response = await _apiClient.post('/agent/contracts', data: payload);

      final apiResponse =
          ApiResponseService.parseResponse<Map<String, dynamic>>(
            response,
            (json) => json is Map<String, dynamic> ? json : <String, dynamic>{},
          );

      if (!apiResponse.success || apiResponse.data == null) {
        throw Exception(apiResponse.message ?? 'Failed to create contract');
      }

      return apiResponse.data!;
    } catch (e) {
      if (e is DioException && e.response != null) {
        final errorMessage = ApiResponseService.getErrorMessage(e);
        throw Exception(errorMessage);
      }
      throw Exception('Failed to create contract: $e');
    }
  }

  /// Create Contract from Property (raw payload)
  /// POST /agent/contracts/from-property
  Future<Map<String, dynamic>> createContractFromPropertyRaw({
    required Map<String, dynamic> payload,
  }) async {
    try {
      final response = await _apiClient.post(
        '/agent/contracts/from-property',
        data: payload,
      );

      final apiResponse =
          ApiResponseService.parseResponse<Map<String, dynamic>>(
            response,
            (json) => json is Map<String, dynamic> ? json : <String, dynamic>{},
          );

      if (!apiResponse.success || apiResponse.data == null) {
        throw Exception(
          apiResponse.message ?? 'Failed to create contract from property',
        );
      }

      return apiResponse.data!;
    } catch (e) {
      if (e is DioException && e.response != null) {
        final errorMessage = ApiResponseService.getErrorMessage(e);
        throw Exception(errorMessage);
      }
      throw Exception('Failed to create contract from property: $e');
    }
  }

  /// Update Contract (raw payload)
  /// PUT /agent/contracts/{id}
  Future<Map<String, dynamic>> updateContractRaw({
    required int contractId,
    required Map<String, dynamic> payload,
  }) async {
    try {
      final response = await _apiClient.put(
        '/agent/contracts/$contractId',
        data: payload,
      );

      final apiResponse =
          ApiResponseService.parseResponse<Map<String, dynamic>>(
            response,
            (json) => json is Map<String, dynamic> ? json : <String, dynamic>{},
          );

      if (!apiResponse.success || apiResponse.data == null) {
        throw Exception(apiResponse.message ?? 'Failed to update contract');
      }

      return apiResponse.data!;
    } catch (e) {
      if (e is DioException && e.response != null) {
        final errorMessage = ApiResponseService.getErrorMessage(e);
        throw Exception(errorMessage);
      }
      throw Exception('Failed to update contract: $e');
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

  // ==================== Contract Documents ====================

  /// Download Contract PDF
  /// GET /agent/contracts/{id}/pdf
  Future<Uint8List> downloadContractPdf({required int contractId}) async {
    try {
      final response = await _apiClient.get(
        '/agent/contracts/$contractId/pdf',
        options: Options(responseType: ResponseType.bytes),
      );
      return Uint8List.fromList(response.data as List<int>);
    } catch (e) {
      if (e is DioException && e.response != null) {
        throw Exception(
          e.response?.data['message'] ?? 'Failed to download contract PDF',
        );
      }
      throw Exception('Failed to download contract PDF: $e');
    }
  }

  /// Get Seller Signed Contract Download URL
  /// GET /agent/contracts/{id}/seller-signed
  Future<Map<String, dynamic>> getSellerSignedContract({
    required int contractId,
  }) async {
    try {
      final response = await _apiClient.get(
        '/agent/contracts/$contractId/seller-signed',
      );

      final apiResponse =
          ApiResponseService.parseResponse<Map<String, dynamic>>(
            response,
            (json) => json is Map<String, dynamic> ? json : <String, dynamic>{},
          );

      if (!apiResponse.success || apiResponse.data == null) {
        throw Exception(
          apiResponse.message ?? 'Failed to get seller signed contract',
        );
      }

      return apiResponse.data!;
    } catch (e) {
      if (e is DioException && e.response != null) {
        final errorMessage = ApiResponseService.getErrorMessage(e);
        throw Exception(errorMessage);
      }
      throw Exception('Failed to get seller signed contract: $e');
    }
  }

  /// Get Buyer Signed Contract Download URL
  /// GET /agent/contracts/{id}/buyer-signed
  Future<Map<String, dynamic>> getBuyerSignedContract({
    required int contractId,
  }) async {
    try {
      final response = await _apiClient.get(
        '/agent/contracts/$contractId/buyer-signed',
      );

      final apiResponse =
          ApiResponseService.parseResponse<Map<String, dynamic>>(
            response,
            (json) => json is Map<String, dynamic> ? json : <String, dynamic>{},
          );

      if (!apiResponse.success || apiResponse.data == null) {
        throw Exception(
          apiResponse.message ?? 'Failed to get buyer signed contract',
        );
      }

      return apiResponse.data!;
    } catch (e) {
      if (e is DioException && e.response != null) {
        final errorMessage = ApiResponseService.getErrorMessage(e);
        throw Exception(errorMessage);
      }
      throw Exception('Failed to get buyer signed contract: $e');
    }
  }

  // ==================== Contract Distribution ====================

  /// Send Contract to Seller
  /// POST /agent/contracts/{id}/send-to-seller
  Future<Map<String, dynamic>> sendContractToSeller({
    required int contractId,
  }) async {
    try {
      final response = await _apiClient.post(
        '/agent/contracts/$contractId/send-to-seller',
      );

      final apiResponse =
          ApiResponseService.parseResponse<Map<String, dynamic>>(
            response,
            (json) => json is Map<String, dynamic> ? json : <String, dynamic>{},
          );

      if (!apiResponse.success || apiResponse.data == null) {
        throw Exception(
          apiResponse.message ?? 'Failed to send contract to seller',
        );
      }

      return apiResponse.data!;
    } catch (e) {
      if (e is DioException && e.response != null) {
        final errorMessage = ApiResponseService.getErrorMessage(e);
        throw Exception(errorMessage);
      }
      throw Exception('Failed to send contract to seller: $e');
    }
  }

  /// Send Contract to Buyer
  /// POST /agent/contracts/{id}/send-to-buyer
  Future<Map<String, dynamic>> sendContractToBuyer({
    required int contractId,
  }) async {
    try {
      final response = await _apiClient.post(
        '/agent/contracts/$contractId/send-to-buyer',
      );

      final apiResponse =
          ApiResponseService.parseResponse<Map<String, dynamic>>(
            response,
            (json) => json is Map<String, dynamic> ? json : <String, dynamic>{},
          );

      if (!apiResponse.success || apiResponse.data == null) {
        throw Exception(
          apiResponse.message ?? 'Failed to send contract to buyer',
        );
      }

      return apiResponse.data!;
    } catch (e) {
      if (e is DioException && e.response != null) {
        final errorMessage = ApiResponseService.getErrorMessage(e);
        throw Exception(errorMessage);
      }
      throw Exception('Failed to send contract to buyer: $e');
    }
  }

  // ==================== Contract Management ====================

  /// Assign Seller to Contract
  /// POST /agent/contracts/{id}/assign-seller
  Future<Map<String, dynamic>> assignSellerToContract({
    required int contractId,
    required AssignSellerRequest request,
  }) async {
    try {
      final response = await _apiClient.post(
        '/agent/contracts/$contractId/assign-seller',
        data: request.toJson(),
      );

      final apiResponse =
          ApiResponseService.parseResponse<Map<String, dynamic>>(
            response,
            (json) => json is Map<String, dynamic> ? json : <String, dynamic>{},
          );

      if (!apiResponse.success || apiResponse.data == null) {
        throw Exception(
          apiResponse.message ?? 'Failed to assign seller to contract',
        );
      }

      return apiResponse.data!;
    } catch (e) {
      if (e is DioException && e.response != null) {
        final errorMessage = ApiResponseService.getErrorMessage(e);
        throw Exception(errorMessage);
      }
      throw Exception('Failed to assign seller to contract: $e');
    }
  }

  /// Reset Availability (for expired contract)
  /// POST /agent/contracts/{id}/reset-availability
  Future<Map<String, dynamic>> resetAvailability({
    required int contractId,
  }) async {
    try {
      final response = await _apiClient.post(
        '/agent/contracts/$contractId/reset-availability',
      );

      final apiResponse =
          ApiResponseService.parseResponse<Map<String, dynamic>>(
            response,
            (json) => json is Map<String, dynamic> ? json : <String, dynamic>{},
          );

      if (!apiResponse.success || apiResponse.data == null) {
        throw Exception(apiResponse.message ?? 'Failed to reset availability');
      }

      return apiResponse.data!;
    } catch (e) {
      if (e is DioException && e.response != null) {
        final errorMessage = ApiResponseService.getErrorMessage(e);
        throw Exception(errorMessage);
      }
      throw Exception('Failed to reset availability: $e');
    }
  }
}
