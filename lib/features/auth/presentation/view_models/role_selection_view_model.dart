import 'package:flutter_riverpod/legacy.dart';

import 'role_selection_view_state.dart';

final roleSelectionViewModelProvider =
    StateNotifierProvider.autoDispose<
      RoleSelectionViewModel,
      RoleSelectionViewState
    >((ref) {
      return RoleSelectionViewModel();
    });

class RoleSelectionViewModel extends StateNotifier<RoleSelectionViewState> {
  RoleSelectionViewModel() : super(const RoleSelectionViewState());

  void selectRole(String role) {
    state = state.copyWith(selectedRole: role);
  }
}
