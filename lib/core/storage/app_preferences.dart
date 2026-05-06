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
  static const String selectedLanguageKey = 'selected_language';
  static const String notificationsEnabledKey = 'notifications_enabled';
  static const String basketItemsKey = 'basket_items';

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

  Future<void> setSelectedLanguage(String languageCode) async {
    final prefs = await _prefs;
    await prefs.setString(selectedLanguageKey, languageCode);
  }

  Future<String?> getSelectedLanguage() async {
    final prefs = await _prefs;
    return prefs.getString(selectedLanguageKey);
  }

  Future<void> setNotificationsEnabled(bool value) async {
    final prefs = await _prefs;
    await prefs.setBool(notificationsEnabledKey, value);
  }

  Future<bool> getNotificationsEnabled() async {
    final prefs = await _prefs;
    return prefs.getBool(notificationsEnabledKey) ?? true;
  }

  Future<void> saveBasketItems(List<Map<String, dynamic>> items) async {
    final userId = await getCurrentUserId();
    await saveBasketItemsForUser(items, userId: userId);
  }

  Future<void> saveBasketItemsForUser(
    List<Map<String, dynamic>> items, {
    int? userId,
  }) async {
    final prefs = await _prefs;
    await prefs.setString(_basketKeyForUser(userId), jsonEncode(items));
  }

  Future<List<Map<String, dynamic>>> getBasketItems() async {
    final userId = await getCurrentUserId();
    return getBasketItemsForUser(userId: userId);
  }

  Future<List<Map<String, dynamic>>> getBasketItemsForUser({int? userId}) async {
    final prefs = await _prefs;
    final rawData = prefs.getString(_basketKeyForUser(userId));

    if (rawData == null || rawData.isEmpty) {
      return [];
    }

    try {
      final decoded = jsonDecode(rawData) as List<dynamic>;
      return decoded
          .map((item) => Map<String, dynamic>.from(item as Map))
          .toList();
    } catch (error, stackTrace) {
      AppLogger.error(
        'Failed to parse saved basket data.',
        error: error,
        stackTrace: stackTrace,
      );
      await prefs.remove(_basketKeyForUser(userId));
      return [];
    }
  }

  Future<void> clearBasketItems() async {
    final userId = await getCurrentUserId();
    await clearBasketItemsForUser(userId: userId);
  }

  Future<void> clearBasketItemsForUser({int? userId}) async {
    final prefs = await _prefs;
    await prefs.remove(_basketKeyForUser(userId));
  }

  Future<int?> getCurrentUserId() async {
    final userData = await getSavedUserData();
    final id = userData?['id'];
    if (id is int) {
      return id;
    }
    if (id == null) {
      return null;
    }
    return int.tryParse(id.toString());
  }

  String _basketKeyForUser(int? userId) {
    if (userId == null) {
      return basketItemsKey;
    }
    return '${basketItemsKey}_$userId';
  }
}
