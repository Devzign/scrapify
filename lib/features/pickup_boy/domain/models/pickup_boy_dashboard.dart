import 'pickup_assignment.dart';

class PickupBoyInfo {
  final int id;
  final String name;
  final String phone;
  final String? profilePhoto;
  final bool isOnline;
  final bool isAvailable;

  const PickupBoyInfo({
    required this.id,
    required this.name,
    required this.phone,
    this.profilePhoto,
    required this.isOnline,
    required this.isAvailable,
  });

  factory PickupBoyInfo.fromJson(Map<String, dynamic> json) {
    return PickupBoyInfo(
      id: json['id'] ?? 0,
      name: json['name']?.toString() ?? '',
      phone: json['phone']?.toString() ?? '',
      profilePhoto: json['profile_photo']?.toString(),
      isOnline: json['is_online'] == true,
      isAvailable: json['is_available'] == true,
    );
  }
}

class PickupBoySummary {
  final int pendingCount;
  final int completedCount;

  const PickupBoySummary({
    required this.pendingCount,
    required this.completedCount,
  });

  factory PickupBoySummary.fromJson(Map<String, dynamic> json) {
    return PickupBoySummary(
      pendingCount: json['pending_count'] ?? 0,
      completedCount: json['completed_count'] ?? 0,
    );
  }
}

class PickupBoyDashboard {
  final PickupBoyInfo? pickupBoy;
  final int pendingCount;
  final int completedCount;
  final bool isOnline;
  final PickupAssignment? currentTask;
  final List<PickupAssignment> upcomingRoute;

  const PickupBoyDashboard({
    this.pickupBoy,
    required this.pendingCount,
    required this.completedCount,
    required this.isOnline,
    this.currentTask,
    required this.upcomingRoute,
  });

  factory PickupBoyDashboard.fromJson(Map<String, dynamic> json) {
    final data = json['data'] ?? json;
    final summary = data['summary'] as Map<String, dynamic>?;
    final pickupBoyJson = data['pickup_boy'] as Map<String, dynamic>?;
    final currentTaskJson = data['current_task'] as Map<String, dynamic>?;
    final upcomingRouteJson = data['upcoming_route'] as List<dynamic>? ?? [];

    return PickupBoyDashboard(
      pickupBoy: pickupBoyJson != null ? PickupBoyInfo.fromJson(pickupBoyJson) : null,
      pendingCount: summary?['pending_count'] ?? data['pending_count'] ?? 0,
      completedCount: summary?['completed_count'] ?? data['completed_count'] ?? 0,
      isOnline: pickupBoyJson?['is_online'] == true,
      currentTask: currentTaskJson != null ? PickupAssignment.fromJson(currentTaskJson) : null,
      upcomingRoute: upcomingRouteJson
          .whereType<Map<String, dynamic>>()
          .map((e) => PickupAssignment.fromJson(e))
          .toList(),
    );
  }
}
