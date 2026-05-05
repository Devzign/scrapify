import 'package:flutter_riverpod/legacy.dart';

import '../data/repositories/help_support_repository.dart';
import 'help_support_state.dart';

class HelpSupportNotifier extends StateNotifier<HelpSupportState> {
  final HelpSupportRepository _repository;

  HelpSupportNotifier(this._repository) : super(const HelpSupportState());

  Future<void> loadTickets() async {
    state = state.copyWith(isLoading: true, clearError: true);
    final response = await _repository.getTickets();
    if (response.isSuccess) {
      state = state.copyWith(
        isLoading: false,
        tickets: response.data ?? const [],
        clearError: true,
      );
      return;
    }
    state = state.copyWith(
      isLoading: false,
      error: response.errorMessage ?? 'Failed to load support requests',
    );
  }

  Future<bool> submitTicket({
    required String subject,
    required String message,
    required String phone,
    int? orderId,
  }) async {
    state = state.copyWith(isSubmitting: true, clearError: true);
    final response = await _repository.submitTicket(
      subject: subject,
      message: message,
      phone: phone,
      orderId: orderId,
    );
    if (!response.isSuccess) {
      state = state.copyWith(
        isSubmitting: false,
        error: response.errorMessage ?? 'Failed to submit request',
      );
      return false;
    }
    state = state.copyWith(isSubmitting: false, clearError: true);
    await loadTickets();
    return true;
  }

  void clearError() {
    state = state.copyWith(clearError: true);
  }
}

final helpSupportProvider =
    StateNotifierProvider<HelpSupportNotifier, HelpSupportState>((ref) {
      final repository = ref.watch(helpSupportRepositoryProvider);
      return HelpSupportNotifier(repository);
    });
