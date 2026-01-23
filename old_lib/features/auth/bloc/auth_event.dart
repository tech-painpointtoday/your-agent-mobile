import 'package:equatable/equatable.dart';
import 'package:youragent/domain/entities/user.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

/// Sign in with email event
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

/// Register with email event
class RegisterWithEmailEvent extends AuthEvent {
  final String name;
  final String email;
  final String password;
  final UserRole role;

  const RegisterWithEmailEvent({required this.name, required this.email, required this.password, required this.role});

  @override
  List<Object?> get props => [name, email, password, role];
}

/// Register agent event
class RegisterAgentEvent extends AuthEvent {
  final String name;
  final String email;
  final String password;
  final String passwordConfirmation;

  const RegisterAgentEvent({
    required this.name,
    required this.email,
    required this.password,
    required this.passwordConfirmation,
  });

  @override
  List<Object?> get props => [name, email, password, passwordConfirmation];
}

/// Sign in with Google event
class SignInWithGoogleEvent extends AuthEvent {
  final UserRole role;

  const SignInWithGoogleEvent({required this.role});

  @override
  List<Object?> get props => [role];
}

/// Sign in with Facebook event
class SignInWithFacebookEvent extends AuthEvent {
  final UserRole role;

  const SignInWithFacebookEvent({required this.role});

  @override
  List<Object?> get props => [role];
}

/// Sign out event
class SignOutEvent extends AuthEvent {
  const SignOutEvent();
}

/// Check auth status event
class CheckAuthStatusEvent extends AuthEvent {
  const CheckAuthStatusEvent();
}

/// Set role for next sign in
class SetRoleEvent extends AuthEvent {
  final UserRole role;

  const SetRoleEvent({required this.role});

  @override
  List<Object?> get props => [role];
}

/// Forgot password event
class AuthForgotPasswordRequested extends AuthEvent {
  final String email;

  const AuthForgotPasswordRequested({required this.email});

  @override
  List<Object?> get props => [email];
}

/// Reset password event
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

/// Resend verification email event
class AuthResendVerificationRequested extends AuthEvent {
  const AuthResendVerificationRequested();
}

/// Resend verification email public event (for unauthenticated users)
class AuthResendVerificationPublicRequested extends AuthEvent {
  final String email;

  const AuthResendVerificationPublicRequested({required this.email});

  @override
  List<Object?> get props => [email];
}
