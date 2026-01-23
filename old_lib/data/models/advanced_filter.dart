/// Model for advanced filter data that can be easily passed to API
class AdvancedFilter {
  // Location filters
  final String? location;
  final String? landmark;
  final double? distanceKm; // Distance in kilometers

  // Property type
  final String? propertyType; // 'Condo' or 'House'

  // Price range (in THB)
  final double? priceMin;
  final double? priceMax;

  // Land size range (in ตร.วา - Thai square wah)
  final double? landSizeMin;
  final double? landSizeMax;

  // Usable area range (in ตร.ม. - square meters)
  final double? usableAreaMin;
  final double? usableAreaMax;

  // Number filters (single select)
  final String? floors; // e.g., '1+', '2+', '3+', '4+', '5+'
  final String? bedrooms; // e.g., '1+', '2+', '3+', '4+', '5+', '6+', '7+', '8+', 'สตูดิโอ+'
  final String? bathrooms; // e.g., '1+', '2+', '3+', '4+', '5+', '6+', '7+', '8+'
  final String? parking; // e.g., '1+', '2+', '3+', '4+', '5+', '6+', '7+', '8+'

  // Multi-select filters
  final List<String> commonFacilities; // e.g., ['ฟิตเนส', 'สระว่ายน้ำ', ...]
  final List<String> furniture; // e.g., ['ไม่มี', 'มีบางส่วน', 'ตกแต่งครบ']
  final List<String> airConditioning; // e.g., ['ไม่มี', 'ติดตั้งบางห้อง', ...]

  const AdvancedFilter({
    this.location,
    this.landmark,
    this.distanceKm,
    this.propertyType,
    this.priceMin,
    this.priceMax,
    this.landSizeMin,
    this.landSizeMax,
    this.usableAreaMin,
    this.usableAreaMax,
    this.floors,
    this.bedrooms,
    this.bathrooms,
    this.parking,
    this.commonFacilities = const [],
    this.furniture = const [],
    this.airConditioning = const [],
  });

  /// Convert to Map for API request
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> json = {};

    if (location != null && location!.isNotEmpty) {
      json['location'] = location;
    }
    if (landmark != null && landmark!.isNotEmpty) {
      json['landmark'] = landmark;
    }
    if (distanceKm != null) {
      json['distance_km'] = distanceKm;
    }
    if (propertyType != null) {
      json['property_type'] = propertyType;
    }
    if (priceMin != null) {
      json['price_min'] = priceMin;
    }
    if (priceMax != null) {
      json['price_max'] = priceMax;
    }
    if (landSizeMin != null) {
      json['land_size_min'] = landSizeMin;
    }
    if (landSizeMax != null) {
      json['land_size_max'] = landSizeMax;
    }
    if (usableAreaMin != null) {
      json['usable_area_min'] = usableAreaMin;
    }
    if (usableAreaMax != null) {
      json['usable_area_max'] = usableAreaMax;
    }
    if (floors != null) {
      json['floors'] = floors;
    }
    if (bedrooms != null) {
      json['bedrooms'] = bedrooms;
    }
    if (bathrooms != null) {
      json['bathrooms'] = bathrooms;
    }
    if (parking != null) {
      json['parking'] = parking;
    }
    if (commonFacilities.isNotEmpty) {
      json['common_facilities'] = commonFacilities;
    }
    if (furniture.isNotEmpty) {
      json['furniture'] = furniture;
    }
    if (airConditioning.isNotEmpty) {
      json['air_conditioning'] = airConditioning;
    }

    return json;
  }

  /// Check if any filter is set
  bool get hasFilters {
    return location != null ||
        landmark != null ||
        distanceKm != null ||
        propertyType != null ||
        priceMin != null ||
        priceMax != null ||
        landSizeMin != null ||
        landSizeMax != null ||
        usableAreaMin != null ||
        usableAreaMax != null ||
        floors != null ||
        bedrooms != null ||
        bathrooms != null ||
        parking != null ||
        commonFacilities.isNotEmpty ||
        furniture.isNotEmpty ||
        airConditioning.isNotEmpty;
  }

  /// Create a copy with updated values
  AdvancedFilter copyWith({
    String? location,
    String? landmark,
    double? distanceKm,
    String? propertyType,
    double? priceMin,
    double? priceMax,
    double? landSizeMin,
    double? landSizeMax,
    double? usableAreaMin,
    double? usableAreaMax,
    String? floors,
    String? bedrooms,
    String? bathrooms,
    String? parking,
    List<String>? commonFacilities,
    List<String>? furniture,
    List<String>? airConditioning,
  }) {
    return AdvancedFilter(
      location: location ?? this.location,
      landmark: landmark ?? this.landmark,
      distanceKm: distanceKm ?? this.distanceKm,
      propertyType: propertyType ?? this.propertyType,
      priceMin: priceMin ?? this.priceMin,
      priceMax: priceMax ?? this.priceMax,
      landSizeMin: landSizeMin ?? this.landSizeMin,
      landSizeMax: landSizeMax ?? this.landSizeMax,
      usableAreaMin: usableAreaMin ?? this.usableAreaMin,
      usableAreaMax: usableAreaMax ?? this.usableAreaMax,
      floors: floors ?? this.floors,
      bedrooms: bedrooms ?? this.bedrooms,
      bathrooms: bathrooms ?? this.bathrooms,
      parking: parking ?? this.parking,
      commonFacilities: commonFacilities ?? this.commonFacilities,
      furniture: furniture ?? this.furniture,
      airConditioning: airConditioning ?? this.airConditioning,
    );
  }
}

