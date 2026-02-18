import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import '../../firebase_options.dart' as firebase_prod;
import '../../firebase_options_dev.dart' as firebase_dev;
import '../../flavors.dart';
import '../config/app_config.dart';

class AppInitializer {
  static Future<void> initialize() async {
    // Initialize Firebase based on flavor
    await _initializeFirebase();
    // Enable Crashlytics for staging and prod only (optional: set to true for all)
    await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(!AppConfig.isDev);
  }

  static Future<void> _initializeFirebase() async {
    FirebaseOptions options;

    switch (F.appFlavor) {
      case Flavor.dev:
        options = firebase_dev.DefaultFirebaseOptions.currentPlatform;
        break;
      case Flavor.staging:
        // Use production config for staging for now
        options = firebase_prod.DefaultFirebaseOptions.currentPlatform;
        break;
      case Flavor.prod:
        options = firebase_prod.DefaultFirebaseOptions.currentPlatform;
        break;
    }

    await Firebase.initializeApp(options: options);
  }
}
