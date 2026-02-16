/// Condo Project model for master data
class CondoProject {
  final int id;
  final String name;
  final int? developerId;
  final String? juristicContactPhone;
  final String? juristicContactEmail;

  CondoProject({
    required this.id,
    required this.name,
    this.developerId,
    this.juristicContactPhone,
    this.juristicContactEmail,
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
      juristicContactPhone: json['juristic_contact_phone'] as String?,
      juristicContactEmail: json['juristic_contact_email'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      if (developerId != null) 'developer_id': developerId,
      if (juristicContactPhone != null)
        'juristic_contact_phone': juristicContactPhone,
      if (juristicContactEmail != null)
        'juristic_contact_email': juristicContactEmail,
    };
  }
}
