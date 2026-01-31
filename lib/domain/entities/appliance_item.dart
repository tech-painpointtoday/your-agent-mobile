import 'package:equatable/equatable.dart';

class ApplianceItem extends Equatable {
  final String id;
  final String name;
  final String? description;
  final List<String> images;
  final int? propertyImageId;
  final String? existingPhotoUrl;

  const ApplianceItem({
    required this.id,
    required this.name,
    this.description,
    this.images = const [],
    this.propertyImageId,
    this.existingPhotoUrl,
  });

  ApplianceItem copyWith({
    String? name,
    String? description,
    List<String>? images,
    int? propertyImageId,
    String? existingPhotoUrl,
    bool clearPropertyImage = false,
  }) {
    return ApplianceItem(
      id: id,
      name: name ?? this.name,
      description: description ?? this.description,
      images: images ?? this.images,
      propertyImageId: clearPropertyImage
          ? null
          : (propertyImageId ?? this.propertyImageId),
      existingPhotoUrl: clearPropertyImage
          ? null
          : (existingPhotoUrl ?? this.existingPhotoUrl),
    );
  }

  bool get hasData =>
      name.isNotEmpty ||
      (description?.isNotEmpty == true) ||
      images.isNotEmpty ||
      propertyImageId != null;

  @override
  List<Object?> get props => [
    id,
    name,
    description,
    images,
    propertyImageId,
    existingPhotoUrl,
  ];

  @override
  String toString() {
    return 'ApplianceItem(id: $id, name: $name, description: $description, images: $images, propertyImageId: $propertyImageId, existingPhotoUrl: $existingPhotoUrl)';
  }
}
