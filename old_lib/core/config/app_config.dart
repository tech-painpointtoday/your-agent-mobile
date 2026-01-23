import 'package:youragent/flavors.dart';

/// App environment enum
enum AppEnvironment {
  dev,
  staging,
  prod,
}

/// App configuration constants
class AppConfig {
  // Google Maps API Key
  // Get your API key from: https://console.cloud.google.com/google/maps-apis
  // Enable "Maps Embed API" for your project
  //
  // To get a valid API key:
  // 1. Go to https://console.cloud.google.com/
  // 2. Create a project or select an existing one
  // 3. Enable "Maps Embed API" in APIs & Services > Library
  // 4. Go to APIs & Services > Credentials
  // 5. Create API Key (or use existing one)
  // 6. Restrict the API key to "Maps Embed API" for security
  // 7. Replace the key below
  static const String googleMapsApiKey =
      'AIzaSyCfEojoebHhrPHCZEOoqgBdb1YCgAelEFg';

  // Check if Google Maps API key is configured
  static bool get hasGoogleMapsApiKey =>
      googleMapsApiKey.isNotEmpty &&
      googleMapsApiKey != 'AIzaSyCfEojoebHhrPHCZEOoqgBdb1YCgAelEFg';

  // Base URL from flavor configuration
  static String get baseUrl => F.baseUrl;

  /// Current app environment based on flavor
  /// Maps Flavor enum to AppEnvironment enum
  static AppEnvironment get currentEnvironment {
    switch (F.appFlavor) {
      case Flavor.local:
      case Flavor.dev:
        return AppEnvironment.dev;
      case Flavor.staging:
        return AppEnvironment.staging;
      case Flavor.prod:
        return AppEnvironment.prod;
    }
  }

  /// Check if current environment is DEV
  /// Returns true only if currentEnvironment == AppEnvironment.dev
  static bool get isDev => currentEnvironment == AppEnvironment.dev;

  /// Check if current environment is STAGING
  static bool get isStaging => currentEnvironment == AppEnvironment.staging;

  /// Check if current environment is PROD
  static bool get isProd => currentEnvironment == AppEnvironment.prod;
}
