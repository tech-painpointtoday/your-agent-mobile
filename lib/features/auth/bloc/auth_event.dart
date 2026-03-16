import 'package:equatable/equatable.dart';

import '../../../domain/entities/user.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();
  @override
  List<Object?> get props => [];
}

class SignInWithEmailEvent extends AuthEvent {
  final String email;
  final String password;
  final UserRole role;
  final bool rememberMe;

  const SignInWithEmailEvent({
    required this.email,
    required this.password,
    required this.role,
    this.rememberMe = false,
  });

  @override
  List<Object?> get props => [email, password, role, rememberMe];
}

class RegisterSellerEvent extends AuthEvent {
  final String name;
  final String email;
  final String password;
  final String passwordConfirmation;

  const RegisterSellerEvent({
    required this.name,
    required this.email,
    required this.password,
    required this.passwordConfirmation,
  });

  @override
  List<Object?> get props => [name, email, password, passwordConfirmation];
}

class SignOutEvent extends AuthEvent {
  const SignOutEvent();
}

class CheckAuthStatusEvent extends AuthEvent {
  const CheckAuthStatusEvent();
}

class SetRoleEvent extends AuthEvent {
  final UserRole role;
  const SetRoleEvent({required this.role});
  @override
  List<Object?> get props => [role];
}

class AuthForgotPasswordRequested extends AuthEvent {
  final String email;
  const AuthForgotPasswordRequested({required this.email});
  @override
  List<Object?> get props => [email];
}

class AuthResetPasswordRequested extends AuthEvent {
  final String token;
  final String email;
  final String password;
  final String passwordConfirmation;

  const AuthResetPasswordRequested({
    required this.token,
    required this.email,
    required this.password,
    required this.passwordConfirmation,
  });

  @override
  List<Object?> get props => [token, email, password, passwordConfirmation];
}

class AuthSignInWithGoogleRequested extends AuthEvent {
  final UserRole role;

  const AuthSignInWithGoogleRequested({required this.role});

  @override
  List<Object?> get props => [role];
}

class AuthSignInWithFacebookRequested extends AuthEvent {
  final UserRole role;

  const AuthSignInWithFacebookRequested({required this.role});

  @override
  List<Object?> get props => [role];
}

class AuthResendVerificationPublicRequested extends AuthEvent {
  final String email;
  const AuthResendVerificationPublicRequested({required this.email});
  @override
  List<Object?> get props => [email];
}
