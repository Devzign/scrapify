class PickupRequestItem {
  final int? id;
  final String? itemName;
  final double? weight;
  final int? quantity;
  final double? rate;

  const PickupRequestItem({
    this.id,
    this.itemName,
    this.weight,
    this.quantity,
    this.rate,
  });

  factory PickupRequestItem.fromJson(Map<String, dynamic> json) {
    return PickupRequestItem(
      id: json['id'],
      itemName: json['item_name']?.toString() ?? json['name']?.toString(),
      weight: (json['weight'] as num?)?.toDouble() ??
          (json['expected_weight'] as num?)?.toDouble(),
      quantity: json['quantity'] ?? json['expected_quantity'],
      rate: (json['rate'] as num?)?.toDouble(),
    );
  }
}

class PickupRequest {
  final int id;
  final String? orderCode;
  final String status;
  final String address;
  final String scheduledAt;
  final double? estimatedAmount;
  final double? finalAmount;
  final List<PickupRequestItem> items;
  final String? customerName;
  final String? customerPhone;

  const PickupRequest({
    required this.id,
    this.orderCode,
    required this.status,
    required this.address,
    required this.scheduledAt,
    this.estimatedAmount,
    this.finalAmount,
    required this.items,
    this.customerName,
    this.customerPhone,
  });

  factory PickupRequest.fromJson(Map<String, dynamic> json) {
    final itemsJson = json['items'] as List<dynamic>? ?? [];
    return PickupRequest(
      id: json['id'] ?? 0,
      orderCode: json['order_code']?.toString() ?? json['pickup_code']?.toString(),
      status: json['status']?.toString() ?? 'pending',
      address: json['address']?.toString() ?? '',
      scheduledAt: json['scheduled_at']?.toString() ?? '',
      estimatedAmount: (json['estimated_amount'] as num?)?.toDouble(),
      finalAmount: (json['final_amount'] as num?)?.toDouble(),
      items: itemsJson
          .whereType<Map<String, dynamic>>()
          .map((e) => PickupRequestItem.fromJson(e))
          .toList(),
      customerName: json['customer_name']?.toString(),
      customerPhone: json['customer_phone']?.toString(),
    );
  }
}

class PickupStats {
  final int total;
  final int pending;
  final int assigned;
  final int completed;
  final int cancelled;

  const PickupStats({
    required this.total,
    required this.pending,
    required this.assigned,
    required this.completed,
    required this.cancelled,
  });

  factory PickupStats.fromJson(Map<String, dynamic> json) {
    final data = json['data'] ?? json;
    return PickupStats(
      total: data['total'] ?? 0,
      pending: data['pending'] ?? 0,
      assigned: data['assigned'] ?? 0,
      completed: data['completed'] ?? 0,
      cancelled: data['cancelled'] ?? 0,
    );
  }
}
