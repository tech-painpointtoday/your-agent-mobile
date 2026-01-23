import 'dart:math' as math;

import 'package:dio/dio.dart';
import 'package:youragent/core/config/app_config.dart';
import 'package:youragent/data/models/nearby_place.dart';

class PlacesService {
  PlacesService({
    Dio? client,
    String? apiKey,
    this.defaultLanguage = 'th',
    this.defaultRadiusMeters = 2000,
  }) : _apiKey = apiKey ?? AppConfig.googleMapsApiKey,
       _client =
           client ??
           Dio(
             BaseOptions(
               baseUrl: 'https://maps.googleapis.com/maps/api/place',
               connectTimeout: const Duration(seconds: 10),
               receiveTimeout: const Duration(seconds: 10),
             ),
           );

  final Dio _client;
  final String _apiKey;
  final String defaultLanguage;
  final int defaultRadiusMeters;

  bool get hasApiKey => _apiKey.isNotEmpty;

  /// Maximum distance in meters (5km) - matches PHP service
  static const int maxDistanceMeters = 5000;

  /// Facility types mapping - matches PHP service
  static const Map<String, List<String>> facilityTypeMapping = {
    'travel': ['bus_station', 'subway_station', 'transit_station'],
    'shopping': ['shopping_mall', 'department_store', 'supermarket'],
    'education': ['school'],
  };

  /// Reverse geocode coordinates to get address components
  /// Returns a map with keys:
  /// - address (formatted address)
  /// - district, subdistrict, state, country, postalCode
  /// - houseNumber, soi, road (best-effort from Google address_components)
  Future<Map<String, String?>> reverseGeocode({
    required double lat,
    required double lng,
    String? language,
  }) async {
    if (!hasApiKey) {
      return {};
    }

    try {
      final geocodeClient = Dio(
        BaseOptions(
          baseUrl: 'https://maps.googleapis.com/maps/api/geocode',
          connectTimeout: const Duration(seconds: 10),
          receiveTimeout: const Duration(seconds: 10),
        ),
      );

      final response = await geocodeClient.get(
        '/json',
        queryParameters: {
          'latlng': '$lat,$lng',
          'language': language ?? defaultLanguage,
          'key': _apiKey,
        },
      );

      final data = response.data as Map<String, dynamic>? ?? {};
      final status = data['status'] as String?;

      if (status != 'OK') {
        return {};
      }

      final results = (data['results'] as List?) ?? [];

      if (results.isEmpty) return {};

      // Step 1: Parse the first result (most specific) to get specific details
      final firstResult = results[0] as Map<String, dynamic>;
      final firstComponents = (firstResult['address_components'] as List?) ?? [];

      String? address;
      String? city;
      String? district;
      String? subdistrict;
      String? state;
      String? country;
      String? postalCode;
      String? houseNumber;
      String? road;
      String? soi;

      // Extract formatted address from first result
      address = firstResult['formatted_address'] as String?;

      // Parse address components from first result (most specific)
      // For Thailand:
      // - administrative_area_level_1 = Province (จังหวัด)
      // - administrative_area_level_2 = District (เขต/อำเภอ)
      // - sublocality_level_1 or locality = Subdistrict (แขวง/ตำบล)
      for (final component in firstComponents) {
        final types = (component['types'] as List?)?.cast<String>() ?? [];
        final longName = component['long_name'] as String?;

        if (types.contains('administrative_area_level_2')) {
          // District (เขต/อำเภอ)
          district = longName;
          city ??= longName; // fallback for city
        } else if (types.contains('sublocality_level_1') ||
            types.contains('locality')) {
          // Subdistrict (แขวง/ตำบล)
          subdistrict = longName;
        } else if (types.contains('sublocality_level_2') ||
            types.contains('neighborhood')) {
          // Often maps to "Soi" / neighborhood (best-effort)
          soi ??= longName;
        } else if (types.contains('administrative_area_level_1')) {
          state = longName;
        } else if (types.contains('country')) {
          country = longName;
        } else if (types.contains('postal_code')) {
          postalCode = longName;
        } else if (types.contains('street_number')) {
          // House number
          houseNumber ??= longName;
        } else if (types.contains('route')) {
          // Road
          road ??= longName;
        } else if (types.contains('premise')) {
          // Building / premise number (fallback for house number)
          houseNumber ??= longName;
        } else if (types.contains('subpremise')) {
          // Unit / room (fallback for house number if missing)
          houseNumber ??= longName;
        }
      }

      // Step 2: Fallback search for missing critical fields
      // If critical fields are missing, search through remaining results
      final criticalFieldsMissing = postalCode == null ||
          subdistrict == null ||
          district == null ||
          state == null;

      if (criticalFieldsMissing && results.length > 1) {
        // Iterate through remaining results (from index 1 to end)
        for (int i = 1; i < results.length; i++) {
          final result = results[i] as Map<String, dynamic>;
          final components = (result['address_components'] as List?) ?? [];

          // Check if we've found all critical fields
          if (postalCode != null &&
              subdistrict != null &&
              district != null &&
              state != null) {
            // All critical fields found, stop searching
            break;
          }

          // Parse components from this result to fill missing fields
          for (final component in components) {
            final types = (component['types'] as List?)?.cast<String>() ?? [];
            final longName = component['long_name'] as String?;

            // Only fill fields that are still null
            if (postalCode == null && types.contains('postal_code')) {
              postalCode = longName;
            }
            if (subdistrict == null &&
                (types.contains('sublocality_level_1') ||
                    types.contains('locality'))) {
              subdistrict = longName;
            }
            if (district == null &&
                types.contains('administrative_area_level_2')) {
              district = longName;
              city ??= longName; // fallback for city
            }
            if (state == null && types.contains('administrative_area_level_1')) {
              state = longName;
            }
            if (country == null && types.contains('country')) {
              country = longName;
            }

            // Stop if postalCode is found (highest priority)
            if (postalCode != null &&
                subdistrict != null &&
                district != null &&
                state != null) {
              break;
            }
          }

          // Stop outer loop if all critical fields are found
          if (postalCode != null &&
              subdistrict != null &&
              district != null &&
              state != null) {
            break;
          }
        }
      }

      return {
        'address': address,
        'city': city,
        'district': district,
        'subdistrict': subdistrict,
        'state': state,
        'country': country,
        'postalCode': postalCode,
        'houseNumber': houseNumber,
        'soi': soi,
        'road': road,
      };
    } catch (e) {
      return {};
    }
  }

