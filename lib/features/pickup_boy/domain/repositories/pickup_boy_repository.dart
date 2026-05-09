import 'dart:io';
import 'package:dio/dio.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/network/api_response.dart';
import '../models/pickup_assignment.dart';
import '../models/pickup_boy_dashboard.dart';
import '../models/pickup_item.dart';

class PickupBoyRepository {
  final DioClient _apiClient;

  PickupBoyRepository(this._apiClient);

  Future<ApiResponse<PickupBoyDashboard>> getDashboard() async {
    final response = await _apiClient.get('/pickup-boy/dashboard');
    if (response.isSuccess) {
      try {
        return ApiResponse.success(PickupBoyDashboard.fromJson(response.data));
      } catch (e) {
        return ApiResponse.error('Failed to parse dashboard data');
      }
    }
    return ApiResponse.error(response.errorMessage ?? 'Failed to load dashboard');
  }

  Future<ApiResponse<List<PickupAssignment>>> getAssignments({String? status}) async {
    final queryParams = <String, dynamic>{};
    if (status != null) queryParams['status'] = status;

    final response = await _apiClient.get(
      '/pickup-boy/assignments',
      queryParameters: queryParams.isNotEmpty ? queryParams : null,
    );
    if (response.isSuccess) {
      try {
        final rawData = response.data['data'] ?? response.data;
        // API returns { "items": [...], "pagination": {...} } or a flat list
        final List<dynamic> items;
        if (rawData is Map<String, dynamic>) {
          items = rawData['items'] as List<dynamic>? ?? [];
        } else if (rawData is List<dynamic>) {
          items = rawData;
        } else {
          items = [];
        }
        final list = items
            .whereType<Map<String, dynamic>>()
            .map((e) => PickupAssignment.fromJson(e))
            .toList();
        return ApiResponse.success(list);
      } catch (e) {
        return ApiResponse.error('Failed to parse assignments');
      }
    }
    return ApiResponse.error(response.errorMessage ?? 'Failed to load assignments');
  }

  Future<ApiResponse<Map<String, dynamic>>> getPickupDetail(int id) async {
    final response = await _apiClient.get('/pickup-boy/pickups/$id');
    if (response.isSuccess) {
      try {
        final data = response.data['data'] ?? response.data;
        return ApiResponse.success(data as Map<String, dynamic>);
      } catch (e) {
        return ApiResponse.error('Failed to parse pickup detail');
      }
    }
    return ApiResponse.error(response.errorMessage ?? 'Failed to load pickup detail');
  }

  Future<ApiResponse<bool>> acceptPickup(int id) async {
    final response = await _apiClient.post('/pickup-boy/pickups/$id/accept');
    if (response.isSuccess) return ApiResponse.success(true);
    return ApiResponse.error(response.errorMessage ?? 'Failed to accept pickup');
  }

  Future<ApiResponse<bool>> rejectPickup(int id) async {
    final response = await _apiClient.post('/pickup-boy/pickups/$id/reject');
    if (response.isSuccess) return ApiResponse.success(true);
    return ApiResponse.error(response.errorMessage ?? 'Failed to reject pickup');
  }

  Future<ApiResponse<bool>> updateStatus(int id, String status) async {
    final response = await _apiClient.post(
      '/pickup-boy/pickups/$id/status',
      data: {'status': status},
    );
    if (response.isSuccess) return ApiResponse.success(true);
    return ApiResponse.error(response.errorMessage ?? 'Failed to update status');
  }

  Future<ApiResponse<Map<String, dynamic>>> verifyPickup(
    int id,
    List<PickupItem> items,
    List<File> images,
  ) async {
    final formData = FormData();

    for (int i = 0; i < items.length; i++) {
      final item = items[i].toJson();
      item.forEach((key, value) {
        if (value != null) {
          formData.fields.add(MapEntry('verified_items[$i][$key]', value.toString()));
        }
      });
    }

    for (final image in images) {
      formData.files.add(MapEntry(
        'images[]',
        await MultipartFile.fromFile(image.path),
      ));
    }

    final response = await _apiClient.post(
      '/pickup-boy/pickups/$id/verify',
      data: formData,
    );
    if (response.isSuccess) {
      try {
        final data = response.data['data'] ?? response.data;
        return ApiResponse.success(data as Map<String, dynamic>);
      } catch (e) {
        return ApiResponse.success({});
      }
    }
    return ApiResponse.error(response.errorMessage ?? 'Failed to verify pickup');
  }

  Future<ApiResponse<bool>> rescheduleRequest(
    int id, {
    required String reasonCode,
    String? additionalNote,
  }) async {
    final response = await _apiClient.post(
      '/pickup-boy/pickups/$id/reschedule-request',
      data: {
        'reason_code': reasonCode,
        if (additionalNote != null) 'additional_note': additionalNote,
      },
    );
    if (response.isSuccess) return ApiResponse.success(true);
    return ApiResponse.error(response.errorMessage ?? 'Failed to send reschedule request');
  }

  Future<ApiResponse<bool>> toggleOnlineStatus(bool isOnline) async {
    final response = await _apiClient.post(
      '/pickup-boy/status',
      data: {'is_online': isOnline},
    );
    if (response.isSuccess) return ApiResponse.success(true);
    return ApiResponse.error(response.errorMessage ?? 'Failed to update status');
  }

  Future<ApiResponse<bool>> updateLocation({
    required double latitude,
    required double longitude,
    String? vehicleNumber,
  }) async {
    final response = await _apiClient.post(
      '/pickup-boy/location',
      data: {
        'latitude': latitude,
        'longitude': longitude,
        if (vehicleNumber != null) 'vehicle_number': vehicleNumber,
      },
    );
    if (response.isSuccess) return ApiResponse.success(true);
    return ApiResponse.error(response.errorMessage ?? 'Failed to update location');
  }
}
