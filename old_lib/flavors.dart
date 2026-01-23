enum Flavor { local, dev, staging, prod }

class F {
  static late final Flavor appFlavor;

  static String get name => appFlavor.name;

  static String get title {
    switch (appFlavor) {
      case Flavor.local:
        return 'YourAgent Local';
      case Flavor.dev:
        return 'YourAgent Dev';
      case Flavor.staging:
        return 'YourAgent Staging';
      case Flavor.prod:
        return 'YourAgent';
    }
  }

  static String get baseUrl {
    switch (appFlavor) {
      case Flavor.local:
        return 'http://localhost:8080/api';
      case Flavor.dev:
        return 'https://dev.yourhome.co.th/api';
      case Flavor.staging:
        return 'https://staging.yourhome.co.th/api';
      case Flavor.prod:
        return 'https://yourhome.co.th/api';
    }
  }
}


