import '../../../../core/network/dio_client.dart';
import '../../../../core/network/api_response.dart';
import '../models/channel_partner_dashboard.dart';

class ChannelPartnerRepository {
  final DioClient _apiClient;

  ChannelPartnerRepository(this._apiClient);

  // --- Endpoints confirmed in api-docs.json ---

  Future<ApiResponse<ChannelPartnerDashboard>> getDashboard() async {
    final response = await _apiClient.get('/channel-partner/dashboard');
    if (response.isSuccess) {
      try {
        return ApiResponse.success(ChannelPartnerDashboard.fromJson(response.data));
      } catch (e) {
        return ApiResponse.error('Failed to parse dashboard data');
      }
    }
    return ApiResponse.error(response.errorMessage ?? 'Failed to load dashboard');
  }

  Future<ApiResponse<Map<String, dynamic>>> getProfile() async {
    final response = await _apiClient.get('/channel-partner/profile');
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

  Future<ApiResponse<void>> submitStatusRequest(Map<String, dynamic> data) async {
    final response = await _apiClient.post('/channel-partner/status-request', data: data);
    if (response.isSuccess) return ApiResponse.success(null);
    return ApiResponse.error(response.errorMessage ?? 'Failed to submit request');
  }

  // --- BRD endpoints (backend to implement) ---

  Future<ApiResponse<List<dynamic>>> getOrders({String? status}) async {
    final queryParams = <String, dynamic>{};
    if (status != null) queryParams['status'] = status;

    final response = await _apiClient.get(
      '/channel-partner/orders',
      queryParameters: queryParams.isNotEmpty ? queryParams : null,
    );
    if (response.isSuccess) {
      try {
        final raw = response.data['data'];
        final data = (raw is Map) ? (raw['items'] ?? []) : (raw ?? []);
        return ApiResponse.success(data as List<dynamic>);
      } catch (e) {
        return ApiResponse.error('Failed to parse orders');
      }
    }
    return ApiResponse.error(response.errorMessage ?? 'Failed to load orders');
  }

  Future<ApiResponse<Map<String, dynamic>>> getOrderDetail(int id) async {
    final response = await _apiClient.get('/channel-partner/orders/$id');
    if (response.isSuccess) {
      try {
        final data = response.data['data'] ?? response.data;
        return ApiResponse.success(data as Map<String, dynamic>);
      } catch (e) {
        return ApiResponse.error('Failed to parse order detail');
      }
    }
    return ApiResponse.error(response.errorMessage ?? 'Failed to load order detail');
  }

  Future<ApiResponse<List<dynamic>>> getPickupBoys() async {
    final response = await _apiClient.get('/channel-partner/pickup-boys');
    if (response.isSuccess) {
      try {
        final data = response.data['data'] ?? [];
        return ApiResponse.success(data as List<dynamic>);
      } catch (e) {
        return ApiResponse.error('Failed to parse pickup boys');
      }
    }
    return ApiResponse.error(response.errorMessage ?? 'Failed to load pickup boys');
  }

  Future<ApiResponse<List<dynamic>>> getWarehouses() async {
    final response = await _apiClient.get('/channel-partner/warehouses');
    if (response.isSuccess) {
      try {
        final data = response.data['data'] ?? [];
        return ApiResponse.success(data as List<dynamic>);
      } catch (e) {
        return ApiResponse.error('Failed to parse warehouses');
      }
    }
    return ApiResponse.error(response.errorMessage ?? 'Failed to load warehouses');
  }

  Future<ApiResponse<List<dynamic>>> getApprovalRequests({String? status}) async {
    final queryParams = <String, dynamic>{};
    if (status != null) queryParams['status'] = status;

    final response = await _apiClient.get(
      '/channel-partner/approval-requests',
      queryParameters: queryParams.isNotEmpty ? queryParams : null,
    );
    if (response.isSuccess) {
      try {
        final raw = response.data['data'];
        final data = (raw is Map) ? (raw['items'] ?? []) : (raw ?? []);
        return ApiResponse.success(data as List<dynamic>);
      } catch (e) {
        return ApiResponse.error('Failed to parse approval requests');
      }
    }
    return ApiResponse.error(response.errorMessage ?? 'Failed to load approval requests');
  }
}
