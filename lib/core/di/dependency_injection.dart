import 'package:flutter/material.dart';
import 'package:youragent/data/repositories/auth_repository_impl.dart';
import 'package:youragent/domain/repositories/auth_repository.dart';
import 'package:youragent/domain/usecases/auth_usecases.dart';

import 'package:youragent/features/auth/bloc/auth_bloc.dart';
import 'package:youragent/services/api_client.dart';
import 'package:youragent/services/property_api_service.dart';
// import 'package:youragent/services/fengshui_api_service.dart';
// import 'package:youragent/services/booking_api_service.dart';
import 'package:youragent/services/chat_api_service.dart';
// import 'package:youragent/services/floorplan_api_service.dart';
// import 'package:youragent/services/pusher_service.dart';
// import 'package:youragent/services/agent_api_service.dart';
// import 'package:youragent/services/places_service.dart';
// import 'package:youragent/services/contract_api_service.dart';
// import 'package:youragent/services/availability_api_service.dart';
import 'package:youragent/services/auth_api_service.dart';
import 'package:youragent/core/config/app_config.dart';
import 'package:talker_flutter/talker_flutter.dart';

/// Global navigator key for accessing overlay from anywhere
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

class DependencyInjection {
  // Talker instance - conditionally configured based on environment
  static Talker? _talkerInstance;

  static Talker get _talker {
    _talkerInstance ??= Talker(
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

  // Singleton instances
  static final ApiClient _apiClient = ApiClient();

  static final AuthApiService _authApiService = AuthApiService(_apiClient);

  static final AuthRepositoryImpl _authRepository = AuthRepositoryImpl(
    authApiService: _authApiService,
  );

  static final PropertyApiService _propertyApiService = PropertyApiService(
    _apiClient,
  );

  static final ChatApiService _chatApiService = ChatApiService(_apiClient);

  static void init(BuildContext context) {
    // This function can be called during app startup to register dependencies
  }

  // Factory methods for dependencies - all return singleton instances
  static ApiClient get apiClient => _apiClient;

  static PropertyApiService get propertyApiService => _propertyApiService;

  static ChatApiService get chatApiService => _chatApiService;

  static AuthApiService get authApiService => _authApiService;

  // Auth dependencies - singleton
  static AuthRepository get authRepository => _authRepository;

  static SignInWithEmail get signInWithEmailUseCase =>
      SignInWithEmail(authRepository);

  static RegisterWithEmail get registerWithEmailUseCase =>
      RegisterWithEmail(authRepository);

  static RegisterAgent get registerAgentUseCase =>
      RegisterAgent(authRepository);

  static SignInWithGoogle get signInWithGoogleUseCase =>
      SignInWithGoogle(authRepository);

  static SignInWithFacebook get signInWithFacebookUseCase =>
      SignInWithFacebook(authRepository);

  static SignOut get signOutUseCase => SignOut(authRepository);

  static AuthBloc get authBloc => AuthBloc(
    signInWithEmailUseCase: signInWithEmailUseCase,
    registerWithEmailUseCase: registerWithEmailUseCase,
    registerAgentUseCase: registerAgentUseCase,
    signInWithGoogleUseCase: signInWithGoogleUseCase,
    signInWithFacebookUseCase: signInWithFacebookUseCase,
    signOutUseCase: signOutUseCase,
    authRepository: authRepository,
  );
}
