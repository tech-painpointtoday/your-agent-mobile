import 'package:youragent/domain/entities/property.dart';
import 'package:youragent/domain/entities/property_spec.dart';
import 'package:youragent/domain/entities/property_location.dart';
import 'package:youragent/domain/entities/property_image.dart';
import 'package:youragent/domain/entities/floor_plan.dart';
import 'package:youragent/data/models/property_status_model.dart';

/// Condo-specific details
class CondoDetails {
  final int? condoProjectId;
  final String? tower;
  final String? floor;
  final String? unitNo;

  CondoDetails({
    this.condoProjectId,
    this.tower,
    this.floor,
    this.unitNo,
  });

  factory CondoDetails.fromJson(Map<String, dynamic> json) {
    return CondoDetails(
      condoProjectId: json['condo_project_id'] as int?,
      tower: json['tower'] as String?,
      floor: json['floor'] as String?,
      unitNo: json['unit_no'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (condoProjectId != null) 'condo_project_id': condoProjectId,
      if (tower != null) 'tower': tower,
      if (floor != null) 'floor': floor,
      if (unitNo != null) 'unit_no': unitNo,
    };
  }
}

/// House-specific details
class HouseDetails {
  final String? villageName;
  final String? moo;
  final String? houseSubtype; // 'detached', 'semi', 'townhouse', etc.
  final String? parkingType;
  final bool? isCornerPlot;
  final String? notes;

  HouseDetails({
    this.villageName,
    this.moo,
    this.houseSubtype,
    this.parkingType,
    this.isCornerPlot,
    this.notes,
  });

  factory HouseDetails.fromJson(Map<String, dynamic> json) {
    return HouseDetails(
      villageName: json['village_name'] as String?,
      moo: json['moo'] as String?,
      houseSubtype: json['house_subtype'] as String?,
      parkingType: json['parking_type'] as String?,
      isCornerPlot: json['is_corner_plot'] as bool?,
      notes: json['notes'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (villageName != null) 'village_name': villageName,
      if (moo != null) 'moo': moo,
      if (houseSubtype != null) 'house_subtype': houseSubtype,
      if (parkingType != null) 'parking_type': parkingType,
      if (isCornerPlot != null) 'is_corner_plot': isCornerPlot,
      if (notes != null) 'notes': notes,
    };
  }
}

/// PropertyModel matching the old Laravel Property API response structure
class PropertyModel extends Property {
  // Nested relationships
  final PropertySpec? specs;
  final PropertyLocation?
  propertyLocation; // Renamed to avoid conflict with Property.location (String)
  final List<PropertyImage>? images;
  final List<FloorPlan>? floorPlans;
  final PropertyStatusModel? propertyStatus; // New status object structure
  final Map<String, dynamic>? seller; // Seller info (can be null)
  final CondoDetails? condoDetails; // Condo-specific details
  final HouseDetails? houseDetails; // House-specific details

  // New fields for unified endpoint
  final String? availableFrom; // Date in YYYY-MM-DD format
  final String? formattedAddressTh; // Formatted address in Thai
  final String? formattedAddressEn; // Formatted address in English

  const PropertyModel({
    super.id,
    required super.name,
    required super.description,
    required super.location, // String location for display
    required super.price,
    required super.bedrooms,
    required super.bathrooms,
    required super.area,
    required super.propertyType,
    required super.hasPool,
    required super.hasFireplace,
    required super.hasGarage,
    super.floors,
    super.compatibility,
    super.compatibilityBefore,
    super.horaScore,
    super.fengshuiScore,
    required super.imageUrl,
    super.imageUrls,
    super.userId,
    super.agentId,
    super.sellerId,
    super.agencyId,
    super.hasAgent,
    super.coAgentId,
    super.approvalStatus,
    super.approvedByUserId,
    super.approvedAt,
    super.rejectionReason,
    super.allowAgentRepresentation,
    super.built,
    super.listingType,
    super.viewCount,
    super.clickCount,
    super.favoriteCount,
    super.inquiryCount,
    super.shareCount,
    super.firstViewedAt,
    super.lastViewedAt,
    super.lastClickedAt,
    super.valueComparison1,
    super.valueComparison2,
    super.status,
    super.createdAt,
    super.updatedAt,
    this.specs,
    this.propertyLocation,
    this.images,
    this.floorPlans,
    this.propertyStatus,
    this.seller,
    this.condoDetails,
    this.houseDetails,
    this.availableFrom,
    this.formattedAddressTh,
    this.formattedAddressEn,
  });

