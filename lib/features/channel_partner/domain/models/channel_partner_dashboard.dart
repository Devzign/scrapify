class ChannelPartnerDashboard {
  final int totalOrders;
  final int activeOrders;
  final int completedOrders;
  final int cancelledOrders;
  final int rescheduledOrders;
  final int totalWarehouses;
  final int activeWarehouses;
  final int pendingWarehouseApprovals;
  final int totalPickupBoys;
  final int activePickupBoys;
  final int availablePickupBoys;
  final int pendingPickupBoyApprovals;
  final int pendingApprovalCount;
  final List<dynamic> recentOrders;

  const ChannelPartnerDashboard({
    required this.totalOrders,
    required this.activeOrders,
    required this.completedOrders,
    required this.cancelledOrders,
    required this.rescheduledOrders,
    required this.totalWarehouses,
    required this.activeWarehouses,
    required this.pendingWarehouseApprovals,
    required this.totalPickupBoys,
    required this.activePickupBoys,
    required this.availablePickupBoys,
    required this.pendingPickupBoyApprovals,
    required this.pendingApprovalCount,
    required this.recentOrders,
  });

  factory ChannelPartnerDashboard.fromJson(Map<String, dynamic> json) {
    final data = json['data'] ?? json;
    final orders = data['orders'] as Map<String, dynamic>? ?? {};
    final warehouses = data['warehouses'] as Map<String, dynamic>? ?? {};
    final pickupBoys = data['pickup_boys'] as Map<String, dynamic>? ??
        data['pickupBoys'] as Map<String, dynamic>? ?? {};

    return ChannelPartnerDashboard(
      totalOrders: orders['total'] ?? data['total_orders'] ?? 0,
      activeOrders: orders['active'] ?? data['active_orders'] ?? 0,
      completedOrders: orders['completed'] ?? data['completed_orders'] ?? 0,
      cancelledOrders: orders['cancelled'] ?? data['cancelled_orders'] ?? 0,
      rescheduledOrders: orders['rescheduled'] ?? data['rescheduled_orders'] ?? 0,
      totalWarehouses: warehouses['total'] ?? data['total_warehouses'] ?? 0,
      activeWarehouses: warehouses['active'] ?? data['active_warehouses'] ?? 0,
      pendingWarehouseApprovals:
          warehouses['pending_approvals'] ?? data['pending_warehouse_approvals'] ?? 0,
      totalPickupBoys: pickupBoys['total'] ?? data['total_pickup_boys'] ?? 0,
      activePickupBoys: pickupBoys['active'] ?? data['active_pickup_boys'] ?? 0,
      availablePickupBoys: pickupBoys['available'] ?? data['available_pickup_boys'] ?? 0,
      pendingPickupBoyApprovals:
          pickupBoys['pending_approvals'] ?? data['pending_pickup_boy_approvals'] ?? 0,
      pendingApprovalCount: data['pending_approval_count'] ?? data['pending_approvals'] ?? 0,
      recentOrders: data['recent_orders'] as List<dynamic>? ?? [],
    );
  }
}
