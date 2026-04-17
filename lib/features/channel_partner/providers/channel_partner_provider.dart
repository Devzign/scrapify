import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../../auth/providers/auth_provider.dart';
import '../domain/models/channel_partner_dashboard.dart';
import '../domain/repositories/channel_partner_repository.dart';

// Repository provider
final channelPartnerRepositoryProvider = Provider<ChannelPartnerRepository>((ref) {
  final dioClient = ref.watch(dioClientProvider);
  return ChannelPartnerRepository(dioClient);
});

// State
class ChannelPartnerState {
  final ChannelPartnerDashboard? dashboard;
  final List<dynamic> orders;
  final List<dynamic> pickupBoys;
  final List<dynamic> warehouses;
  final List<dynamic> approvalRequests;
  final bool isLoading;
  final bool isActionLoading;
  final String? error;

  const ChannelPartnerState({
    this.dashboard,
    this.orders = const [],
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
      state = state.copyWith(approvalRequests: result.data ?? [], isLoading: false);
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

  void clearError() => state = state.copyWith(clearError: true);
}

// Provider
final channelPartnerProvider =
    StateNotifierProvider<ChannelPartnerNotifier, ChannelPartnerState>((ref) {
  final repo = ref.watch(channelPartnerRepositoryProvider);
  return ChannelPartnerNotifier(repo);
});
