import 'dart:convert';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/network/api_response.dart';
import '../models/user.dart';

class AuthRepository {
  final DioClient _apiClient;
  
  static const String _tokenKey = 'auth_token';
  static const String _userKey = 'user_data';
  static const String _onboardingKey = 'has_seen_onboarding';

  AuthRepository(this._apiClient);

  /// Send OTP to a provided mobile number and role
  Future<ApiResponse<String>> sendOtp({
    required String phone,
    required String role,
  }) async {
    final response = await _apiClient.post(
      '/auth/send-otp',
      data: {
        'phone': phone,
        'role': role,
      },
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
      '/auth/verify-otp',
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
        
        // Also set onboarding seen if login successful
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool(_onboardingKey, true);
        
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
    final response = await _apiClient.get('/auth/profile');
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
    return ApiResponse.error(response.errorMessage ?? 'Failed to fetch profile');
  }

  /// Logs the user out locally and remotely
  Future<void> logout() async {
    // Attempt remote logout, ignore errors if token already expired
    await _apiClient.post('/auth/logout');
    await _clearSession();
  }

  // --- Session Management Helpers ---

  Future<void> _saveSession(String token, User user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
    await prefs.setString(_userKey, jsonEncode(user.toJson()));
  }

  Future<void> _saveUser(User user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userKey, jsonEncode(user.toJson()));
  }

  Future<User?> getUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userStr = prefs.getString(_userKey);
    if (userStr != null) {
      try {
        return User.fromJson(jsonDecode(userStr));
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  Future<void> _clearSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_userKey);
  }

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }
}
