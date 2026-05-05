class WarehousePickupBoy {
  final int id;
  final String name;
  final String phone;
  final String? email;
  final String? profilePhoto;
  final bool isActive;
  final bool isOnline;
  final bool isAvailable;
  final int currentAssignmentCount;
  final int completedCount;
  final String? vehicleNumber;
  final String? walletBalance;
  final String? lastActiveAt;
  final String? locationUpdatedAt;
  final double? latitude;
  final double? longitude;
  final int? cityId;
  final int? warehouseId;
  final int? channelPartnerId;
  final String? bankName;
  final String? accountNumber;
  final String? ifscCode;
  final String? upiId;
  final String? createdAt;

  const WarehousePickupBoy({
    required this.id,
    required this.name,
    required this.phone,
    this.email,
    this.profilePhoto,
    required this.isActive,
    required this.isOnline,
    required this.isAvailable,
    required this.currentAssignmentCount,
    required this.completedCount,
    this.vehicleNumber,
    this.walletBalance,
    this.lastActiveAt,
    this.locationUpdatedAt,
    this.latitude,
    this.longitude,
    this.cityId,
    this.warehouseId,
    this.channelPartnerId,
    this.bankName,
    this.accountNumber,
    this.ifscCode,
    this.upiId,
    this.createdAt,
  });

  factory WarehousePickupBoy.fromJson(Map<String, dynamic> json) {
    int asInt(dynamic value) {
      if (value is int) return value;
      if (value is num) return value.toInt();
      if (value is String) return int.tryParse(value.trim()) ?? 0;
      return 0;
    }

    int? asIntNullable(dynamic value) {
      if (value == null) return null;
      if (value is int) return value;
      if (value is num) return value.toInt();
      if (value is String) return int.tryParse(value.trim());
      return null;
    }

    double? asDouble(dynamic value) {
      if (value == null) return null;
      if (value is double) return value;
      if (value is num) return value.toDouble();
      if (value is String) return double.tryParse(value.trim());
      return null;
    }

    return WarehousePickupBoy(
      id: asInt(json['id']),
      name: json['name']?.toString() ?? '',
      phone: json['phone']?.toString() ?? '',
      email: json['email']?.toString(),
      profilePhoto: json['profile_photo_path']?.toString() ?? json['profile_photo']?.toString(),
      isActive: json['is_active'] == true || (json['status'] == 1 || json['status'] == true),
      isOnline: json['is_online'] == true,
      isAvailable: json['is_available'] == true,
      currentAssignmentCount: asInt(json['current_assignment_count']),
      completedCount: asInt(json['completed_count']),
      vehicleNumber: json['vehicle_number']?.toString(),
      walletBalance: json['wallet_balance']?.toString(),
      lastActiveAt: json['last_active_at']?.toString(),
      locationUpdatedAt: json['location_updated_at']?.toString(),
      latitude: asDouble(json['latitude']),
      longitude: asDouble(json['longitude']),
      cityId: asIntNullable(json['city_id']),
      warehouseId: asIntNullable(json['warehouse_id']),
      channelPartnerId: asIntNullable(json['channel_partner_id']),
      bankName: json['bank_name']?.toString(),
      accountNumber: json['account_number']?.toString(),
      ifscCode: json['ifsc_code']?.toString(),
      upiId: json['upi_id']?.toString(),
      createdAt: json['created_at']?.toString(),
    );
  }
}
