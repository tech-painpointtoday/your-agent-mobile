import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/errors/failures.dart';
import '../../../core/di/dependency_injection.dart';
import '../../../domain/repositories/auth_repository.dart';
import '../../../domain/usecases/auth_usecases.dart';
import '../../../services/credentials_storage_service.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final SignInWithEmail signInWithEmailUseCase;
  final RegisterWithEmail registerWithEmailUseCase;
  final RegisterSeller registerSellerUseCase;
  final SignInWithGoogle signInWithGoogleUseCase;
  final SignInWithFacebook signInWithFacebookUseCase;
  final SignOut signOutUseCase;
  final AuthRepository authRepository;

  AuthBloc({
    required this.signInWithEmailUseCase,
    required this.registerWithEmailUseCase,
    required this.registerSellerUseCase,
    required this.signInWithGoogleUseCase,
    required this.signInWithFacebookUseCase,
    required this.signOutUseCase,
    required this.authRepository,
  }) : super(const AuthInitial()) {
    on<SignInWithEmailEvent>(_onSignInWithEmail);
    on<RegisterSellerEvent>(_onRegisterSeller);
    on<SignOutEvent>(_onSignOut);
    on<CheckAuthStatusEvent>(_onCheckAuthStatus);
    on<SetRoleEvent>(_onSetRole);
    on<AuthForgotPasswordRequested>(_onForgotPassword);
    on<AuthResetPasswordRequested>(_onResetPassword);

    on<AuthResendVerificationPublicRequested>(_onResendVerificationPublic);
    on<AuthSignInWithGoogleRequested>(_onSignInWithGoogle);
    on<AuthSignInWithFacebookRequested>(_onSignInWithFacebook);
  }

  Future<void> _onSignInWithEmail(
    SignInWithEmailEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    final result = await signInWithEmailUseCase(
      SignInParams(
        email: event.email,
        password: event.password,
        role: event.role,
      ),
    );

    await result.fold<Future<void>>(
      (failure) async {
        if (failure is EmailNotVerifiedFailure) {
          emit(
            EmailNotVerified(email: failure.email, message: failure.message),
          );
        } else {
          emit(AuthError(failure.message));
        }
      },
      (user) async {
        if (event.rememberMe) {
          await CredentialsStorageService().saveEmail(email: event.email);
        } else {
          await CredentialsStorageService().clear();
        }
        emit(Authenticated(user));
        // Run device registration after emit so token is committed and 401 here won't block login
        Future.delayed(const Duration(milliseconds: 150), () {
          DependencyInjection.deviceService.registerDeviceAfterLogin();
        });
      },
    );
  }

  Future<void> _onRegisterSeller(
    RegisterSellerEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    final result = await registerSellerUseCase(
      RegisterSellerParams(
        name: event.name,
        email: event.email,
        password: event.password,
        passwordConfirmation: event.passwordConfirmation,
      ),
    );
    await result.fold<Future<void>>(
      (failure) async => emit(AuthError(failure.message)),
      (user) async {
        emit(RegistrationSuccess(user: user, message: 'Success'));
        Future.delayed(const Duration(milliseconds: 150), () {
          DependencyInjection.deviceService.registerDeviceAfterLogin();
        });
      },
    );
  }

  Future<void> _onSignOut(SignOutEvent event, Emitter<AuthState> emit) async {
    emit(const AuthLoading());
    final result = await DependencyInjection.signOutUseCase();
    result.fold(
      (failure) => emit(AuthError(failure.message)),
      (_) => emit(const Unauthenticated()),
    );
  }

  Future<void> _onCheckAuthStatus(
    CheckAuthStatusEvent event,
    Emitter<AuthState> emit,
  ) async {
    final user = authRepository.currentUser;
    if (user != null) {
      emit(Authenticated(user));
    } else {
      emit(const Unauthenticated());
    }
  }

  void _onSetRole(SetRoleEvent event, Emitter<AuthState> emit) {
    // also update repository role hint (used for redirect target)
    try {
      (authRepository as dynamic).setRole(event.role);
    } catch (_) {}
    emit(RoleSelected(event.role));
  }

  Future<void> _onForgotPassword(
    AuthForgotPasswordRequested event,
    Emitter<AuthState> emit,
  ) async {
    final base = state is AuthOperationState
        ? state as AuthOperationState
        : const AuthOperationState();
    emit(
      base.copyWith(
        forgotPasswordStatus: ForgotPasswordStatus.loading,
        errorMessage: null,
      ),
    );
    try {
      await DependencyInjection.authApiService.forgotPassword(
        email: event.email,
      );
      emit(base.copyWith(forgotPasswordStatus: ForgotPasswordStatus.success));
    } catch (e) {
      emit(
        base.copyWith(
          forgotPasswordStatus: ForgotPasswordStatus.failure,
          errorMessage: e.toString().replaceFirst('Exception: ', ''),
        ),
      );
    }
  }

  Future<void> _onResetPassword(
    AuthResetPasswordRequested event,
    Emitter<AuthState> emit,
  ) async {
    final base = state is AuthOperationState
        ? state as AuthOperationState
        : const AuthOperationState();
    emit(
      base.copyWith(
        resetPasswordStatus: ResetPasswordStatus.loading,
        errorMessage: null,
      ),
    );
    try {
      await DependencyInjection.authApiService.resetPassword(
        token: event.token,
        email: event.email,
        password: event.password,
        passwordConfirmation: event.passwordConfirmation,
      );
      emit(base.copyWith(resetPasswordStatus: ResetPasswordStatus.success));
    } catch (e) {
      emit(
        base.copyWith(
          resetPasswordStatus: ResetPasswordStatus.failure,
          errorMessage: e.toString().replaceFirst('Exception: ', ''),
        ),
      );
    }
  }

  Future<void> _onResendVerificationPublic(
    AuthResendVerificationPublicRequested event,
    Emitter<AuthState> emit,
  ) async {
    final base = state is AuthOperationState
        ? state as AuthOperationState
        : const AuthOperationState();
    emit(
      base.copyWith(
        resendEmailStatus: ResendEmailStatus.loading,
        resendEmailError: null,
      ),
    );
    try {
      await DependencyInjection.authApiService.resendVerificationEmailPublic(
        event.email,
      );
      emit(base.copyWith(resendEmailStatus: ResendEmailStatus.success));
    } catch (e) {
      emit(
        base.copyWith(
          resendEmailStatus: ResendEmailStatus.failure,
          resendEmailError: e.toString().replaceFirst('Exception: ', ''),
        ),
      );
    }
  }

  Future<void> _onSignInWithGoogle(
    AuthSignInWithGoogleRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    final result = await signInWithGoogleUseCase(event.role);
    await result.fold<Future<void>>(
      (failure) async => emit(AuthError(failure.message)),
      (user) async {
        emit(Authenticated(user));
        Future.delayed(const Duration(milliseconds: 150), () {
          DependencyInjection.deviceService.registerDeviceAfterLogin();
        });
      },
    );
  }

  Future<void> _onSignInWithFacebook(
    AuthSignInWithFacebookRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    final result = await signInWithFacebookUseCase(event.role);
    await result.fold<Future<void>>(
      (failure) async => emit(AuthError(failure.message)),
      (user) async {
        emit(Authenticated(user));
        Future.delayed(const Duration(milliseconds: 150), () {
          DependencyInjection.deviceService.registerDeviceAfterLogin();
        });
      },
    );
  }
}
