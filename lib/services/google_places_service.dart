import 'dart:convert';

import 'package:dio/dio.dart';

class PlacePrediction {
  final String placeId;
  final String description;

  const PlacePrediction({required this.placeId, required this.description});
}

class PlaceResolvedLocation {
  final double lat;
  final double lng;
  final String formattedAddressEn;
  final Map<String, String> components;

  const PlaceResolvedLocation({
    required this.lat,
    required this.lng,
    required this.formattedAddressEn,
    required this.components,
  });
}

/// Google Places + Geocoding REST helper.
///
/// Uses existing `dio` dependency. Requires `apiKey`.
class GooglePlacesService {
  final Dio _dio;
  final String apiKey;

  GooglePlacesService({Dio? dio, required this.apiKey}) : _dio = dio ?? Dio();

  bool get isConfigured => apiKey.trim().isNotEmpty;

  Future<List<PlacePrediction>> autocomplete({
    required String input,
    String language = 'th',
    String components = 'country:th',
  }) async {
    if (!isConfigured) return const [];
    final uri = Uri.https(
      'maps.googleapis.com',
      '/maps/api/place/autocomplete/json',
      {
        'input': input,
        'language': language,
        'components': components,
        'key': apiKey,
      },
    );

    final res = await _dio.getUri(uri);
    final data = _ensureMap(res.data);
    final status = (data['status'] ?? '').toString();
    if (status != 'OK') return const [];

    final preds = (data['predictions'] as List? ?? const []);
    return preds
        .map((e) => e as Map)
        .map(
          (e) => PlacePrediction(
            placeId: (e['place_id'] ?? '').toString(),
            description: (e['description'] ?? '').toString(),
          ),
        )
        .where((p) => p.placeId.isNotEmpty)
        .toList(growable: false);
  }

  Future<PlaceResolvedLocation?> placeDetails({
    required String placeId,
    String language = 'en',
  }) async {
    if (!isConfigured) return null;
    final uri =
        Uri.https('maps.googleapis.com', '/maps/api/place/details/json', {
          'place_id': placeId,
          'fields': 'geometry,formatted_address,address_component',
          'language': language,
          'key': apiKey,
        });

    final res = await _dio.getUri(uri);
    final data = _ensureMap(res.data);
    final status = (data['status'] ?? '').toString();
    if (status != 'OK') return null;

    final result = (data['result'] as Map?) ?? const {};
    final geometry = (result['geometry'] as Map?) ?? const {};
    final loc = (geometry['location'] as Map?) ?? const {};
    final lat = (loc['lat'] as num?)?.toDouble();
    final lng = (loc['lng'] as num?)?.toDouble();
    if (lat == null || lng == null) return null;

    final formatted = (result['formatted_address'] ?? '').toString();
    final components = _mapAddressComponents(
      result['address_components'] as List?,
    );

    return PlaceResolvedLocation(
      lat: lat,
      lng: lng,
      formattedAddressEn: formatted,
      components: components,
    );
  }

  Future<PlaceResolvedLocation?> reverseGeocode({
    required double lat,
    required double lng,
    String language = 'en',
  }) async {
    if (!isConfigured) return null;
    final uri = Uri.https('maps.googleapis.com', '/maps/api/geocode/json', {
      'latlng': '$lat,$lng',
      'language': language,
      'region': 'th',
      'key': apiKey,
    });

    final res = await _dio.getUri(uri);
    final data = _ensureMap(res.data);
    final status = (data['status'] ?? '').toString();
    if (status != 'OK') return null;

    final results = (data['results'] as List? ?? const []);
    if (results.isEmpty) return null;

    final first = results.first as Map;
    final formatted = (first['formatted_address'] ?? '').toString();
    final components = _mapAddressComponents(
      first['address_components'] as List?,
    );

    return PlaceResolvedLocation(
      lat: lat,
      lng: lng,
      formattedAddressEn: formatted,
      components: components,
    );
  }

  Map<String, String> _mapAddressComponents(List? components) {
    final Map<String, String> out = {};
    if (components == null) return out;

    String? getByType(String type) {
      for (final c in components) {
        final m = c as Map;
        final types = (m['types'] as List? ?? const [])
            .map((e) => e.toString())
            .toList();
        if (types.contains(type)) {
          return (m['long_name'] ?? '').toString();
        }
      }
      return null;
    }

    // Thailand mapping heuristics (Google types)
    out['number'] = getByType('street_number') ?? '';

    String road = getByType('route') ?? '';
    String soi = getByType('sublocality_level_3') ?? '';

    // Optimization: Google often puts "Soi" in the "route" field for Thai addresses.
    // If detected, move it to the 'soi' field.
    if (road.contains('ซอย') || road.toLowerCase().contains('soi')) {
      if (soi.isEmpty) {
        soi = road;
      }
    }

    out['road'] = road;
    out['soi'] = soi;
    out['postal_code'] = getByType('postal_code') ?? '';
    out['province'] = getByType('administrative_area_level_1') ?? '';
    out['district'] =
        getByType('administrative_area_level_2') ??
        getByType('sublocality_level_2') ??
        '';
    // subdistrict often under sublocality_level_1 in Thailand
    out['subdistrict'] =
        getByType('sublocality_level_1') ?? getByType('sublocality') ?? '';
    out['city'] =
        getByType('locality') ?? getByType('sublocality_level_1') ?? '';
    out['state'] = out['province'] ?? '';

    return out;
  }

  Map<String, dynamic> _ensureMap(dynamic data) {
    if (data is Map<String, dynamic>) return data;
    if (data is Map) return data.map((k, v) => MapEntry(k.toString(), v));
    if (data is String) return jsonDecode(data) as Map<String, dynamic>;
    return const <String, dynamic>{};
  }
}
