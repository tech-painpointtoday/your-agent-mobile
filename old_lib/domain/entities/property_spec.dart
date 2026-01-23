import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';

/// PropertySpec entity matching the old Laravel PropertySpec model
class PropertySpec extends Equatable {
  final int? id;
  final int propertyId;
  final String? name;
  final int bedrooms;
  final int bathrooms;
  final int garage;
  final String type; // Property type (e.g., 'Condo', 'House')
  final String? status;
  final String? address;
  final String price; // Stored as string in backend
  final String? description;
  final double? landSize;
  final double? buildingSize;
  final String? houseColor;
  final String? availableFrom;
  final double? horaScore;
  final double? fengshuiScore;

  // Computed attributes
  final int? horaStars;
  final int? fengshuiStars;

  // Specifications and specification values (from API)
  // specifications: object with keys like "floors", "bedrooms", etc.
  // specification_values: object with keys like "common_facilities", "furniture", etc.
  final Map<String, dynamic>? specifications;
  final Map<String, dynamic>? specificationValues;

  const PropertySpec({
    this.id,
    required this.propertyId,
    required this.name,
    required this.bedrooms,
    required this.bathrooms,
    required this.garage,
    required this.type,
    this.status,
    this.address,
    required this.price,
    this.description,
    this.landSize,
    this.buildingSize,
    this.houseColor,
    this.availableFrom,
    this.horaScore,
    this.fengshuiScore,
    this.horaStars,
    this.fengshuiStars,
    this.specifications,
    this.specificationValues,
  });

  factory PropertySpec.fromJson(Map<String, dynamic> json) {
    // Helper function to parse double values from various types
    double? parseDouble(dynamic value) {
      if (value == null) return null;
      if (value is num) return value.toDouble();
      if (value is String) return double.tryParse(value);
      return null;
    }

    // Parse scores safely (handle both string and numeric formats)
    final horaScore = parseDouble(json['hora_score']);
    final fengshuiScore = parseDouble(json['fengshui_score']);

    // Parse stars - can be int directly from API or calculated from score
    int? horaStars;
    int? fengshuiStars;

    if (json['hora_stars'] != null) {
      // If hora_stars is provided directly, use it
      if (json['hora_stars'] is int) {
        horaStars = json['hora_stars'] as int;
      } else if (json['hora_stars'] is num) {
        horaStars = (json['hora_stars'] as num).toInt();
      } else if (json['hora_stars'] is String) {
        horaStars = int.tryParse(json['hora_stars']);
      }
    } else if (horaScore != null) {
      // Calculate stars from score (5/100 * score, rounded)
      horaStars = (5 / 100 * horaScore).round();
    }

    if (json['fengshui_stars'] != null) {
      // If fengshui_stars is provided directly, use it
      if (json['fengshui_stars'] is int) {
        fengshuiStars = json['fengshui_stars'] as int;
      } else if (json['fengshui_stars'] is num) {
        fengshuiStars = (json['fengshui_stars'] as num).toInt();
      } else if (json['fengshui_stars'] is String) {
        fengshuiStars = int.tryParse(json['fengshui_stars']);
      }
    } else if (fengshuiScore != null) {
      // Calculate stars from score (5/100 * score, rounded)
      fengshuiStars = (5 / 100 * fengshuiScore).round();
    }

    return PropertySpec(
      id: json['id'] as int?,
      propertyId: json['property_id'] as int,
      name: json['name'] as String,
      bedrooms: json['bedrooms'] as int? ?? 0,
      bathrooms: json['bathrooms'] as int? ?? 0,
      garage: json['garage'] as int? ?? 0,
      type: json['type'] as String? ?? '',
      status: json['status'] as String?,
      address: json['address'] as String?,
      price: json['price']?.toString() ?? '0',
      description: json['description'] as String?,
      landSize: json['land_size'] != null
          ? double.tryParse(json['land_size'].toString())
          : null,
      buildingSize: json['building_size'] != null
          ? double.tryParse(json['building_size'].toString())
          : null,
      houseColor: json['house_color'] as String?,
      availableFrom: json['available_from'] as String?,
      horaScore: horaScore,
      fengshuiScore: fengshuiScore,
      horaStars: horaStars,
      fengshuiStars: fengshuiStars,
      // Handle specifications and specification_values as objects
      specifications: json['specifications'] is Map<String, dynamic>
          ? json['specifications'] as Map<String, dynamic>
          : json['specifications'] is List
          ? null // Old format (array) - ignore
          : null,
      specificationValues: () {
        final Map<String, dynamic>? specValues = json['specification_values'] is Map<String, dynamic>
            ? json['specification_values'] as Map<String, dynamic>
            : json['specification_values'] is List
            ? null // Old format (array) - ignore
            : null;
        
        // Reduced logging: Only log summary, not details for each specification_value
        if (specValues != null && specValues.isNotEmpty) {
          final keys = specValues.keys.toList();
          final summary = specValues.entries.map((e) {
            if (e.value is List) {
              return '${e.key}: ${(e.value as List).length} items';
            }
            return '${e.key}: ${e.value}';
          }).join(', ');
          debugPrint('PropertySpec: specification_values keys: $keys ($summary)');
        }
        // Don't log when specification_values is null/empty (too verbose)
        
        return specValues;
      }(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'property_id': propertyId,
      'name': name,
      'bedrooms': bedrooms,
      'bathrooms': bathrooms,
      'garage': garage,
      'type': type,
      'status': status,
      'address': address,
      'price': price,
      'description': description,
      'land_size': landSize,
      'building_size': buildingSize,
      'house_color': houseColor,
      'available_from': availableFrom,
      'hora_score': horaScore,
      'fengshui_score': fengshuiScore,
      'specifications': specifications,
      'specification_values': specificationValues,
    };
  }

  @override
  List<Object?> get props => [
    id,
    propertyId,
    name,
    bedrooms,
    bathrooms,
    garage,
    type,
    status,
    address,
    price,
    description,
    landSize,
    buildingSize,
    houseColor,
    availableFrom,
    horaScore,
    fengshuiScore,
    horaStars,
    fengshuiStars,
    specifications,
    specificationValues,
  ];
}
