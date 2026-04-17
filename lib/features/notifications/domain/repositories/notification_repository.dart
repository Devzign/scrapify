import '../../../../core/network/api_endpoints.dart';
import '../../../../core/network/api_response.dart';
import '../../../../core/network/dio_client.dart';
import '../models/notification_model.dart';

class NotificationRepository {
  final DioClient _apiClient;

  NotificationRepository(this._apiClient);

  Future<ApiResponse<List<NotificationModel>>> getNotifications() async {
    final response = await _apiClient.get(ApiEndpoints.notifications);
    if (response.isSuccess) {
      try {
        final List<dynamic> data = response.data['data'] ?? [];
        final notifications = data
            .map((e) => NotificationModel.fromJson(e))
            .toList();
        return ApiResponse.success(notifications);
      } catch (e) {
        return ApiResponse.error('Failed to parse notifications');
      }
    }
    return ApiResponse.error(
      response.errorMessage ?? 'Failed to fetch notifications',
    );
  }

  Future<ApiResponse<void>> readNotification(String id) async {
    final response = await _apiClient.post(ApiEndpoints.notificationRead(id));
    if (response.isSuccess) {
      return ApiResponse.success(null);
    }
    return ApiResponse.error(
      response.errorMessage ?? 'Failed to read notification',
    );
  }

  Future<ApiResponse<void>> readAllNotifications() async {
    final response = await _apiClient.post(ApiEndpoints.notificationsReadAll);
    if (response.isSuccess) {
      return ApiResponse.success(null);
    }
    return ApiResponse.error(
      response.errorMessage ?? 'Failed to read all notifications',
    );
  }
}
