import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../../auth/providers/auth_provider.dart';
import '../domain/models/pickup_request.dart';
import '../domain/repositories/pickup_repository.dart';

// Repository provider
final pickupRepositoryProvider = Provider<PickupRepository>((ref) {
  final dioClient = ref.watch(dioClientProvider);
  return PickupRepository(dioClient);
});

// State
class PickupState {
  final List<PickupRequest> requests;
  final PickupStats? stats;
  final List<dynamic> categories;
  final bool isLoading;
  final bool isActionLoading;
  final String? error;

  const PickupState({
    this.requests = const [],
    this.stats,
    this.categories = const [],
    this.isLoading = false,
    this.isActionLoading = false,
    this.error,
  });

  PickupState copyWith({
    List<PickupRequest>? requests,
    PickupStats? stats,
    List<dynamic>? categories,
    bool? isLoading,
    bool? isActionLoading,
    String? error,
    bool clearError = false,
  }) {
    return PickupState(
      requests: requests ?? this.requests,
      stats: stats ?? this.stats,
      categories: categories ?? this.categories,
      isLoading: isLoading ?? this.isLoading,
      isActionLoading: isActionLoading ?? this.isActionLoading,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

// Notifier
class PickupNotifier extends StateNotifier<PickupState> {
  final PickupRepository _repository;

  PickupNotifier(this._repository) : super(const PickupState());

  Future<void> loadPickups({String? status}) async {
    state = state.copyWith(isLoading: true, clearError: true);
    final result = await _repository.getPickups(status: status);
    if (result.isSuccess) {
      state = state.copyWith(requests: result.data ?? [], isLoading: false);
    } else {
      state = state.copyWith(isLoading: false, error: result.errorMessage);
    }
  }

  Future<void> loadStats() async {
    final result = await _repository.getStats();
    if (result.isSuccess) {
      state = state.copyWith(stats: result.data);
    }
  }

  Future<void> loadCategories() async {
    state = state.copyWith(isLoading: true, clearError: true);
    final result = await _repository.getCategories();
    if (result.isSuccess) {
      state = state.copyWith(categories: result.data ?? [], isLoading: false);
    } else {
      state = state.copyWith(isLoading: false, error: result.errorMessage);
    }
  }

  Future<bool> cancelPickup(int id, String reason) async {
    state = state.copyWith(isActionLoading: true, clearError: true);
    final result = await _repository.cancelPickup(id, reason);
    state = state.copyWith(isActionLoading: false);
    if (result.isSuccess) {
      await loadPickups();
    } else {
      state = state.copyWith(error: result.errorMessage);
    }
    return result.isSuccess;
  }

  Future<bool> submitReview(int id, int rating, {String? review}) async {
    state = state.copyWith(isActionLoading: true, clearError: true);
    final result = await _repository.submitReview(id, rating, review: review);
    state = state.copyWith(isActionLoading: false);
    if (!result.isSuccess) {
      state = state.copyWith(error: result.errorMessage);
    }
    return result.isSuccess;
  }

  void clearError() => state = state.copyWith(clearError: true);
}

// Provider
final pickupProvider =
    StateNotifierProvider<PickupNotifier, PickupState>((ref) {
  final repo = ref.watch(pickupRepositoryProvider);
  return PickupNotifier(repo);
});
