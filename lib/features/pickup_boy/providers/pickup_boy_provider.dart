import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../../auth/providers/auth_provider.dart';
import '../domain/models/pickup_assignment.dart';
import '../domain/models/pickup_boy_dashboard.dart';
import '../domain/models/pickup_item.dart';
import '../domain/repositories/pickup_boy_repository.dart';

// Repository provider
final pickupBoyRepositoryProvider = Provider<PickupBoyRepository>((ref) {
  final dioClient = ref.watch(dioClientProvider);
  return PickupBoyRepository(dioClient);
});

// State
class PickupBoyState {
  final PickupBoyDashboard? dashboard;
  final List<PickupAssignment> assignments;
  final String period;
  final bool isLoading;
  final bool isActionLoading;
  final String? error;

  const PickupBoyState({
    this.dashboard,
    this.assignments = const [],
    this.period = 'overall',
    this.isLoading = false,
    this.isActionLoading = false,
    this.error,
  });

  PickupBoyState copyWith({
    PickupBoyDashboard? dashboard,
    List<PickupAssignment>? assignments,
    String? period,
    bool? isLoading,
    bool? isActionLoading,
    String? error,
    bool clearError = false,
  }) {
    return PickupBoyState(
      dashboard: dashboard ?? this.dashboard,
      assignments: assignments ?? this.assignments,
      period: period ?? this.period,
      isLoading: isLoading ?? this.isLoading,
      isActionLoading: isActionLoading ?? this.isActionLoading,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

// Notifier
class PickupBoyNotifier extends StateNotifier<PickupBoyState> {
  final PickupBoyRepository _repository;

  PickupBoyNotifier(this._repository) : super(const PickupBoyState());

  Future<void> loadDashboard({String? period}) async {
    final selectedPeriod = period ?? state.period;
    state = state.copyWith(isLoading: true, clearError: true);
    final result = await _repository.getDashboard(period: selectedPeriod);
    if (result.isSuccess) {
      state = state.copyWith(
        dashboard: result.data,
        period: selectedPeriod,
        isLoading: false,
      );
    } else {
      state = state.copyWith(isLoading: false, error: result.errorMessage);
    }
  }

  Future<void> loadAssignments({String? status, String? period}) async {
    final selectedPeriod = period ?? state.period;
    state = state.copyWith(isLoading: true, clearError: true);
    final result = await _repository.getAssignments(
      status: status,
      period: selectedPeriod,
    );
    if (result.isSuccess) {
      state = state.copyWith(
        assignments: result.data ?? [],
        period: selectedPeriod,
        isLoading: false,
      );
    } else {
      state = state.copyWith(isLoading: false, error: result.errorMessage);
    }
  }

  Future<bool> acceptPickup(int id) async {
    state = state.copyWith(isActionLoading: true, clearError: true);
    final result = await _repository.acceptPickup(id);
    state = state.copyWith(isActionLoading: false);
    if (result.isError) {
      state = state.copyWith(error: result.errorMessage);
    }
    return !result.isError;
  }

  Future<bool> rejectPickup(int id) async {
    state = state.copyWith(isActionLoading: true, clearError: true);
    final result = await _repository.rejectPickup(id);
    state = state.copyWith(isActionLoading: false);
    if (result.isError) {
      state = state.copyWith(error: result.errorMessage);
    }
    return !result.isError;
  }

  Future<bool> updateStatus(int id, String status) async {
    state = state.copyWith(isActionLoading: true, clearError: true);
    final result = await _repository.updateStatus(id, status);
    state = state.copyWith(isActionLoading: false);
    if (result.isError) {
      state = state.copyWith(error: result.errorMessage);
    }
    return !result.isError;
  }

  Future<Map<String, dynamic>?> verifyPickup(
    int id,
    List<PickupItem> items,
    List<File> images,
  ) async {
    state = state.copyWith(isActionLoading: true, clearError: true);
    final result = await _repository.verifyPickup(id, items, images);
    state = state.copyWith(isActionLoading: false);
    if (result.isSuccess) return result.data;
    state = state.copyWith(error: result.errorMessage);
    return null;
  }

  Future<bool> rescheduleRequest(
    int id, {
    required String reasonCode,
    String? additionalNote,
  }) async {
    state = state.copyWith(isActionLoading: true, clearError: true);
    final result = await _repository.rescheduleRequest(
      id,
      reasonCode: reasonCode,
      additionalNote: additionalNote,
    );
    state = state.copyWith(isActionLoading: false);
    if (result.isError) {
      state = state.copyWith(error: result.errorMessage);
    }
    return !result.isError;
  }

  Future<bool> toggleOnline(bool isOnline) async {
    final current = state.dashboard?.isOnline;
    if (current != null && current == isOnline) {
      return true;
    }

    state = state.copyWith(isActionLoading: true, clearError: true);
    final result = await _repository.toggleOnlineStatus(isOnline);
    state = state.copyWith(isActionLoading: false);
    if (!result.isError && state.dashboard != null) {
      final updated = PickupBoyDashboard(
        pickupBoy: state.dashboard!.pickupBoy == null
            ? null
            : PickupBoyInfo(
                id: state.dashboard!.pickupBoy!.id,
                name: state.dashboard!.pickupBoy!.name,
                phone: state.dashboard!.pickupBoy!.phone,
                profilePhoto: state.dashboard!.pickupBoy!.profilePhoto,
                isOnline: isOnline,
                isAvailable: state.dashboard!.pickupBoy!.isAvailable,
              ),
        summary: state.dashboard!.summary,
        pendingCount: state.dashboard!.pendingCount,
        completedCount: state.dashboard!.completedCount,
        isOnline: isOnline,
        currentTask: state.dashboard!.currentTask,
        upcomingRoute: state.dashboard!.upcomingRoute,
      );
      state = state.copyWith(dashboard: updated);
    } else if (result.isError) {
      state = state.copyWith(error: result.errorMessage);
    }
    return !result.isError;
  }

  void clearError() => state = state.copyWith(clearError: true);

  Future<void> setPeriod({
    required String period,
    required String assignmentStatus,
  }) async {
    await loadDashboard(period: period);
    await loadAssignments(status: assignmentStatus, period: period);
  }
}

// Provider
final pickupBoyProvider =
    StateNotifierProvider<PickupBoyNotifier, PickupBoyState>((ref) {
      final repo = ref.watch(pickupBoyRepositoryProvider);
      return PickupBoyNotifier(repo);
    });
