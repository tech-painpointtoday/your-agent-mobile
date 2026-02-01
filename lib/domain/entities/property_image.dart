import 'package:equatable/equatable.dart';

class PropertyImage extends Equatable {
  final int? id;
  final int? propertyId;
  final String? url;
  final String? path;
  final String? fileName;
  final bool? isPrimary;

  const PropertyImage({
    this.id,
    this.propertyId,
    this.url,
    this.path,
    this.fileName,
    this.isPrimary,
  });

  String get displayUrl {
    // Return url if available, otherwise try to construct from path/filename or return placeholder
    if (url != null && url!.isNotEmpty) return url!;
    // If we only have relative path, we might need a base URL, currently just returning empty or what we have
    // Assuming the API might return a full URL in 'url' field
    return path ?? fileName ?? '';
  }

  factory PropertyImage.fromJson(Map<String, dynamic> json) {
    return PropertyImage(
      id: json['id'] is int
          ? json['id']
          : int.tryParse(json['id']?.toString() ?? ''),
      propertyId: json['property_id'] is int
          ? json['property_id']
          : int.tryParse(json['property_id']?.toString() ?? ''),
      url: json['url'] as String?, // Assuming API returns 'url'
      path: json['path'] as String?,
      fileName: json['file_name'] as String?,
      isPrimary: json['is_primary'] == 1 || json['is_primary'] == true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'property_id': propertyId,
      'url': url,
      'path': path,
      'file_name': fileName,
      'is_primary': isPrimary,
    };
  }

  @override
  List<Object?> get props => [id, propertyId, url, path, fileName, isPrimary];
}