  factory PropertyModel.fromJson(Map<String, dynamic> json) {
    // Handle nested API structure (specs, location, images)
    final specsJson = json['specs'] as Map<String, dynamic>?;
    final locationJson = json['location'] as Map<String, dynamic>?;
    final imagesJson = (json['images'] as List?) ?? [];

    // Parse nested relationships
    final PropertySpec? specs = specsJson != null
        ? PropertySpec.fromJson({...specsJson, 'property_id': json['id'] ?? 0})
        : null;

    final PropertyLocation? location = locationJson != null
        ? PropertyLocation.fromJson({
            ...locationJson,
            'property_id': json['id'] ?? 0,
          })
        : null;

    final List<PropertyImage> images = imagesJson
        .map((img) {
          try {
            return PropertyImage.fromJson({
              ...img as Map<String, dynamic>,
              'property_id': json['id'] ?? 0,
            });
          } catch (e) {
            // Skip invalid image entries
            return null;
          }
        })
        .whereType<PropertyImage>()
        .toList();

    // Parse floor_plans array
    final floorPlansJson = (json['floor_plans'] as List?) ?? [];
    final List<FloorPlan> floorPlans = floorPlansJson
        .map((fp) {
          try {
            return FloorPlan.fromJson({
              ...fp as Map<String, dynamic>,
              'property_id': json['id'] ?? 0,
            });
          } catch (e) {
            // Skip invalid floor plan entries
            return null;
          }
        })
        .whereType<FloorPlan>()
        .toList();

    // Parse status object (new structure)
    final PropertyStatusModel? propertyStatus =
        json['status'] is Map<String, dynamic>
        ? PropertyStatusModel.fromJson(json['status'] as Map<String, dynamic>)
        : null;

    // Parse seller object (can be null)
    final Map<String, dynamic>? seller = json['seller'] is Map<String, dynamic>
        ? json['seller'] as Map<String, dynamic>
        : null;

    // Parse condo details (if exists)
    final CondoDetails? condoDetails = json['condo_details'] is Map<String, dynamic>
        ? CondoDetails.fromJson(json['condo_details'] as Map<String, dynamic>)
        : null;

    // Parse house details (if exists)
    final HouseDetails? houseDetails = json['house_details'] is Map<String, dynamic>
        ? HouseDetails.fromJson(json['house_details'] as Map<String, dynamic>)
        : null;

    // Get primary image URL
    final primaryImage = images.isNotEmpty ? images.first : null;
    final String imageUrl =
        primaryImage?.displayUrl ?? 'assets/images/imagewithfallback@2x.png';

    // Get all image URLs
    final List<String> imageUrls = images.map((img) => img.displayUrl).toList();

    // Parse price from specs (handle both string and numeric formats)
    final String? rawPrice = specs?.price ?? specsJson?['price']?.toString();
    final int price = rawPrice != null
        ? double.tryParse(rawPrice)?.round() ?? 0
        : 0;

    // Parse area (prefer building_size, fallback to land_size)
    final double area =
        specs?.buildingSize ??
        specs?.landSize ??
        double.tryParse(
          (specsJson?['building_size'] ?? specsJson?['land_size'] ?? '0')
              .toString(),
        ) ??
        0.0;

    // Helper function to parse double values from various types
    double? parseDouble(dynamic value) {
      if (value == null) return null;
      if (value is num) return value.toDouble();
      if (value is String) return double.tryParse(value);
      return null;
    }

    // Get compatibility scores (prefer from json level, fallback to specs)
    final double? fengshuiScore =
        parseDouble(json['fengshui_score']) ?? specs?.fengshuiScore;

    final double? horaScore =
        parseDouble(json['hora_score']) ?? specs?.horaScore;

    // Parse dates
    DateTime? parseDateTime(dynamic value) {
      if (value == null) return null;
      if (value is DateTime) return value;
      if (value is String) {
        try {
          return DateTime.parse(value);
        } catch (e) {
          return null;
        }
      }
      return null;
    }

    // Get property name
    final String name =
        (specs?.name?.trim().isNotEmpty == true ? specs!.name : 'Unknown') ??
        'Unknown';

    // Get property description
    final String description =
        (specs?.description?.trim().isNotEmpty == true
            ? specs!.description
            : specs?.type) ??
        json['name'] as String? ??
        'Property';

    // Get location string from PropertyLocation or fallback
    final String locationStr =
        location?.city ??
        location?.state ??
        specs?.address ??
        json['location'] as String? ??
        '';

    // Determine property type
    final String propertyType =
        specs?.type ?? json['property_type'] as String? ?? '';

    // Handle bedrooms - can be int, array, or in specs
    int parseBedrooms() {
      // First try from specs
      if (specs?.bedrooms != null && specs!.bedrooms > 0) {
        return specs.bedrooms;
      }
      // Try from json directly (might be int)
      if (json['bedrooms'] is int) {
        return json['bedrooms'] as int;
      }
      // Try from json as array (take first element or length)
      if (json['bedrooms'] is List) {
        final bedroomsList = json['bedrooms'] as List;
        if (bedroomsList.isNotEmpty) {
          final first = bedroomsList.first;
          if (first is int) return first;
          if (first is Map) {
            // If it's an object, try to get a count or id
            return bedroomsList.length;
          }
        }
        return bedroomsList.length;
      }
      // Fallback to specsJson
      if (specsJson?['bedrooms'] != null) {
        final bedroomsValue = specsJson!['bedrooms'];
        if (bedroomsValue is int) return bedroomsValue;
        if (bedroomsValue is String) {
          return int.tryParse(bedroomsValue) ?? 0;
        }
      }
      return 0;
    }

    // Handle bathrooms - similar to bedrooms
    int parseBathrooms() {
      if (specs?.bathrooms != null && specs!.bathrooms > 0) {
        return specs.bathrooms;
      }
      if (json['bathrooms'] is int) {
        return json['bathrooms'] as int;
      }
      if (json['bathrooms'] is List) {
        final bathroomsList = json['bathrooms'] as List;
        if (bathroomsList.isNotEmpty) {
          final first = bathroomsList.first;
          if (first is int) return first;
        }
        return bathroomsList.length;
      }
      if (specsJson?['bathrooms'] != null) {
        final bathroomsValue = specsJson!['bathrooms'];
        if (bathroomsValue is int) return bathroomsValue;
        if (bathroomsValue is String) {
          return int.tryParse(bathroomsValue) ?? 0;
        }
      }
      return 0;
    }

    final int bedrooms = parseBedrooms();
    final int bathrooms = parseBathrooms();

    // Check for garage
    final bool hasGarage =
        (specs?.garage ?? 0) > 0 || (json['has_garage'] as bool? ?? false);

    // Check for agent
    final bool hasAgent =
        json['agent_id'] != null ||
        json['ownership_type'] == 'managed' ||
        false;

    return PropertyModel(
      id: json['id'] as int?,
      name: name,
      description: description,
      location: locationStr,
      price: price,
      bedrooms: bedrooms,
      bathrooms: bathrooms,
      area: area,
      propertyType: propertyType,
      hasPool: json['has_pool'] as bool? ?? false,
      hasFireplace: json['has_fireplace'] as bool? ?? false,
      hasGarage: hasGarage,
      floors: json['floors'] as int?,
      compatibility: fengshuiScore,
      compatibilityBefore: json['compatibility_before'] != null
          ? parseDouble(json['compatibility_before'])
          : null,
      horaScore: horaScore,
      fengshuiScore: fengshuiScore,
      imageUrl: imageUrl,
      imageUrls: imageUrls.isNotEmpty ? imageUrls : null,
      userId: json['user_id'] as int?,
      agentId: json['agent_id'] as int?,
      sellerId: json['seller_id'] as int?,
      agencyId: json['agency_id'] as int?,
      hasAgent: hasAgent,
      coAgentId: json['co_agent_id'] as int?,
      approvalStatus: json['approval_status'] as String?,
      approvedByUserId: json['approved_by_user_id'] as int?,
      approvedAt: parseDateTime(json['approved_at']),
      rejectionReason: json['rejection_reason'] as String?,
      allowAgentRepresentation:
          json['allow_agent_representation'] as bool? ?? false,
      built: json['built'] as String?,
      listingType: json['listing_type'] as String?,
      viewCount: json['view_count'] as int?,
      clickCount: json['click_count'] as int?,
      favoriteCount: json['favorite_count'] as int?,
      inquiryCount: json['inquiry_count'] as int?,
      shareCount: json['share_count'] as int?,
      firstViewedAt: parseDateTime(json['first_viewed_at']),
      lastViewedAt: parseDateTime(json['last_viewed_at']),
      lastClickedAt: parseDateTime(json['last_clicked_at']),
      valueComparison1: json['value_comparison1'] != null
          ? parseDouble(json['value_comparison1'])
          : null,
      valueComparison2: json['value_comparison2'] != null
          ? parseDouble(json['value_comparison2'])
          : null,
      // Handle status - can be a string or an object (completion status)
      // If it's an object, we'll store null and let propertyStatus handle it
      status: json['status'] is String ? json['status'] as String? : null,
      createdAt: parseDateTime(json['created_at']),
      updatedAt: parseDateTime(json['updated_at']),
      specs: specs,
      propertyLocation: location,
      images: images.isNotEmpty ? images : null,
      floorPlans: floorPlans.isNotEmpty ? floorPlans : null,
      propertyStatus: propertyStatus,
      seller: seller,
      condoDetails: condoDetails,
      houseDetails: houseDetails,
      availableFrom: json['available_from'] as String?,
      formattedAddressTh: json['formatted_address_th'] as String?,
      formattedAddressEn: json['formatted_address_en'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'location': location,
      'price': price,
      'bedrooms': bedrooms,
      'bathrooms': bathrooms,
      'area': area,
      'property_type': propertyType,
      'has_pool': hasPool,
      'has_fireplace': hasFireplace,
      'has_garage': hasGarage,
      'floors': floors,
      'compatibility': compatibility,
      'compatibility_before': compatibilityBefore,
      'hora_score': horaScore,
      'fengshui_score': fengshuiScore,
      'image_url': imageUrl,
      'image_urls': imageUrls,
      'user_id': userId,
      'agent_id': agentId,
      'seller_id': sellerId,
      'agency_id': agencyId,
      'has_agent': hasAgent,
      'co_agent_id': coAgentId,
      'approval_status': approvalStatus,
      'approved_by_user_id': approvedByUserId,
      'approved_at': approvedAt?.toIso8601String(),
      'rejection_reason': rejectionReason,
      'allow_agent_representation': allowAgentRepresentation,
      'built': built,
      'listing_type': listingType,
      'view_count': viewCount,
      'click_count': clickCount,
      'favorite_count': favoriteCount,
      'inquiry_count': inquiryCount,
      'share_count': shareCount,
      'first_viewed_at': firstViewedAt?.toIso8601String(),
      'last_viewed_at': lastViewedAt?.toIso8601String(),
      'last_clicked_at': lastClickedAt?.toIso8601String(),
      'value_comparison1': valueComparison1,
      'value_comparison2': valueComparison2,
      'status': status,
      'specs': specs?.toJson(),
      'property_location': propertyLocation
          ?.toJson(), // PropertyLocation relationship (renamed to avoid conflict)
      'images': images?.map((img) => img.toJson()).toList(),
      'condo_details': condoDetails?.toJson(),
      'house_details': houseDetails?.toJson(),
      'available_from': availableFrom,
      'formatted_address_th': formattedAddressTh,
      'formatted_address_en': formattedAddressEn,
    };
  }

  Property toEntity() {
    return Property(
      id: id,
      name: name,
      description: description,
      location: location,
      price: price,
      bedrooms: bedrooms,
      bathrooms: bathrooms,
      area: area,
      propertyType: propertyType,
      hasPool: hasPool,
      hasFireplace: hasFireplace,
      hasGarage: hasGarage,
      floors: floors,
      compatibility: compatibility,
      compatibilityBefore: compatibilityBefore,
      horaScore: horaScore,
      fengshuiScore: fengshuiScore,
      imageUrl: imageUrl,
      imageUrls: imageUrls,
      userId: userId,
      agentId: agentId,
      sellerId: sellerId,
      agencyId: agencyId,
      hasAgent: hasAgent,
      coAgentId: coAgentId,
      approvalStatus: approvalStatus,
      approvedByUserId: approvedByUserId,
      approvedAt: approvedAt,
      rejectionReason: rejectionReason,
      allowAgentRepresentation: allowAgentRepresentation,
      built: built,
      listingType: listingType,
      viewCount: viewCount,
      clickCount: clickCount,
      favoriteCount: favoriteCount,
      inquiryCount: inquiryCount,
      shareCount: shareCount,
      firstViewedAt: firstViewedAt,
      lastViewedAt: lastViewedAt,
      lastClickedAt: lastClickedAt,
      valueComparison1: valueComparison1,
      valueComparison2: valueComparison2,
      status: status,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}
