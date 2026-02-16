import 'package:equatable/equatable.dart';

class ApplianceItem extends Equatable {
  final String id;
  final String name;
  final String? description;
  final String? itemCode;
  final List<String> images;
  final int? propertyImageId;
  final String? existingPhotoUrl; // This will hold the raw photo_url
  final String? validatedPhotoUrl;
  final List<String> existingPhotoUrls; // This will hold validated_photo_urls
  final List<Map<String, dynamic>> photos; // From the 'photos' field

  const ApplianceItem({
    required this.id,
    required this.name,
    this.itemCode,
    this.description,
    this.images = const [],
    this.propertyImageId,
    this.existingPhotoUrl,
    this.validatedPhotoUrl,
    this.existingPhotoUrls = const [],
    this.photos = const [],
  });

  ApplianceItem copyWith({
    String? name,
    String? itemCode,
    String? description,
    List<String>? images,
    int? propertyImageId,
    String? existingPhotoUrl,
    String? validatedPhotoUrl,
    List<String>? existingPhotoUrls,
    List<Map<String, dynamic>>? photos,
    bool clearPropertyImage = false,
    bool clearItemCode = false,
  }) {
    return ApplianceItem(
      id: id,
      name: name ?? this.name,
      itemCode: clearItemCode ? null : (itemCode ?? this.itemCode),
      description: description ?? this.description,
      images: images ?? this.images,
      propertyImageId: clearPropertyImage
          ? null
          : (propertyImageId ?? this.propertyImageId),
      existingPhotoUrl: clearPropertyImage
          ? null
          : (existingPhotoUrl ?? this.existingPhotoUrl),
      validatedPhotoUrl: clearPropertyImage
          ? null
          : (validatedPhotoUrl ?? this.validatedPhotoUrl),
      existingPhotoUrls: existingPhotoUrls ?? this.existingPhotoUrls,
      photos: photos ?? this.photos,
    );
  }

  bool get hasData =>
      name.isNotEmpty ||
      (description?.isNotEmpty == true) ||
      images.isNotEmpty ||
      propertyImageId != null ||
      existingPhotoUrl != null ||
      validatedPhotoUrl != null ||
      existingPhotoUrls.isNotEmpty ||
      photos.isNotEmpty;

  @override
  List<Object?> get props => [
    id,
    name,
    itemCode,
    description,
    images,
    propertyImageId,
    existingPhotoUrl,
    validatedPhotoUrl,
    existingPhotoUrls,
    photos,
  ];

  @override
  String toString() {
    return 'ApplianceItem(id: $id, name: $name, description: $description, images: $images, propertyImageId: $propertyImageId, existingPhotoUrl: $existingPhotoUrl, validatedPhotoUrl: $validatedPhotoUrl, existingPhotoUrls: $existingPhotoUrls, photos: $photos)';
  }
}
