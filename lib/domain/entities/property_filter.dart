import 'package:equatable/equatable.dart';
import 'package:youragent/domain/entities/property.dart';

class PropertyFilter extends Equatable {
  final String? approvalStatus;
  final bool? isDraft;
  final String? propertyType;
  final String? listingType;
  final String? occupancyStatus;
  final String? color;
  final double? minPrice;
  final double? maxPrice;
  final int? floors;
  final int? bedrooms;
  final int? bathrooms;
  final int? parkingSpaces;
  final double? landSize;
  final double? buildingSize;
  // Dynamic specification filters
  final Map<String, String> singleSelectSpecs; // key => selected value
  final Map<String, Set<String>> multiSelectSpecs; // key => selected values

  const PropertyFilter({
    this.approvalStatus,
    this.isDraft,
    this.propertyType,
    this.listingType,
    this.occupancyStatus,
    this.color,
    this.minPrice,
    this.maxPrice,
    this.floors,
    this.bedrooms,
    this.bathrooms,
    this.parkingSpaces,
    this.landSize,
    this.buildingSize,
    this.singleSelectSpecs = const {},
    this.multiSelectSpecs = const {},
  });

  bool get isEmpty {
    bool isDefault(dynamic value) {
      if (value == null) return true;
      if (value is String) {
        return value == 'ทั้งหมด' || value == 'All' || value.isEmpty;
      }
      return false;
    }

    // Check if all multi-select specs are empty
    bool allMultiSpecsEmpty = true;
    for (final spec in multiSelectSpecs.values) {
      if (spec.isNotEmpty) {
        allMultiSpecsEmpty = false;
        break;
      }
    }

    return isDefault(approvalStatus) &&
        isDraft == null &&
        isDefault(propertyType) &&
        isDefault(listingType) &&
        isDefault(occupancyStatus) &&
        isDefault(color) &&
        minPrice == null &&
        maxPrice == null &&
        floors == null &&
        bedrooms == null &&
        bathrooms == null &&
        parkingSpaces == null &&
        landSize == null &&
        buildingSize == null &&
        singleSelectSpecs.isEmpty &&
        allMultiSpecsEmpty;
  }

  bool matches(Property property) {
    if (isEmpty) return true;

    // Draft
    if (isDraft != null && property.isDraft != isDraft) return false;

    bool isDefault(String? value) {
      if (value == null) return true;
      return value == 'ทั้งหมด' || value == 'All' || value.isEmpty;
    }

    // Approval Status
    if (!isDefault(approvalStatus)) {
      final statusStr = switch (property.approvalStatus) {
        PropertyApprovalStatus.pending => 'รอการอนุมัติ',
        PropertyApprovalStatus.approved => 'อนุมัติแล้ว',
        PropertyApprovalStatus.rejected => 'ไม่อนุมัติ',
      };
      if (statusStr != approvalStatus) return false;
    }

    // Property Type
    if (!isDefault(propertyType)) {
      if (property.propertyType?.label != propertyType) return false;
    }

    // Listing Type
    if (!isDefault(listingType)) {
      final listingStr = switch (property.listingType) {
        PropertyListingType.sale => 'ขาย',
        PropertyListingType.rent => 'เช่า',
        PropertyListingType.saleOrRent => 'ขายและเช่า',
        _ => '',
      };
      if (listingStr != listingType) return false;
    }

    // Occupancy Status
    if (!isDefault(occupancyStatus)) {
      final isAvailable =
          property.status == PropertyAvailabilityStatus.available;
      // Check if the occupancy status matches "vacancy" (available) or "occupied" (not available)
      // We'll check for both Thai and English terms to handle localization
      final isVacancyFilter =
          occupancyStatus == 'ว่าง' ||
          occupancyStatus == 'Vacancy' ||
          (occupancyStatus?.toLowerCase().contains('vacan') ?? false);
      final isOccupiedFilter =
          occupancyStatus == 'ไม่ว่าง' ||
          occupancyStatus == 'เช่าแล้ว' ||
          occupancyStatus == 'Occupied' ||
          (occupancyStatus?.toLowerCase().contains('occup') ?? false);

      if (isVacancyFilter && !isAvailable) return false;
      if (isOccupiedFilter && isAvailable) return false;
    }

    // Color
    if (color != null &&
        color != 'ทั้งหมด' &&
        property.houseColor?.label != color) {
      return false;
    }

    // Price
    if (minPrice != null && property.price < minPrice!) return false;
    if (maxPrice != null && property.price > maxPrice!) return false;

    // Floors
    if (floors != null && property.totalFloors != floors) return false;

    // Bedrooms (special handling for Studio = 0)
    if (bedrooms != null && property.bedrooms != bedrooms) {
      return false;
    }

    // Room Type (backward compatibility: check 'room_type' in single select specs)
    if (singleSelectSpecs.containsKey('room_type')) {
      final roomTypeValue = singleSelectSpecs['room_type'];
      if (roomTypeValue != null &&
          property.specifications['unit_type'] != roomTypeValue) {
        return false;
      }
    }

    // Bathrooms
    if (bathrooms != null) {
      // 8+ handling if needed
      if (bathrooms == 8) {
        if (property.bathrooms < 8) return false;
      } else if (property.bathrooms != bathrooms) {
        return false;
      }
    }

    // Parking
    if (parkingSpaces != null && property.garage != parkingSpaces) return false;

    // Sizes
    if (landSize != null && (property.landSize ?? 0) < landSize!) return false;
    if (buildingSize != null && (property.buildingSize ?? 0) < buildingSize!) {
      return false;
    }

    // Dynamic Single-Select Specifications
    for (final entry in singleSelectSpecs.entries) {
      final key = entry.key;
      final value = entry.value;
      if (property.specifications[key] != value) {
        return false;
      }
    }

    // Dynamic Multi-Select Specifications
    for (final entry in multiSelectSpecs.entries) {
      final key = entry.key;
      final selectedValues = entry.value;
      if (selectedValues.isEmpty) continue;

      final propertyValues = property.specificationValues[key];
      if (propertyValues is! List) return false;

      // Check if all selected values exist in property values
      for (final val in selectedValues) {
        if (!propertyValues.contains(val)) return false;
      }
    }

    return true;
  }

