import 'package:firebase_messaging/firebase_messaging.dart';
import 'local_notification_service.dart';
import '../utils/app_logger.dart';

class FcmService {
  FcmService._();
  static final FcmService instance = FcmService._();

  String? _cachedToken;
  bool _handlersAttached = false;

  Future<void> initializeMessaging() async {
    try {
      await LocalNotificationService.instance.initialize();

      await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
        alert: true,
        badge: true,
        sound: true,
      );

      if (!_handlersAttached) {
        FirebaseMessaging.onMessage.listen((RemoteMessage message) {
          final title = message.notification?.title ?? 'Scrapify';
          final body = message.notification?.body ?? 'You have a new update.';
          LocalNotificationService.instance.show(
            title: title,
            body: body,
            id: DateTime.now().millisecondsSinceEpoch ~/ 1000,
          );
        });

        FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
          AppLogger.info(
            'Notification tapped (background): ${message.messageId}',
          );
        });

        _handlersAttached = true;
      }

      final initialMessage = await FirebaseMessaging.instance.getInitialMessage();
      if (initialMessage != null) {
        AppLogger.info(
          'Notification opened app from terminated state: ${initialMessage.messageId}',
        );
      }

      FirebaseMessaging.instance.onTokenRefresh.listen((newToken) {
        _cachedToken = newToken;
        AppLogger.info('FCM token refreshed');
      });
    } catch (e) {
      AppLogger.error('Failed to initialize FCM messaging handlers', error: e);
    }
  }

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
