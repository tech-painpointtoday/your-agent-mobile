import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:talker_bloc_logger/talker_bloc_logger.dart';

import 'app.dart';
import 'core/config/app_config.dart';
import 'core/di/dependency_injection.dart';
import 'core/init/app_initializer.dart';
import 'flavors.dart';

/// Default entrypoint.
///
/// Use `--dart-define=FLAVOR=dev|staging|prod` to select environment.
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  const flavorString = String.fromEnvironment('FLAVOR', defaultValue: 'dev');
  F.appFlavor = Flavor.values.firstWhere(
    (f) => f.name == flavorString,
    orElse: () => Flavor.dev,
  );

  // Initialize Talker logging observers ONLY in DEV environment
  if (AppConfig.isDev && DependencyInjection.talker != null) {
    // Attach TalkerBlocObserver to monitor BLoC events
    Bloc.observer = TalkerBlocObserver(talker: DependencyInjection.talker!);
  }

  await AppInitializer.initialize();
  runApp(const App());
}