  PropertyFilter copyWith({
    String? Function()? approvalStatus,
    bool? isDraft,
    String? Function()? propertyType,
    String? Function()? listingType,
    String? Function()? occupancyStatus,
    String? Function()? color,
    double? Function()? minPrice,
    double? Function()? maxPrice,
    int? Function()? floors,
    int? Function()? bedrooms,
    int? Function()? bathrooms,
    int? Function()? parkingSpaces,
    double? Function()? landSize,
    double? Function()? buildingSize,
    Map<String, String>? singleSelectSpecs,
    Map<String, Set<String>>? multiSelectSpecs,
  }) {
    return PropertyFilter(
      approvalStatus: approvalStatus != null
          ? approvalStatus()
          : this.approvalStatus,
      isDraft: isDraft ?? this.isDraft,
      propertyType: propertyType != null ? propertyType() : this.propertyType,
      listingType: listingType != null ? listingType() : this.listingType,
      occupancyStatus: occupancyStatus != null
          ? occupancyStatus()
          : this.occupancyStatus,
      color: color != null ? color() : this.color,
      minPrice: minPrice != null ? minPrice() : this.minPrice,
      maxPrice: maxPrice != null ? maxPrice() : this.maxPrice,
      floors: floors != null ? floors() : this.floors,
      bedrooms: bedrooms != null ? bedrooms() : this.bedrooms,
      bathrooms: bathrooms != null ? bathrooms() : this.bathrooms,
      parkingSpaces: parkingSpaces != null
          ? parkingSpaces()
          : this.parkingSpaces,
      landSize: landSize != null ? landSize() : this.landSize,
      buildingSize: buildingSize != null ? buildingSize() : this.buildingSize,
      singleSelectSpecs: singleSelectSpecs ?? this.singleSelectSpecs,
      multiSelectSpecs: multiSelectSpecs ?? this.multiSelectSpecs,
    );
  }

  @override
  List<Object?> get props => [
    approvalStatus,
    isDraft,
    propertyType,
    listingType,
    occupancyStatus,
    color,
    minPrice,
    maxPrice,
    floors,
    bedrooms,
    bathrooms,
    parkingSpaces,
    landSize,
    buildingSize,
    singleSelectSpecs,
    multiSelectSpecs,
  ];
}
