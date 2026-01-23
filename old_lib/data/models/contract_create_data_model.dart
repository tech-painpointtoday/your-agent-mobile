import 'package:youragent/data/models/property_model.dart';

/// Response model for contract creation data from property or booking
/// GET /agent/contracts/properties/{id}/create or /agent/contracts/bookings/{id}/create
class ContractCreateData {
  final PropertyModel? property;
  final PropertyOwner? owner;
  final String? ownerType;
  final String? contractType;
  final List<String> propertyImages;
  final List<Bank> banks;
  final Map<String, String> accountTypes;

  ContractCreateData({
    this.property,
    this.owner,
    this.ownerType,
    this.contractType,
    this.propertyImages = const [],
    this.banks = const [],
    this.accountTypes = const {},
  });

  factory ContractCreateData.fromJson(Map<String, dynamic> json) {
    return ContractCreateData(
      property: json['property'] != null ? PropertyModel.fromJson(json['property'] as Map<String, dynamic>) : null,
      owner: json['owner'] != null ? PropertyOwner.fromJson(json['owner'] as Map<String, dynamic>) : null,
      ownerType: json['owner_type'] as String?,
      contractType: json['contract_type'] as String?,
      propertyImages: (json['property_images'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      banks: (json['banks'] as List<dynamic>?)?.map((e) => Bank.fromJson(e as Map<String, dynamic>)).toList() ?? [],
      accountTypes: (json['account_types'] as Map<String, dynamic>?)?.map((k, v) => MapEntry(k, v.toString())) ?? {},
    );
  }

  /// Check if this is a buy/sale contract
  bool get isSaleContract => contractType == 'buy' || contractType == 'sale';

  /// Check if this is a rental contract
  bool get isRentalContract => contractType == 'rent' || contractType == 'rental';
}

/// Property owner/agent information
class PropertyOwner {
  final int? id;
  final int? agencyId;
  final String? name;
  final String? email;
  final String? mobileNumber;
  final String? bio;
  final String? profilePhoto;
  final String? companyName;
  final String? licenseNumber;
  final String? emailVerifiedAt;

  PropertyOwner({
    this.id,
    this.agencyId,
    this.name,
    this.email,
    this.mobileNumber,
    this.bio,
    this.profilePhoto,
    this.companyName,
    this.licenseNumber,
    this.emailVerifiedAt,
  });

  factory PropertyOwner.fromJson(Map<String, dynamic> json) {
    return PropertyOwner(
      id: json['id'] as int?,
      agencyId: json['agency_id'] as int?,
      name: json['name'] as String?,
      email: json['email'] as String?,
      mobileNumber: json['mobile_number'] as String?,
      bio: json['bio'] as String?,
      profilePhoto: json['profile_photo'] as String?,
      companyName: json['company_name'] as String?,
      licenseNumber: json['license_number'] as String?,
      emailVerifiedAt: json['email_verified_at'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'agency_id': agencyId,
    'name': name,
    'email': email,
    'mobile_number': mobileNumber,
    'bio': bio,
    'profile_photo': profilePhoto,
    'company_name': companyName,
    'license_number': licenseNumber,
    'email_verified_at': emailVerifiedAt,
  };

  /// Check if owner has verified email
  bool get isEmailVerified => emailVerifiedAt != null;
}

/// Bank information for payment setup
class Bank {
  final String code;
  final String name;

  Bank({required this.code, required this.name});

  factory Bank.fromJson(Map<String, dynamic> json) {
    return Bank(code: json['code'] as String? ?? '', name: json['name'] as String? ?? '');
  }

  Map<String, dynamic> toJson() => {'code': code, 'name': name};

  @override
  String toString() => name;

  @override
  bool operator ==(Object other) => identical(this, other) || (other is Bank && code == other.code);

  @override
  int get hashCode => code.hashCode;
}
