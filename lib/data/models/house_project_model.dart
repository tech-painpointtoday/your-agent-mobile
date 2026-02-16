/// House Project model for master data
class HouseProject {
  final int id;
  final String name;
  final String nameTh;
  final String nameEn;
  final int? developerId;
  final String? juristicContactPhone;
  final String? juristicContactEmail;

  HouseProject({
    required this.id,
    required this.name,
    required this.nameTh,
    required this.nameEn,
    this.developerId,
    this.juristicContactPhone,
    this.juristicContactEmail,
  });

  factory HouseProject.fromJson(Map<String, dynamic> json) {
    final String nameTh = json['name_th'] as String? ?? '';
    final String nameEn = json['name_en'] as String? ?? '';
    final String name =
        (json['name_th'] as String?) ?? (json['name_en'] as String?) ?? '';

    return HouseProject(
      id: json['id'] as int,
      name: name,
      nameTh: nameTh,
      nameEn: nameEn,
      developerId: json['developer_id'] as int?,
      juristicContactPhone: json['juristic_contact_phone'] as String?,
      juristicContactEmail: json['juristic_contact_email'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'name_th': nameTh,
      'name_en': nameEn,
      if (developerId != null) 'developer_id': developerId,
      if (juristicContactPhone != null)
        'juristic_contact_phone': juristicContactPhone,
      if (juristicContactEmail != null)
        'juristic_contact_email': juristicContactEmail,
    };
  }
}
