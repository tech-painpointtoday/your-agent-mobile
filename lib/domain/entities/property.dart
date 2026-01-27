import 'package:equatable/equatable.dart';

/// Represents the status/approval state of a property listing
enum PropertyStatus {
  pending, // รอการอนุมัติ - Pending approval
  approved, // อนุมัติแล้ว - Approved
  rejected, // ไม่อนุมัติ - Rejected
}

/// Property entity representing a real estate property listing
class Property extends Equatable {
  // Basic identification
  final String id;
  final String code; // e.g., "000010"
  final String title; // Matches Laravel 'name'
  final String description;
  final String location; // e.g., "ปุณณวิถี, กรุงเทพมหานคร"
  final String? address; // Full address
  final double latitude;
  final double longitude;

  // Pricing & Status
  final double price;
  final PropertyStatus status;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final String? approvalStatus; // 'pending', 'approved', 'rejected'

  // Specifications
  final int bedrooms;
  final int bathrooms;
  final double area; // Area in sqm
  final double? landSize; // Land size in sq.wah
  final String propertyType; // e.g., 'house', 'condo'
  final int? floors;
  final int? garage;
  final bool hasPool;
  final bool hasFireplace;
  final String? houseColor;
  final String? built; // Construction year

  // Compatibility scores
  final double? compatibility;
  final double? fengshuiScore;
  final double? horaScore;

  // Images
  final String imageUrl; // Primary image
  final List<String>? imageUrls; // All images

  // Relationships
  final int? userId;
  final int? agentId;
  final int? sellerId;
  final int? agencyId;

  // Detail objects (simplified from model)
  final String? villageName;
  final String? tower;
  final String? floor;
  final String? unitNo;
  final String? houseSubtype;
  final String? availableFrom;

  // Performance metrics
  final int? viewCount;
  final int? clickCount;
  final int? favoriteCount;

  // Completion Status (from getPropertyStatus)
  final int completionPercentage;
  final String? nextStep;

  const Property({
    required this.id,
    required this.code,
    required this.title,
    required this.description,
    required this.location,
    this.address,
    required this.latitude,
    required this.longitude,
    this.price = 0,
    required this.status,
    required this.createdAt,
    this.updatedAt,
    this.approvalStatus,
    this.bedrooms = 0,
    this.bathrooms = 0,
    this.area = 0,
    this.landSize,
    this.propertyType = '',
    this.floors,
    this.garage,
    this.hasPool = false,
    this.hasFireplace = false,
    this.houseColor,
    this.built,
    this.compatibility,
    this.fengshuiScore,
    this.horaScore,
    required this.imageUrl,
    this.imageUrls,
    this.userId,
    this.agentId,
    this.sellerId,
    this.agencyId,
    this.villageName,
    this.tower,
    this.floor,
    this.unitNo,
    this.houseSubtype,
    this.availableFrom,
    this.viewCount,
    this.clickCount,
    this.favoriteCount,
    this.completionPercentage = 0,
    this.nextStep,
  });

  @override
  List<Object?> get props => [
    id,
    code,
    title,
    description,
    location,
    address,
    latitude,
    longitude,
    price,
    status,
    createdAt,
    updatedAt,
    approvalStatus,
    bedrooms,
    bathrooms,
    area,
    landSize,
    propertyType,
    floors,
    garage,
    hasPool,
    hasFireplace,
    houseColor,
    built,
    compatibility,
    fengshuiScore,
    horaScore,
    imageUrl,
    imageUrls,
    userId,
    agentId,
    sellerId,
    agencyId,
    villageName,
    tower,
    floor,
    unitNo,
    houseSubtype,
    availableFrom,
    viewCount,
    clickCount,
    favoriteCount,
    completionPercentage,
    nextStep,
  ];

  /// Returns the Thai label for the property status
  String get statusLabel {
    switch (status) {
      case PropertyStatus.pending:
        return 'รอการอนุมัติ';
      case PropertyStatus.approved:
        return 'อนุมัติแล้ว';
      case PropertyStatus.rejected:
        return 'ไม่อนุมัติ';
    }
  }
}
