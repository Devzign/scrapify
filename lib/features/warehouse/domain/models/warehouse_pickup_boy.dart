class WarehousePickupBoy {
  final int id;
  final String name;
  final String phone;
  final String? profilePhoto;
  final bool isActive;
  final bool isOnline;
  final bool isAvailable;
  final int currentAssignmentCount;
  final int completedCount;

  const WarehousePickupBoy({
    required this.id,
    required this.name,
    required this.phone,
    this.profilePhoto,
    required this.isActive,
    required this.isOnline,
    required this.isAvailable,
    required this.currentAssignmentCount,
    required this.completedCount,
  });

  factory WarehousePickupBoy.fromJson(Map<String, dynamic> json) {
    int asInt(dynamic value) {
      if (value is int) return value;
      if (value is num) return value.toInt();
      if (value is String) return int.tryParse(value.trim()) ?? 0;
      return 0;
    }

    return WarehousePickupBoy(
      id: asInt(json['id']),
      name: json['name']?.toString() ?? '',
      phone: json['phone']?.toString() ?? '',
      profilePhoto: json['profile_photo']?.toString(),
      isActive: json['is_active'] == true,
      isOnline: json['is_online'] == true,
      isAvailable: json['is_available'] == true,
      currentAssignmentCount: asInt(json['current_assignment_count']),
      completedCount: asInt(json['completed_count']),
    );
  }
}
