/// Model classes for property filter options from /public/info API
class PropertyFilterOptions {
  final List<SingleSelectFilter> singleSelect;
  final List<MultiSelectFilter> multiSelect;

  PropertyFilterOptions({required this.singleSelect, required this.multiSelect});

  factory PropertyFilterOptions.fromJson(Map<String, dynamic> json) {
    return PropertyFilterOptions(
      singleSelect:
          (json['single_select'] as List<dynamic>?)
              ?.map((e) => SingleSelectFilter.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      multiSelect:
          (json['multi_select'] as List<dynamic>?)
              ?.map((e) => MultiSelectFilter.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() => {
    'single_select': singleSelect.map((e) => e.toJson()).toList(),
    'multi_select': multiSelect.map((e) => e.toJson()).toList(),
  };
}

class SingleSelectFilter {
  final String key;
  final String labelEn;
  final String labelTh;
  final String category;
  final List<String> options;

  SingleSelectFilter({
    required this.key,
    required this.labelEn,
    required this.labelTh,
    required this.category,
    required this.options,
  });

  factory SingleSelectFilter.fromJson(Map<String, dynamic> json) {
    return SingleSelectFilter(
      key: json['key'] as String? ?? '',
      labelEn: json['label_en'] as String? ?? '',
      labelTh: json['label_th'] as String? ?? '',
      category: json['category'] as String? ?? '',
      options: (json['options'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
    );
  }

  Map<String, dynamic> toJson() => {
    'key': key,
    'label_en': labelEn,
    'label_th': labelTh,
    'category': category,
    'options': options,
  };

  /// Get label based on locale
  String getLabel(String locale) => locale == 'th' ? labelTh : labelEn;
}

class MultiSelectFilter {
  final String key;
  final String labelEn;
  final String labelTh;
  final String category;
  final List<String> options;

  MultiSelectFilter({
    required this.key,
    required this.labelEn,
    required this.labelTh,
    required this.category,
    required this.options,
  });

  factory MultiSelectFilter.fromJson(Map<String, dynamic> json) {
    return MultiSelectFilter(
      key: json['key'] as String? ?? '',
      labelEn: json['label_en'] as String? ?? '',
      labelTh: json['label_th'] as String? ?? '',
      category: json['category'] as String? ?? '',
      options: (json['options'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
    );
  }

  Map<String, dynamic> toJson() => {
    'key': key,
    'label_en': labelEn,
    'label_th': labelTh,
    'category': category,
    'options': options,
  };

  /// Get label based on locale
  String getLabel(String locale) => locale == 'th' ? labelTh : labelEn;
}