  /// Geocode address text to get coordinates
  /// Returns a map with keys: lat, lng, formattedAddress
  Future<Map<String, dynamic>> geocode({
    required String address,
    String? language,
  }) async {
    if (!hasApiKey || address.isEmpty) {
      return {};
    }

    try {
      final geocodeClient = Dio(
        BaseOptions(
          baseUrl: 'https://maps.googleapis.com/maps/api/geocode',
          connectTimeout: const Duration(seconds: 10),
          receiveTimeout: const Duration(seconds: 10),
        ),
      );

      final response = await geocodeClient.get(
        '/json',
        queryParameters: {
          'address': address,
          'language': language ?? defaultLanguage,
          'key': _apiKey,
        },
      );

      final data = response.data as Map<String, dynamic>? ?? {};
      final status = data['status'] as String?;

      if (status != 'OK') {
        return {};
      }

      final results = (data['results'] as List?) ?? [];

      if (results.isEmpty) return {};

      // Get the first result (most relevant)
      final result = results[0] as Map<String, dynamic>;
      final location = result['geometry']?['location'] as Map<String, dynamic>?;

      if (location == null) return {};

      final lat = location['lat']?.toDouble();
      final lng = location['lng']?.toDouble();
      final formattedAddress = result['formatted_address'] as String?;

      if (lat == null || lng == null) return {};

      return {'lat': lat, 'lng': lng, 'formattedAddress': formattedAddress};
    } catch (e) {
      return {};
    }
  }

  /// Fetch nearby places for a category (travel, shopping, education)
  /// Combines multiple facility types per category
  /// Fetches ALL places within radius (no limit)
  Future<List<NearbyPlace>> fetchNearbyByCategory({
    required double lat,
    required double lng,
    required String category,
    int? radiusMeters,
    String? language,
  }) async {
    if (!hasApiKey) return [];

    final types = facilityTypeMapping[category] ?? [];
    if (types.isEmpty) return [];

    final radius = radiusMeters ?? defaultRadiusMeters;
    final lang = language ?? defaultLanguage;

    final allPlaces = <NearbyPlace>[];

    for (final type in types) {
      try {
        // Fetch all places (use high limit to get all results)
        final places = await fetchNearby(
          lat: lat,
          lng: lng,
          type: type,
          radiusMeters: radius,
          language: lang,
          limit: 60, // High limit to get all places in radius
        );
        allPlaces.addAll(places);

        // Small delay to avoid rate limits (matches PHP service)
        await Future.delayed(const Duration(milliseconds: 100));
      } catch (_) {
        // Continue with next type on error
      }
    }

    // Sort by distance and return all (no limit)
    allPlaces.sort((a, b) => a.distanceMeters.compareTo(b.distanceMeters));
    return allPlaces;
  }

