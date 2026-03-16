import 'package:equatable/equatable.dart';

enum UserRole { seller }

class User extends Equatable {
  final String? id;
  final String email;
  final String? displayName;
  final String? photoUrl;
  final UserRole role;
  final String provider;
  final List<String>? deviceTokens;

  const User({
    this.id,
    required this.email,
    this.displayName,
    this.photoUrl,
    required this.role,
    required this.provider,
    this.deviceTokens,
  });

  @override
  List<Object?> get props => [
    id,
    email,
    displayName,
    photoUrl,
    role,
    provider,
    deviceTokens,
  ];
}
