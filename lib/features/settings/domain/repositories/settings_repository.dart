import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/api_endpoints.dart';
import '../../../../core/network/api_response.dart';
import '../../../../core/network/dio_client.dart';
import '../models/app_settings_model.dart';

final settingsRepositoryProvider = Provider<SettingsRepository>((ref) {
  return SettingsRepository(DioClient());
});

class SettingsRepository {
  final DioClient _dioClient;

  SettingsRepository(this._dioClient);

  Future<ApiResponse<AppSettingsModel>> getAppSettings({
    double? latitude,
    double? longitude,
    String? locationName,
    String? fcmToken,
  }) async {
    final normalizedLocationName = (locationName ?? '').trim();
    return _dioClient.post<AppSettingsModel>(
      ApiEndpoints.appSettings,
      data: {
        'latitude': latitude,
        'longitude': longitude,
        'location_name': normalizedLocationName,
        'fcm_token': (fcmToken ?? '').trim(),
      },
      parser: (json) =>
          AppSettingsModel.fromJson(json['data'] as Map<String, dynamic>),
    );
  }

  Future<ApiResponse<void>> updateLanguage(String languageCode) async {
    return _dioClient.post<void>(
      ApiEndpoints.appSettingsLanguage,
      data: {'language': languageCode},
    );
  }
}
