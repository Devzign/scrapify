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
    final assignedBoy = json['assigned_pickup_boy'] as Map<String, dynamic>?;
    return WarehouseRequest(
      id: json['id'] ?? json['pickup_id'] ?? 0,
      orderCode: json['order_code']?.toString() ??
          json['pickup_code']?.toString() ??
          '#${json['id']}',
      customerName: json['customer_name']?.toString() ?? '',
      customerPhone: json['customer_phone']?.toString() ?? '',
      address: json['address']?.toString() ?? '',
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      scheduledAt: json['scheduled_at']?.toString() ?? '',
      status: json['status']?.toString() ?? 'pending',
      itemSummary: json['item_summary']?.toString() ?? json['items_summary']?.toString(),
      estimatedWeight: (json['estimated_weight'] as num?)?.toDouble() ??
          (json['estimated_weight_kg'] as num?)?.toDouble(),
      assignedPickupBoyName: assignedBoy?['name']?.toString() ?? json['pickup_boy_name']?.toString(),
      assignedPickupBoyId: assignedBoy?['id'] ?? json['pickup_boy_id'],
    );
  }
}
