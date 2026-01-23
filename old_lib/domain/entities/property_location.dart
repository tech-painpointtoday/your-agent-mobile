import 'package:equatable/equatable.dart';

/// PropertyLocation entity matching the old Laravel PropertyLocation model
class PropertyLocation extends Equatable {
  final int? id;
  final int propertyId;
  final String? number; // House number (raw)
  final Map<String, dynamic>?
      computedNumber; // Computed number from splitNumbers
  final String? computedHouseNumber;
  final String? city;
  final String? state;
  final String? district;
  final String? province;
  final String? subdistrict;
  final String? soi;
  final String? road;
  final String? country;
  final String? postalCode;
  final double? latitude;
  final double? longitude;
  final String? direction; // PropertyDirection enum
  final String? formattedAddressTh;
  final String? formattedAddressEn;
  final String? addressLine1;

  const PropertyLocation({
    this.id,
    required this.propertyId,
    this.number,
    this.computedNumber,
    this.computedHouseNumber,
    this.city,
    this.state,
    this.district,
    this.province,
    this.subdistrict,
    this.soi,
    this.road,
    this.country,
    this.postalCode,
    this.latitude,
    this.longitude,
    this.direction,
    this.formattedAddressTh,
    this.formattedAddressEn,
    this.addressLine1,
  });

  factory PropertyLocation.fromJson(Map<String, dynamic> json) {
    // Handle number field - can be a string or an object
    String? numberString;
    Map<String, dynamic>? computedNumber;

    if (json['number'] != null) {
      if (json['number'] is String) {
        // If number is a string, use it directly
        numberString = json['number'] as String;
      } else if (json['number'] is Map<String, dynamic>) {
        // If number is an object, extract original and store the full object
        final numberObj = json['number'] as Map<String, dynamic>;
        numberString = numberObj['original'] as String?;
        computedNumber = numberObj; // Store the full number object
      }
    }

    // Also check for computed_number field (fallback)
    if (computedNumber == null && json['computed_number'] != null) {
      computedNumber = json['computed_number'] as Map<String, dynamic>?;
    }

    return PropertyLocation(
      id: json['id'] as int?,
      propertyId: json['property_id'] as int,
      number: numberString,
      computedNumber: computedNumber,
      computedHouseNumber: json['computed_house_number'] as String?,
      city: json['city'] as String?,
      state: json['state'] as String?,
      district: json['district'] as String?,
      province: json['province'] as String?,
      subdistrict: json['subdistrict'] as String?,
      soi: json['soi'] as String?,
      road: json['road'] as String?,
      country: json['country'] as String?,
      postalCode: json['postal_code'] as String?,
      latitude: json['latitude'] != null
          ? double.tryParse(json['latitude'].toString())
          : null,
      longitude: json['longitude'] != null
          ? double.tryParse(json['longitude'].toString())
          : null,
      direction: json['direction'] as String?,
      formattedAddressTh: json['formatted_address_th'] as String?,
      formattedAddressEn: json['formatted_address_en'] as String?,
      addressLine1: json['address_line1'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'property_id': propertyId,
      'number': number,
      'computed_number': computedNumber,
      'computed_house_number': computedHouseNumber,
      'city': city,
      'state': state,
      'district': district,
      'province': province,
      'subdistrict': subdistrict,
      'soi': soi,
      'road': road,
      'country': country,
      'postal_code': postalCode,
      'latitude': latitude,
      'longitude': longitude,
      'direction': direction,
      'formatted_address_th': formattedAddressTh,
      'formatted_address_en': formattedAddressEn,
      'address_line1': addressLine1,
    };
  }

  // Get final computed number result (for house number matching)
  int? get finalComputedNumber {
    if (computedNumber != null) {
      return computedNumber!['final_result'] as int?;
    }
    if (computedHouseNumber != null) {
      return int.tryParse(computedHouseNumber!);
    }
    return null;
  }

  @override
  List<Object?> get props => [
    id,
    propertyId,
    number,
    computedNumber,
    computedHouseNumber,
    city,
    state,
        district,
        province,
        subdistrict,
        soi,
        road,
    country,
    postalCode,
    latitude,
    longitude,
    direction,
        formattedAddressTh,
        formattedAddressEn,
        addressLine1,
  ];
}
