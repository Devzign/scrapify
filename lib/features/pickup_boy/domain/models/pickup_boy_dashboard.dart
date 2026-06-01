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
      isOnline: _asBool(json['is_online']),
      isAvailable: _asBool(json['is_available']),
    );
  }
}

class PickupBoySummary {
  final String period;
  final int totalPickups;
  final int assignedCount;
  final int pendingCount;
  final int completedCount;
  final int rejectedCount;

  const PickupBoySummary({
    required this.period,
    required this.totalPickups,
    required this.assignedCount,
    required this.pendingCount,
    required this.completedCount,
    required this.rejectedCount,
  });

  factory PickupBoySummary.fromJson(Map<String, dynamic> json) {
    return PickupBoySummary(
      period: json['period']?.toString() ?? 'today',
      totalPickups: _asInt(json['total_pickups']),
      assignedCount: _asInt(json['assigned_count']),
      pendingCount: json['pending_count'] ?? 0,
      completedCount: json['completed_count'] ?? 0,
      rejectedCount: _asInt(json['rejected_count']),
    );
  }
}

class PickupBoyDashboard {
  final PickupBoyInfo? pickupBoy;
  final PickupBoySummary summary;
  final int pendingCount;
  final int completedCount;
  final bool isOnline;
  final PickupAssignment? currentTask;
  final List<PickupAssignment> upcomingRoute;

  const PickupBoyDashboard({
    this.pickupBoy,
    required this.summary,
    required this.pendingCount,
    required this.completedCount,
    required this.isOnline,
    this.currentTask,
    required this.upcomingRoute,
  });

  factory PickupBoyDashboard.fromJson(Map<String, dynamic> json) {
    final data = json['data'] ?? json;
    final summaryJson = data['summary'] as Map<String, dynamic>? ?? const {};
    final pickupBoyJson = data['pickup_boy'] as Map<String, dynamic>?;
    final currentTaskJson = data['current_task'] as Map<String, dynamic>?;
    final upcomingRouteJson = data['upcoming_route'] as List<dynamic>? ?? [];

    return PickupBoyDashboard(
      pickupBoy: pickupBoyJson != null
          ? PickupBoyInfo.fromJson(pickupBoyJson)
          : null,
      summary: PickupBoySummary.fromJson(summaryJson),
      pendingCount:
          summaryJson['pending_count'] ?? data['pending_count'] ?? 0,
      completedCount:
          summaryJson['completed_count'] ?? data['completed_count'] ?? 0,
      isOnline:
          _asBool(pickupBoyJson?['is_online']) ||
          _asBool(data['is_online']) ||
          _asBool(data['online_status']),
      currentTask: currentTaskJson != null
          ? PickupAssignment.fromJson(currentTaskJson)
          : null,
      upcomingRoute: upcomingRouteJson
          .whereType<Map<String, dynamic>>()
          .map((e) => PickupAssignment.fromJson(e))
          .toList(),
    );
  }
}

bool _asBool(dynamic value) {
  if (value is bool) return value;
  if (value is num) return value != 0;
  final normalized = value?.toString().trim().toLowerCase() ?? '';
  return normalized == 'true' ||
      normalized == '1' ||
      normalized == 'online' ||
      normalized == 'available' ||
      normalized == 'yes';
}

int _asInt(dynamic value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse(value?.toString() ?? '') ?? 0;
}
