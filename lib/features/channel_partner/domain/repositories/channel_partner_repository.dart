import '../../../../core/network/dio_client.dart';
import '../../../../core/network/api_response.dart';
import 'package:dio/dio.dart';
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

  Future<ApiResponse<List<dynamic>>> getCustomers({String? q}) async {
    final response = await _apiClient.get(
      '/channel-partner/customers',
      queryParameters: q != null && q.trim().isNotEmpty ? {'q': q.trim()} : null,
    );
    if (response.isSuccess) {
      try {
        final raw = response.data['data'];
        final data = (raw is Map) ? (raw['items'] ?? []) : (raw ?? []);
        return ApiResponse.success(data as List<dynamic>);
      } catch (_) {
        return ApiResponse.error('Failed to parse customers');
      }
    }
    return ApiResponse.error(response.errorMessage ?? 'Failed to load customers');
  }

  Future<ApiResponse<List<dynamic>>> getCategories() async {
    final response = await _apiClient.get('/categories');
    if (response.isSuccess) {
      try {
        final raw = response.data['data'];
        final data = (raw is Map) ? (raw['items'] ?? []) : (raw ?? []);
        return ApiResponse.success(data as List<dynamic>);
      } catch (_) {
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
        final raw = response.data['data'];
        final data = (raw is Map) ? (raw['items'] ?? []) : (raw ?? []);
        return ApiResponse.success(data as List<dynamic>);
      } catch (_) {
        return ApiResponse.error('Failed to parse subcategories');
      }
    }
    return ApiResponse.error(response.errorMessage ?? 'Failed to load subcategories');
  }

  Future<ApiResponse<Map<String, dynamic>>> createCustomer(
    Map<String, dynamic> payload,
  ) async {
    final response = await _apiClient.post('/channel-partner/customers', data: payload);
    if (response.isSuccess) {
      try {
        return ApiResponse.success(
          (response.data['data'] ?? response.data) as Map<String, dynamic>,
        );
      } catch (_) {
        return ApiResponse.error('Failed to parse created customer');
      }
    }
    return ApiResponse.error(response.errorMessage ?? 'Failed to create customer');
  }

  Future<ApiResponse<Map<String, dynamic>>> updateCustomer(
    int id,
    Map<String, dynamic> payload,
  ) async {
    final response = await _apiClient.put('/channel-partner/customers/$id', data: payload);
    if (response.isSuccess) {
      try {
        return ApiResponse.success(
          (response.data['data'] ?? response.data) as Map<String, dynamic>,
        );
      } catch (_) {
        return ApiResponse.error('Failed to parse updated customer');
      }
    }
    return ApiResponse.error(response.errorMessage ?? 'Failed to update customer');
  }

  Future<ApiResponse<Map<String, dynamic>>> getCustomerDetail(int id) async {
    final response = await _apiClient.get('/channel-partner/customers/$id');
    if (response.isSuccess) {
      try {
        return ApiResponse.success(
          (response.data['data'] ?? response.data) as Map<String, dynamic>,
        );
      } catch (_) {
        return ApiResponse.error('Failed to parse customer details');
      }
    }
    return ApiResponse.error(response.errorMessage ?? 'Failed to load customer details');
  }

  Future<ApiResponse<Map<String, dynamic>>> createPickupRequest({
    required Map<String, dynamic> payload,
    List<MultipartFile>? images,
  }) async {
    final form = FormData.fromMap(payload);
    if (images != null && images.isNotEmpty) {
      for (final image in images) {
        form.files.add(MapEntry('images[]', image));
      }
    }
    final response = await _apiClient.post('/channel-partner/pickups', data: form);
    if (response.isSuccess) {
      try {
        return ApiResponse.success(
          (response.data['data'] ?? response.data) as Map<String, dynamic>,
        );
      } catch (_) {
        return ApiResponse.error('Failed to parse pickup request response');
      }
    }
    return ApiResponse.error(response.errorMessage ?? 'Failed to create pickup request');
  }

  Future<ApiResponse<List<dynamic>>> getPartnerPickups({
    String? status,
    String? date,
    String? customer,
    String? pickupBoy,
    String? q,
  }) async {
    final qp = <String, dynamic>{};
    if (status != null && status.isNotEmpty) qp['status'] = status;
    if (date != null && date.isNotEmpty) qp['date'] = date;
    if (customer != null && customer.isNotEmpty) qp['customer'] = customer;
    if (pickupBoy != null && pickupBoy.isNotEmpty) qp['pickup_boy'] = pickupBoy;
    if (q != null && q.isNotEmpty) qp['q'] = q;

    final response = await _apiClient.get(
      '/channel-partner/pickups',
      queryParameters: qp.isEmpty ? null : qp,
    );
    if (response.isSuccess) {
      try {
        final raw = response.data['data'];
        final data = (raw is Map) ? (raw['items'] ?? []) : (raw ?? []);
        return ApiResponse.success(data as List<dynamic>);
      } catch (_) {
        return ApiResponse.error('Failed to parse pickups');
      }
    }
    return ApiResponse.error(response.errorMessage ?? 'Failed to load pickups');
  }

  Future<ApiResponse<Map<String, dynamic>>> getPartnerPickupDetail(int id) async {
    final response = await _apiClient.get('/channel-partner/pickups/$id');
    if (response.isSuccess) {
      try {
        return ApiResponse.success(
          (response.data['data'] ?? response.data) as Map<String, dynamic>,
        );
      } catch (_) {
        return ApiResponse.error('Failed to parse pickup details');
      }
    }
    return ApiResponse.error(response.errorMessage ?? 'Failed to load pickup details');
  }

  Future<ApiResponse<List<dynamic>>> getAssignablePickupBoys(int pickupId) async {
    final response = await _apiClient.get('/channel-partner/pickups/$pickupId/assignable-pickup-boys');
    if (response.isSuccess) {
      try {
        final raw = response.data['data'];
        final data = (raw is Map) ? (raw['items'] ?? []) : (raw ?? []);
        return ApiResponse.success(data as List<dynamic>);
      } catch (_) {
        return ApiResponse.error('Failed to parse assignable pickup boys');
      }
    }
    return ApiResponse.error(response.errorMessage ?? 'Failed to load assignable pickup boys');
  }

  Future<ApiResponse<bool>> assignPickupBoy({
    required int pickupId,
    required int pickupBoyId,
    bool reassign = false,
  }) async {
    final path = reassign
        ? '/channel-partner/pickups/$pickupId/reassign'
        : '/channel-partner/pickups/$pickupId/assign';
    final response = await _apiClient.post(
      path,
      data: {'pickup_boy_id': pickupBoyId},
    );
    if (response.isSuccess) {
      return ApiResponse.success(true);
    }
    return ApiResponse.error(response.errorMessage ?? 'Failed to assign pickup boy');
  }

  Future<ApiResponse<bool>> submitWarehouseHandover({
    required int pickupId,
    required double finalWeight,
    required double finalAmount,
    String? remarks,
    List<MultipartFile>? proofs,
  }) async {
    final form = FormData.fromMap({
      'final_weight': finalWeight,
      'final_amount': finalAmount,
      if (remarks != null && remarks.trim().isNotEmpty) 'remarks': remarks.trim(),
    });
    if (proofs != null) {
      for (final proof in proofs) {
        form.files.add(MapEntry('proofs[]', proof));
      }
    }
    final response = await _apiClient.post(
      '/channel-partner/pickups/$pickupId/deliver-to-warehouse',
      data: form,
    );
    if (response.isSuccess) {
      return ApiResponse.success(true);
    }
    return ApiResponse.error(response.errorMessage ?? 'Failed to submit handover');
  }

  Future<ApiResponse<List<dynamic>>> getSettlements({String? status}) async {
    final response = await _apiClient.get(
      '/channel-partner/settlements',
      queryParameters: status != null && status.isNotEmpty ? {'status': status} : null,
    );
    if (response.isSuccess) {
      try {
        final raw = response.data['data'];
        final data = (raw is Map) ? (raw['items'] ?? []) : (raw ?? []);
        return ApiResponse.success(data as List<dynamic>);
      } catch (_) {
        return ApiResponse.error('Failed to parse settlements');
      }
    }
    return ApiResponse.error(response.errorMessage ?? 'Failed to load settlements');
  }
}
