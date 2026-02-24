import 'package:flutter/material.dart';
import 'package:youragent/data/repositories/auth_repository_impl.dart';
import 'package:youragent/domain/repositories/auth_repository.dart';
import 'package:youragent/domain/usecases/auth_usecases.dart';

import 'package:youragent/features/auth/bloc/auth_bloc.dart';
import 'package:youragent/services/api_client.dart';
import 'package:youragent/services/property_api_service.dart';
// import 'package:youragent/services/fengshui_api_service.dart';
import 'package:youragent/services/booking_api_service.dart';
import 'package:youragent/services/chat_api_service.dart';
import 'package:youragent/services/pusher_service.dart';
// import 'package:youragent/services/agent_api_service.dart';
// import 'package:youragent/services/places_service.dart';
// import 'package:youragent/services/contract_api_service.dart';
// import 'package:youragent/services/availability_api_service.dart';
import 'package:youragent/services/auth_api_service.dart';
import 'package:youragent/services/contract_api_service.dart';
import 'package:youragent/services/address_lookup_service.dart';
import 'package:youragent/services/google_places_service.dart';
import 'package:youragent/services/settings_api_service.dart';
import 'package:youragent/services/notification_api_service.dart';
import 'package:youragent/services/available_time_api_service.dart';
import 'package:youragent/core/services/deep_link_service.dart';
import 'package:youragent/core/config/app_config.dart';
import 'package:youragent/core/services/device_service.dart';
import 'package:youragent/features/chat/services/chat_search_service.dart';
import 'package:talker_flutter/talker_flutter.dart';
import 'package:youragent/core/services/push_notification_service.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:youragent/features/notifications/bloc/notification_bloc.dart';
import 'package:youragent/features/notifications/bloc/notification_event.dart';
import 'package:go_router/go_router.dart';

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
    _authRepository,
  );

  static final ChatApiService _chatApiService = ChatApiService(_apiClient);

  static final ContractApiService _contractApiService = ContractApiService(
    _apiClient,
  );

  static final AddressLookupService _addressLookupService =
      AddressLookupService();

  static final GooglePlacesService _googlePlacesService = GooglePlacesService(
    apiKey: AppConfig.googleMapsApiKey,
  );

  static final SettingsApiService _settingsApiService = SettingsApiService(
    _apiClient,
  );

  static final DeepLinkService _deepLinkService = DeepLinkService();

  static final PusherService _pusherService = PusherService();

  static final ChatSearchService _chatSearchService = ChatSearchService();

  static final AvailableTimeApiService _availableTimeApiService =
      AvailableTimeApiService(apiClient: _apiClient);

  static final BookingApiService _bookingApiService = BookingApiService(
    apiClient: _apiClient,
  );

  static final NotificationApiService _notificationApiService =
      NotificationApiService(_apiClient);

  static final PushNotificationService _pushNotificationService =
      PushNotificationService();

  static final AuthBloc _authBloc = AuthBloc(
    signInWithEmailUseCase: signInWithEmailUseCase,
    registerWithEmailUseCase: registerWithEmailUseCase,
    registerAgentUseCase: registerAgentUseCase,
    signInWithGoogleUseCase: signInWithGoogleUseCase,
    signInWithFacebookUseCase: signInWithFacebookUseCase,
    signOutUseCase: signOutUseCase,
    authRepository: authRepository,
  );

  static void init(BuildContext context) {
    // This function can be called during app startup to register dependencies
    _addressLookupService.loadData();
    _deepLinkService.init();
    _pusherService.init();
    DeviceService().init();

    // Initialize Push Notifications
    _pushNotificationService.initialize(
      onNotificationTap: (notificationId) {
        // notificationId format is 'booking_123'
        if (notificationId.startsWith('booking_')) {
          final id = notificationId.replaceFirst('booking_', '');
          navigatorKey.currentContext?.push('/chat/$id');
        } else {
          navigatorKey.currentContext?.push('/notifications/$notificationId');
        }
        // Refresh notifications list if available
        try {
          navigatorKey.currentContext?.read<NotificationBloc>().add(
            const LoadNotifications(),
          );
        } catch (_) {}
      },
      onTokenReceived: (token) {
        // DeviceService already handles storage and registration via onTokenRefresh,
        // but we can log it here or perform additional actions if needed.
        debugPrint('PushNotificationService token: $token');
      },
    );
  }

  // Factory methods for dependencies - all return singleton instances
  static ApiClient get apiClient => _apiClient;

  static PropertyApiService get propertyApiService => _propertyApiService;

  static ChatApiService get chatApiService => _chatApiService;

  static ContractApiService get contractApiService => _contractApiService;

  static AuthApiService get authApiService => _authApiService;

  static AddressLookupService get addressLookupService => _addressLookupService;

  static GooglePlacesService get googlePlacesService => _googlePlacesService;

  static SettingsApiService get settingsApiService => _settingsApiService;

  static DeepLinkService get deepLinkService => _deepLinkService;

  static PusherService get pusherService => _pusherService;

  static DeviceService get deviceService => DeviceService();

  static ChatSearchService get chatSearchService => _chatSearchService;

  static AvailableTimeApiService get availableTimeApiService =>
      _availableTimeApiService;

  static BookingApiService get bookingApiService => _bookingApiService;

  static NotificationApiService get notificationApiService =>
      _notificationApiService;

  static PushNotificationService get pushNotificationService =>
      _pushNotificationService;

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

  static AuthBloc get authBloc => _authBloc;
}
