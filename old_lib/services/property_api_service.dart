import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'api_client.dart';
import 'api_response_service.dart';
import 'package:youragent/data/models/property_model.dart';
import 'package:youragent/data/models/api_response.dart';
import 'package:youragent/data/models/property_filter_options.dart';
import 'package:youragent/data/models/developer_model.dart';
import 'package:youragent/data/models/condo_project_model.dart';
import 'package:image_picker/image_picker.dart';

/// Photo upload data structure
/// Uses XFile for cross-platform compatibility (web and mobile)
class PhotoUploadData {
  final XFile file;
  final String tag;
  final String? facingDirection;

  PhotoUploadData({
    required this.file,
    this.tag = 'gallery',
    this.facingDirection,
  });
}

/// Property API Service - handles all property-related API endpoints
class PropertyApiService {
  static PropertyApiService? _instance;
  final ApiClient _apiClient;

  PropertyApiService._(this._apiClient);

  factory PropertyApiService(ApiClient apiClient) {
    _instance ??= PropertyApiService._(apiClient);
    return _instance!;
  }

  /// Get all properties (approved only)
  /// GET /$role/properties (e.g., /agent/properties)
  Future<List<PropertyModel>> getProperties({
    required String role, // 'agent' or 'agency'
    int? id,
  }) async {
    try {
      final queryParams = <String, dynamic>{};
      if (id != null) queryParams['id'] = id;

      // Reduced logging: Only log essential info
      if (id != null) {
        debugPrint(
          'PropertyApiService: getProperties called with role=$role, id=$id',
        );
      }
      final response = await _apiClient.get(
        '/$role/properties',
        queryParameters: queryParams,
      );
      final data = response.data;

      // Log the actual URL that was called
      debugPrint(
        'PropertyApiService: API URL called: ${response.requestOptions.uri}',
      );

      List<dynamic> propertiesList = [];

      if (data is Map<String, dynamic>) {
        // Handle response structure: { "success": true, "data": { "properties": [...] } }
        if (data['data'] != null && data['data'] is Map<String, dynamic>) {
          final dataValue = data['data'] as Map<String, dynamic>;
          if (dataValue['properties'] != null &&
              dataValue['properties'] is List) {
            propertiesList = dataValue['properties'] as List;
            debugPrint(
              'PropertyApiService: Found ${propertiesList.length} properties in data.properties',
            );
          }
        }
        // Fallback: check top-level properties
        else if (data['properties'] != null && data['properties'] is List) {
          propertiesList = data['properties'] as List;
          debugPrint(
            'PropertyApiService: Found ${propertiesList.length} properties in top-level properties',
          );
        }
        // Fallback: check if data itself is a list
        else if (data['data'] is List) {
          propertiesList = data['data'] as List;
          debugPrint(
            'PropertyApiService: Found ${propertiesList.length} properties in data (list)',
          );
        }
      } else if (data is List) {
        propertiesList = data;
        debugPrint(
          'PropertyApiService: Response is a list with ${propertiesList.length} properties',
        );
      }

      debugPrint(
        'PropertyApiService: Found ${propertiesList.length} properties in response',
      );

      if (propertiesList.isEmpty) {
        debugPrint('PropertyApiService: No properties found in response');
        return [];
      }

      // Only log first property summary (not all details) to reduce verbosity
      if (propertiesList.first is Map<String, dynamic>) {
        final firstProp = propertiesList.first as Map<String, dynamic>;
        debugPrint(
          'PropertyApiService: First property ID: ${firstProp['id']}, has specs: ${firstProp['specs'] != null}, has location: ${firstProp['location'] != null}',
        );
      }

      final properties = propertiesList
          .map((json) {
            try {
              if (json is Map<String, dynamic>) {
                final property = PropertyModel.fromJson(json);
                // Only log errors, not successful parsing (too verbose for lists)
                return property;
              }
              debugPrint('PropertyApiService: Skipping non-map property entry');
              return null;
            } catch (e, stackTrace) {
              debugPrint(
                'PropertyApiService: Error parsing property: $e\n$stackTrace',
              );
              return null;
            }
          })
          .whereType<PropertyModel>()
          .toList();

      // Summary log only
      debugPrint(
        'PropertyApiService: Successfully parsed ${properties.length} properties',
      );
      if (properties.isNotEmpty) {
        // Log all property IDs if an ID was requested
        if (id != null) {
          debugPrint('PropertyApiService: Requested property ID: $id');
          debugPrint(
            'PropertyApiService: All property IDs in response: ${properties.map((p) => p.id).toList()}',
          );
          // Find the matching property
          final matchingProperty = properties.where((p) => p.id == id).toList();
          if (matchingProperty.isEmpty) {
            debugPrint(
              'PropertyApiService: WARNING - No property found with ID $id in response!',
            );
          } else {
            debugPrint(
              'PropertyApiService: Found ${matchingProperty.length} property(ies) matching ID $id',
            );
          }
        }
        // Summary only - don't log all details for each property
        final firstProperty = properties.first;
        debugPrint(
          'PropertyApiService: Summary - ID: ${firstProperty.id}, specs: ${firstProperty.specs != null}, location: ${firstProperty.propertyLocation != null}, images: ${firstProperty.images?.length ?? 0}, floorPlans: ${firstProperty.floorPlans?.length ?? 0}',
        );
      }
      return properties;
    } catch (e) {
      throw Exception('Failed to get properties: $e');
    }
  }

