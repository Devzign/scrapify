import 'dart:io' show Platform;

import 'package:flutter/foundation.dart' show kIsWeb;

import '../../../../core/network/api_endpoints.dart';
import '../../../../core/network/api_role_mapper.dart';
import '../../../../core/network/api_response.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/storage/app_preferences.dart';
import '../models/user.dart';

class AuthRepository {
  final DioClient _apiClient;
  final AppPreferences _preferences;

  AuthRepository(this._apiClient, this._preferences);

  /// Send OTP to a provided mobile number and role
  Future<ApiResponse<String>> sendOtp({
    required String phone,
    required String role,
  }) async {
    final response = await _apiClient.post(
      ApiEndpoints.authSendOtp,
      data: {'phone': phone, 'role': ApiRoleMapper.toApiRole(role)},
    );

    if (response.isSuccess) {
      // Return the OTP only for testing/development if provided by backend,
      // otherwise just return a success message.
      final otp = response.data?['data']?['otp']?.toString() ?? 'OTP Sent';
      return ApiResponse.success(otp);
    } else {
      return ApiResponse.error(response.errorMessage ?? 'Failed to send OTP');
    }
  }

  /// Verify OTP and store the resulting token and User data
  Future<ApiResponse<User>> verifyOtp({
    required String phone,
    required String otp,
  }) async {
    final response = await _apiClient.post(
      ApiEndpoints.authVerifyOtp,
      data: {
        'phone': phone,
        'otp': otp,
        'device_name': kIsWeb ? 'Web' : Platform.operatingSystem,
      },
    );

    if (response.isSuccess) {
      try {
        final data = response.data['data'];
        final token = data['token'] as String;
        final user = User.fromJson(data['user']);

        await _saveSession(token, user);
        await _preferences.setHasSeenOnboarding(true);

        return ApiResponse.success(user);
      } catch (e) {
        return ApiResponse.error('Failed to parse user data');
      }
    } else {
      return ApiResponse.error(response.errorMessage ?? 'Invalid OTP');
    }
  }

  /// Fetch user profile
  Future<ApiResponse<User>> fetchProfile() async {
    final response = await _apiClient.get(ApiEndpoints.authProfile);
    if (response.isSuccess) {
      try {
        final user = User.fromJson(response.data['data']);
        // Update local user data
        await _saveUser(user);
        return ApiResponse.success(user);
      } catch (e) {
        return ApiResponse.error('Failed to parse user data');
      }
    }
    return ApiResponse.error(
      response.errorMessage ?? 'Failed to fetch profile',
    );
  }

  /// Logs the user out locally and remotely
  Future<void> logout() async {
    // Attempt remote logout, ignore errors if token already expired
    await _apiClient.post(ApiEndpoints.authLogout);
    await _clearSession();
  }

  // --- Session Management Helpers ---

  Future<void> _saveSession(String token, User user) async {
    await _preferences.saveSession(token: token, userData: user.toJson());
  }

  Future<void> _saveUser(User user) async {
    await _preferences.saveUserData(user.toJson());
  }

  Future<User?> getUser() async {
    final userData = await _preferences.getSavedUserData();

    if (userData == null) {
      return null;
    }

    return User.fromJson(userData);
  }

  Future<void> _clearSession() async {
    await _preferences.clearSession();
  }

  Future<String?> getToken() async {
    return _preferences.getAuthToken();
  }
}
