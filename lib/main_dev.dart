import 'package:flutter/material.dart';

import 'app.dart';
import 'core/error/app_error_handler.dart';
import 'core/init/app_initializer.dart';
import 'flavors.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  F.appFlavor = Flavor.dev;
  await AppInitializer.initialize();
  AppErrorHandler.initialize();
  runApp(const App());
}
