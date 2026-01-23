import 'package:equatable/equatable.dart';
import 'package:youragent/domain/entities/property_spec.dart';

/// Response data model for /agent/properties/create/specs
/// Contains only the specs data from the API response
class PropertySpecsData extends Equatable {
  final PropertySpec propertySpecs;
  final List<PropertySpecificationDefinition> specificationDefinitions;
  final String nextStep;

  const PropertySpecsData({
    required this.propertySpecs,
    required this.specificationDefinitions,
    required this.nextStep,
  });

  factory PropertySpecsData.fromJson(Map<String, dynamic> json) {
    return PropertySpecsData(
      propertySpecs: PropertySpec.fromJson(json['property_specs'] as Map<String, dynamic>? ?? {}),
      specificationDefinitions:
          (json['property_specification_definitions'] as List?)
              ?.map((e) => PropertySpecificationDefinition.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      nextStep: json['next_step'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'property_specs': propertySpecs.toJson(),
      'property_specification_definitions': specificationDefinitions.map((e) => e.toJson()).toList(),
      'next_step': nextStep,
    };
  }

  @override
  List<Object?> get props => [propertySpecs, specificationDefinitions, nextStep];
}

/// Property Specification Definition - defines available spec fields
class PropertySpecificationDefinition extends Equatable {
  final int id;
  final String key;
  final String category;
  final String labelEn;
  final String labelTh;
  final String type; // 'single_select' or 'multi_select'
  final List<String> options;
  final bool isActive;
  final int sortOrder;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const PropertySpecificationDefinition({
    required this.id,
    required this.key,
    required this.category,
    required this.labelEn,
    required this.labelTh,
    required this.type,
    required this.options,
    required this.isActive,
    required this.sortOrder,
    this.createdAt,
    this.updatedAt,
  });

  factory PropertySpecificationDefinition.fromJson(Map<String, dynamic> json) {
    return PropertySpecificationDefinition(
      id: json['id'] as int? ?? 0,
      key: json['key'] as String? ?? '',
      category: json['category'] as String? ?? '',
      labelEn: json['label_en'] as String? ?? '',
      labelTh: json['label_th'] as String? ?? '',
      type: json['type'] as String? ?? 'single_select',
      options: (json['options'] as List?)?.map((e) => e.toString()).toList() ?? [],
      isActive: json['is_active'] as bool? ?? true,
      sortOrder: json['sort_order'] as int? ?? 0,
      createdAt: json['created_at'] != null ? DateTime.tryParse(json['created_at'] as String) : null,
      updatedAt: json['updated_at'] != null ? DateTime.tryParse(json['updated_at'] as String) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'key': key,
      'category': category,
      'label_en': labelEn,
      'label_th': labelTh,
      'type': type,
      'options': options,
      'is_active': isActive,
      'sort_order': sortOrder,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  bool get isSingleSelect => type == 'single_select';
  bool get isMultiSelect => type == 'multi_select';

  @override
  List<Object?> get props => [
    id,
    key,
    category,
    labelEn,
    labelTh,
    type,
    options,
    isActive,
    sortOrder,
    createdAt,
    updatedAt,
  ];
}
