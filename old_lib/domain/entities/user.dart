import 'package:equatable/equatable.dart';

enum UserRole { agent, agency }

class User extends Equatable {
  final String? id;
  final String email;
  final String? displayName;
  final String? photoUrl;
  final UserRole role;
  final String provider;
  final String? licenseNumber;
  final String? businessType;
  final String? companyName;

  const User({
    this.id,
    required this.email,
    this.displayName,
    this.photoUrl,
    required this.role,
    required this.provider,
    this.licenseNumber,
    this.businessType,
    this.companyName,
  });

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'] as String?,
      email: map['email'] as String? ?? '',
      displayName: map['displayName'] as String?,
      photoUrl: map['photoUrl'] as String?,
      role: UserRole.values.firstWhere((e) => e.name == map['role'], orElse: () => UserRole.agent),
      provider: map['provider'] as String? ?? 'email',
      licenseNumber: map['licenseNumber'] as String?,
      businessType: map['businessType'] as String?,
      companyName: map['companyName'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'email': email,
      'displayName': displayName,
      'photoUrl': photoUrl,
      'role': role.name,
      'provider': provider,
      'licenseNumber': licenseNumber,
      'businessType': businessType,
      'companyName': companyName,
    };
  }

  User copyWith({
    String? id,
    String? email,
    String? displayName,
    String? photoUrl,
    UserRole? role,
    String? provider,
    String? licenseNumber,
    String? businessType,
    String? companyName,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      photoUrl: photoUrl ?? this.photoUrl,
      role: role ?? this.role,
      provider: provider ?? this.provider,
      licenseNumber: licenseNumber ?? this.licenseNumber,
      businessType: businessType ?? this.businessType,
      companyName: companyName ?? this.companyName,
    );
  }

  @override
  List<Object?> get props => [
    id,
    email,
    displayName,
    photoUrl,
    role,
    provider,
    licenseNumber,
    businessType,
    companyName,
  ];
}
