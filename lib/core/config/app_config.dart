import '../../flavors.dart';

enum AppEnvironment { dev, staging, prod }

class AppConfig {
  static String get baseUrl => F.baseUrl;

  static AppEnvironment get currentEnvironment {
    switch (F.appFlavor) {
      case Flavor.dev:
        return AppEnvironment.dev;
      case Flavor.staging:
        return AppEnvironment.staging;
      case Flavor.prod:
        return AppEnvironment.prod;
    }
  }

  static bool get isDev => currentEnvironment == AppEnvironment.dev;
  static bool get isStaging => currentEnvironment == AppEnvironment.staging;
  static bool get isProd => currentEnvironment == AppEnvironment.prod;

  static const String googleMapsApiKey =
      'AIzaSyCfEojoebHhrPHCZEOoqgBdb1YCgAelEFg';

  /// Pusher Channels (client uses key + cluster only; secret is server-side).
  static const String pusherKey = 'a2391ca343476cf7cfdf';
  static const String pusherCluster = 'ap1';
  static const String pusherAppId = '2036190';
}
