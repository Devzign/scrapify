import 'dart:io';
import 'package:dio/dio.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/network/api_response.dart';
import '../models/pickup_request.dart';

class PickupRepository {
  final DioClient _apiClient;

  PickupRepository(this._apiClient);

  Future<ApiResponse<PickupRequest>> createPickup({
    required String address,
    required int cityId,
    required String scheduledAt,
    required List<Map<String, dynamic>> items,
    required List<File> images,
    int? addressId,
    double? latitude,
    double? longitude,
    String? payoutMethod,
    int? paymentDetailId,
    String? customerName,
    String? customerPhone,
  }) async {
    final formData = FormData();

    formData.fields.addAll([
      MapEntry('address', address),
      MapEntry('city_id', cityId.toString()),
      MapEntry('scheduled_at', scheduledAt),
      if (addressId != null) MapEntry('address_id', addressId.toString()),
      if (latitude != null) MapEntry('latitude', latitude.toString()),
      if (longitude != null) MapEntry('longitude', longitude.toString()),
      if (payoutMethod != null) MapEntry('payout_method', payoutMethod),
      if (paymentDetailId != null) MapEntry('payment_detail_id', paymentDetailId.toString()),
      if (customerName != null) MapEntry('customer_name', customerName),
      if (customerPhone != null) MapEntry('customer_phone', customerPhone),
    ]);

    for (int i = 0; i < items.length; i++) {
      items[i].forEach((key, value) {
        if (value != null) {
          formData.fields.add(MapEntry('items[$i][$key]', value.toString()));
        }
      });
    }

    for (final image in images) {
      formData.files.add(MapEntry(
        'images[]',
        await MultipartFile.fromFile(image.path),
      ));
    }

    final response = await _apiClient.post('/pickup-request', data: formData);
    if (response.isSuccess) {
      try {
        final data = response.data['data'] ?? response.data;
        return ApiResponse.success(PickupRequest.fromJson(data as Map<String, dynamic>));
      } catch (e) {
        return ApiResponse.error('Failed to parse pickup response');
      }
    }
    return ApiResponse.error(response.errorMessage ?? 'Failed to create pickup');
  }

  Future<ApiResponse<List<PickupRequest>>> getPickups({String? status}) async {
    final queryParams = <String, dynamic>{};
    if (status != null) queryParams['status'] = status;

    final response = await _apiClient.get(
      '/pickup-requests',
      queryParameters: queryParams.isNotEmpty ? queryParams : null,
    );
    if (response.isSuccess) {
      try {
        final data = response.data['data'] ?? response.data;
        final list = (data as List<dynamic>)
            .whereType<Map<String, dynamic>>()
            .map((e) => PickupRequest.fromJson(e))
            .toList();
        return ApiResponse.success(list);
      } catch (e) {
        return ApiResponse.error('Failed to parse pickups');
      }
    }
    return ApiResponse.error(response.errorMessage ?? 'Failed to load pickups');
  }

  Future<ApiResponse<PickupStats>> getStats() async {
    final response = await _apiClient.get('/pickup-requests/stats');
    if (response.isSuccess) {
      try {
        return ApiResponse.success(PickupStats.fromJson(response.data));
      } catch (e) {
        return ApiResponse.error('Failed to parse stats');
      }
    }
    return ApiResponse.error(response.errorMessage ?? 'Failed to load stats');
  }

  Future<ApiResponse<PickupRequest>> getPickupDetail(int id) async {
    final response = await _apiClient.get('/pickup-requests/$id');
    if (response.isSuccess) {
      try {
        final data = response.data['data'] ?? response.data;
        return ApiResponse.success(PickupRequest.fromJson(data as Map<String, dynamic>));
      } catch (e) {
        return ApiResponse.error('Failed to parse pickup detail');
      }
    }
    return ApiResponse.error(response.errorMessage ?? 'Failed to load pickup detail');
  }

  Future<ApiResponse<void>> reschedule(
    int id, {
    required String scheduledAt,
    String? reason,
  }) async {
    final response = await _apiClient.post(
      '/pickup-requests/$id/reschedule',
      data: {
        'scheduled_at': scheduledAt,
        if (reason != null) 'reason': reason,
      },
    );
    if (response.isSuccess) return ApiResponse.success(null);
    return ApiResponse.error(response.errorMessage ?? 'Failed to reschedule');
  }

  Future<ApiResponse<Map<String, dynamic>>> getTracking(int id) async {
    final response = await _apiClient.get('/pickup-requests/$id/tracking');
    if (response.isSuccess) {
      try {
        final data = response.data['data'] ?? response.data;
        return ApiResponse.success(data as Map<String, dynamic>);
      } catch (e) {
        return ApiResponse.error('Failed to parse tracking data');
      }
    }
    return ApiResponse.error(response.errorMessage ?? 'Failed to load tracking');
  }

  Future<ApiResponse<void>> cancelPickup(int id, String reason) async {
    final response = await _apiClient.post(
      '/pickup-requests/$id/cancel',
      data: {'reason': reason},
    );
    if (response.isSuccess) return ApiResponse.success(null);
    return ApiResponse.error(response.errorMessage ?? 'Failed to cancel pickup');
  }

  Future<ApiResponse<void>> submitReview(int id, int rating, {String? review}) async {
    final response = await _apiClient.post(
      '/pickup-requests/$id/review',
      data: {
        'rating': rating,
        if (review != null) 'review': review,
      },
    );
    if (response.isSuccess) return ApiResponse.success(null);
    return ApiResponse.error(response.errorMessage ?? 'Failed to submit review');
  }

  Future<ApiResponse<List<dynamic>>> getCategories() async {
    final response = await _apiClient.get('/categories');
    if (response.isSuccess) {
      try {
        final data = response.data['data'] ?? [];
        return ApiResponse.success(data as List<dynamic>);
      } catch (e) {
        return ApiResponse.error('Failed to parse categories');
      }
    }
    return ApiResponse.error(response.errorMessage ?? 'Failed to load categories');
  }

  Future<ApiResponse<List<dynamic>>> getSubcategories(int categoryId) async {
    final response = await _apiClient.get(
      '/subcategories',
      queryParameters: {'category_id': categoryId},
    );
    if (response.isSuccess) {
      try {
        final data = response.data['data'] ?? [];
        return ApiResponse.success(data as List<dynamic>);
      } catch (e) {
        return ApiResponse.error('Failed to parse subcategories');
      }
    }
    return ApiResponse.error(response.errorMessage ?? 'Failed to load subcategories');
  }

  Future<ApiResponse<List<dynamic>>> getItems(int subcategoryId) async {
    final response = await _apiClient.get(
      '/items',
      queryParameters: {'subcategory_id': subcategoryId},
    );
    if (response.isSuccess) {
      try {
        final data = response.data['data'] ?? [];
        return ApiResponse.success(data as List<dynamic>);
      } catch (e) {
        return ApiResponse.error('Failed to parse items');
      }
    }
    return ApiResponse.error(response.errorMessage ?? 'Failed to load items');
  }
}
