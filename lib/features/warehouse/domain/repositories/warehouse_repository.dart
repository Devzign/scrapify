import '../../../../core/network/dio_client.dart';
import '../../../../core/network/api_response.dart';
import '../models/warehouse_dashboard.dart';
import '../models/warehouse_request.dart';
import '../models/warehouse_pickup_boy.dart';

class WarehouseRepository {
  final DioClient _apiClient;

  WarehouseRepository(this._apiClient);

  Future<ApiResponse<WarehouseDashboard>> getDashboard() async {
    final response = await _apiClient.get('/warehouse/dashboard');
    if (response.isSuccess) {
      try {
        return ApiResponse.success(WarehouseDashboard.fromJson(response.data));
      } catch (e) {
        return ApiResponse.error('Failed to parse dashboard data');
      }
    }
    return ApiResponse.error(response.errorMessage ?? 'Failed to load dashboard');
  }

  Future<ApiResponse<List<WarehouseRequest>>> getRequests({String? status}) async {
    final queryParams = <String, dynamic>{};
    if (status != null) queryParams['status'] = status;

    final response = await _apiClient.get(
      '/warehouse/requests',
      queryParameters: queryParams.isNotEmpty ? queryParams : null,
    );
    if (response.isSuccess) {
      try {
        final data = response.data['data'] ?? response.data;
        final list = (data as List<dynamic>)
            .whereType<Map<String, dynamic>>()
            .map((e) => WarehouseRequest.fromJson(e))
            .toList();
        return ApiResponse.success(list);
      } catch (e) {
        return ApiResponse.error('Failed to parse requests');
      }
    }
    return ApiResponse.error(response.errorMessage ?? 'Failed to load requests');
  }

  Future<ApiResponse<Map<String, dynamic>>> getRequestDetail(int id) async {
    final response = await _apiClient.get('/warehouse/requests/$id');
    if (response.isSuccess) {
      try {
        final data = response.data['data'] ?? response.data;
        return ApiResponse.success(data as Map<String, dynamic>);
      } catch (e) {
        return ApiResponse.error('Failed to parse request detail');
      }
    }
    return ApiResponse.error(response.errorMessage ?? 'Failed to load request detail');
  }

  Future<ApiResponse<List<WarehousePickupBoy>>> getPickupBoys() async {
    final response = await _apiClient.get('/warehouse/pickup-boys');
    if (response.isSuccess) {
      try {
        final data = response.data['data'] ?? response.data;
        final list = (data as List<dynamic>)
            .whereType<Map<String, dynamic>>()
            .map((e) => WarehousePickupBoy.fromJson(e))
            .toList();
        return ApiResponse.success(list);
      } catch (e) {
        return ApiResponse.error('Failed to parse pickup boys');
      }
    }
    return ApiResponse.error(response.errorMessage ?? 'Failed to load pickup boys');
  }

  Future<ApiResponse<List<WarehousePickupBoy>>> getAssignablePickupBoys(int requestId) async {
    final response = await _apiClient.get('/warehouse/requests/$requestId/assignable-pickup-boys');
    if (response.isSuccess) {
      try {
        final data = response.data['data'] ?? response.data;
        final list = (data as List<dynamic>)
            .whereType<Map<String, dynamic>>()
            .map((e) => WarehousePickupBoy.fromJson(e))
            .toList();
        return ApiResponse.success(list);
      } catch (e) {
        return ApiResponse.error('Failed to parse assignable pickup boys');
      }
    }
    return ApiResponse.error(response.errorMessage ?? 'Failed to load assignable pickup boys');
  }

  Future<ApiResponse<void>> assignPickupBoy(
    int requestId,
    int pickupBoyId, {
    String? notes,
  }) async {
    final response = await _apiClient.post(
      '/warehouse/requests/$requestId/assign',
      data: {
        'pickup_boy_id': pickupBoyId,
        if (notes != null) 'notes': notes,
      },
    );
    if (response.isSuccess) return ApiResponse.success(null);
    return ApiResponse.error(response.errorMessage ?? 'Failed to assign pickup boy');
  }

  Future<ApiResponse<void>> reassignPickupBoy(
    int requestId,
    int pickupBoyId,
    String reason,
  ) async {
    final response = await _apiClient.post(
      '/warehouse/requests/$requestId/reassign',
      data: {
        'pickup_boy_id': pickupBoyId,
        'reason': reason,
      },
    );
    if (response.isSuccess) return ApiResponse.success(null);
    return ApiResponse.error(response.errorMessage ?? 'Failed to reassign pickup boy');
  }

  Future<ApiResponse<Map<String, dynamic>>> getProfile() async {
    final response = await _apiClient.get('/warehouse/profile');
    if (response.isSuccess) {
      try {
        final data = response.data['data'] ?? response.data;
        return ApiResponse.success(data as Map<String, dynamic>);
      } catch (e) {
        return ApiResponse.error('Failed to parse profile');
      }
    }
    return ApiResponse.error(response.errorMessage ?? 'Failed to load profile');
  }
}
