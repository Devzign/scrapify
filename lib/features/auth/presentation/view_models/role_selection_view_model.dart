import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../../providers/auth_provider.dart';
import 'role_selection_view_state.dart';

final roleSelectionViewModelProvider =
    StateNotifierProvider.autoDispose<
      RoleSelectionViewModel,
      RoleSelectionViewState
    >((ref) {
      return RoleSelectionViewModel(ref);
    });

class RoleSelectionViewModel extends StateNotifier<RoleSelectionViewState> {
  final Ref _ref;

  RoleSelectionViewModel(this._ref) : super(const RoleSelectionViewState());

  Future<void> loadRoles() async {
    if (state.isLoading || state.hasLoadedRoles) {
      return;
    }

    state = state.copyWith(isLoading: true, clearError: true);

    final response = await _ref.read(authRepositoryProvider).fetchUserTypes();
    if (!response.isSuccess || response.data == null) {
      state = state.copyWith(
        isLoading: false,
        error: response.errorMessage ?? 'Failed to load user types',
        hasLoadedRoles: true,
      );
      return;
    }

    final roles = response.data!
        .where((role) => role.visible && role.code.toLowerCase() != 'admin')
        .toList();

    // Preserve the user's prior selection if it's still valid; otherwise leave
    // it null so the user has to make an active choice before continuing.
    final selectedRole =
        roles.any((role) => role.code == state.selectedRole)
            ? state.selectedRole
            : null;

    state = state.copyWith(
      roles: roles,
      selectedRole: selectedRole,
      clearSelectedRole: selectedRole == null,
      isLoading: false,
      hasLoadedRoles: true,
    );
  }

  void selectRole(String role) {
    state = state.copyWith(selectedRole: role);
  }
}
