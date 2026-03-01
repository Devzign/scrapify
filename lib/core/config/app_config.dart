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
        AppFlavor.dev        => 'Scrapify Dev',
        AppFlavor.staging    => 'Scrapify Stag',
        AppFlavor.production => 'Scrapify',
      },
      baseUrl: switch (flavor) {
        AppFlavor.dev        => 'https://dev-api.scrapify.com',
        AppFlavor.staging    => 'https://staging-api.scrapify.com',
        AppFlavor.production => 'https://api.scrapify.com',
      },
    );
  }

  @override
  String toString() =>
      'AppConfig(flavor: $flavor, appName: $appName, baseUrl: $baseUrl)';
}
