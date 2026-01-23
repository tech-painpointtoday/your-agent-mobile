import 'package:equatable/equatable.dart';

/// PropertyImage entity matching the old Laravel PropertyImage model
class PropertyImage extends Equatable {
  final int? id;
  final int propertyId;
  final String url;
  final String? validatedUrl; // Computed attribute
  final String? altText;
  final String? caption;
  final String? facingDirection;
  final String? tag;
  final bool isUrlValid;
  final DateTime? urlValidatedAt;
  final String? urlType; // 's3_valid', 's3_expired', 'external'
  final DateTime? s3ExpiresAt;
  final bool needsRefresh; // Computed attribute

  const PropertyImage({
    this.id,
    required this.propertyId,
    required this.url,
    this.validatedUrl,
    this.altText,
    this.caption,
    this.facingDirection,
    this.tag,
    this.isUrlValid = true,
    this.urlValidatedAt,
    this.urlType,
    this.s3ExpiresAt,
    this.needsRefresh = false,
  });

  factory PropertyImage.fromJson(Map<String, dynamic> json) {
    // Check if URL needs refresh (S3 URLs that are expired)
    final bool needsRefresh = json['needs_refresh'] as bool? ??
        (json['url_type'] == 's3_expired' ||
            (json['url_type'] == 's3_valid' &&
                json['s3_expires_at'] != null &&
                DateTime.parse(json['s3_expires_at']).isBefore(DateTime.now())));

    // Get validated URL (prefer validated_url, fallback to url)
    final String validatedUrl = json['validated_url'] as String? ??
        (json['is_url_valid'] == true ? json['url'] as String : '');

    return PropertyImage(
      id: json['id'] as int?,
      propertyId: json['property_id'] as int,
      url: json['url'] as String,
      validatedUrl: validatedUrl,
      altText: json['alt_text'] as String?,
      caption: json['caption'] as String?,
      facingDirection: json['facing_direction'] as String?,
      tag: json['tag'] as String?,
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

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'property_id': propertyId,
      'url': url,
      'validated_url': validatedUrl,
      'alt_text': altText,
      'caption': caption,
      'facing_direction': facingDirection,
      'tag': tag,
      'is_url_valid': isUrlValid,
      'url_validated_at': urlValidatedAt?.toIso8601String(),
      'url_type': urlType,
      's3_expires_at': s3ExpiresAt?.toIso8601String(),
      'needs_refresh': needsRefresh,
    };
  }

  // Get the URL to display (validated URL or fallback)
  String get displayUrl => validatedUrl ?? url;

  // Check if this is an S3 URL
  bool get isS3Url => urlType == 's3_valid' || urlType == 's3_expired';

  @override
  List<Object?> get props => [
    id,
    propertyId,
    url,
    validatedUrl,
    altText,
    caption,
    facingDirection,
    tag,
    isUrlValid,
    urlValidatedAt,
    urlType,
    s3ExpiresAt,
    needsRefresh,
  ];
}

