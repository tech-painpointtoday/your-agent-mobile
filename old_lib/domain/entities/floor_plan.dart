import 'package:equatable/equatable.dart';

/// FloorPlan entity matching the old Laravel FloorPlan model
enum FloorPlanFileType {
  json,
  gltf,
  usdz,
  image, // PNG floor plan images
}

class FloorPlan extends Equatable {
  final int? id;
  final int propertyId;
  final int? propertyAgentId;
  final int? story; // Floor/story number
  final String filename;
  final String? url;
  final String? validatedUrl; // Computed attribute
  final FloorPlanFileType? fileType;
  final bool isUrlValid;
  final DateTime? urlValidatedAt;
  final String? urlType; // 's3_valid', 's3_expired', 'external'
  final DateTime? s3ExpiresAt;
  final bool needsRefresh; // Computed attribute

  const FloorPlan({
    this.id,
    required this.propertyId,
    this.propertyAgentId,
    this.story,
    required this.filename,
    this.url,
    this.validatedUrl,
    this.fileType,
    this.isUrlValid = true,
    this.urlValidatedAt,
    this.urlType,
    this.s3ExpiresAt,
    this.needsRefresh = false,
  });

  factory FloorPlan.fromJson(Map<String, dynamic> json) {
    // Check if URL needs refresh
    final bool needsRefresh = json['needs_refresh'] as bool? ??
        (json['url_type'] == 's3_expired' ||
            (json['url_type'] == 's3_valid' &&
                json['s3_expires_at'] != null &&
                DateTime.parse(json['s3_expires_at']).isBefore(DateTime.now())));

    // Get validated URL
    final String? validatedUrl = json['validated_url'] as String? ??
        (json['is_url_valid'] == true ? json['url'] as String? : null);

    return FloorPlan(
      id: json['id'] as int?,
      propertyId: json['property_id'] as int,
      propertyAgentId: json['property_agent_id'] as int?,
      story: json['story'] as int?,
      filename: json['filename'] as String,
      url: json['url'] as String?,
      validatedUrl: validatedUrl,
      fileType: _parseFileType(json['file_type']),
      isUrlValid: json['is_url_valid'] as bool? ?? true,
      urlValidatedAt: json['url_validated_at'] != null
          ? DateTime.parse(json['url_validated_at'])
          : null,
      urlType: json['url_type'] as String?,
      s3ExpiresAt: json['s3_expires_at'] != null
          ? DateTime.parse(json['s3_expires_at'])
          : null,
      needsRefresh: needsRefresh,
    );
  }

  static FloorPlanFileType? _parseFileType(dynamic type) {
    if (type is String) {
      switch (type.toLowerCase()) {
        case 'json':
          return FloorPlanFileType.json;
        case 'gltf':
        case '3d':
          return FloorPlanFileType.gltf;
        case 'usdz':
          return FloorPlanFileType.usdz;
        case 'image':
          return FloorPlanFileType.image;
        default:
          return null;
      }
    }
    return null;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'property_id': propertyId,
      'property_agent_id': propertyAgentId,
      'story': story,
      'filename': filename,
      'url': url,
      'validated_url': validatedUrl,
      'file_type': fileType?.name,
      'is_url_valid': isUrlValid,
      'url_validated_at': urlValidatedAt?.toIso8601String(),
      'url_type': urlType,
      's3_expires_at': s3ExpiresAt?.toIso8601String(),
      'needs_refresh': needsRefresh,
    };
  }

  // Get the URL to display (validated URL or fallback)
  String? get displayUrl => validatedUrl ?? url;

  // Check if this is an S3 URL
  bool get isS3Url => urlType == 's3_valid' || urlType == 's3_expired';

  @override
  List<Object?> get props => [
    id,
    propertyId,
    propertyAgentId,
    story,
    filename,
    url,
    validatedUrl,
    fileType,
    isUrlValid,
    urlValidatedAt,
    urlType,
    s3ExpiresAt,
    needsRefresh,
  ];
}


