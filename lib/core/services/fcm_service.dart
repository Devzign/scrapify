import 'package:firebase_messaging/firebase_messaging.dart';
import '../utils/app_logger.dart';

class FcmService {
  FcmService._();
  static final FcmService instance = FcmService._();

  String? _cachedToken;

  Future<bool> ensurePermission() async {
    try {
      final current = await FirebaseMessaging.instance
          .getNotificationSettings();
      if (current.authorizationStatus == AuthorizationStatus.authorized ||
          current.authorizationStatus == AuthorizationStatus.provisional) {
        return true;
      }

      final settings = await FirebaseMessaging.instance.requestPermission(
        alert: true,
        badge: true,
        sound: true,
        provisional: false,
      );

      if (settings.authorizationStatus == AuthorizationStatus.denied) {
        AppLogger.info('FCM permission denied by user');
        return false;
      }
      return true;
    } catch (e) {
      AppLogger.error('Failed to request FCM permission', error: e);
      return false;
    }
  }

  Future<String?> getToken() async {
    if (_cachedToken != null && _cachedToken!.isNotEmpty) {
      return _cachedToken;
    }

    try {
      final granted = await ensurePermission();
      if (!granted) {
        return null;
      }
      _cachedToken = await FirebaseMessaging.instance.getToken();
      AppLogger.info('FCM token fetched: ${_cachedToken != null}');
      return _cachedToken;
    } catch (e) {
      AppLogger.error('Failed to fetch FCM token', error: e);
      return null;
    }
  }
}
