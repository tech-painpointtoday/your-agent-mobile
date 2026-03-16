enum Flavor { dev, staging, prod }

/// Flavor configuration
class F {
  static late final Flavor appFlavor;

  static String get name => appFlavor.name;

  static String get title {
    switch (appFlavor) {
      case Flavor.dev:
        return 'YourHome Dev';
      case Flavor.staging:
        return 'YourHome Staging';
      case Flavor.prod:
        return 'YourHome';
    }
  }

  static String get baseUrl {
    switch (appFlavor) {
      case Flavor.dev:
        return 'https://dev.yourhome.co.th/api';
      case Flavor.staging:
        return 'https://staging.yourhome.co.th/api';
      case Flavor.prod:
        return 'https://yourhome.co.th/api';
    }
  }

  /// True only for production builds. Use to show banner/badge in dev/staging.
  static bool get isProduction => appFlavor == Flavor.prod;

  /// Short label for in-app banner when not production (e.g. "DEV", "STAGING").
  static String get bannerLabel {
    switch (appFlavor) {
      case Flavor.dev:
        return 'DEV';
      case Flavor.staging:
        return 'STAGING';
      case Flavor.prod:
        return '';
    }
  }
}