  /// Get property status
  /// GET /agent/properties/{id}/status or /agent/property/{id}/status
  Future<PropertyModel> getPropertyStatus({
    required String role,
    required int propertyId,
  }) async {
    try {
      // Try both possible endpoints if needed, but usually it's plural for agent stuff
      debugPrint(
        'PropertyApiService: getPropertyStatus called with role=$role, propertyId=$propertyId',
      );
      final response = await _apiClient.get(
        '/$role/properties/$propertyId/status',
      );
      final data = response.data as Map<String, dynamic>;

      debugPrint('PropertyApiService: Response data keys: ${data.keys}');
      if (data['property'] != null &&
          data['property'] is Map<String, dynamic>) {
        final propertyMap = data['property'] as Map<String, dynamic>;
        debugPrint(
          'PropertyApiService: Property ID in response: ${propertyMap['id']}',
        );
      }

      final propertyData = data['property'] is Map<String, dynamic>
          ? data['property'] as Map<String, dynamic>
          : data['data'] is Map<String, dynamic>
          ? data['data'] as Map<String, dynamic>
          : data;

      final property = PropertyModel.fromJson(propertyData);
      debugPrint('PropertyApiService: Parsed property ID: ${property.id}');
      return property;
    } catch (e) {
      // Fallback to singular if plural fails
      try {
        final response = await _apiClient.get(
          '/$role/property/$propertyId/status',
        );
        final data = response.data as Map<String, dynamic>;
        final propertyData = data['property'] is Map<String, dynamic>
            ? data['property'] as Map<String, dynamic>
            : data;
        return PropertyModel.fromJson(propertyData);
      } catch (_) {
        throw Exception('Failed to get property status: $e');
      }
    }
  }

  /// Save a new property using unified endpoint
  /// POST /agent/properties
  /// This replaces the old multi-step process (createProperty + createPropertySpecs + createPropertyLocation)
  Future<PropertyModel> saveProperty({
    required String role,
    required Map<String, dynamic> data,
  }) async {
    try {
      final response = await _apiClient.post('/$role/properties', data: data);
      final apiResponse = ApiResponse<Map<String, dynamic>>.fromJson(
        response.data as Map<String, dynamic>,
        (data) => data as Map<String, dynamic>,
      );
      if (!apiResponse.success || apiResponse.data == null) {
        throw Exception(apiResponse.message ?? 'Failed to create property');
      }
      return PropertyModel.fromJson(apiResponse.data!);
    } catch (e) {
      if (e is DioException) {
        throw Exception(ApiResponseService.getErrorMessage(e));
      }
      throw Exception('Failed to create property: $e');
    }
  }

