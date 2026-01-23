import 'package:equatable/equatable.dart';

enum UserRole { agent, agency }

class User extends Equatable {
  final String? id;
  final String email;
  final String? displayName;
  final String? photoUrl;
  final UserRole role;
  final String provider;

  const User({
    this.id,
    required this.email,
    this.displayName,
    this.photoUrl,
    required this.role,
    required this.provider,
  });

  @override
  List<Object?> get props => [id, email, displayName, photoUrl, role, provider];
}

