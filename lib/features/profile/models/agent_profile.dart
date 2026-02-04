class AgentProfile {
  final AgentDetails agent;
  final ProfileVerificationStatus verificationStatus;
  final bool canUseSystem;
  final bool lineConnected;

  AgentProfile({
    required this.agent,
    required this.verificationStatus,
    required this.canUseSystem,
    required this.lineConnected,
  });

  factory AgentProfile.fromJson(Map<String, dynamic> json) {
    return AgentProfile(
      agent: AgentDetails.fromJson(json['agent']),
      verificationStatus: ProfileVerificationStatus.fromJson(
        json['verification_status'],
      ),
      canUseSystem: json['can_use_system'] ?? false,
      lineConnected: json['line_connected'] ?? false,
    );
  }
}

class AgentDetails {
  final int id;
  final int? agencyId;
  final String agentCredential;
  final String? credentialUsedAt;
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
  final String? mobileNumberVerifiedAt;
  final String? createdAt;
  final String? updatedAt;
  final String? nationalId;
  final String? address;
  final String? reachableRadius;
  final String? serviceAreaCenterLat;
  final String? serviceAreaCenterLng;

  AgentDetails({
    required this.id,
    this.agencyId,
    required this.agentCredential,
    this.credentialUsedAt,
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
    this.mobileNumberVerifiedAt,
    this.createdAt,
    this.updatedAt,
    this.nationalId,
    this.address,
    this.reachableRadius,
    this.serviceAreaCenterLat,
    this.serviceAreaCenterLng,
  });

  factory AgentDetails.fromJson(Map<String, dynamic> json) {
    return AgentDetails(
      id: json['id'] ?? 0,
      agencyId: json['agency_id'],
      agentCredential: json['agent_credential'] ?? '',
      credentialUsedAt: json['credential_used_at'],
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      emailVerifiedAt: json['email_verified_at'],
      mobileNumber: json['mobile_number'],
      bio: json['bio'],
      profilePhoto: json['profile_photo'],
      socialLinks: json['social_links'] is Map<String, dynamic>
          ? json['social_links'] as Map<String, dynamic>
          : null,
      languages: json['languages'] is Map<String, dynamic>
          ? json['languages'] as Map<String, dynamic>
          : null,
      yearsOfExperience: json['years_of_experience'],
      companyName: json['company_name'],
      licenseNumber: json['license_number'],
      mobileNumberVerifiedAt: json['mobile_number_verified_at'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
      nationalId: json['national_id'],
      address: json['address'],
      reachableRadius: json['reachable_radius']?.toString(),
      serviceAreaCenterLat: json['service_area_center_lat']?.toString(),
      serviceAreaCenterLng: json['service_area_center_lng']?.toString(),
    );
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
