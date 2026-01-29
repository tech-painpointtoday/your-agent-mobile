import 'dart:convert';
import 'package:flutter/services.dart';

class AddressLookupService {
  List<Map<String, dynamic>> _data = [];
  bool _isLoaded = false;

  Future<void> loadData() async {
    if (_isLoaded) return;
    try {
      final jsonString = await rootBundle.loadString(
        'assets/etc/thai_address.json',
      );
      final List<dynamic> jsonList = json.decode(jsonString);
      _data = jsonList.cast<Map<String, dynamic>>();
      _isLoaded = true;
    } catch (e) {
      // Handle error or log it
      print('Error loading thai_address.json: $e');
    }
  }

  /// Looks up address details based on available fields.
  /// Returns the first matching record found, or null if no match.
  ///
  /// Matching priority:
  /// 1. If 'district' (Tambon) is provided, it's usually the most granular.
  /// 2. If 'city' (Amphoe) is provided.
  /// 3. If 'province' is provided.
  /// 4. If 'postalCode' is provided.
  String _normalize(String input) {
    return input
        .replaceAll('แขวง', '')
        .replaceAll('เขต', '')
        .replaceAll('ตำบล', '')
        .replaceAll('อำเภอ', '')
        .replaceAll('จังหวัด', '')
        .trim();
  }

  /// Looks up address details based on available fields.
  /// Returns the first matching record found, or null if no match.
  Map<String, dynamic>? lookup({
    String? district,
    String? city,
    String? province,
    String? postalCode,
  }) {
    if (!_isLoaded || _data.isEmpty) return null;

    try {
      final normalizedDistrict = district != null ? _normalize(district) : '';
      final normalizedCity = city != null ? _normalize(city) : '';
      final normalizedProvince = province != null ? _normalize(province) : '';

      final candidates = _data.where((item) {
        bool match = true;

        if (postalCode != null && postalCode.isNotEmpty) {
          match = match && item['zipcode'].toString() == postalCode;
        }

        if (match && normalizedProvince.isNotEmpty) {
          match =
              match &&
              _normalize(
                item['province'].toString(),
              ).contains(normalizedProvince);
        }

        // If we have a subdistrict/district, try to match it against either field in JSON
        // because Google Maps results can sometimes be ambiguous between Khet/Khwaeng
        if (match &&
            (normalizedDistrict.isNotEmpty || normalizedCity.isNotEmpty)) {
          bool subMatch = false;

          if (normalizedDistrict.isNotEmpty) {
            subMatch =
                _normalize(
                  item['district'].toString(),
                ).contains(normalizedDistrict) ||
                _normalize(
                  item['amphoe'].toString(),
                ).contains(normalizedDistrict);
          }

          if (normalizedCity.isNotEmpty) {
            final cityMatch =
                _normalize(
                  item['district'].toString(),
                ).contains(normalizedCity) ||
                _normalize(item['amphoe'].toString()).contains(normalizedCity);
            subMatch = normalizedDistrict.isNotEmpty
                ? (subMatch && cityMatch)
                : cityMatch;
          }

          match = match && subMatch;
        }

        return match;
      }).toList();

      if (candidates.isNotEmpty) {
        // If we have multiple candidates and a perfect match for subdistrict exists, prefer it
        if (candidates.length > 1 && normalizedDistrict.isNotEmpty) {
          final perfectMatch = candidates.firstWhere(
            (c) => _normalize(c['district'].toString()) == normalizedDistrict,
            orElse: () => candidates.first,
          );
          return perfectMatch;
        }
        return candidates.first;
      }
    } catch (e) {
      print('Error looking up address: $e');
    }

    return null;
  }
}
