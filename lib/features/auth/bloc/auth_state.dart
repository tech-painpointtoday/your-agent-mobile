import 'package:equatable/equatable.dart';

import '../../../domain/entities/user.dart';

abstract class AuthState extends Equatable {
  const AuthState();
  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {
  const AuthInitial();
}

class AuthLoading extends AuthState {
  const AuthLoading();
}

class Authenticated extends AuthState {
  final User user;
  const Authenticated(this.user);

  @override
  List<Object?> get props => [user];
}

class Unauthenticated extends AuthState {
  const Unauthenticated();
}

class AuthError extends AuthState {
  final String message;
  const AuthError(this.message);

  @override
  List<Object?> get props => [message];
}

class EmailNotVerified extends AuthState {
  final String email;
  final String message;
  const EmailNotVerified({required this.email, required this.message});

  @override
  List<Object?> get props => [email, message];
}

class RoleSelected extends AuthState {
  final UserRole role;
  const RoleSelected(this.role);

  @override
  List<Object?> get props => [role];
}

enum ForgotPasswordStatus { initial, loading, success, failure }
enum ResetPasswordStatus { initial, loading, success, failure }
enum ResendEmailStatus { initial, loading, success, failure }

class AuthOperationState extends AuthState {
  final ForgotPasswordStatus forgotPasswordStatus;
  final ResetPasswordStatus resetPasswordStatus;
  final ResendEmailStatus resendEmailStatus;
  final String? errorMessage;
  final String? resendEmailError;

  const AuthOperationState({
    this.forgotPasswordStatus = ForgotPasswordStatus.initial,
    this.resetPasswordStatus = ResetPasswordStatus.initial,
    this.resendEmailStatus = ResendEmailStatus.initial,
    this.errorMessage,
    this.resendEmailError,
  });

  AuthOperationState copyWith({
    ForgotPasswordStatus? forgotPasswordStatus,
    ResetPasswordStatus? resetPasswordStatus,
    ResendEmailStatus? resendEmailStatus,
    String? errorMessage,
    String? resendEmailError,
  }) {
    return AuthOperationState(
      forgotPasswordStatus: forgotPasswordStatus ?? this.forgotPasswordStatus,
      resetPasswordStatus: resetPasswordStatus ?? this.resetPasswordStatus,
      resendEmailStatus: resendEmailStatus ?? this.resendEmailStatus,
      errorMessage: errorMessage ?? this.errorMessage,
      resendEmailError: resendEmailError ?? this.resendEmailError,
    );
  }

  @override
  List<Object?> get props => [
        forgotPasswordStatus,
        resetPasswordStatus,
        resendEmailStatus,
        errorMessage,
        resendEmailError,
      ];
}

