import 'dart:io';

import 'package:dio/dio.dart';

import '../../../../core/network/api_endpoints.dart';
import '../../../../core/network/api_response.dart';
import '../../../../core/network/dio_client.dart';
import '../../../auth/domain/models/user.dart';

class ProfileRepository {
  final DioClient _apiClient;

  ProfileRepository(this._apiClient);

  Future<ApiResponse<User>> updateProfile({
    String? name,
    String? email,
    int? cityId,
    File? profilePhoto,
  }) async {
    try {
      final formData = FormData.fromMap({
        if (name != null) 'name': name,
        if (email != null) 'email': email,
        if (cityId != null) 'city_id': cityId,
        if (profilePhoto != null)
          'profile_photo': await MultipartFile.fromFile(profilePhoto.path),
      });

      final response = await _apiClient.post(
        ApiEndpoints.authProfileUpdate,
        data: formData,
      );

      if (response.isSuccess) {
        // We typically get a raw response or user data back.
        // As per the swagger doc, it might not return the full user,
        // but we assume it might inside 'data'. If not, we trigger a fetch in the provider.
        return ApiResponse.success(User.fromJson(response.data['data'] ?? {}));
      }
      return ApiResponse.error(
        response.errorMessage ?? 'Failed to update profile',
      );
    } catch (e) {
      return ApiResponse.error('Exception updating profile: $e');
    }
  }
}
