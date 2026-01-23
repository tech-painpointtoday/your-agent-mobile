import 'package:equatable/equatable.dart';
import 'package:youragent/domain/entities/user.dart';

abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

/// Initial state
class AuthInitial extends AuthState {
  const AuthInitial();
}

/// Loading state during authentication
class AuthLoading extends AuthState {
  const AuthLoading();
}

/// Authenticated state with user data
class Authenticated extends AuthState {
  final User user;

  const Authenticated(this.user);

  @override
  List<Object?> get props => [user];
}

/// Unauthenticated state
class Unauthenticated extends AuthState {
  const Unauthenticated();
}

/// Authentication error state
class AuthError extends AuthState {
  final String message;

  const AuthError(this.message);

  @override
  List<Object?> get props => [message];
}

/// Email not verified state
class EmailNotVerified extends AuthState {
  final String email;
  final String message;

  const EmailNotVerified({required this.email, required this.message});

  @override
  List<Object?> get props => [email, message];
}

/// Authentication cancelled state (user cancelled social login)
class AuthCancelled extends AuthState {
  const AuthCancelled();
}

/// Role selected state (for pre-login role selection)
class RoleSelected extends AuthState {
  final UserRole role;

  const RoleSelected(this.role);

  @override
  List<Object?> get props => [role];
}

/// Forgot password status enum
enum ForgotPasswordStatus { initial, loading, success, failure }

/// Reset password status enum
enum ResetPasswordStatus { initial, loading, success, failure }

/// Resend verification status enum
enum ResendVerificationStatus { initial, loading, success, failure }

/// Resend email status enum (for public resend)
enum ResendEmailStatus { initial, loading, success, failure }

/// Auth state with operation status flags (extends base AuthState)
class AuthOperationState extends AuthState {
  final ForgotPasswordStatus forgotPasswordStatus;
  final ResetPasswordStatus resetPasswordStatus;
  final ResendVerificationStatus resendVerificationStatus;
  final ResendEmailStatus resendEmailStatus;
  final String? errorMessage;
  final String? resendEmailError;

  const AuthOperationState({
    this.forgotPasswordStatus = ForgotPasswordStatus.initial,
    this.resetPasswordStatus = ResetPasswordStatus.initial,
    this.resendVerificationStatus = ResendVerificationStatus.initial,
    this.resendEmailStatus = ResendEmailStatus.initial,
    this.errorMessage,
    this.resendEmailError,
  });

  AuthOperationState copyWith({
    ForgotPasswordStatus? forgotPasswordStatus,
    ResetPasswordStatus? resetPasswordStatus,
    ResendVerificationStatus? resendVerificationStatus,
    ResendEmailStatus? resendEmailStatus,
    String? errorMessage,
    String? resendEmailError,
  }) {
    return AuthOperationState(
      forgotPasswordStatus: forgotPasswordStatus ?? this.forgotPasswordStatus,
      resetPasswordStatus: resetPasswordStatus ?? this.resetPasswordStatus,
      resendVerificationStatus: resendVerificationStatus ?? this.resendVerificationStatus,
      resendEmailStatus: resendEmailStatus ?? this.resendEmailStatus,
      errorMessage: errorMessage ?? this.errorMessage,
      resendEmailError: resendEmailError ?? this.resendEmailError,
    );
  }

  @override
  List<Object?> get props => [
        forgotPasswordStatus,
        resetPasswordStatus,
        resendVerificationStatus,
        resendEmailStatus,
        errorMessage,
        resendEmailError,
      ];
}