  /// @deprecated Use createProperty with unified payload instead
  /// Create a new property (with optional photos)
  /// POST /agent/properties/create
  @Deprecated('Use createProperty with unified payload instead')
  Future<PropertyModel> createPropertyLegacy({
    required String role,
    required String built,
    Map<String, dynamic>? otherFields,
    List<XFile>? photos,
  }) async {
    try {
      if (photos != null && photos.isNotEmpty) {
        final formData = FormData.fromMap({
          'built': built,
          if (otherFields != null) ...otherFields,
        });

        for (var photo in photos) {
          final bytes = await photo.readAsBytes();
          formData.files.add(
            MapEntry(
              'photos[]',
              MultipartFile.fromBytes(bytes, filename: photo.name),
            ),
          );
        }

        final response = await _apiClient.post(
          '/$role/properties/create',
          data: formData,
          options: Options(contentType: 'multipart/form-data'),
        );
        final apiResponse = ApiResponse<Map<String, dynamic>>.fromJson(
          response.data as Map<String, dynamic>,
          (data) => data as Map<String, dynamic>,
        );
        if (!apiResponse.success || apiResponse.data == null) {
          throw Exception(apiResponse.message ?? 'Failed to create property');
        }
        return PropertyModel.fromJson(apiResponse.data!);
      } else {
        final response = await _apiClient.post(
          '/$role/properties/create',
          data: {'built': built, if (otherFields != null) ...otherFields},
        );
        final apiResponse = ApiResponse<Map<String, dynamic>>.fromJson(
          response.data as Map<String, dynamic>,
          (data) => data as Map<String, dynamic>,
        );
        if (!apiResponse.success || apiResponse.data == null) {
          throw Exception(apiResponse.message ?? 'Failed to create property');
        }
        return PropertyModel.fromJson(apiResponse.data!);
      }
    } catch (e) {
      if (e is DioException) {
        throw Exception(ApiResponseService.getErrorMessage(e));
      }
      throw Exception('Failed to create property: $e');
    }
  }

  /// @deprecated Use createProperty or updateProperty with unified payload instead
  /// Create property specs
  /// POST /agent/properties/create/specs
  @Deprecated(
    'Use createProperty or updateProperty with unified payload instead',
  )
  Future<Map<String, dynamic>> createPropertySpecs({
    required int propertyId,
    int? bedrooms,
    int? bathrooms,
    double? price,
    String? name,
    int? garage,
    String? type,
    String? status,
    String? address,
    String? description,
    double? landSize,
    double? buildingSize,
    String? houseColor,
    String? availableFrom,
    Map<String, dynamic>? specifications,
    Map<String, List<String>>? specificationValues,
  }) async {
    try {
      print("specifications: $specifications");
      print("specificationValues: $specificationValues");
      final data = <String, dynamic>{'property_id': propertyId};
      if (bedrooms != null) data['bedrooms'] = bedrooms;
      if (bathrooms != null) data['bathrooms'] = bathrooms;
      if (price != null) data['price'] = price;
      if (name != null) data['name'] = name;
      if (garage != null) data['garage'] = garage;
      if (type != null) data['type'] = type;
      if (status != null) data['status'] = status;
      if (address != null) data['address'] = address;
      if (description != null) data['description'] = description;
      if (landSize != null) data['land_size'] = landSize;
      if (buildingSize != null) data['building_size'] = buildingSize;
      if (houseColor != null) data['house_color'] = houseColor;
      if (availableFrom != null) data['available_from'] = availableFrom;
      if (specifications != null) data['specifications'] = specifications;
      if (specificationValues != null) {
        data['specification_values'] = specificationValues;
      }

      print("data: ${data.toString()}");

      final response = await _apiClient.post(
        '/agent/properties/create/specs',
        data: data,
      );

      return response.data as Map<String, dynamic>;
    } catch (e) {
      if (e is DioException) {
        throw Exception(ApiResponseService.getErrorMessage(e));
      }
      throw Exception('Failed to create property specs: $e');
    }
  }

