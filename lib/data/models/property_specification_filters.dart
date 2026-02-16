import 'package:equatable/equatable.dart';

class PropertySpecificationFilters extends Equatable {
  final List<PropertySpecification> singleSelect;
  final List<PropertySpecification> multiSelect;

  const PropertySpecificationFilters({
    this.singleSelect = const [],
    this.multiSelect = const [],
  });

  factory PropertySpecificationFilters.fromJson(Map<String, dynamic> json) {
    // Navigate into 'filters' if it exists (for compatibility with data['data'] wrapper)
    final filters = json['filters'] as Map<String, dynamic>? ?? json;

    return PropertySpecificationFilters(
      singleSelect:
          (filters['single_select'] as List<dynamic>?)
              ?.map(
                (e) =>
                    PropertySpecification.fromJson(e as Map<String, dynamic>),
              )
              .toList() ??
          [],
      multiSelect:
          (filters['multi_select'] as List<dynamic>?)
              ?.map(
                (e) =>
                    PropertySpecification.fromJson(e as Map<String, dynamic>),
              )
              .toList() ??
          [],
    );
  }

  @override
  List<Object?> get props => [singleSelect, multiSelect];
}

class PropertySpecification extends Equatable {
  final String key;
  final String labelEn;
  final String labelTh;
  final String label;
  final String category;
  final List<String> options;
  final List<PropertySpecificationOption> optionsWithImages;

  const PropertySpecification({
    required this.key,
    required this.labelEn,
    required this.labelTh,
    required this.label,
    required this.category,
    required this.options,
    this.optionsWithImages = const [],
  });

  factory PropertySpecification.fromJson(Map<String, dynamic> json) {
    return PropertySpecification(
      key: json['key'] as String? ?? '',
      labelEn: json['label_en'] as String? ?? '',
      labelTh: json['label_th'] as String? ?? '',
      label: json['label'] as String? ?? '',
      category: json['category'] as String? ?? 'structure',
      options:
          (json['options'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      optionsWithImages:
          (json['options_with_images'] as List<dynamic>?)
              ?.map(
                (e) => PropertySpecificationOption.fromJson(
                  e as Map<String, dynamic>,
                ),
              )
              .toList() ??
          [],
    );
  }

  @override
  List<Object?> get props => [
    key,
    labelEn,
    labelTh,
    label,
    category,
    options,
    optionsWithImages,
  ];
}

class PropertySpecificationOption extends Equatable {
  final String value;
  final String label;
  final String labelTh;
  final String? imageUrl;

  const PropertySpecificationOption({
    required this.value,
    required this.label,
    required this.labelTh,
    this.imageUrl,
  });

  factory PropertySpecificationOption.fromJson(Map<String, dynamic> json) {
    return PropertySpecificationOption(
      value: json['value'] as String? ?? '',
      label: json['label'] as String? ?? '',
      labelTh: json['label_th'] as String? ?? '',
      imageUrl: json['image_url'] as String?,
    );
  }

  @override
  List<Object?> get props => [value, label, labelTh, imageUrl];
}
