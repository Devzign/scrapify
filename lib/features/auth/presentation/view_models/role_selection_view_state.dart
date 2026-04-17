class RoleSelectionViewState {
  final String selectedRole;

  const RoleSelectionViewState({this.selectedRole = 'customer'});

  RoleSelectionViewState copyWith({String? selectedRole}) {
    return RoleSelectionViewState(
      selectedRole: selectedRole ?? this.selectedRole,
    );
  }
}
