class WarehouseInfo {
  final int id;
  final String name;
  final String? code;
  final String? city;
  final String? address;

  const WarehouseInfo({
    required this.id,
    required this.name,
    this.code,
    this.city,
    this.address,
  });

  factory WarehouseInfo.fromJson(Map<String, dynamic> json) {
    int asInt(dynamic value) {
      if (value is int) return value;
      if (value is num) return value.toInt();
      if (value is String) return int.tryParse(value.trim()) ?? 0;
      return 0;
    }

    return WarehouseInfo(
      id: asInt(json['id']),
      name: json['name']?.toString() ?? '',
      code: json['code']?.toString(),
      city: json['city']?.toString(),
      address: json['address']?.toString(),
    );
  }
}

class WarehouseDashboard {
  final WarehouseInfo? warehouse;
  final int totalRequests;
  final int unassignedRequests;
  final int assignedRequests;
  final int activePickups;
  final int completedPickups;
  final int rescheduledRequests;
  final int totalPickupBoys;
  final int activePickupBoys;
  final int availablePickupBoys;
  final List<dynamic> recentRequests;

  const WarehouseDashboard({
    this.warehouse,
    required this.totalRequests,
    required this.unassignedRequests,
    required this.assignedRequests,
    required this.activePickups,
    required this.completedPickups,
    required this.rescheduledRequests,
    required this.totalPickupBoys,
    required this.activePickupBoys,
    required this.availablePickupBoys,
    required this.recentRequests,
  });

  factory WarehouseDashboard.fromJson(Map<String, dynamic> json) {
    int asInt(dynamic value) {
      if (value is int) return value;
      if (value is num) return value.toInt();
      if (value is String) return int.tryParse(value.trim()) ?? 0;
      return 0;
    }

    final data = json['data'] ?? json;
    final metrics = data['metrics'] as Map<String, dynamic>? ?? {};
    final warehouseJson = data['warehouse'] as Map<String, dynamic>?;

    return WarehouseDashboard(
      warehouse: warehouseJson != null
          ? WarehouseInfo.fromJson(warehouseJson)
          : null,
      totalRequests: asInt(metrics['total_requests'] ?? data['total_requests']),
      unassignedRequests: asInt(
        metrics['unassigned_requests'] ?? data['unassigned_requests'],
      ),
      assignedRequests: asInt(
        metrics['assigned_requests'] ?? data['assigned_requests'],
      ),
      activePickups: asInt(metrics['active_pickups'] ?? data['active_pickups']),
      completedPickups: asInt(
        metrics['completed_pickups'] ?? data['completed_pickups'],
      ),
      rescheduledRequests: asInt(
        metrics['rescheduled_requests'] ?? data['rescheduled_requests'],
      ),
      totalPickupBoys: asInt(
        metrics['total_pickup_boys'] ?? data['total_pickup_boys'],
      ),
      activePickupBoys: asInt(
        metrics['active_pickup_boys'] ?? data['active_pickup_boys'],
      ),
      availablePickupBoys: asInt(
        metrics['available_pickup_boys'] ?? data['available_pickup_boys'],
      ),
      recentRequests: data['recent_requests'] as List<dynamic>? ?? [],
    );
  }
}