  /// @deprecated Use createProperty or updateProperty with unified payload instead
  /// Create property location
  /// POST /agent/properties/create/location
  @Deprecated(
    'Use createProperty or updateProperty with unified payload instead',
  )
  Future<Map<String, dynamic>> createPropertyLocation({
    required int propertyId,
    String? number,
    String? city,
    double? latitude,
    double? longitude,
    String? direction,
    String? state,
    String? country,
    String? postalCode,
  }) async {
    try {
      final data = <String, dynamic>{'property_id': propertyId};
      if (number != null) data['number'] = number;
      if (city != null) data['city'] = city;
      if (latitude != null) data['latitude'] = latitude;
      if (longitude != null) data['longitude'] = longitude;
      if (direction != null) data['direction'] = direction;
      if (state != null) data['state'] = state;
      if (country != null) data['country'] = country;
      if (postalCode != null) data['postal_code'] = postalCode;

      final response = await _apiClient.post(
        '/agent/properties/create/location',
        data: data,
      );
      return response.data as Map<String, dynamic>;
    } catch (e) {
      if (e is DioException) {
        throw Exception(ApiResponseService.getErrorMessage(e));
      }
      throw Exception('Failed to create property location: $e');
    }
  }

  /// Upload photos for a property
  /// POST /agent/upload/photos or /agency/upload/photos
  ///
  /// Expected format:
  /// - property_id: {{property_id}}
  /// - photos[0][file]: {{file image}}
  /// - photos[0][tag]: gallery
  /// - photos[0][facing_direction]: N (Optional: N, NE, E, SE, S, SW, W, NW)
  Future<Map<String, dynamic>> uploadPhotos({
    required String role,
    required int propertyId,
    required List<PhotoUploadData> photos,
  }) async {
    try {
      final formData = FormData.fromMap({'property_id': propertyId});

      // Add each photo with array index format
      for (int i = 0; i < photos.length; i++) {
        final photo = photos[i];
        final filename = photo.file.name;

        // Read file bytes (works on both web and mobile)
        final bytes = await photo.file.readAsBytes();

        // Add file: photos[0][file], photos[1][file], etc.
        // Use fromBytes for cross-platform compatibility
        formData.files.add(
          MapEntry(
            'photos[$i][file]',
            MultipartFile.fromBytes(bytes, filename: filename),
          ),
        );

        // Add tag: photos[0][tag], photos[1][tag], etc.
        formData.fields.add(MapEntry('photos[$i][tag]', photo.tag));

        // Add facing_direction if provided: photos[0][facing_direction], etc.
        if (photo.facingDirection != null &&
            photo.facingDirection!.isNotEmpty) {
          formData.fields.add(
            MapEntry('photos[$i][facing_direction]', photo.facingDirection!),
          );
        }
      }

      debugPrint(
        'PropertyApiService: Uploading ${photos.length} photos for property $propertyId',
      );

      final response = await _apiClient.post(
        '/$role/upload/photos',
        data: formData,
        options: Options(contentType: 'multipart/form-data'),
      );
      return response.data as Map<String, dynamic>;
    } catch (e) {
      print("Failed to upload photos: $e");
      if (e is DioException) {
        throw Exception(ApiResponseService.getErrorMessage(e));
      }
      throw Exception('Failed to upload photos: $e');
    }
  }

  /// Upload photos for a property (convenience method with simple XFile list)
  /// Automatically creates PhotoUploadData with default tag 'gallery'
  Future<Map<String, dynamic>> uploadPhotosSimple({
    required String role,
    required int propertyId,
    required List<XFile> photos,
    String tag = 'gallery',
    String? facingDirection,
  }) async {
    final photoData = photos
        .map(
          (file) => PhotoUploadData(
            file: file,
            tag: tag,
            facingDirection: facingDirection,
          ),
        )
        .toList();

    return uploadPhotos(role: role, propertyId: propertyId, photos: photoData);
  }

  /// Refresh photo URLs (for S3 URLs that expired)
  /// POST /agent/refresh/photo-urls or /agency/refresh/photo-urls
  Future<Map<String, dynamic>> refreshPhotoUrls({
    required String role,
    required int propertyId,
  }) async {
    try {
      final response = await _apiClient.post(
        '/$role/refresh/photo-urls',
        data: {'property_id': propertyId},
      );
      return response.data as Map<String, dynamic>;
    } catch (e) {
      throw Exception('Failed to refresh photo URLs: $e');
    }
  }

