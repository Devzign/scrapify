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
  final String requestType;
  final double? estimatedAmount;
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
    required this.requestType,
    this.estimatedAmount,
    this.itemSummary,
    this.estimatedWeight,
    this.assignedPickupBoyName,
    this.assignedPickupBoyId,
  });

  bool get isCorporate => requestType.toLowerCase() == 'corporate';

  bool get hasCorporateQuote => estimatedAmount != null;

  bool get requiresCorporateQuote => isCorporate && !hasCorporateQuote;

  WarehouseRequest copyWith({
    int? id,
    String? orderCode,
    String? customerName,
    String? customerPhone,
    String? address,
    double? latitude,
    double? longitude,
    String? scheduledAt,
    String? status,
    String? requestType,
    double? estimatedAmount,
    String? itemSummary,
    double? estimatedWeight,
    String? assignedPickupBoyName,
    int? assignedPickupBoyId,
    bool clearAssignedPickupBoy = false,
  }) {
    return WarehouseRequest(
      id: id ?? this.id,
      orderCode: orderCode ?? this.orderCode,
      customerName: customerName ?? this.customerName,
      customerPhone: customerPhone ?? this.customerPhone,
      address: address ?? this.address,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      scheduledAt: scheduledAt ?? this.scheduledAt,
      status: status ?? this.status,
      requestType: requestType ?? this.requestType,
      estimatedAmount: estimatedAmount ?? this.estimatedAmount,
      itemSummary: itemSummary ?? this.itemSummary,
      estimatedWeight: estimatedWeight ?? this.estimatedWeight,
      assignedPickupBoyName: clearAssignedPickupBoy
          ? null
          : assignedPickupBoyName ?? this.assignedPickupBoyName,
      assignedPickupBoyId: clearAssignedPickupBoy
          ? null
          : assignedPickupBoyId ?? this.assignedPickupBoyId,
    );
  }

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

    // Support both flat 'assigned_pickup_boy' and nested 'assignment.pickup_boy'
    final assignment = json['assignment'] is Map
        ? (json['assignment'] as Map).cast<String, dynamic>()
        : null;
    final assignedBoy = json['assigned_pickup_boy'] is Map
        ? (json['assigned_pickup_boy'] as Map).cast<String, dynamic>()
        : assignment?['pickup_boy'] is Map
        ? (assignment!['pickup_boy'] as Map).cast<String, dynamic>()
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
      requestType: json['request_type']?.toString() ?? 'scrap',
      estimatedAmount: asDouble(json['estimated_amount']),
      itemSummary:
          json['item_summary']?.toString() ?? json['items_summary']?.toString(),
      estimatedWeight:
          asDouble(json['estimated_weight']) ??
          asDouble(json['estimated_weight_kg']),
      assignedPickupBoyName:
          assignedBoy?['name']?.toString() ??
          json['pickup_boy_name']?.toString(),
      assignedPickupBoyId:
          asInt(assignedBoy?['id']) ??
          asInt(json['pickup_boy_id']) ??
          asInt(assignment?['pickup_boy_id']),
    );
  }
}
