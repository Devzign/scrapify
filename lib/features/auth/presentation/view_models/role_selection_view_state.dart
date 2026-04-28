import '../../domain/models/user_type_option.dart';

class RoleSelectionViewState {
  final List<UserTypeOption> roles;
  final String selectedRole;
  final bool isLoading;
  final String? error;
  final bool hasLoadedRoles;

  const RoleSelectionViewState({
    this.roles = const [],
    this.selectedRole = 'customer',
    this.isLoading = false,
    this.error,
    this.hasLoadedRoles = false,
  });

  RoleSelectionViewState copyWith({
    List<UserTypeOption>? roles,
    String? selectedRole,
    bool? isLoading,
    String? error,
    bool? hasLoadedRoles,
    bool clearError = false,
  }) {
    return RoleSelectionViewState(
      roles: roles ?? this.roles,
      selectedRole: selectedRole ?? this.selectedRole,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
      hasLoadedRoles: hasLoadedRoles ?? this.hasLoadedRoles,
    );
  }
}
