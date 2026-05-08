import 'package:flutter_riverpod/flutter_riverpod.dart';
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
      final repository = ref.read(settingsRepositoryProvider);
      final response = await repository.getAppSettings(
        latitude: latitude,
        longitude: longitude,
        locationName: locationName,
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
