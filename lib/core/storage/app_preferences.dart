import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../utils/app_logger.dart';

final appPreferencesProvider = Provider<AppPreferences>((ref) {
  return AppPreferences();
});

class AppPreferences {
  static const String authTokenKey = 'auth_token';
  static const String userDataKey = 'user_data';
  static const String hasSeenOnboardingKey = 'has_seen_onboarding';

  Future<SharedPreferences> get _prefs async {
    return SharedPreferences.getInstance();
  }

  Future<void> saveSession({
    required String token,
    required Map<String, dynamic> userData,
  }) async {
    final prefs = await _prefs;
    await prefs.setString(authTokenKey, token);
    await prefs.setString(userDataKey, jsonEncode(userData));
  }

  Future<void> saveUserData(Map<String, dynamic> userData) async {
    final prefs = await _prefs;
    await prefs.setString(userDataKey, jsonEncode(userData));
  }

  Future<void> clearSession() async {
    final prefs = await _prefs;
    await prefs.remove(authTokenKey);
    await prefs.remove(userDataKey);
  }

  Future<String?> getAuthToken() async {
    final prefs = await _prefs;
    return prefs.getString(authTokenKey);
  }

  Future<Map<String, dynamic>?> getSavedUserData() async {
    final prefs = await _prefs;
    final userData = prefs.getString(userDataKey);

    if (userData == null || userData.isEmpty) {
      return null;
    }

    try {
      final decodedData = jsonDecode(userData);
      return Map<String, dynamic>.from(decodedData as Map);
    } catch (error, stackTrace) {
      AppLogger.error(
        'Failed to parse saved user data.',
        error: error,
        stackTrace: stackTrace,
      );
      return null;
    }
  }

  Future<String?> getPrimaryUserRole() async {
    final userData = await getSavedUserData();
    final roles = userData?['roles'] as List<dynamic>?;

    if (roles == null || roles.isEmpty) {
      return null;
    }

    return roles.first.toString();
  }

  Future<bool> getHasSeenOnboarding() async {
    final prefs = await _prefs;
    return prefs.getBool(hasSeenOnboardingKey) ?? false;
  }

  Future<void> setHasSeenOnboarding(bool value) async {
    final prefs = await _prefs;
    await prefs.setBool(hasSeenOnboardingKey, value);
  }
}
