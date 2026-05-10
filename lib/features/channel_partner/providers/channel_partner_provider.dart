import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:dio/dio.dart';
import '../../auth/providers/auth_provider.dart';
import '../domain/models/channel_partner_dashboard.dart';
import '../domain/repositories/channel_partner_repository.dart';

// Repository provider
final channelPartnerRepositoryProvider = Provider<ChannelPartnerRepository>((
  ref,
) {
  final dioClient = ref.watch(dioClientProvider);
  return ChannelPartnerRepository(dioClient);
});

// State
class ChannelPartnerState {
  final ChannelPartnerDashboard? dashboard;
  final List<dynamic> orders;
  final List<dynamic> customers;
  final List<dynamic> pickups;
  final List<dynamic> settlements;
  final List<dynamic> pickupBoys;
  final List<dynamic> warehouses;
  final List<dynamic> approvalRequests;
  final bool isLoading;
  final bool isActionLoading;
  final String? error;

  const ChannelPartnerState({
    this.dashboard,
    this.orders = const [],
    this.customers = const [],
    this.pickups = const [],
    this.settlements = const [],
    this.pickupBoys = const [],
    this.warehouses = const [],
    this.approvalRequests = const [],
    this.isLoading = false,
    this.isActionLoading = false,
    this.error,
  });

