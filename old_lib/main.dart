import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_web_plugins/flutter_web_plugins.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:talker_bloc_logger/talker_bloc_logger.dart';
import 'core/init/app_initializer.dart';
import 'app.dart';
import 'flavors.dart';
import 'core/config/app_config.dart';
import 'core/di/dependency_injection.dart';

// Conditional import for web plugin registration
import 'services/location_service_web_stub.dart'
    if (dart.library.html) 'services/location_service_web.dart'
    as location_service;

// Default to empty string if not provided
const String appFlavor = String.fromEnvironment(
  'FLAVOR',
  defaultValue: 'local',
);

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Register web plugins (location service)
  if (kIsWeb) {
    try {
      // Register location service using web plugin registrar
      location_service.LocationServiceWeb.registerWith(webPluginRegistrar);
    } catch (e) {
      debugPrint('Warning: Could not register location service: $e');
    }
  }

  // Set app flavor FIRST before any services that depend on it (like ApiClient)
  F.appFlavor = Flavor.values.firstWhere(
    (element) => element.name == appFlavor,
    orElse: () => Flavor.local, // Default to local if FLAVOR is missing
  );

  // Initialize Talker logging observers ONLY in DEV environment
  if (AppConfig.isDev && DependencyInjection.talker != null) {
    // Attach TalkerBlocObserver to monitor BLoC events
    Bloc.observer = TalkerBlocObserver(talker: DependencyInjection.talker!);

    // Note: TalkerDioLogger should be attached to Dio instance in ApiClient
    // This is typically done in the ApiClient constructor or initialization
    // Example: dio.interceptors.add(TalkerDioLogger(talker: DependencyInjection.talker!));
  }

  // Initialize app services (Facebook SDK, etc.) - this may create ApiClient which needs F.baseUrl
  await AppInitializer.initialize();

  runApp(const App());
}
