import 'package:flutter/material.dart';

import 'app.dart';
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

  await AppInitializer.initialize();
  runApp(const App());
}

