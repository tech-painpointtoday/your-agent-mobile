import 'package:youragent/domain/entities/property.dart';
import 'package:youragent/domain/entities/property_spec.dart';
import 'package:youragent/domain/entities/property_location.dart';
import 'package:youragent/domain/entities/property_image.dart';
import 'package:youragent/domain/entities/floor_plan.dart';
import 'package:youragent/data/models/property_status_model.dart';
import 'package:youragent/data/models/agent_model.dart';

/// Condo-specific details
class CondoDetails {
  final int? condoProjectId;
  final String? tower;
  final String? floor;
  final String? unitNo;

  CondoDetails({this.condoProjectId, this.tower, this.floor, this.unitNo});

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

/// PropertyModel matching the API response structure
class PropertyModel extends Property {
  // Nested relationships
  final PropertySpec? specs;
  final PropertyLocation? propertyLocation;
  final List<PropertyImage>? images;
  final List<FloorPlan>? floorPlans;
  final PropertyStatusModel? propertyStatus;
  final AgentModel? agent;
  final Map<String, dynamic>? seller;
  final CondoDetails? condoDetails;
  final HouseDetails? houseDetails;

  const PropertyModel({
    required super.id,
    required super.code,
    required super.title,
    required super.description,
    required super.location,
    super.address,
    required super.latitude,
    required super.longitude,
    super.price,
    required super.status,
    required super.createdAt,
    super.updatedAt,
    super.approvalStatus,
    super.bedrooms,
    super.bathrooms,
    super.area,
    super.landSize,
    super.propertyType,
    super.floors,
    super.garage,
    super.hasPool,
    super.hasFireplace,
    super.houseColor,
    super.built,
    super.compatibility,
    super.fengshuiScore,
    super.horaScore,
    required super.imageUrl,
    super.imageUrls,
    super.userId,
    super.agentId,
    super.sellerId,
    super.agencyId,
    super.villageName,
    super.tower,
    super.floor,
    super.unitNo,
    super.houseSubtype,
    super.availableFrom,
    super.viewCount,
    super.clickCount,
    super.favoriteCount,
    super.completionPercentage,
    super.nextStep,
    this.specs,
    this.propertyLocation,
    this.images,
    this.floorPlans,
    this.propertyStatus,
    this.agent,
    this.seller,
    this.condoDetails,
    this.houseDetails,
  });

