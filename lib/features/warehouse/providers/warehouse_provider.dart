import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../../auth/providers/auth_provider.dart';
import '../domain/models/warehouse_dashboard.dart';
import '../domain/models/warehouse_request.dart';
import '../domain/models/warehouse_pickup_boy.dart';
import '../domain/repositories/warehouse_repository.dart';

// Repository provider
final warehouseRepositoryProvider = Provider<WarehouseRepository>((ref) {
  final dioClient = ref.watch(dioClientProvider);
  return WarehouseRepository(dioClient);
});

// State
class WarehouseState {
  final WarehouseDashboard? dashboard;
  final List<WarehouseRequest> requests;
  final List<WarehousePickupBoy> pickupBoys;
  final List<WarehousePickupBoy> assignablePickupBoys;
  final bool isLoading;
  final bool isActionLoading;
  final String? error;

  const WarehouseState({
    this.dashboard,
    this.requests = const [],
    this.pickupBoys = const [],
    this.assignablePickupBoys = const [],
    this.isLoading = false,
    this.isActionLoading = false,
    this.error,
  });

  WarehouseState copyWith({
    WarehouseDashboard? dashboard,
    List<WarehouseRequest>? requests,
    List<WarehousePickupBoy>? pickupBoys,
    List<WarehousePickupBoy>? assignablePickupBoys,
    bool? isLoading,
    bool? isActionLoading,
    String? error,
    bool clearError = false,
  }) {
    return WarehouseState(
      dashboard: dashboard ?? this.dashboard,
      requests: requests ?? this.requests,
      pickupBoys: pickupBoys ?? this.pickupBoys,
      assignablePickupBoys: assignablePickupBoys ?? this.assignablePickupBoys,
      isLoading: isLoading ?? this.isLoading,
      isActionLoading: isActionLoading ?? this.isActionLoading,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

// Notifier
class WarehouseNotifier extends StateNotifier<WarehouseState> {
  final WarehouseRepository _repository;

  WarehouseNotifier(this._repository) : super(const WarehouseState());

  Future<void> loadDashboard() async {
    state = state.copyWith(isLoading: true, clearError: true);
    final result = await _repository.getDashboard();
    if (result.isSuccess) {
      state = state.copyWith(dashboard: result.data, isLoading: false);
    } else {
      state = state.copyWith(isLoading: false, error: result.errorMessage);
    }
  }

  Future<void> loadRequests({String? status}) async {
    state = state.copyWith(isLoading: true, clearError: true);
    final result = await _repository.getRequests(status: status);
    if (result.isSuccess) {
      state = state.copyWith(requests: result.data ?? [], isLoading: false);
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

  Future<void> loadAssignablePickupBoys(int requestId) async {
    state = state.copyWith(isActionLoading: true, clearError: true);
    final result = await _repository.getAssignablePickupBoys(requestId);
    if (result.isSuccess) {
      state = state.copyWith(
        assignablePickupBoys: result.data ?? [],
        isActionLoading: false,
      );
    } else {
      state = state.copyWith(isActionLoading: false, error: result.errorMessage);
    }
  }

  Future<bool> assignPickupBoy(
    int requestId,
    int pickupBoyId, {
    String? notes,
  }) async {
    state = state.copyWith(isActionLoading: true, clearError: true);
    final result = await _repository.assignPickupBoy(requestId, pickupBoyId, notes: notes);
    state = state.copyWith(isActionLoading: false);
    if (!result.isSuccess) {
      state = state.copyWith(error: result.errorMessage);
    }
    return result.isSuccess;
  }

  Future<bool> reassignPickupBoy(
    int requestId,
    int pickupBoyId,
    String reason,
  ) async {
    state = state.copyWith(isActionLoading: true, clearError: true);
    final result = await _repository.reassignPickupBoy(requestId, pickupBoyId, reason);
    state = state.copyWith(isActionLoading: false);
    if (!result.isSuccess) {
      state = state.copyWith(error: result.errorMessage);
    }
    return result.isSuccess;
  }

  void clearError() => state = state.copyWith(clearError: true);
}

// Provider
final warehouseProvider =
    StateNotifierProvider<WarehouseNotifier, WarehouseState>((ref) {
  final repo = ref.watch(warehouseRepositoryProvider);
  return WarehouseNotifier(repo);
});
