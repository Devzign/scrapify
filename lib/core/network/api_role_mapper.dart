class ApiRoleMapper {
  const ApiRoleMapper._();

  static String toApiRole(String role) {
    switch (role) {
      case 'pickup_partner':
        return 'pickup_boy';
      case 'dealer':
        return 'channel_partner';
      default:
        return role;
    }
  }

  static String toAppRole(String? role) {
    switch (role) {
      case 'pickup_boy':
        return 'pickup_partner';
      case 'channel_partner':
        return 'dealer';
      default:
        return role ?? 'customer';
    }
  }
}
