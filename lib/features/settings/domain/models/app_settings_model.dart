class AppSettingsModel {
  final String language;
  final List<String> supportedLanguages;
  final AppFeatures features;
  final ServiceAvailability serviceAvailability;
  final Map<String, dynamic> settings;
  final bool isLoading;
  final bool hasLoaded;

  AppSettingsModel({
    required this.language,
    required this.supportedLanguages,
    required this.features,
    required this.serviceAvailability,
    required this.settings,
    this.isLoading = false,
    this.hasLoaded = false,
  });

  factory AppSettingsModel.fromJson(Map<String, dynamic> json) {
    return AppSettingsModel(
      language: json['language']?.toString() ?? 'en',
      supportedLanguages:
          (json['supported_languages'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          ['en'],
      features: AppFeatures.fromJson(
        json['features'] as Map<String, dynamic>? ?? {},
      ),
      serviceAvailability: ServiceAvailability.fromJson(
        json['service_availability'] as Map<String, dynamic>? ?? {},
      ),
      settings: json['settings'] as Map<String, dynamic>? ?? {},
      isLoading: false,
      hasLoaded: true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'language': language,
      'supported_languages': supportedLanguages,
      'features': features.toJson(),
      'service_availability': serviceAvailability.toJson(),
      'settings': settings,
      'is_loading': isLoading,
      'has_loaded': hasLoaded,
    };
  }

  AppSettingsModel copyWith({
    String? language,
    List<String>? supportedLanguages,
    AppFeatures? features,
    ServiceAvailability? serviceAvailability,
    Map<String, dynamic>? settings,
    bool? isLoading,
    bool? hasLoaded,
  }) {
    return AppSettingsModel(
      language: language ?? this.language,
      supportedLanguages: supportedLanguages ?? this.supportedLanguages,
      features: features ?? this.features,
      serviceAvailability: serviceAvailability ?? this.serviceAvailability,
      settings: settings ?? this.settings,
      isLoading: isLoading ?? this.isLoading,
      hasLoaded: hasLoaded ?? this.hasLoaded,
    );
  }
}

class AppFeatures {
  final bool donationEnabled;
  final bool scrapPickupEnabled;
  final bool walletEnabled;

  AppFeatures({
    this.donationEnabled = true,
    this.scrapPickupEnabled = true,
    this.walletEnabled = false,
  });

  factory AppFeatures.fromJson(Map<String, dynamic> json) {
    return AppFeatures(
      donationEnabled: json['donation_enabled'] as bool? ?? true,
      scrapPickupEnabled: json['scrap_pickup_enabled'] as bool? ?? true,
      walletEnabled: json['wallet_enabled'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'donation_enabled': donationEnabled,
      'scrap_pickup_enabled': scrapPickupEnabled,
      'wallet_enabled': walletEnabled,
    };
  }
}

class ServiceAvailability {
  final bool isServiceable;
  final String message;
  final String locationName;

  ServiceAvailability({
    this.isServiceable = true,
    this.message = '',
    this.locationName = '',
  });

  factory ServiceAvailability.fromJson(Map<String, dynamic> json) {
    return ServiceAvailability(
      isServiceable: json['is_serviceable'] as bool? ?? true,
      message: json['message']?.toString() ?? '',
      locationName: json['location_name']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'is_serviceable': isServiceable,
      'message': message,
      'location_name': locationName,
    };
  }
}