  /// Fetch nearby places for a given [type] (e.g., 'transit_station', 'shopping_mall', 'school')
  Future<List<NearbyPlace>> fetchNearby({
    required double lat,
    required double lng,
    required String type,
    int? radiusMeters,
    String? language,
    int limit = 5,
  }) async {
    if (!hasApiKey) return [];

    final radius = radiusMeters ?? defaultRadiusMeters;
    final lang = language ?? defaultLanguage;

    try {
      final response = await _client.get(
        '/nearbysearch/json',
        queryParameters: {
          'location': '$lat,$lng',
          'radius': radius,
          'type': type,
          'language': lang,
          'key': _apiKey,
        },
      );

      final data = response.data as Map<String, dynamic>? ?? {};
      final status = data['status'] as String?;

      if (status != 'OK' && status != 'ZERO_RESULTS') {
        return [];
      }

      final results = (data['results'] as List?) ?? [];

      final places = results
          .map((item) => _mapPlace(item, lat, lng))
          .whereType<NearbyPlace>()
          .where((place) => place.distanceMeters <= maxDistanceMeters)
          .take(limit)
          .toList();

      return places;
    } catch (_) {
      return [];
    }
  }

  NearbyPlace? _mapPlace(
    Map<String, dynamic> json,
    double originLat,
    double originLng,
  ) {
    final nameRaw = json['name'] as String?;
    if (nameRaw == null) return null;

    final name = _cleanFacilityName(nameRaw);
    if (name == null || name.isEmpty) return null;

    final vicinity = json['vicinity'] as String?;
    final address = vicinity != null ? _cleanFacilityAddress(vicinity) : null;

    final location = json['geometry']?['location'] as Map<String, dynamic>?;
    final lat = location?['lat']?.toDouble();
    final lng = location?['lng']?.toDouble();
    if (lat == null || lng == null) return null;

    final distanceMeters = _haversineDistanceMeters(
      originLat,
      originLng,
      lat,
      lng,
    );

    // Skip if too far (matches PHP service)
    if (distanceMeters > maxDistanceMeters) return null;

    final rating = json['rating']?.toDouble();
    final userRatingsTotal = json['user_ratings_total'] as int?;

    return NearbyPlace(
      name: name,
      address: address,
      distanceMeters: distanceMeters.roundToDouble(),
      rating: rating,
      userRatingsTotal: userRatingsTotal,
    );
  }

  /// Calculate distance using Haversine formula - matches PHP service
  double _haversineDistanceMeters(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    const earthRadius = 6371000.0; // Earth's radius in meters
    final dLat = _degToRad(lat2 - lat1);
    final dLon = _degToRad(lon2 - lon1);
    final a =
        math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(_degToRad(lat1)) *
            math.cos(_degToRad(lat2)) *
            math.sin(dLon / 2) *
            math.sin(dLon / 2);
    final c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
    return earthRadius * c;
  }

  double _degToRad(double deg) => deg * (math.pi / 180.0);

  /// Clean and validate facility name - matches PHP service logic
  String? _cleanFacilityName(String name) {
    if (name.isEmpty) return null;

    // Remove extra whitespace
    var cleaned = name.trim();

    // Check if name contains too much non-Latin text
    final latinChars = RegExp(r'[a-zA-Z0-9\s]').allMatches(cleaned).length;
    final totalChars = cleaned.length;

    // If less than 30% Latin characters, clean it
    if (totalChars > 0 && (latinChars / totalChars) < 0.3) {
      // Extract just Thai/English part - allow Thai characters (U+0E00-U+0E7F), Latin, numbers, spaces, hyphens, dots
      cleaned = cleaned.replaceAll(
        RegExp(r'[^\u0E00-\u0E7Fa-zA-Z0-9\s\-\.]'),
        '',
      );
      cleaned = cleaned.trim();

      if (cleaned.length < 3) {
        return null; // Skip if too short after cleaning
      }
    }

    // Limit length to prevent overflow
    if (cleaned.length > 100) {
      cleaned = '${cleaned.substring(0, 97)}...';
    }

    return cleaned;
  }

  /// Clean facility address - matches PHP service logic
  String? _cleanFacilityAddress(String address) {
    if (address.isEmpty) return null;

    // Remove extra whitespace
    var cleaned = address.trim();

    // Clean up problematic characters - allow Thai characters (U+0E00-U+0E7F), Latin, numbers, spaces, hyphens, dots, commas
    cleaned = cleaned.replaceAll(
      RegExp(r'[^\u0E00-\u0E7Fa-zA-Z0-9\s\-\.\,]'),
      '',
    );
    cleaned = cleaned.trim();

    // Limit length
    if (cleaned.length > 150) {
      cleaned = '${cleaned.substring(0, 147)}...';
    }

    return cleaned;
  }
}
