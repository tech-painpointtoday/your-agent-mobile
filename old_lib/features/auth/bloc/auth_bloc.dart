import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:youragent/core/errors/failures.dart';
import 'package:youragent/core/di/dependency_injection.dart';
import 'package:youragent/domain/repositories/auth_repository.dart';
import 'package:youragent/domain/usecases/auth_usecases.dart';
import 'package:youragent/services/session_service.dart';
import 'package:youragent/services/credentials_storage_service.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final SignInWithEmail signInWithEmailUseCase;
  final RegisterWithEmail registerWithEmailUseCase;
  final RegisterAgent registerAgentUseCase;
  final SignInWithGoogle signInWithGoogleUseCase;
  final SignInWithFacebook signInWithFacebookUseCase;
  final SignOut signOutUseCase;
  final AuthRepository authRepository;

  AuthBloc({
    required this.signInWithEmailUseCase,
    required this.registerWithEmailUseCase,
    required this.registerAgentUseCase,
    required this.signInWithGoogleUseCase,
    required this.signInWithFacebookUseCase,
    required this.signOutUseCase,
    required this.authRepository,
  }) : super(const AuthInitial()) {
    on<SignInWithEmailEvent>(_onSignInWithEmail);
    on<RegisterWithEmailEvent>(_onRegisterWithEmail);
    on<RegisterAgentEvent>(_onRegisterAgent);
    on<SignInWithGoogleEvent>(_onSignInWithGoogle);
    on<SignInWithFacebookEvent>(_onSignInWithFacebook);
    on<SignOutEvent>(_onSignOut);
    on<CheckAuthStatusEvent>(_onCheckAuthStatus);
    on<SetRoleEvent>(_onSetRole);
    on<AuthForgotPasswordRequested>(_onForgotPassword);
    on<AuthResetPasswordRequested>(_onResetPassword);
    on<AuthResendVerificationRequested>(_onResendVerification);
    on<AuthResendVerificationPublicRequested>(_onResendVerificationPublic);
  }

  Future<void> _onSignInWithEmail(SignInWithEmailEvent event, Emitter<AuthState> emit) async {
    emit(const AuthLoading());

    final result = await signInWithEmailUseCase(
      SignInParams(email: event.email, password: event.password, role: event.role),
    );

    result.fold((failure) {
      // Check if this is an EmailNotVerifiedFailure
      if (failure is EmailNotVerifiedFailure) {
        emit(EmailNotVerified(email: failure.email, message: failure.message));
      } else {
        emit(AuthError(failure.message));
      }
    }, (user) {
      // Save email only if remember me is checked (password is never stored)
      if (event.rememberMe) {
        CredentialsStorageService().saveCredentials(
          email: event.email,
          // Password is intentionally not stored for security
        );
      } else {
        // Clear credentials if remember me is not checked
        CredentialsStorageService().clearCredentials();
      }
      emit(Authenticated(user));
    });
  }

  Future<void> _onRegisterWithEmail(RegisterWithEmailEvent event, Emitter<AuthState> emit) async {
    emit(const AuthLoading());

    final result = await registerWithEmailUseCase(
      RegisterParams(name: event.name, email: event.email, password: event.password, role: event.role),
    );

    result.fold((failure) => emit(AuthError(failure.message)), (user) => emit(Authenticated(user)));
  }

  Future<void> _onRegisterAgent(RegisterAgentEvent event, Emitter<AuthState> emit) async {
    emit(const AuthLoading());

    final result = await registerAgentUseCase(
      RegisterAgentParams(
        name: event.name,
        email: event.email,
        password: event.password,
        passwordConfirmation: event.passwordConfirmation,
      ),
    );

    result.fold((failure) => emit(AuthError(failure.message)), (user) => emit(Authenticated(user)));
  }

  Future<void> _onSignInWithGoogle(SignInWithGoogleEvent event, Emitter<AuthState> emit) async {
    emit(const AuthLoading());

    final result = await signInWithGoogleUseCase(event.role);

    result.fold((failure) {
      if (failure is CancellationFailure) {
        emit(const AuthCancelled());
      } else {
        emit(AuthError(failure.message));
      }
    }, (user) => emit(Authenticated(user)));
  }

  Future<void> _onSignInWithFacebook(SignInWithFacebookEvent event, Emitter<AuthState> emit) async {
    emit(const AuthLoading());

    final result = await signInWithFacebookUseCase(event.role);

    result.fold((failure) {
      if (failure is CancellationFailure) {
        emit(const AuthCancelled());
      } else {
        emit(AuthError(failure.message));
      }
    }, (user) => emit(Authenticated(user)));
  }

  Future<void> _onSignOut(SignOutEvent event, Emitter<AuthState> emit) async {
    emit(const AuthLoading());

    final result = await signOutUseCase();

    result.fold((failure) => emit(AuthError(failure.message)), (_) => emit(const Unauthenticated()));
  }

  Future<void> _onCheckAuthStatus(CheckAuthStatusEvent event, Emitter<AuthState> emit) async {
    final currentUser = authRepository.currentUser;
    if (currentUser != null) {
      // Check if session is still valid
      final sessionService = SessionService();
      final lastActivity = await sessionService.getLastActivity();

      // If no session activity recorded yet, initialize it (fresh login)
      if (lastActivity == null) {
        debugPrint('🔐 Fresh login detected, initializing session');
        await sessionService.initializeSession();
        emit(Authenticated(currentUser));
        return;
      }

      final isValid = await sessionService.isSessionValid();

      if (isValid) {
        // Session is valid, update activity and authenticate
        await sessionService.updateActivity();
        emit(Authenticated(currentUser));
      } else {
        // Session expired - but check if this is a timing issue
        final now = DateTime.now();
        final timeSinceLastActivity = now.difference(lastActivity);

        // Be more lenient in the first 5 seconds after login to avoid race conditions
        // This handles the case where the session check happens before session init completes
        if (timeSinceLastActivity.inSeconds < 5) {
          debugPrint(
            '⚠️ Possible timing issue detected (${timeSinceLastActivity.inSeconds}s since last activity), re-initializing session',
          );
          // Re-initialize session and authenticate rather than logging out
          await sessionService.initializeSession();
          emit(Authenticated(currentUser));
        } else {
          // Session truly expired, logout user
          debugPrint('⏰ Session expired (${timeSinceLastActivity.inSeconds}s since last activity), logging out');
          add(const SignOutEvent());
        }
      }
    } else {
      emit(const Unauthenticated());
    }
  }

  void _onSetRole(SetRoleEvent event, Emitter<AuthState> emit) {
    emit(RoleSelected(event.role));
  }

  Future<void> _onForgotPassword(
    AuthForgotPasswordRequested event,
    Emitter<AuthState> emit,
  ) async {
    final currentState = state;
    final operationState = currentState is AuthOperationState
        ? currentState
        : const AuthOperationState();
    
    emit(operationState.copyWith(
      forgotPasswordStatus: ForgotPasswordStatus.loading,
      errorMessage: null,
    ));

    try {
      await DependencyInjection.authApiService.forgotPassword(
        email: event.email,
      );
      emit(operationState.copyWith(
        forgotPasswordStatus: ForgotPasswordStatus.success,
      ));
    } catch (e) {
      emit(operationState.copyWith(
        forgotPasswordStatus: ForgotPasswordStatus.failure,
        errorMessage: e.toString().replaceFirst('Exception: ', ''),
      ));
    }
  }

  Future<void> _onResetPassword(
    AuthResetPasswordRequested event,
    Emitter<AuthState> emit,
  ) async {
    final currentState = state;
    final operationState = currentState is AuthOperationState
        ? currentState
        : const AuthOperationState();
    
    emit(operationState.copyWith(
      resetPasswordStatus: ResetPasswordStatus.loading,
      errorMessage: null,
    ));

    try {
      await DependencyInjection.authApiService.resetPassword(
        token: event.token,
        email: event.email,
        password: event.password,
        passwordConfirmation: event.passwordConfirmation,
      );
      emit(operationState.copyWith(
        resetPasswordStatus: ResetPasswordStatus.success,
      ));
    } catch (e) {
      emit(operationState.copyWith(
        resetPasswordStatus: ResetPasswordStatus.failure,
        errorMessage: e.toString().replaceFirst('Exception: ', ''),
      ));
    }
  }

  Future<void> _onResendVerification(
    AuthResendVerificationRequested event,
    Emitter<AuthState> emit,
  ) async {
    final currentState = state;
    final operationState = currentState is AuthOperationState
        ? currentState
        : const AuthOperationState();
    
    emit(operationState.copyWith(
      resendVerificationStatus: ResendVerificationStatus.loading,
      errorMessage: null,
    ));

    try {
      await DependencyInjection.authApiService.resendVerificationAuthenticated();
      emit(operationState.copyWith(
        resendVerificationStatus: ResendVerificationStatus.success,
      ));
    } catch (e) {
      emit(operationState.copyWith(
        resendVerificationStatus: ResendVerificationStatus.failure,
        errorMessage: e.toString().replaceFirst('Exception: ', ''),
      ));
    }
  }

  Future<void> _onResendVerificationPublic(
    AuthResendVerificationPublicRequested event,
    Emitter<AuthState> emit,
  ) async {
    final currentState = state;
    final operationState = currentState is AuthOperationState
        ? currentState
        : const AuthOperationState();
    
    emit(operationState.copyWith(
      resendEmailStatus: ResendEmailStatus.loading,
      resendEmailError: null,
    ));

    try {
      await DependencyInjection.authApiService.resendVerificationEmailPublic(event.email);
      emit(operationState.copyWith(
        resendEmailStatus: ResendEmailStatus.success,
      ));
    } catch (e) {
      emit(operationState.copyWith(
        resendEmailStatus: ResendEmailStatus.failure,
        resendEmailError: e.toString().replaceFirst('Exception: ', ''),
      ));
    }
  }
}
