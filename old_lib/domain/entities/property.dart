import 'package:equatable/equatable.dart';

/// Property entity matching the old Laravel Property model structure
class Property extends Equatable {
  // Basic identification
  final int? id;
  final String name;
  final String description;
  final String location;

  // Pricing
  final int price;

  // Specifications (from PropertySpec relationship)
  final int bedrooms;
  final int bathrooms;
  final double area;
  final String propertyType;
  final bool hasPool;
  final bool hasFireplace;
  final bool hasGarage;
  final int? floors;

  // Compatibility scores
  final double? compatibility; // fengshui_score
  final double? compatibilityBefore;
  final double? horaScore;
  final double? fengshuiScore;

  // Images (from PropertyImage relationship)
  final String imageUrl; // Primary image
  final List<String>? imageUrls; // All images

  // Relationships
  final int? userId;
  final int? agentId;
  final int? sellerId;
  final int? agencyId;
  final bool hasAgent;
  final int? coAgentId;

  // Approval workflow
  final String? approvalStatus; // 'pending', 'approved', 'rejected'
  final int? approvedByUserId;
  final DateTime? approvedAt;
  final String? rejectionReason;
  final bool allowAgentRepresentation;

  // Property details
  final String? built; // Construction year
  final String? listingType;

  // Performance metrics
  final int? viewCount;
  final int? clickCount;
  final int? favoriteCount;
  final int? inquiryCount;
  final int? shareCount;
  final DateTime? firstViewedAt;
  final DateTime? lastViewedAt;
  final DateTime? lastClickedAt;

  // Timestamps
  final DateTime? createdAt;
  final DateTime? updatedAt;

  // Value comparisons
  final double? valueComparison1;
  final double? valueComparison2;

  // Status (computed from approval_status)
  final String? status;

  const Property({
    this.id,
    required this.name,
    required this.description,
    required this.location,
    required this.price,
    required this.bedrooms,
    required this.bathrooms,
    required this.area,
    required this.propertyType,
    required this.hasPool,
    required this.hasFireplace,
    required this.hasGarage,
    this.floors,
    this.compatibility,
    this.compatibilityBefore,
    this.horaScore,
    this.fengshuiScore,
    required this.imageUrl,
    this.imageUrls,
    this.userId,
    this.agentId,
    this.sellerId,
    this.agencyId,
    this.hasAgent = false,
    this.coAgentId,
    this.approvalStatus,
    this.approvedByUserId,
    this.approvedAt,
    this.rejectionReason,
    this.allowAgentRepresentation = false,
    this.built,
    this.listingType,
    this.viewCount,
    this.clickCount,
    this.favoriteCount,
    this.inquiryCount,
    this.shareCount,
    this.firstViewedAt,
    this.lastViewedAt,
    this.lastClickedAt,
    this.valueComparison1,
    this.valueComparison2,
    this.status,
    this.createdAt,
    this.updatedAt,
  });

  // Computed property for price per square meter
  double get pricePerSqm => area > 0 ? price / area : 0;

  // Check if property is approved
  bool get isApproved => approvalStatus == 'approved';

  // Check if property is pending
  bool get isPending => approvalStatus == 'pending';

  // Check if property is rejected
  bool get isRejected => approvalStatus == 'rejected';

  @override
  List<Object?> get props => [
    id,
    name,
    location,
    price,
    bedrooms,
    bathrooms,
    area,
    propertyType,
    hasPool,
    hasFireplace,
    hasGarage,
    floors,
    compatibility,
    compatibilityBefore,
    horaScore,
    fengshuiScore,
    imageUrl,
    imageUrls,
    userId,
    agentId,
    sellerId,
    agencyId,
    hasAgent,
    coAgentId,
    approvalStatus,
    approvedByUserId,
    approvedAt,
    rejectionReason,
    allowAgentRepresentation,
    built,
    listingType,
    viewCount,
    clickCount,
    favoriteCount,
    inquiryCount,
    shareCount,
    firstViewedAt,
    lastViewedAt,
    lastClickedAt,
    valueComparison1,
    valueComparison2,
    status,
    createdAt,
    updatedAt,
  ];
}
