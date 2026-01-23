import 'api_client.dart';
import 'package:youragent/domain/entities/floor_plan.dart';
import 'package:dio/dio.dart';
import 'dart:io';

/// FloorPlan API Service - handles all floor plan-related API endpoints
class FloorPlanApiService {
  static FloorPlanApiService? _instance;
  final ApiClient _apiClient;

  FloorPlanApiService._(this._apiClient);

  factory FloorPlanApiService(ApiClient apiClient) {
    _instance ??= FloorPlanApiService._(apiClient);
    return _instance!;
  }

  /// List Floor Plans
  /// GET /agent/properties/{id}/floorplans
  Future<List<FloorPlan>> getFloorPlans({required String role, required int propertyId}) async {
    try {
      final response = await _apiClient.get('/$role/properties/$propertyId/floorplans');
      final data = response.data as Map<String, dynamic>;
      final dynamic list = data['floor_plans'] ?? data['floorplans'];
      if (list is List) {
        return list.map((json) => FloorPlan.fromJson(json as Map<String, dynamic>)).toList();
      }
      return [];
    } catch (e) {
      if (e is DioException && e.response != null) {
        throw Exception(e.response?.data['message'] ?? 'Failed to get floor plans');
      }
      throw Exception('Failed to list floor plans: $e');
    }
  }

  /// Create Floor Plan
  /// POST /agent/properties/{id}/floorplans
  Future<FloorPlan> createFloorPlan({required String role, required int propertyId, required File floorPlan}) async {
    try {
      final formData = FormData.fromMap({
        'property_id': propertyId,
        'floor_plan': await MultipartFile.fromFile(floorPlan.path, filename: floorPlan.path.split('/').last),
      });

      final response = await _apiClient.post(
        '/$role/properties/$propertyId/floorplans',
        data: formData,
        options: Options(contentType: 'multipart/form-data'),
      );
      final data = response.data as Map<String, dynamic>;
      return FloorPlan.fromJson(data['floor_plan'] ?? data['floorplan'] ?? data);
    } catch (e) {
      if (e is DioException && e.response != null) {
        throw Exception(e.response?.data['message'] ?? 'Failed to create floor plan');
      }
      throw Exception('Failed to create floor plan: $e');
    }
  }

  /// Update Floor Plan
  /// PUT /agent/floorplans/{id}
  Future<FloorPlan> updateFloorPlan({
    required String role,
    required int floorPlanId,
    File? floorPlan,
    Map<String, dynamic>? otherFields,
  }) async {
    try {
      if (floorPlan != null) {
        final formData = FormData.fromMap({
          'floor_plan': await MultipartFile.fromFile(floorPlan.path, filename: floorPlan.path.split('/').last),
          if (otherFields != null) ...otherFields,
        });

        final response = await _apiClient.put(
          '/$role/floorplans/$floorPlanId',
          data: formData,
          options: Options(contentType: 'multipart/form-data'),
        );
        final data = response.data as Map<String, dynamic>;
        return FloorPlan.fromJson(data['floor_plan'] ?? data['floorplan'] ?? data);
      } else {
        final response = await _apiClient.put('/$role/floorplans/$floorPlanId', data: otherFields ?? {});
        final data = response.data as Map<String, dynamic>;
        return FloorPlan.fromJson(data['floor_plan'] ?? data['floorplan'] ?? data);
      }
    } catch (e) {
      if (e is DioException && e.response != null) {
        throw Exception(e.response?.data['message'] ?? 'Failed to update floor plan');
      }
      throw Exception('Failed to update floor plan: $e');
    }
  }

  /// Delete Floor Plan
  /// DELETE /agent/floorplans/{id}
  Future<void> deleteFloorPlan({required String role, required int floorPlanId}) async {
    try {
      await _apiClient.delete('/$role/floorplans/$floorPlanId');
    } catch (e) {
      if (e is DioException && e.response != null) {
        throw Exception(e.response?.data['message'] ?? 'Failed to delete floor plan');
      }
      throw Exception('Failed to delete floor plan: $e');
    }
  }

  /// Refresh Floor Plan URLs
  /// POST /agent/refresh/floorplan-urls
  Future<Map<String, dynamic>> refreshFloorPlanUrls({required String role, required int propertyId}) async {
    try {
      final response = await _apiClient.post('/$role/refresh/floorplan-urls', data: {'property_id': propertyId});
      return response.data as Map<String, dynamic>;
    } catch (e) {
      if (e is DioException && e.response != null) {
        throw Exception(e.response?.data['message'] ?? 'Failed to refresh floor plan URLs');
      }
      throw Exception('Failed to refresh floor plan URLs: $e');
    }
  }
}
