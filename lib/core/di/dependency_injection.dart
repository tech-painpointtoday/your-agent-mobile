import 'package:flutter/material.dart';
import 'package:talker_flutter/talker_flutter.dart';

import '../../core/config/app_config.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/usecases/auth_usecases.dart';
import '../../features/auth/bloc/auth_bloc.dart';
import '../../services/api_client.dart';
import '../../services/auth_api_service.dart';
import '../../services/chat_api_service.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

class DependencyInjection {
  // Talker instance - conditionally configured based on environment
  // If NOT Dev: Set loggerOutput: null and enable: false to disable logging overhead in Prod
  // If Dev: Enable full logging, colors, and history
  static Talker? _talkerInstance;
  
  static Talker get _talker {
    _talkerInstance ??= TalkerFlutter.init(
      settings: TalkerSettings(
        enabled: AppConfig.isDev,
        useHistory: AppConfig.isDev,
        maxHistoryItems: AppConfig.isDev ? 100 : 0,
        useConsoleLogs: AppConfig.isDev,
      ),
    );
    return _talkerInstance!;
  }
  
  // Talker getter - only active in DEV environment
  static Talker? get talker {
    if (!AppConfig.isDev) {
      return null;
    }
    return _talker;
  }

  static final ApiClient _apiClient = ApiClient();
  static final AuthApiService _authApiService = AuthApiService(_apiClient);
  static final ChatApiService _chatApiService = ChatApiService(_apiClient);
  static final AuthRepositoryImpl _authRepository = AuthRepositoryImpl(
    authApiService: _authApiService,
  );

  static ApiClient get apiClient => _apiClient;
  static AuthApiService get authApiService => _authApiService;
  static ChatApiService get chatApiService => _chatApiService;
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
