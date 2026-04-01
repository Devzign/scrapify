import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
  Future<ApiResponse<void>> readNotification(String id) async {
    return ApiResponse(statusCode: 200);
  }

  @override
  Future<ApiResponse<void>> readAllNotifications() async {
    return ApiResponse(statusCode: 200);
  }
}

void main() {
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
        child: const MaterialApp(home: NotificationsScreen()),
      ),
    );

    await tester.pumpAndSettle();
    expect(find.byType(NotificationsScreen), findsOneWidget);
  });
}