  /// Track property click
  /// POST /properties/{property}/track-click
  Future<Map<String, dynamic>> trackClick({required int propertyId}) async {
    try {
      final response = await _apiClient.post(
        '/properties/$propertyId/track-click',
      );
      return response.data as Map<String, dynamic>;
    } catch (e) {
      throw Exception('Failed to track click: $e');
    }
  }

  /// Track property view
  /// POST /properties/{property}/track-view
  Future<Map<String, dynamic>> trackView({required int propertyId}) async {
    try {
      final response = await _apiClient.post(
        '/properties/$propertyId/track-view',
      );
      return response.data as Map<String, dynamic>;
    } catch (e) {
      throw Exception('Failed to track view: $e');
    }
  }

  /// Debug property performance data
  /// GET /api/debug/property/{property}/performance
  Future<Map<String, dynamic>> debugPerformance({
    required int propertyId,
  }) async {
    try {
      final response = await _apiClient.get(
        '/api/debug/property/$propertyId/performance',
      );
      return response.data as Map<String, dynamic>;
    } catch (e) {
      throw Exception('Failed to get performance data: $e');
    }
  }

  /// Get nearby properties by coordinates
  /// GET /api/properties/nearby?lat={lat}&lng={lng}&radius={radius}
  Future<List<PropertyModel>> getNearbyProperties({
    required double latitude,
    required double longitude,
    double radius = 0.01,
    int limit = 10,
  }) async {
    try {
      final queryParams = {
        'lat': latitude.toString(),
        'lng': longitude.toString(),
        'radius': radius.toString(),
        'limit': limit.toString(),
      };

      final response = await _apiClient.get(
        '/api/properties/nearby',
        queryParameters: queryParams,
      );

      if (response.data['success'] == true) {
        final properties = (response.data['properties'] as List)
            .map((json) => PropertyModel.fromJson(json))
            .toList();
        return properties;
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  /// Get property by ID (public endpoint)
  /// GET /api/properties/{id}
  Future<PropertyModel?> getPropertyById(int propertyId) async {
    try {
      final response = await _apiClient.get('/api/properties/$propertyId');
      if (response.data['success'] == true) {
        return PropertyModel.fromJson(response.data['property']);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  /// Delete a property
  /// DELETE /agent/properties/{id}
  Future<void> deleteProperty({
    required String role,
    required int propertyId,
  }) async {
    try {
      await _apiClient.delete('/$role/properties/$propertyId');
    } catch (e) {
      throw Exception('Failed to delete property: $e');
    }
  }

  /// Get developers (master data)
  /// GET /public/developers
  Future<List<Developer>> getDevelopers() async {
    try {
      final response = await _apiClient.get('/public/developers');

      final apiResponse =
          ApiResponseService.parseResponse<Map<String, dynamic>>(response, (
            json,
          ) {
            if (json is Map<String, dynamic>) {
              return json;
            }
            return <String, dynamic>{};
          });

      if (!apiResponse.success || apiResponse.data == null) {
        return [];
      }

      // Extract developers from nested data.developers structure
      final data = apiResponse.data!;
      if (data['developers'] is List) {
        final developersList = data['developers'] as List;
        return developersList
            .map((item) => Developer.fromJson(item as Map<String, dynamic>))
            .toList();
      }

      return [];
    } catch (e) {
      debugPrint('Error getting developers: $e');
      return [];
    }
  }

  /// Get condo projects (master data)
  /// GET /public/condo-projects?developer_id={developerId}&q={query}
  Future<List<CondoProject>> getCondoProjects({
    int? developerId,
    String? query,
  }) async {
    try {
      final queryParams = <String, dynamic>{};
      if (developerId != null) queryParams['developer_id'] = developerId;
      if (query != null && query.isNotEmpty) queryParams['q'] = query;

      final response = await _apiClient.get(
        '/public/condo-projects',
        queryParameters: queryParams,
      );

      // Response structure:
      // {
      //   "success": true,
      //   "data": {
      //     "condo_projects": [ ... ],
      //     "count": 154
      //   }
      // }
      final apiResponse =
          ApiResponseService.parseResponse<Map<String, dynamic>>(response, (
            json,
          ) {
            if (json is Map<String, dynamic>) {
              return json;
            }
            return <String, dynamic>{};
          });

      if (!apiResponse.success || apiResponse.data == null) {
        return [];
      }

      final data = apiResponse.data!;
      if (data['condo_projects'] is List) {
        final list = data['condo_projects'] as List;
        return list
            .map((item) => CondoProject.fromJson(item as Map<String, dynamic>))
            .toList();
      }

      return [];
    } catch (e) {
      debugPrint('Error getting condo projects: $e');
      return [];
    }
  }

  /// Set condo details for a property
  /// POST /agent/properties/{propertyId}/condo-details
  Future<void> setCondoDetails({
    required int propertyId,
    required int condoProjectId,
    String? tower,
    String? floor,
    String? unitNo,
  }) async {
    try {
      final data = <String, dynamic>{'condo_project_id': condoProjectId};
      if (tower != null && tower.isNotEmpty) data['tower'] = tower;
      if (floor != null && floor.isNotEmpty) data['floor'] = floor;
      if (unitNo != null && unitNo.isNotEmpty) data['unit_no'] = unitNo;

      final response = await _apiClient.post(
        '/agent/properties/$propertyId/condo-details',
        data: data,
      );

      final apiResponse = ApiResponseService.parseResponse<void>(
        response,
        null,
      );

      if (!apiResponse.success) {
        throw Exception(apiResponse.message ?? 'Failed to set condo details');
      }
    } catch (e) {
      if (e is DioException && e.response != null) {
        final errorMessage = ApiResponseService.getErrorMessage(e);
        throw Exception(errorMessage);
      }
      throw Exception('Failed to set condo details: $e');
    }
  }

  /// Set house details for a property
  /// POST /agent/properties/{propertyId}/house-details
  Future<void> setHouseDetails({
    required int propertyId,
    String? villageName,
    String? moo,
    String? houseSubtype,
    String? parkingType,
    bool? isCornerPlot,
    String? notes,
  }) async {
    try {
      final data = <String, dynamic>{};
      if (villageName != null && villageName.isNotEmpty) {
        data['village_name'] = villageName;
      }
      if (moo != null && moo.isNotEmpty) data['moo'] = moo;
      if (houseSubtype != null && houseSubtype.isNotEmpty) {
        data['house_subtype'] = houseSubtype;
      }
      if (parkingType != null && parkingType.isNotEmpty) {
        data['parking_type'] = parkingType;
      }
      if (isCornerPlot != null) data['is_corner_plot'] = isCornerPlot;
      if (notes != null && notes.isNotEmpty) data['notes'] = notes;

      final response = await _apiClient.post(
        '/agent/properties/$propertyId/house-details',
        data: data,
      );

      final apiResponse = ApiResponseService.parseResponse<void>(
        response,
        null,
      );

      if (!apiResponse.success) {
        throw Exception(apiResponse.message ?? 'Failed to set house details');
      }
    } catch (e) {
      if (e is DioException && e.response != null) {
        final errorMessage = ApiResponseService.getErrorMessage(e);
        throw Exception(errorMessage);
      }
      throw Exception('Failed to set house details: $e');
    }
  }

  /// Get public filter info
  /// GET /public/info
  Future<PropertyFilterOptions> getPublicFilterInfo() async {
    try {
      final response = await _apiClient.get('/public/info');
      final data = response.data as Map<String, dynamic>;

      if (data['success'] == true && data['data'] != null) {
        final filtersData = data['data']['filters'] as Map<String, dynamic>;
        return PropertyFilterOptions.fromJson(filtersData);
      }

      throw Exception('Invalid response format from /public/info');
    } catch (e) {
      if (e is DioException) {
        throw Exception(ApiResponseService.getErrorMessage(e));
      }
      throw Exception('Failed to get filter info: $e');
    }
  }
}
