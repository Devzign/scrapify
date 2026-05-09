import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:scrapify/features/notifications/presentation/notifications_screen.dart';
import 'package:scrapify/features/notifications/providers/notification_provider.dart';
import 'package:scrapify/features/notifications/domain/models/notification_model.dart';

import 'package:scrapify/core/network/api_response.dart';
import 'package:scrapify/features/notifications/domain/repositories/notification_repository.dart';

class FakeNotificationRepository implements NotificationRepository {
  @override
  Future<ApiResponse<List<NotificationModel>>> getNotifications() async {
    return ApiResponse(statusCode: 200, data: []);
  }

  @override
  Future<ApiResponse<bool>> readNotification(String id) async {
    return ApiResponse(statusCode: 200, data: true);
  }

  @override
  Future<ApiResponse<bool>> readAllNotifications() async {
    return ApiResponse(statusCode: 200, data: true);
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    SharedPreferences.setMockInitialValues({});
    await EasyLocalization.ensureInitialized();
  });

  testWidgets('NotificationsScreen renders without exploding', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          notificationRepositoryProvider.overrideWithValue(
            FakeNotificationRepository(),
          ),
        ],
        child: EasyLocalization(
          supportedLocales: const [Locale('en'), Locale('hi')],
          path: 'assets/translations',
          fallbackLocale: const Locale('en'),
          child: const MaterialApp(home: NotificationsScreen()),
        ),
      ),
    );

    await tester.pumpAndSettle();
    expect(find.byType(NotificationsScreen), findsOneWidget);
  });
}
