import 'dart:convert';

class SellerProfile {
  final SellerDetails seller;

  SellerProfile({
    required this.seller,
  });

  factory SellerProfile.fromJson(Map<String, dynamic> json) {
    // API response shape:
    // {
    //   "success": true,
    //   "data": {
    //     "id": ...,
    //     "name": ...,
    //     ...
    //   }
    // }
    final data = json['data'] is Map<String, dynamic>
        ? json['data'] as Map<String, dynamic>
        : json;

    return SellerProfile(
      seller: SellerDetails.fromJson(data),
    );
  }
}

class SellerDetails {
  final int id;
  final String name;
  final String email;
  final String? emailVerifiedAt;
  final String? mobileNumber;
  final String? bio;
  final String? profilePhoto;
  final Map<String, dynamic>? socialLinks;
  final Map<String, dynamic>? languages;
  final int? yearsOfExperience;
  final String? companyName;
  final String? licenseNumber;
  final String? businessType;
  final String? businessRegistrationNumber;
  final String? businessAddress;
  final String? createdAt;
  final String? updatedAt;

  SellerDetails({
    required this.id,
    required this.name,
    required this.email,
    this.emailVerifiedAt,
    this.mobileNumber,
    this.bio,
    this.profilePhoto,
    this.socialLinks,
    this.languages,
    this.yearsOfExperience,
    this.companyName,
    this.licenseNumber,
    this.businessType,
    this.businessRegistrationNumber,
    this.businessAddress,
    this.createdAt,
    this.updatedAt,
  });

  factory SellerDetails.fromJson(Map<String, dynamic> json) {
    return SellerDetails(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      emailVerifiedAt: json['email_verified_at'],
      mobileNumber: json['mobile_number'],
      bio: json['bio'],
      profilePhoto: json['profile_photo'],
      socialLinks: json['social_links'] is Map<String, dynamic>
          ? json['social_links'] as Map<String, dynamic>
          : (json['social_links'] is String
              ? jsonDecode(json['social_links']) as Map<String, dynamic>
              : null),
      languages: json['languages'] is Map<String, dynamic>
          ? json['languages'] as Map<String, dynamic>
          : (json['languages'] is String
              ? jsonDecode(json['languages']) as Map<String, dynamic>
              : null),
      yearsOfExperience: json['years_of_experience'],
      companyName: json['company_name'],
      licenseNumber: json['license_number'],
      businessType: json['business_type'],
      businessRegistrationNumber: json['business_registration_number'],
      businessAddress: json['business_address'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
    );
  }

  int get profileLevel {
    final hasWorkInfo = companyName?.isNotEmpty == true;
    final hasServiceArea = businessAddress?.isNotEmpty == true;

    int currentLevel = 1;
    if (hasWorkInfo) currentLevel = 2;
    if (hasWorkInfo && hasServiceArea) currentLevel = 3;
    return currentLevel;
  }
}

class ProfileVerificationStatus {
  final bool isVerified;
  final bool emailVerified;
  final bool mobileVerified;
  final bool canUseSystem;
  final List<dynamic> pendingVerifications;

  ProfileVerificationStatus({
    required this.isVerified,
    required this.emailVerified,
    required this.mobileVerified,
    required this.canUseSystem,
    required this.pendingVerifications,
  });

  factory ProfileVerificationStatus.fromJson(Map<String, dynamic> json) {
    return ProfileVerificationStatus(
      isVerified: json['is_verified'] ?? false,
      emailVerified: json['email_verified'] ?? false,
      mobileVerified: json['mobile_verified'] ?? false,
      canUseSystem: json['can_use_system'] ?? false,
      pendingVerifications: json['pending_verifications'] ?? [],
    );
  }
}

