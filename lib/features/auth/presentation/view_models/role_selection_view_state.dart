import '../../domain/models/user_type_option.dart';

class RoleSelectionViewState {
  final List<UserTypeOption> roles;

  /// `null` until the user explicitly taps a role card. We deliberately do
  /// NOT seed a default — the user must make an active choice before they
  /// can continue.
  final String? selectedRole;
  final bool isLoading;
  final String? error;
  final bool hasLoadedRoles;

  const RoleSelectionViewState({
    this.roles = const [],
    this.selectedRole,
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
    bool clearSelectedRole = false,
  }) {
    return RoleSelectionViewState(
      roles: roles ?? this.roles,
      selectedRole: clearSelectedRole
          ? null
          : (selectedRole ?? this.selectedRole),
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
      hasLoadedRoles: hasLoadedRoles ?? this.hasLoadedRoles,
    );
  }
}
