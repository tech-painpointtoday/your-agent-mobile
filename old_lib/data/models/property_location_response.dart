import 'package:equatable/equatable.dart';
import 'package:youragent/domain/entities/property_location.dart';

/// Response data model for /agent/properties/create/location
/// Contains only the location data from the API response
class PropertyLocationData extends Equatable {
  final PropertyLocation propertyLocation;
  final String nextStep;

  const PropertyLocationData({required this.propertyLocation, required this.nextStep});

  factory PropertyLocationData.fromJson(Map<String, dynamic> json) {
    return PropertyLocationData(
      propertyLocation: PropertyLocation.fromJson(json['property_location'] as Map<String, dynamic>? ?? {}),
      nextStep: json['next_step'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {'property_location': propertyLocation.toJson(), 'next_step': nextStep};
  }

  @override
  List<Object?> get props => [propertyLocation, nextStep];
}
