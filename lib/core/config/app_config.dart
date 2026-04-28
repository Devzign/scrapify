/// Flavor enumeration
enum AppFlavor { dev, staging, production }

/// Global app configuration — initialized once at startup from the entry point.
class AppConfig {
  static bool _initialized = false;
  static bool get isInitialized => _initialized;
  AppConfig._({
    required this.flavor,
    required this.appName,
    required this.baseUrl,
  });

  static late AppConfig _instance;
  static AppConfig get instance => _instance;

  final AppFlavor flavor;
  final String appName;
  final String baseUrl;

  bool get isDev => flavor == AppFlavor.dev;
  bool get isStaging => flavor == AppFlavor.staging;
  bool get isProduction => flavor == AppFlavor.production;

  static void initialize(AppFlavor flavor) {
    _instance = AppConfig._(
      flavor: flavor,
      appName: switch (flavor) {
        AppFlavor.dev => 'Scrapify Dev',
        AppFlavor.staging => 'Scrapify Stag',
        AppFlavor.production => 'Scrapify',
      },
      baseUrl: switch (flavor) {
        AppFlavor.dev => 'http://127.0.0.1:8000/api',
        AppFlavor.staging =>
          'https://floralwhite-spoonbill-935004.hostingersite.com/api',
        AppFlavor.production =>
          'https://scrapi5.com/api',
      },
    );
    _initialized = true;
  }

  @override
  String toString() =>
      'AppConfig(flavor: $flavor, appName: $appName, baseUrl: $baseUrl)';
}
