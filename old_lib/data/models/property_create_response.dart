import 'package:equatable/equatable.dart';
import 'package:youragent/data/models/property_status_model.dart';

/// Response data model for /agent/properties/create
/// Contains only the property data from the API response
class PropertyCreateData extends Equatable {
  final int id;
  final String? title;
  final String? built;
  final String? listingType;
  final String? approvalStatus;
  final PropertyStatusModel? status;
  final bool? allowAgentRepresentation;
  final double? fengshuiScore;
  final int viewCount;
  final int clickCount;
  final int favoriteCount;
  final int inquiryCount;
  final int shareCount;
  final DateTime? firstViewedAt;
  final DateTime? lastViewedAt;
  final DateTime? lastClickedAt;
  final DateTime? approvedAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  const PropertyCreateData({
    required this.id,
    this.title,
    this.built,
    this.listingType,
    this.approvalStatus,
    this.status,
    this.allowAgentRepresentation,
    this.fengshuiScore,
    required this.viewCount,
    required this.clickCount,
    required this.favoriteCount,
    required this.inquiryCount,
    required this.shareCount,
    this.firstViewedAt,
    this.lastViewedAt,
    this.lastClickedAt,
    this.approvedAt,
    required this.createdAt,
    required this.updatedAt,
  });

  factory PropertyCreateData.fromJson(Map<String, dynamic> json) {
    return PropertyCreateData(
      id: json['id'] as int,
      title: json['title'] as String?,
      built: json['built'] as String?,
      listingType: json['listing_type'] as String?,
      approvalStatus: json['approval_status'] as String?,
      status: json['status'] is Map<String, dynamic>
          ? PropertyStatusModel.fromJson(json['status'] as Map<String, dynamic>)
          : null,
      allowAgentRepresentation: json['allow_agent_representation'] as bool?,
      fengshuiScore: json['fengshui_score'] != null ? (json['fengshui_score'] as num).toDouble() : null,
      viewCount: json['view_count'] as int? ?? 0,
      clickCount: json['click_count'] as int? ?? 0,
      favoriteCount: json['favorite_count'] as int? ?? 0,
      inquiryCount: json['inquiry_count'] as int? ?? 0,
      shareCount: json['share_count'] as int? ?? 0,
      firstViewedAt: json['first_viewed_at'] != null ? DateTime.tryParse(json['first_viewed_at'] as String) : null,
      lastViewedAt: json['last_viewed_at'] != null ? DateTime.tryParse(json['last_viewed_at'] as String) : null,
      lastClickedAt: json['last_clicked_at'] != null ? DateTime.tryParse(json['last_clicked_at'] as String) : null,
      approvedAt: json['approved_at'] != null ? DateTime.tryParse(json['approved_at'] as String) : null,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'built': built,
      'listing_type': listingType,
      'approval_status': approvalStatus,
      'status': status?.toJson(),
      'allow_agent_representation': allowAgentRepresentation,
      'fengshui_score': fengshuiScore,
      'view_count': viewCount,
      'click_count': clickCount,
      'favorite_count': favoriteCount,
      'inquiry_count': inquiryCount,
      'share_count': shareCount,
      'first_viewed_at': firstViewedAt?.toIso8601String(),
      'last_viewed_at': lastViewedAt?.toIso8601String(),
      'last_clicked_at': lastClickedAt?.toIso8601String(),
      'approved_at': approvedAt?.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  @override
  List<Object?> get props => [
    id,
    title,
    built,
    listingType,
    approvalStatus,
    status,
    allowAgentRepresentation,
    fengshuiScore,
    viewCount,
    clickCount,
    favoriteCount,
    inquiryCount,
    shareCount,
    firstViewedAt,
    lastViewedAt,
    lastClickedAt,
    approvedAt,
    createdAt,
    updatedAt,
  ];
}
