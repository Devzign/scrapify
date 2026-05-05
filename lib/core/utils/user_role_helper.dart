import '../../features/auth/domain/models/user.dart';
import '../network/api_role_mapper.dart';

bool isCustomerUser(User? user) {
  if (user == null || user.roles.isEmpty) {
    return false;
  }
  final normalizedRole = ApiRoleMapper.toAppRole(user.roles.first);
  return normalizedRole == 'customer';
}
