import 'package:equatable/equatable.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

/// Represents the status/approval state of a property listing
enum PropertyApprovalStatus {
  pending, // รอการอนุมัติ
  approved, // อนุมัติแล้ว
  rejected, // ไม่อนุมัติ
  draft, // แบบร่าง (สำหรับ Preview)
}

class Property extends Equatable {
  final int? id;
  final String? code;
  final String title;
  final String? name; // Internal name / Project name
  final String description;

  // Location
  final String? address;
  final double latitude;
  final double longitude;
  final bool locationSet;
  final String? number;
  final String? city;
  final String? state;
  final String? province;
  final String? country;
  final String? postalCode;
  final String? subdistrict;
  final String? district;
  final String? road;
  final String? soi;
  final String? formattedAddressEn;
  final String? formattedAddressTh;

  // Pricing & Status
  final double price;
  final PropertyApprovalStatus approvalStatus;
  final String? listingType; // sale, rent
  final String? status; // available, sold, rented
  final String? availableFrom;

  // Specifications
  final int bedrooms;
  final int bathrooms;
  final int? garage;
  final double area; // Usable area (sqm)
  final double? landSize; // Land area (sq wah)
  final double? buildingSize;
  final String propertyType;
  final String? propertyStyle;
  final int? totalFloors; // Total floors of the property
  final String? houseColor;
  final String? built; // Year/Date built
  final String? direction;

  // Dynamic / Collections
  final List<String> highlights;
  final List<String> facilities;
  final Map<String, dynamic>
  specifications; // raw dynamic specs (e.g. "floors": "2")
  final Map<String, dynamic> specificationValues; // raw dynamic values

  // Images
  final String? imageUrl; // Cover image URL
  final List<String> imageUrls; // All remote image URLs
  final List<XFile> imageFiles; // Local image files (for Preview)

  // Metadata
  final DateTime createdAt;
  final int viewCount;

  // Helper: Check if this is a draft/preview
  bool get isDraft => id == null;

  const Property({
    this.id,
    this.code,
    required this.title,
    this.name,
    this.description = '',
    this.address,
    this.latitude = 0,
    this.longitude = 0,
    this.locationSet = false,
    this.number,
    this.city,
    this.state,
    this.country,
    this.postalCode,
    this.subdistrict,
    this.district,
    this.province,
    this.road,
    this.soi,
    this.formattedAddressEn,
    this.formattedAddressTh,
    this.price = 0,
    this.approvalStatus = PropertyApprovalStatus.pending,
    this.listingType,
    this.status,
    this.availableFrom,
    this.bedrooms = 0,
    this.bathrooms = 0,
    this.garage,
    this.area = 0,
    this.landSize,
    this.buildingSize,
    this.propertyType = '',
    this.propertyStyle,
    this.totalFloors,
    this.houseColor,
    this.built,
    this.direction,
    this.highlights = const [],
    this.facilities = const [],
    this.specifications = const {},
    this.specificationValues = const {},
    this.imageUrl,
    this.imageUrls = const [],
    this.imageFiles = const [],
    required this.createdAt,
    this.viewCount = 0,
  });

