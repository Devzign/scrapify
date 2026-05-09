import 'dart:io' show Platform;

import 'package:flutter/foundation.dart' show kIsWeb;

import '../../../../core/network/api_endpoints.dart';
import '../../../../core/network/api_role_mapper.dart';
import '../../../../core/network/api_response.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/storage/app_preferences.dart';
import '../models/user.dart';
import '../models/user_type_option.dart';

class AuthRepository {
  final DioClient _apiClient;
  final AppPreferences _preferences;

  AuthRepository(this._apiClient, this._preferences);

  /// Pre-validate referral code (no auth required, public endpoint).
  /// Returns success with optional referrer name on data.
  Future<ApiResponse<String?>> validateReferralCode(String code) async {
    final response = await _apiClient.post(
      ApiEndpoints.referralValidateCode,
      data: {'referral_code': code.trim().toUpperCase()},
    );
    if (response.isSuccess) {
      final referrerName =
          response.data?['data']?['referrer_name']?.toString();
      return ApiResponse.success(referrerName);
    }
    return ApiResponse.error(response.errorMessage ?? 'Invalid referral code');
  }

  /// Send OTP to a provided mobile number and role
  Future<ApiResponse<String>> sendOtp({
    required String phone,
    required String role,
    String? name,
    String? referralCode,
  }) async {
    final body = <String, dynamic>{
      'phone': phone,
      'role': ApiRoleMapper.toApiRole(role),
      if (role == 'customer' && name != null && name.trim().isNotEmpty)
        'name': name.trim(),
    };
    if (role == 'customer' &&
        referralCode != null &&
        referralCode.trim().isNotEmpty) {
      body['referral_code'] = referralCode.trim().toUpperCase();
    }

    final response = await _apiClient.post(
      ApiEndpoints.authSendOtp,
      data: body,
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

  Future<ApiResponse<List<UserTypeOption>>> fetchUserTypes() async {
    return _apiClient.get<List<UserTypeOption>>(
      ApiEndpoints.authUserTypes,
      parser: (json) {
        final rawData = json['data'];
        final List<dynamic> list;

        if (rawData is List<dynamic>) {
          list = rawData;
        } else if (rawData is Map<String, dynamic>) {
          list = rawData['items'] as List<dynamic>? ?? const [];
        } else {
          list = const [];
        }

        return list
            .whereType<Map>()
            .map(
              (entry) =>
                  UserTypeOption.fromJson(Map<String, dynamic>.from(entry)),
            )
            .toList()
          ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
      },
    );
  }

  /// Verify OTP and store the resulting token and User data
  Future<ApiResponse<User>> verifyOtp({
    required String phone,
    required String otp,
    String? role,
    String? referralCode,
  }) async {
    final body = <String, dynamic>{
      'phone': phone,
      'otp': otp,
      'device_name': kIsWeb ? 'Web' : Platform.operatingSystem,
      if (role != null && role.trim().isNotEmpty)
        'role': ApiRoleMapper.toApiRole(role),
      if (role == 'customer' &&
          referralCode != null &&
          referralCode.trim().isNotEmpty)
        'referral_code': referralCode.trim().toUpperCase(),
    };

    final response = await _apiClient.post(
      ApiEndpoints.authVerifyOtp,
      data: body,
    );

    if (response.isSuccess) {
      try {
        final data = response.data['data'];
        final token = data['token'] as String;
        final user = User.fromJson(data['user']);
        _lastReferralApplied = data['referral_applied'] == true;

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

  /// True if last verifyOtp call applied a referral.
  /// Reset to false on next verifyOtp call.
  bool get lastReferralApplied => _lastReferralApplied;
  bool _lastReferralApplied = false;

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
    await _preferences.clearBasketItems();
    await _preferences.clearBasketItemsForUser(userId: null);
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
