/// Condo Project model for master data
class CondoProject {
  final int id;
  final String name;
  final int? developerId;

  CondoProject({
    required this.id,
    required this.name,
    this.developerId,
  });

  factory CondoProject.fromJson(Map<String, dynamic> json) {
    // API returns separate English and Thai names; prefer Thai for display,
    // fall back to English if Thai is missing.
    final String? nameTh = json['name_th'] as String?;
    final String? nameEn = json['name_en'] as String?;

    return CondoProject(
      id: json['id'] as int,
      name: nameTh ?? nameEn ?? '',
      developerId: json['developer_id'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      if (developerId != null) 'developer_id': developerId,
    };
  }
}
