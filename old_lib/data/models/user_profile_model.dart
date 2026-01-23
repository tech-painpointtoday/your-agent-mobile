/// User Profile Model
/// Represents user profile data from API
class UserProfileModel {
  final int id;
  final String name;
  final String email;
  final String? profilePhoto;
  final DateTime? emailVerifiedAt;
  final String? mobileNumber;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? agentCredential;
  final DateTime? credentialUsedAt;
  final String? bio;
  final List<String>? socialLinks;
  final List<String>? languages;
  final int? yearsOfExperience;
  final String? companyName;
  final String? licenseNumber;
  final DateTime? mobileNumberVerifiedAt;
  final double? reachableRadius;
  final double? serviceAreaCenterLat;
  final double? serviceAreaCenterLng;
  final double? minCompatibilityScoreThreshold;

  UserProfileModel({
    required this.id,
    required this.name,
    required this.email,
    this.profilePhoto,
    this.emailVerifiedAt,
    this.mobileNumber,
    required this.createdAt,
    required this.updatedAt,
    this.agentCredential,
    this.credentialUsedAt,
    this.bio,
    this.socialLinks,
    this.languages,
    this.yearsOfExperience,
    this.companyName,
    this.licenseNumber,
    this.mobileNumberVerifiedAt,
    this.reachableRadius,
    this.serviceAreaCenterLat,
    this.serviceAreaCenterLng,
    this.minCompatibilityScoreThreshold,
  });

  /// More tolerant JSON parsing to handle different backend shapes.
  factory UserProfileModel.fromJson(Map<String, dynamic> json) {
    int parseInt(dynamic value, {int fallback = 0}) {
      if (value == null) return fallback;
      if (value is int) return value;
      if (value is num) return value.toInt();
      if (value is String) return int.tryParse(value) ?? fallback;
      return fallback;
    }

    double? parseDouble(dynamic value) {
      if (value == null) return null;
      if (value is num) return value.toDouble();
      if (value is String) return double.tryParse(value);
      return null;
    }

    DateTime parseDate(dynamic value, {DateTime? fallback}) {
      if (value == null) return fallback ?? DateTime.now();
      if (value is DateTime) return value;
      if (value is String) {
        try {
          return DateTime.parse(value);
        } catch (_) {
          return fallback ?? DateTime.now();
        }
      }
      return fallback ?? DateTime.now();
    }

    List<String>? parseList(dynamic value) {
      if (value == null) return null;
      if (value is List) return value.map((e) => e.toString()).toList();
      if (value is String) {
        // Simple comma separated parsing if it's a string
        if (value.contains(',')) return value.split(',').map((e) => e.trim()).toList();
        return [value];
      }
      return null;
    }

    final createdRaw = json['created_at'] ?? json['createdAt'] ?? json['created'];
    final updatedRaw = json['updated_at'] ?? json['updatedAt'] ?? json['updated'];

    final emailVerifiedRaw = json['email_verified_at'] ?? json['emailVerifiedAt'];

    final mobileVerifiedRaw = json['mobile_number_verified_at'] ?? json['mobileNumberVerifiedAt'];

    final credentialUsedRaw = json['credential_used_at'] ?? json['credentialUsedAt'];

    final profilePhotoRaw = json['profile_photo'] ?? json['profile_photo_url'] ?? json['avatar'];

    final mobileRaw = json['mobile_number'] ?? json['phone'] ?? json['phone_number'];

    return UserProfileModel(
      id: parseInt(json['id']),
      name: (json['name'] ?? json['full_name'] ?? '').toString(),
      email: (json['email'] ?? '').toString(),
      profilePhoto: profilePhotoRaw?.toString(),
      emailVerifiedAt: emailVerifiedRaw != null ? parseDate(emailVerifiedRaw) : null,
      mobileNumber: mobileRaw?.toString(),
      createdAt: parseDate(createdRaw),
      updatedAt: parseDate(updatedRaw, fallback: DateTime.now()),
      agentCredential: json['agent_credential']?.toString(),
      credentialUsedAt: credentialUsedRaw != null ? parseDate(credentialUsedRaw) : null,
      bio: json['bio']?.toString(),
      socialLinks: parseList(json['social_links']),
      languages: parseList(json['languages']),
      yearsOfExperience: json['years_of_experience'] != null ? parseInt(json['years_of_experience']) : null,
      companyName: json['company_name']?.toString(),
      licenseNumber: json['license_number']?.toString(),
      mobileNumberVerifiedAt: mobileVerifiedRaw != null ? parseDate(mobileVerifiedRaw) : null,
      reachableRadius: parseDouble(json['reachable_radius']),
      serviceAreaCenterLat: parseDouble(json['service_area_center_lat']),
      serviceAreaCenterLng: parseDouble(json['service_area_center_lng']),
      minCompatibilityScoreThreshold: parseDouble(json['min_compatibility_score_threshold']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      if (profilePhoto != null) 'profile_photo': profilePhoto,
      if (emailVerifiedAt != null) 'email_verified_at': emailVerifiedAt!.toIso8601String(),
      if (mobileNumber != null) 'mobile_number': mobileNumber,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      if (agentCredential != null) 'agent_credential': agentCredential,
      if (credentialUsedAt != null) 'credential_used_at': credentialUsedAt!.toIso8601String(),
      if (bio != null) 'bio': bio,
      if (socialLinks != null) 'social_links': socialLinks,
      if (languages != null) 'languages': languages,
      if (yearsOfExperience != null) 'years_of_experience': yearsOfExperience,
      if (companyName != null) 'company_name': companyName,
      if (licenseNumber != null) 'license_number': licenseNumber,
      if (mobileNumberVerifiedAt != null) 'mobile_number_verified_at': mobileNumberVerifiedAt!.toIso8601String(),
      if (reachableRadius != null) 'reachable_radius': reachableRadius,
      if (serviceAreaCenterLat != null) 'service_area_center_lat': serviceAreaCenterLat,
      if (serviceAreaCenterLng != null) 'service_area_center_lng': serviceAreaCenterLng,
      if (minCompatibilityScoreThreshold != null) 'min_compatibility_score_threshold': minCompatibilityScoreThreshold,
    };
  }

  /// Check if email is verified
  bool get isEmailVerified => emailVerifiedAt != null;
  bool get isMobileVerified => mobileNumberVerifiedAt != null;
}
