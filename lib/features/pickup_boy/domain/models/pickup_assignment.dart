class PickupAssignment {
  final int id;
  final String orderCode;
  final String customerName;
  final String customerPhone;
  final String address;
  final double? latitude;
  final double? longitude;
  final String scheduledAt;
  final String status;
  final String? itemsSummary;
  final double? estimatedWeightKg;

  const PickupAssignment({
    required this.id,
    required this.orderCode,
    required this.customerName,
    required this.customerPhone,
    required this.address,
    this.latitude,
    this.longitude,
    required this.scheduledAt,
    required this.status,
    this.itemsSummary,
    this.estimatedWeightKg,
  });

  factory PickupAssignment.fromJson(Map<String, dynamic> json) {
    return PickupAssignment(
      id: json['pickup_id'] ?? json['id'] ?? 0,
      orderCode: json['order_code']?.toString() ?? json['pickup_code']?.toString() ?? '#${json['id']}',
      customerName: json['customer_name']?.toString() ?? '',
      customerPhone: json['customer_phone']?.toString() ?? '',
      address: json['address']?.toString() ?? '',
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      scheduledAt: json['scheduled_at']?.toString() ?? '',
      status: json['status']?.toString() ?? 'assigned',
      itemsSummary: json['items_summary']?.toString(),
      estimatedWeightKg: (json['estimated_weight_kg'] as num?)?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'order_code': orderCode,
    'customer_name': customerName,
    'customer_phone': customerPhone,
    'address': address,
    'latitude': latitude,
    'longitude': longitude,
    'scheduled_at': scheduledAt,
    'status': status,
    'items_summary': itemsSummary,
    'estimated_weight_kg': estimatedWeightKg,
  };
}
