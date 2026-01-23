import 'package:flutter/material.dart';

import 'core/init/app_initializer.dart';
import 'app.dart';
import 'flavors.dart';

/// Entry point for the dev flavor (yourhome dev).
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  F.appFlavor = Flavor.dev;

  await AppInitializer.initialize();

  runApp(const App());
}







