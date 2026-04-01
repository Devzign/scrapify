import '../network/api_role_mapper.dart';
import 'app_routes.dart';

class RoleRouteResolver {
  const RoleRouteResolver._();

  static String resolve(String? role) {
    switch (ApiRoleMapper.toAppRole(role)) {
      case 'pickup_partner':
        return AppRoutes.pickupDashboard;
      case 'warehouse':
        return AppRoutes.warehouseDashboard;
      case 'dealer':
        return AppRoutes.partnerDashboard;
      default:
        return AppRoutes.customerDashboard;
    }
  }
}
