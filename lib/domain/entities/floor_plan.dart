import 'package:equatable/equatable.dart';

class FloorPlan extends Equatable {
  final int? id;
  final int? propertyId;
  final String? imageUrl;
  final String? description;
  final int? order;

  const FloorPlan({
    this.id,
    this.propertyId,
    this.imageUrl,
    this.description,
    this.order,
  });

  factory FloorPlan.fromJson(Map<String, dynamic> json) {
    return FloorPlan(
      id: json['id'] as int?,
      propertyId: json['property_id'] as int?,
      imageUrl: json['image_url'] as String?,
      description: json['description'] as String?,
      order: json['order'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'property_id': propertyId,
      'image_url': imageUrl,
      'description': description,
      'order': order,
    };
  }

  @override
  List<Object?> get props => [id, propertyId, imageUrl, description, order];
}
