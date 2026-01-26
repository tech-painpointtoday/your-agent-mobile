import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapMarkerUtils {
  static BitmapDescriptor? _cachedMarkerIcon;

  static Future<BitmapDescriptor> createCustomMarkerIcon({
    String assetPath = 'assets/icons/map-marker-filled.svg',
  }) async {
    if (_cachedMarkerIcon != null) {
      return _cachedMarkerIcon!;
    }

    try {
      // For now, use default marker - SVG parsing requires additional dependencies
      // TODO: Implement proper SVG to BitmapDescriptor conversion
      return BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed);
    } catch (e) {
      debugPrint('Error loading marker: $e');
      return BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed);
    }
  }

  static void clearCache() {
    _cachedMarkerIcon = null;
  }
}
