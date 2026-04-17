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
    return WarehousePickupBoy(
      id: json['id'] ?? 0,
      name: json['name']?.toString() ?? '',
      phone: json['phone']?.toString() ?? '',
      profilePhoto: json['profile_photo']?.toString(),
      isActive: json['is_active'] == true,
      isOnline: json['is_online'] == true,
      isAvailable: json['is_available'] == true,
      currentAssignmentCount: json['current_assignment_count'] ?? 0,
      completedCount: json['completed_count'] ?? 0,
    );
  }
}
