import 'dart:io';

import 'package:dio/dio.dart';

import '../../../../core/network/api_endpoints.dart';
import '../../../../core/network/api_response.dart';
import '../../../../core/network/dio_client.dart';
class ProfileRepository {
  final DioClient _apiClient;

  ProfileRepository(this._apiClient);

  Future<ApiResponse<void>> updateProfile({
    String? name,
    String? email,
    int? cityId,
    File? profilePhoto,
    bool removePhoto = false,
  }) async {
    try {
      final formData = FormData.fromMap({
        if (name != null) 'name': name,
        if (email != null) 'email': email,
        if (cityId != null) 'city_id': cityId,
        if (profilePhoto != null)
          'profile_photo': await MultipartFile.fromFile(profilePhoto.path),
        if (removePhoto) 'remove_photo': 'true',
      });

      final response = await _apiClient.post<dynamic>(
        ApiEndpoints.authProfileUpdate,
        data: formData,
      );

      if (response.isSuccess) {
        return ApiResponse.success(null);
      }
      return ApiResponse.error(
        response.errorMessage ?? 'Failed to update profile',
      );
    } catch (e) {
      return ApiResponse.error('Exception updating profile: $e');
    }
  }
}
