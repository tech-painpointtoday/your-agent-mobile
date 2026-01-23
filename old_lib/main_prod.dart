import 'package:flutter/material.dart';

import 'core/init/app_initializer.dart';
import 'app.dart';
import 'flavors.dart';

/// Entry point for the prod flavor (yourhome production).
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  F.appFlavor = Flavor.prod;

  await AppInitializer.initialize();

  runApp(const App());
}







