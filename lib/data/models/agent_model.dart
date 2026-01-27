class AgentModel {
  final int id;
  final String name;
  final String email;
  final String? mobileNumber;
  final String? bio;
  final String? profilePhoto;
  final Map<String, dynamic>? socialLinks;
  final String? languages;
  final String? yearsOfExperience;
  final String? companyName;
  final String? licenseNumber;
  final String? reachableRadius;
  final double? serviceAreaCenterLat;
  final double? serviceAreaCenterLng;
  final int? agencyId;
  final DateTime? emailVerifiedAt;
  final bool? lineConnected;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  AgentModel({
    required this.id,
    required this.name,
    required this.email,
    this.mobileNumber,
    this.bio,
    this.profilePhoto,
    this.socialLinks,
    this.languages,
    this.yearsOfExperience,
    this.companyName,
    this.licenseNumber,
    this.reachableRadius,
    this.serviceAreaCenterLat,
    this.serviceAreaCenterLng,
    this.agencyId,
    this.emailVerifiedAt,
    this.lineConnected,
    this.createdAt,
    this.updatedAt,
  });

  factory AgentModel.fromJson(Map<String, dynamic> json) {
    DateTime? parseDateTime(dynamic value) {
      if (value == null) return null;
      if (value is DateTime) return value;
      if (value is String) {
        try {
          return DateTime.parse(value);
        } catch (e) {
          return null;
        }
      }
      return null;
    }

    double? parseDouble(dynamic value) {
      if (value == null) return null;
      if (value is num) return value.toDouble();
      if (value is String) return double.tryParse(value);
      return null;
    }

    return AgentModel(
      id: json['id'] as int,
      name: json['name'] as String? ?? 'Unknown Agent',
      email: json['email'] as String? ?? '',
      mobileNumber: json['mobile_number'] as String?,
      bio: json['bio'] as String?,
      profilePhoto: json['profile_photo'] as String?,
      socialLinks: json['social_links'] as Map<String, dynamic>?,
      languages: json['languages'] as String?,
      yearsOfExperience: json['years_of_experience']?.toString(),
      companyName: json['company_name'] as String?,
      licenseNumber: json['license_number'] as String?,
      reachableRadius: json['reachable_radius']?.toString(),
      serviceAreaCenterLat: parseDouble(json['service_area_center_lat']),
      serviceAreaCenterLng: parseDouble(json['service_area_center_lng']),
      agencyId: json['agency_id'] as int?,
      emailVerifiedAt: parseDateTime(json['email_verified_at']),
      lineConnected:
          json['line_connected'] == true || json['line_connected'] == 1,
      createdAt: parseDateTime(json['created_at']),
      updatedAt: parseDateTime(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'mobile_number': mobileNumber,
      'bio': bio,
      'profile_photo': profilePhoto,
      'social_links': socialLinks,
      'languages': languages,
      'years_of_experience': yearsOfExperience,
      'company_name': companyName,
      'license_number': licenseNumber,
      'reachable_radius': reachableRadius,
      'service_area_center_lat': serviceAreaCenterLat,
      'service_area_center_lng': serviceAreaCenterLng,
      'agency_id': agencyId,
      'email_verified_at': emailVerifiedAt?.toIso8601String(),
      'line_connected': lineConnected,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }
}
