import 'package:flutter/material.dart';

import '../../data/repositories/auth_repository_impl.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/usecases/auth_usecases.dart';
import '../../features/auth/bloc/auth_bloc.dart';
import '../../services/api_client.dart';
import '../../services/auth_api_service.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

class DependencyInjection {
  static final ApiClient _apiClient = ApiClient();
  static final AuthApiService _authApiService = AuthApiService(_apiClient);
  static final AuthRepositoryImpl _authRepository =
      AuthRepositoryImpl(authApiService: _authApiService);

  static ApiClient get apiClient => _apiClient;
  static AuthApiService get authApiService => _authApiService;
  static AuthRepository get authRepository => _authRepository;

  static SignInWithEmail get signInWithEmailUseCase =>
      SignInWithEmail(_authRepository);
  static RegisterAgent get registerAgentUseCase =>
      RegisterAgent(_authRepository);
  static SignOut get signOutUseCase => SignOut(_authRepository);

  static AuthBloc get authBloc => AuthBloc(
        signInWithEmailUseCase: signInWithEmailUseCase,
        registerAgentUseCase: registerAgentUseCase,
        authRepository: _authRepository,
      );
}