  /// Factory: Parses Nested API Response (Smart Parser)
  factory Property.fromJson(Map<String, dynamic> json) {
    // 1. Extract Core Data Wrapper
    final data = json.containsKey('data')
        ? json['data'] as Map<String, dynamic>
        : json;

    // 2. Extract Nested Objects (Safely)
    final specs = data['specs'] is Map<String, dynamic>
        ? data['specs'] as Map<String, dynamic>
        : {};
    final location = data['location'] is Map<String, dynamic>
        ? data['location'] as Map<String, dynamic>
        : {};
    final specValues = specs['specification_values'] is Map<String, dynamic>
        ? specs['specification_values'] as Map<String, dynamic>
        : {};
    final rawSpecs = specs['specifications'] is Map<String, dynamic>
        ? specs['specifications'] as Map<String, dynamic>
        : {};

    // 3. Helper Parsers
    double parseDouble(dynamic val) {
      if (val == null) return 0.0;
      if (val is num) return val.toDouble();
      if (val is String) return double.tryParse(val) ?? 0.0;
      return 0.0;
    }

    int parseInt(dynamic val) {
      if (val == null) return 0;
      if (val is num) return val.toInt();
      if (val is String) return int.tryParse(val) ?? 0;
      return 0;
    }

    List<String> parseList(dynamic list) {
      if (list is List) return list.map((e) => e.toString()).toList();
      return [];
    }

    String? parseString(dynamic val) {
      if (val == null) return null;
      if (val is String) return val;
      // Intentionally do NOT call toString() on Maps/Lists to reference them as strings
      if (val is num) return val.toString();
      return null;
    }

    PropertyApprovalStatus parseStatus(String? s) {
      if (s == 'approved') return PropertyApprovalStatus.approved;
      if (s == 'rejected') return PropertyApprovalStatus.rejected;
      if (s == 'draft') return PropertyApprovalStatus.draft;
      return PropertyApprovalStatus.pending;
    }

    // 4. Parse Images
    final imagesList = (data['images'] is List) ? data['images'] as List : [];
    final parsedImageUrls = imagesList.map((img) {
      if (img is Map) return (img['url'] ?? img['display_url']).toString();
      return img.toString();
    }).toList();
    final firstImage = parsedImageUrls.isNotEmpty
        ? parsedImageUrls.first
        : null;

    // 5. Construct Entity
    return Property(
      id: parseInt(data['id']),
      code: parseString(data['code']),
      // Title logic: Prefer title -> name -> generated name
      title:
          parseString(data['title']) ??
          parseString(specs['name']) ??
          'New Property',
      name: parseString(specs['name']),
      description:
          parseString(data['description']) ??
          parseString(specs['description']) ??
          '',

      // Status & Price
      approvalStatus: parseStatus(data['approval_status']?.toString()),
      price: parseDouble(specs['price'] ?? data['price']),
      listingType: parseString(data['listing_type']),
      // Ensure we don't pick up the complex 'status' object as the string status
      status: parseString(specs['status']),
      availableFrom:
          parseString(specs['available_from']) ??
          parseString(data['available_from']),

      // Location (Priority: Specs -> Location Object)
      address:
          parseString(specs['address']) ??
          parseString(location['formatted_address_th']),
      latitude: parseDouble(location['latitude']),
      longitude: parseDouble(location['longitude']),
      locationSet: location.isNotEmpty,
      number: location['number'] is Map
          ? location['number']['original']?.toString()
          : location['number']?.toString(),
      city: parseString(location['city']),
      state:
          parseString(location['province']) ?? parseString(location['state']),
      province: parseString(location['province']),
      country: parseString(location['country']),
      postalCode: parseString(location['postal_code']),
      district: parseString(location['district']),
      subdistrict: parseString(location['subdistrict']),
      road: parseString(location['road']),
      soi: parseString(location['soi']),
      formattedAddressTh: parseString(location['formatted_address_th']),
      formattedAddressEn: parseString(location['formatted_address_en']),

      // Details
      propertyType:
          parseString(specs['type']) ??
          parseString(data['property_type']) ??
          '',
      bedrooms: parseInt(specs['bedrooms']),
      bathrooms: parseInt(specs['bathrooms']),
      garage: parseInt(specs['garage']),
      area: parseDouble(specs['building_size'] ?? specs['area']),
      landSize: parseDouble(specs['land_size']),
      buildingSize: parseDouble(specs['building_size']),
      propertyStyle:
          parseString(specs['property_style']) ??
          parseString(data['property_style']),
      houseColor: parseString(specs['house_color']),
      built: parseString(data['built']),
      direction: parseString(specs['direction']),
      totalFloors: parseInt(
        specs['total_floors'] ?? rawSpecs['floors'],
      ), // Try spec object then raw map
      // Dynamic Values
      specifications: Map<String, dynamic>.from(rawSpecs),
      specificationValues: Map<String, dynamic>.from(specValues),
      highlights: parseList(specValues['good_points']),
      facilities: parseList(specValues['common_facilities']),

      // Images
      imageUrl: firstImage,
      imageUrls: parsedImageUrls,

      // Metadata
      createdAt:
          DateTime.tryParse(data['created_at']?.toString() ?? '') ??
          DateTime.now(),
      viewCount: parseInt(data['view_count']),
    );
  }

  /// Converts Entity to API Create Payload (Flat Structure)
  Map<String, dynamic> toCreatePayload() {
    return {
      'name': title, // API expects 'name'
      'type': propertyType,
      'price': price,
      'description': description,
      'listing_type': listingType,
      'status': status,
      'built': built,
      'available_from': availableFrom,
      'house_color': houseColor,
      'direction': direction,

      // Main Stats
      'bedrooms': bedrooms,
      'bathrooms': bathrooms,
      'garage': garage,
      'land_size': landSize,
      'building_size': buildingSize,

      // Location
      'latitude': latitude,
      'longitude': longitude,
      'address': address,
      'number': number,
      'city': city,
      'state': state, // Province
      'province': state, // Redundant but safe
      'postal_code': postalCode,
      'district': district,
      'subdistrict': subdistrict,
      'road': road,
      'soi': soi,
      'country': country,
      'formatted_address_en': formattedAddressEn,
      'formatted_address_th': formattedAddressTh,

      // Dynamic Specifications Map
      'specifications': {
        ...specifications,
        'floors': totalFloors?.toString(),
        'bedrooms': bedrooms.toString(),
        'bathrooms': bathrooms.toString(),
        'parking_spaces': garage?.toString(),
      },

      // Dynamic Values Map (Multi-selects)
      'specification_values': specificationValues,
    };
  }

  @override
  List<Object?> get props => [
    id,
    code,
    title,
    price,
    address,
    approvalStatus,
    imageUrls,
    imageFiles,
    bedrooms,
    bathrooms,
    specifications,
    createdAt,
  ];
}
