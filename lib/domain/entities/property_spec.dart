import 'package:equatable/equatable.dart';

class PropertySpec extends Equatable {
  final int? id;
  final int? propertyId;
  final String? type; // property_type
  final String? name; // property name/title in specs
  final String? description;
  final String? address;
  final String? price; // Stored as string or int
  final int? bedrooms;
  final int? bathrooms;
  final int? garage;
  final double? buildingSize;
  final double? landSize;
  final double? fengshuiScore;
  final double? horaScore;
  final int? fengshuiStars;
  final int? horaStars;
  final String? houseColor;
  final String? availableFrom;
  final Map<String, dynamic>? specifications;
  final Map<String, dynamic>? specificationValues;

  const PropertySpec({
    this.id,
    this.propertyId,
    this.type,
    this.name,
    this.description,
    this.address,
    this.price,
    this.bedrooms,
    this.bathrooms,
    this.garage,
    this.buildingSize,
    this.landSize,
    this.fengshuiScore,
    this.horaScore,
    this.fengshuiStars,
    this.horaStars,
    this.houseColor,
    this.availableFrom,
    this.specifications,
    this.specificationValues,
  });

  factory PropertySpec.fromJson(Map<String, dynamic> json) {
    return PropertySpec(
      id: json['id'] is int
          ? json['id']
          : int.tryParse(json['id']?.toString() ?? ''),
      propertyId: json['property_id'] is int
          ? json['property_id']
          : int.tryParse(json['property_id']?.toString() ?? ''),
      type: json['type']?.toString(),
      name: json['name']?.toString(),
      description: json['description']?.toString(),
      address: json['address']?.toString(),
      price: json['price']?.toString(),
      bedrooms: json['bedrooms'] is int
          ? json['bedrooms'] as int?
          : int.tryParse(json['bedrooms']?.toString() ?? '0'),
      bathrooms: json['bathrooms'] is int
          ? json['bathrooms'] as int?
          : int.tryParse(json['bathrooms']?.toString() ?? '0'),
      garage: json['garage'] is int
          ? json['garage'] as int?
          : int.tryParse(json['garage']?.toString() ?? '0'),
      buildingSize: json['building_size'] != null
          ? double.tryParse(json['building_size'].toString())
          : null,
      landSize: json['land_size'] != null
          ? double.tryParse(json['land_size'].toString())
          : null,
      fengshuiScore: json['fengshui_score'] != null
          ? double.tryParse(json['fengshui_score'].toString())
          : null,
      horaScore: json['hora_score'] != null
          ? double.tryParse(json['hora_score'].toString())
          : null,
      fengshuiStars: json['fengshui_stars'] is int
          ? json['fengshui_stars'] as int?
          : int.tryParse(json['fengshui_stars']?.toString() ?? ''),
      horaStars: json['hora_stars'] is int
          ? json['hora_stars'] as int?
          : int.tryParse(json['hora_stars']?.toString() ?? ''),
      houseColor: json['house_color']?.toString(),
      availableFrom: json['available_from']?.toString(),
      specifications: json['specifications'] is Map<String, dynamic>
          ? json['specifications'] as Map<String, dynamic>
          : null,
      specificationValues: json['specification_values'] is Map<String, dynamic>
          ? json['specification_values'] as Map<String, dynamic>
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'property_id': propertyId,
      'type': type,
      'name': name,
      'description': description,
      'address': address,
      'price': price,
      'bedrooms': bedrooms,
      'bathrooms': bathrooms,
      'garage': garage,
      'building_size': buildingSize,
      'land_size': landSize,
      'fengshui_score': fengshuiScore,
      'hora_score': horaScore,
      'fengshui_stars': fengshuiStars,
      'hora_stars': horaStars,
      'house_color': houseColor,
      'available_from': availableFrom,
      'specifications': specifications,
      'specification_values': specificationValues,
    };
  }

  @override
  List<Object?> get props => [
    id,
    propertyId,
    type,
    name,
    description,
    address,
    price,
    bedrooms,
    bathrooms,
    garage,
    buildingSize,
    landSize,
    fengshuiScore,
    horaScore,
    fengshuiStars,
    horaStars,
    houseColor,
    availableFrom,
    specifications,
    specificationValues,
  ];
}