  ChannelPartnerState copyWith({
    ChannelPartnerDashboard? dashboard,
    List<dynamic>? orders,
    List<dynamic>? customers,
    List<dynamic>? pickups,
    List<dynamic>? settlements,
    List<dynamic>? pickupBoys,
    List<dynamic>? warehouses,
    List<dynamic>? approvalRequests,
    bool? isLoading,
    bool? isActionLoading,
    String? error,
    bool clearError = false,
  }) {
    return ChannelPartnerState(
      dashboard: dashboard ?? this.dashboard,
      orders: orders ?? this.orders,
      customers: customers ?? this.customers,
      pickups: pickups ?? this.pickups,
      settlements: settlements ?? this.settlements,
      pickupBoys: pickupBoys ?? this.pickupBoys,
      warehouses: warehouses ?? this.warehouses,
      approvalRequests: approvalRequests ?? this.approvalRequests,
      isLoading: isLoading ?? this.isLoading,
      isActionLoading: isActionLoading ?? this.isActionLoading,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

// Notifier
class ChannelPartnerNotifier extends StateNotifier<ChannelPartnerState> {
  final ChannelPartnerRepository _repository;

  ChannelPartnerNotifier(this._repository) : super(const ChannelPartnerState());

  Future<void> loadDashboard() async {
    state = state.copyWith(isLoading: true, clearError: true);
    final result = await _repository.getDashboard();
    if (result.isSuccess) {
      state = state.copyWith(dashboard: result.data, isLoading: false);
    } else {
      state = state.copyWith(isLoading: false, error: result.errorMessage);
    }
  }

  Future<void> loadOrders({String? status}) async {
    state = state.copyWith(isLoading: true, clearError: true);
    final result = await _repository.getOrders(status: status);
    if (result.isSuccess) {
      state = state.copyWith(orders: result.data ?? [], isLoading: false);
    } else {
      state = state.copyWith(isLoading: false, error: result.errorMessage);
    }
  }

  Future<void> loadCustomers({String? q}) async {
    state = state.copyWith(isLoading: true, clearError: true);
    final result = await _repository.getCustomers(q: q);
    if (result.isSuccess) {
      state = state.copyWith(customers: result.data ?? [], isLoading: false);
    } else {
      state = state.copyWith(isLoading: false, error: result.errorMessage);
    }
  }

  Future<Map<String, dynamic>?> createCustomer(Map<String, dynamic> payload) async {
    state = state.copyWith(isActionLoading: true, clearError: true);
    final result = await _repository.createCustomer(payload);
    state = state.copyWith(isActionLoading: false);
    if (result.isSuccess) {
      return result.data;
    }
    state = state.copyWith(error: result.errorMessage);
    return null;
  }

  Future<Map<String, dynamic>?> updateCustomer(
    int id,
    Map<String, dynamic> payload,
  ) async {
    state = state.copyWith(isActionLoading: true, clearError: true);
    final result = await _repository.updateCustomer(id, payload);
    state = state.copyWith(isActionLoading: false);
    if (result.isSuccess) {
      return result.data;
    }
    state = state.copyWith(error: result.errorMessage);
    return null;
  }

  Future<Map<String, dynamic>?> getCustomerDetail(int id) async {
    state = state.copyWith(isActionLoading: true, clearError: true);
    final result = await _repository.getCustomerDetail(id);
    state = state.copyWith(isActionLoading: false);
    if (result.isSuccess) {
      return result.data;
    }
    state = state.copyWith(error: result.errorMessage);
    return null;
  }

  Future<Map<String, dynamic>?> createPickupRequest({
    required Map<String, dynamic> payload,
    List<MultipartFile>? images,
  }) async {
    state = state.copyWith(isActionLoading: true, clearError: true);
    final result = await _repository.createPickupRequest(
      payload: payload,
      images: images,
    );
    state = state.copyWith(isActionLoading: false);
    if (result.isSuccess) {
      return result.data;
    }
    state = state.copyWith(error: result.errorMessage);
    return null;
  }

  Future<void> loadPartnerPickups({
    String? status,
    String? date,
    String? customer,
    String? pickupBoy,
    String? q,
  }) async {
    state = state.copyWith(isLoading: true, clearError: true);
    final result = await _repository.getPartnerPickups(
      status: status,
      date: date,
      customer: customer,
      pickupBoy: pickupBoy,
      q: q,
    );
    if (result.isSuccess) {
      state = state.copyWith(pickups: result.data ?? [], isLoading: false);
    } else {
      state = state.copyWith(isLoading: false, error: result.errorMessage);
    }
  }

  Future<Map<String, dynamic>?> getPartnerPickupDetail(int id) async {
    state = state.copyWith(isActionLoading: true, clearError: true);
    final result = await _repository.getPartnerPickupDetail(id);
    state = state.copyWith(isActionLoading: false);
    if (result.isSuccess) {
      return result.data;
    }
    state = state.copyWith(error: result.errorMessage);
    return null;
  }

  Future<List<dynamic>> getAssignablePickupBoys(int pickupId) async {
    state = state.copyWith(isActionLoading: true, clearError: true);
    final result = await _repository.getAssignablePickupBoys(pickupId);
    state = state.copyWith(isActionLoading: false);
    if (result.isSuccess) {
      return result.data ?? const [];
    }
    state = state.copyWith(error: result.errorMessage);
    return const [];
  }

  Future<bool> assignPickupBoy({
    required int pickupId,
    required int pickupBoyId,
    bool reassign = false,
  }) async {
    state = state.copyWith(isActionLoading: true, clearError: true);
    final result = await _repository.assignPickupBoy(
      pickupId: pickupId,
      pickupBoyId: pickupBoyId,
      reassign: reassign,
    );
    state = state.copyWith(isActionLoading: false);
    if (!result.isSuccess) {
      state = state.copyWith(error: result.errorMessage);
    }
    return result.isSuccess;
  }

  Future<bool> submitWarehouseHandover({
    required int pickupId,
    required double finalWeight,
    required double finalAmount,
    String? remarks,
    List<MultipartFile>? proofs,
  }) async {
    state = state.copyWith(isActionLoading: true, clearError: true);
    final result = await _repository.submitWarehouseHandover(
      pickupId: pickupId,
      finalWeight: finalWeight,
      finalAmount: finalAmount,
      remarks: remarks,
      proofs: proofs,
    );
    state = state.copyWith(isActionLoading: false);
    if (!result.isSuccess) {
      state = state.copyWith(error: result.errorMessage);
    }
    return result.isSuccess;
  }

  Future<void> loadSettlements({String? status}) async {
    state = state.copyWith(isLoading: true, clearError: true);
    final result = await _repository.getSettlements(status: status);
    if (result.isSuccess) {
      state = state.copyWith(settlements: result.data ?? [], isLoading: false);
    } else {
      state = state.copyWith(isLoading: false, error: result.errorMessage);
    }
  }

  Future<void> loadPickupBoys() async {
    state = state.copyWith(isLoading: true, clearError: true);
    final result = await _repository.getPickupBoys();
    if (result.isSuccess) {
      state = state.copyWith(pickupBoys: result.data ?? [], isLoading: false);
    } else {
      state = state.copyWith(isLoading: false, error: result.errorMessage);
    }
  }

  Future<void> loadWarehouses() async {
    state = state.copyWith(isLoading: true, clearError: true);
    final result = await _repository.getWarehouses();
    if (result.isSuccess) {
      state = state.copyWith(warehouses: result.data ?? [], isLoading: false);
    } else {
      state = state.copyWith(isLoading: false, error: result.errorMessage);
    }
  }

  Future<void> loadApprovalRequests({String? status}) async {
    state = state.copyWith(isLoading: true, clearError: true);
    final result = await _repository.getApprovalRequests(status: status);
    if (result.isSuccess) {
      state = state.copyWith(
        approvalRequests: result.data ?? [],
        isLoading: false,
      );
    } else {
      state = state.copyWith(isLoading: false, error: result.errorMessage);
    }
  }

  Future<bool> submitStatusRequest(Map<String, dynamic> data) async {
    state = state.copyWith(isActionLoading: true, clearError: true);
    final result = await _repository.submitStatusRequest(data);
    state = state.copyWith(isActionLoading: false);
    if (!result.isSuccess) {
      state = state.copyWith(error: result.errorMessage);
    }
    return result.isSuccess;
  }

  Future<Map<String, dynamic>?> getOrderDetail(int id) async {
    state = state.copyWith(isActionLoading: true, clearError: true);
    final result = await _repository.getOrderDetail(id);
    state = state.copyWith(isActionLoading: false);
    if (result.isSuccess) {
      return result.data;
    }
    state = state.copyWith(error: result.errorMessage);
    return null;
  }

  void clearError() => state = state.copyWith(clearError: true);
}

// Provider
final channelPartnerProvider =
    StateNotifierProvider<ChannelPartnerNotifier, ChannelPartnerState>((ref) {
      final repo = ref.watch(channelPartnerRepositoryProvider);
      return ChannelPartnerNotifier(repo);
    });
