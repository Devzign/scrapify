import 'app_routes.dart';

class RoleRouteResolver {
  const RoleRouteResolver._();

  static String resolve(String? role) {
    switch (role) {
      case 'pickup_partner':
      case 'pickup_boy':
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
