class UserProfileModel {
  final int id;
  final String name;
  final String email;
  final String? profilePhoto;
  final DateTime? emailVerifiedAt;
  final List<String>? deviceTokens;

  UserProfileModel({
    required this.id,
    required this.name,
    required this.email,
    this.profilePhoto,
    this.emailVerifiedAt,
    this.deviceTokens,
  });

  factory UserProfileModel.fromJson(Map<String, dynamic> json) {
    int parseInt(dynamic value, {int fallback = 0}) {
      if (value == null) return fallback;
      if (value is int) return value;
      if (value is num) return value.toInt();
      if (value is String) return int.tryParse(value) ?? fallback;
      return fallback;
    }

    DateTime? parseDateNullable(dynamic value) {
      if (value == null) return null;
      if (value is DateTime) return value;
      if (value is String) {
        try {
          return DateTime.parse(value);
        } catch (_) {
          return null;
        }
      }
      return null;
    }

    final emailVerifiedRaw =
        json['email_verified_at'] ?? json['emailVerifiedAt'];
    final profilePhotoRaw =
        json['profile_photo'] ?? json['profile_photo_url'] ?? json['avatar'];

    return UserProfileModel(
      id: parseInt(json['id']),
      name: (json['name'] ?? json['full_name'] ?? '').toString(),
      email: (json['email'] ?? '').toString(),
      profilePhoto: profilePhotoRaw?.toString(),
      emailVerifiedAt: parseDateNullable(emailVerifiedRaw),
      deviceTokens: json['device_tokens'] != null
          ? List<String>.from(json['device_tokens'] as Iterable)
          : null,
    );
  }

  bool get isEmailVerified => emailVerifiedAt != null;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'profile_photo': profilePhoto,
      'email_verified_at': emailVerifiedAt?.toIso8601String(),
      'device_tokens': deviceTokens,
    };
  }
}
