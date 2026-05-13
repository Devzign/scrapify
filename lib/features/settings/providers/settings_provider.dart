import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/services/location_service.dart';
import '../domain/models/app_settings_model.dart';
import '../domain/repositories/settings_repository.dart';
import '../../../../core/utils/app_logger.dart';

final settingsProvider =
    NotifierProvider<AppSettingsNotifier, AppSettingsModel>(() {
      return AppSettingsNotifier();
    });

class AppSettingsNotifier extends Notifier<AppSettingsModel> {
  @override
  AppSettingsModel build() {
    return AppSettingsModel(
      language: 'en',
      supportedLanguages: ['en'],
      features: AppFeatures(),
      serviceAvailability: ServiceAvailability(),
      settings: {},
      isLoading: true,
      hasLoaded: false,
    );
  }

  Future<void> syncSettings({
    double? latitude,
    double? longitude,
    String? locationName,
    String? fcmToken,
  }) async {
    state = state.copyWith(isLoading: true);
    try {
      double? resolvedLatitude = latitude;
      double? resolvedLongitude = longitude;
      String resolvedLocationName = (locationName ?? '').trim();

      if (resolvedLatitude == null || resolvedLongitude == null) {
        final locationService = LocationService();
        final bestLocation = await locationService.getBestAvailableLocation();
        resolvedLatitude = resolvedLatitude ?? bestLocation?.latitude;
        resolvedLongitude = resolvedLongitude ?? bestLocation?.longitude;
        if (resolvedLocationName.isEmpty) {
          resolvedLocationName = bestLocation?.locationName?.trim() ?? '';
        }
      } else if (resolvedLocationName.isEmpty) {
        final locationService = LocationService();
        final bestLocation = await locationService.getBestAvailableLocation();
        resolvedLocationName = bestLocation?.locationName?.trim() ?? '';
      }

      final repository = ref.read(settingsRepositoryProvider);
      final response = await repository.getAppSettings(
        latitude: resolvedLatitude,
        longitude: resolvedLongitude,
        locationName: resolvedLocationName,
        fcmToken: fcmToken,
      );

      if (response.isSuccess && response.data != null) {
        state = response.data!.copyWith(isLoading: false, hasLoaded: true);
        AppLogger.info('App settings synced successfully: ${state.language}');
      } else {
        state = state.copyWith(isLoading: false, hasLoaded: true);
        AppLogger.error(
          'Failed to sync app settings: ${response.errorMessage}',
        );
      }
    } catch (e) {
      state = state.copyWith(isLoading: false, hasLoaded: true);
      AppLogger.error('Error syncing app settings', error: e);
    }
  }

  Future<void> updateLanguage(String languageCode) async {
    try {
      final repository = ref.read(settingsRepositoryProvider);
      final response = await repository.updateLanguage(languageCode);

      if (response.isSuccess) {
        state = state.copyWith(language: languageCode);
        AppLogger.info(
          'App language updated successfully on backend: $languageCode',
        );
      }
    } catch (e) {
      AppLogger.error('Error updating app language', error: e);
    }
  }
}