  factory PropertyModel.fromJson(Map<String, dynamic> json) {
    final specsJson = json['specs'] as Map<String, dynamic>?;
    final locationJson = json['location'] as Map<String, dynamic>?;
    final imagesJson = (json['images'] as List?) ?? [];
    final floorPlansJson = (json['floor_plans'] as List?) ?? [];
    final agentJson = json['agent'] as Map<String, dynamic>?;

    final specs = specsJson != null ? PropertySpec.fromJson(specsJson) : null;
    final location = locationJson != null
        ? PropertyLocation.fromJson(locationJson)
        : null;
    final agent = agentJson != null ? AgentModel.fromJson(agentJson) : null;

    final images = imagesJson
        .map((img) => PropertyImage.fromJson(img as Map<String, dynamic>))
        .toList();

    final floorPlans = floorPlansJson
        .map((fp) => FloorPlan.fromJson(fp as Map<String, dynamic>))
        .toList();

    final propertyStatus = json['status'] != null
        ? PropertyStatusModel.fromJson(json['status'] as Map<String, dynamic>)
        : null;

    final condoDetails = json['condo_details'] != null
        ? CondoDetails.fromJson(json['condo_details'] as Map<String, dynamic>)
        : null;

    final houseDetails = json['house_details'] != null
        ? HouseDetails.fromJson(json['house_details'] as Map<String, dynamic>)
        : null;

    // Helper parsers
    double parseDouble(dynamic value, {double fallback = 0.0}) {
      if (value == null) return fallback;
      if (value is num) return value.toDouble();
      if (value is String) return double.tryParse(value) ?? fallback;
      return fallback;
    }

    int parseInt(dynamic value, {int fallback = 0}) {
      if (value == null) return fallback;
      if (value is int) return value;
      if (value is num) return value.toInt();
      if (value is String) return int.tryParse(value) ?? fallback;
      return fallback;
    }

    DateTime parseDateTime(dynamic value) {
      if (value == null) return DateTime.now();
      if (value is DateTime) return value;
      if (value is String) return DateTime.tryParse(value) ?? DateTime.now();
      return DateTime.now();
    }

    // Mapping fields
    final id = json['id']?.toString() ?? '';
    final code = id.padLeft(6, '0');
    final title = json['title'] as String? ?? specs?.name ?? 'No Title';
    final description = specs?.description ?? '';
    final locationStr =
        location?.city ?? location?.state ?? specs?.address ?? '';

    final price = parseDouble(specs?.price);
    final latitude = parseDouble(location?.latitude);
    final longitude = parseDouble(location?.longitude);

    final approvalStatusString =
        json['approval_status'] as String? ?? 'pending';
    PropertyStatus status;
    switch (approvalStatusString) {
      case 'approved':
        status = PropertyStatus.approved;
        break;
      case 'rejected':
        status = PropertyStatus.rejected;
        break;
      default:
        status = PropertyStatus.pending;
    }

    final imageUrl = images.isNotEmpty
        ? images.first.displayUrl
        : 'assets/images/imagewithfallback@2x.png';
    final imageUrls = images.map((img) => img.displayUrl).toList();

    return PropertyModel(
      id: id,
      code: code,
      title: title,
      description: description,
      location: locationStr,
      address: specs?.address,
      latitude: latitude,
      longitude: longitude,
      price: price,
      status: status,
      createdAt: parseDateTime(json['created_at']),
      updatedAt: DateTime.tryParse(json['updated_at'] ?? ''),
      approvalStatus: approvalStatusString,
      bedrooms: parseInt(specs?.bedrooms),
      bathrooms: parseInt(specs?.bathrooms),
      area: parseDouble(specs?.buildingSize),
      landSize: parseDouble(specs?.landSize),
      propertyType: specs?.type ?? '',
      floors: parseInt(json['floors']),
      garage: parseInt(specs?.garage),
      hasPool: json['has_pool'] == true,
      hasFireplace: json['has_fireplace'] == true,
      houseColor: specs?.houseColor,
      built: json['built'] as String?,
      compatibility: parseDouble(json['fengshui_score']),
      fengshuiScore: parseDouble(json['fengshui_score']),
      horaScore: parseDouble(json['hora_score']),
      imageUrl: imageUrl,
      imageUrls: imageUrls,
      userId: json['user_id'] as int?,
      agentId: json['agent_id'] as int?,
      sellerId: json['seller_id'] as int?,
      agencyId: json['agency_id'] as int?,
      villageName: location?.villageName,
      tower: condoDetails?.tower,
      floor: condoDetails?.floor,
      unitNo: condoDetails?.unitNo,
      houseSubtype: houseDetails?.houseSubtype,
      availableFrom: specs?.availableFrom,
      viewCount: parseInt(json['view_count']),
      clickCount: parseInt(json['click_count']),
      favoriteCount: parseInt(json['favorite_count']),
      completionPercentage: propertyStatus?.completionPercentage ?? 0,
      nextStep: propertyStatus?.nextStep,
      specs: specs,
      propertyLocation: location,
      images: images,
      floorPlans: floorPlans,
      propertyStatus: propertyStatus,
      agent: agent,
      seller: json['seller'] as Map<String, dynamic>?,
      condoDetails: condoDetails,
      houseDetails: houseDetails,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'code': code,
      'title': title,
      'description': description,
      'location': propertyLocation?.toJson(),
      'specs': specs?.toJson(),
      'images': images?.map((i) => i.toJson()).toList(),
      'floor_plans': floorPlans?.map((f) => f.toJson()).toList(),
      'status': propertyStatus?.toJson(),
      'agent': agent?.toJson(),
      'seller': seller,
      'condo_details': condoDetails?.toJson(),
      'house_details': houseDetails?.toJson(),
      'approval_status': approvalStatus,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }
}
