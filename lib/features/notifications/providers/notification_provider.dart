import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../../auth/providers/auth_provider.dart';
import '../domain/models/notification_model.dart';
import '../domain/repositories/notification_repository.dart';

final notificationRepositoryProvider = Provider<NotificationRepository>((ref) {
  final dioClient = ref.watch(dioClientProvider);
  return NotificationRepository(dioClient);
});

final notificationProvider = StateNotifierProvider<NotificationNotifier, AsyncValue<List<NotificationModel>>>((ref) {
  final repository = ref.watch(notificationRepositoryProvider);
  return NotificationNotifier(repository);
});

class NotificationNotifier extends StateNotifier<AsyncValue<List<NotificationModel>>> {
  final NotificationRepository _repository;

  NotificationNotifier(this._repository) : super(const AsyncValue.loading()) {
    getNotifications();
  }

  Future<void> getNotifications() async {
    state = const AsyncValue.loading();
    final response = await _repository.getNotifications();
    if (response.isSuccess) {
      state = AsyncValue.data(response.data!);
    } else {
      state = AsyncValue.error(response.errorMessage ?? 'Failed to fetch notifications', StackTrace.current);
    }
  }

  Future<bool> readNotification(String id) async {
    final response = await _repository.readNotification(id);
    if (response.isSuccess) {
      // Optimistically update the list
      state = state.whenData((notifications) {
        return notifications.map((n) {
          if (n.id == id) {
            return NotificationModel(
              id: n.id,
              title: n.title,
              body: n.body,
              isRead: true,
              createdAt: n.createdAt,
              data: n.data,
            );
          }
          return n;
        }).toList();
      });
      return true;
    }
    return false;
  }

  Future<bool> readAllNotifications() async {
    final response = await _repository.readAllNotifications();
    if (response.isSuccess) {
      // Optimistically update all
      state = state.whenData((notifications) {
        return notifications.map((n) {
          return NotificationModel(
            id: n.id,
            title: n.title,
            body: n.body,
            isRead: true,
            createdAt: n.createdAt,
            data: n.data,
          );
        }).toList();
      });
      return true;
    }
    return false;
  }
}
