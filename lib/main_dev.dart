import 'package:flutter/material.dart';

import 'app.dart';
import 'core/init/app_initializer.dart';
import 'flavors.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  F.appFlavor = Flavor.dev;
  await AppInitializer.initialize();
  runApp(const App());
}

