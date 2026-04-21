class WarehouseRequest {
  final int id;
  final String orderCode;
  final String customerName;
  final String customerPhone;
  final String address;
  final double? latitude;
  final double? longitude;
  final String scheduledAt;
  final String status;
  final String? itemSummary;
  final double? estimatedWeight;
  final String? assignedPickupBoyName;
  final int? assignedPickupBoyId;

  const WarehouseRequest({
    required this.id,
    required this.orderCode,
    required this.customerName,
    required this.customerPhone,
    required this.address,
    this.latitude,
    this.longitude,
    required this.scheduledAt,
    required this.status,
    this.itemSummary,
    this.estimatedWeight,
    this.assignedPickupBoyName,
    this.assignedPickupBoyId,
  });

  factory WarehouseRequest.fromJson(Map<String, dynamic> json) {
    int? asInt(dynamic value) {
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

    final assignedBoy = json['assigned_pickup_boy'] is Map
        ? (json['assigned_pickup_boy'] as Map).cast<String, dynamic>()
        : null;

    return WarehouseRequest(
      id: asInt(json['id']) ?? asInt(json['pickup_id']) ?? 0,
      orderCode:
          json['order_code']?.toString() ??
          json['pickup_code']?.toString() ??
          '#${json['id']}',
      customerName: json['customer_name']?.toString() ?? '',
      customerPhone: json['customer_phone']?.toString() ?? '',
      address: json['address']?.toString() ?? '',
      latitude: asDouble(json['latitude']),
      longitude: asDouble(json['longitude']),
      scheduledAt: json['scheduled_at']?.toString() ?? '',
      status: json['status']?.toString() ?? 'pending',
      itemSummary:
          json['item_summary']?.toString() ?? json['items_summary']?.toString(),
      estimatedWeight:
          asDouble(json['estimated_weight']) ??
          asDouble(json['estimated_weight_kg']),
      assignedPickupBoyName:
          assignedBoy?['name']?.toString() ??
          json['pickup_boy_name']?.toString(),
      assignedPickupBoyId:
          asInt(assignedBoy?['id']) ?? asInt(json['pickup_boy_id']),
    );
  }
}
