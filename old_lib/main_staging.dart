import 'package:flutter/material.dart';

import 'core/init/app_initializer.dart';
import 'app.dart';
import 'flavors.dart';

/// Entry point for the staging flavor (yourhome staging).
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  F.appFlavor = Flavor.staging;

  await AppInitializer.initialize();

  runApp(const App());
}







