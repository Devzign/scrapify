/// A single expected item in a pickup assignment.
class ExpectedPickupItem {
  final int? pickupItemId;
  final int? itemId;
  final String categoryName;
  final String? categoryNameHi;
  final double? weightKg;
  final int quantity;
  final String? condition;
  final double? ratePerKg;
  final double? totalPrice;

  const ExpectedPickupItem({
    this.pickupItemId,
    this.itemId,
    required this.categoryName,
    this.categoryNameHi,
    this.weightKg,
    this.quantity = 1,
    this.condition,
    this.ratePerKg,
    this.totalPrice,
  });

  factory ExpectedPickupItem.fromJson(Map<String, dynamic> json) {
    double? toDouble(dynamic v) {
      if (v == null) return null;
      if (v is double) return v;
      if (v is num) return v.toDouble();
      if (v is String) return double.tryParse(v.trim());
      return null;
    }

    // category_name can be a String or a localized Map {"en": "...", "hi": "..."}
    String catName = '';
    String? catNameHi;
    final rawCat = json['category_name'];
    if (rawCat is Map) {
      catName = rawCat['en']?.toString() ?? rawCat.values.first?.toString() ?? '';
      catNameHi = rawCat['hi']?.toString();
    } else if (rawCat is String) {
      catName = rawCat;
    }

    return ExpectedPickupItem(
      pickupItemId: json['pickup_item_id'] as int?,
      itemId: json['item_id'] as int?,
      categoryName: catName,
      categoryNameHi: catNameHi,
      weightKg: toDouble(json['weight_kg']),
      quantity: (json['quantity'] as int?) ?? 1,
      condition: json['condition']?.toString(),
      ratePerKg: toDouble(json['rate_per_kg']),
      totalPrice: toDouble(json['total_price']),
    );
  }

  /// Returns the localized name based on language code.
  String localizedName(String langCode) {
    if (langCode == 'hi' && categoryNameHi != null && categoryNameHi!.isNotEmpty) {
      return categoryNameHi!;
    }
    return categoryName;
  }
}

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
  final List<ExpectedPickupItem> expectedItems;

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
    this.expectedItems = const [],
  });

  factory PickupAssignment.fromJson(Map<String, dynamic> json) {
    double? toDouble(dynamic v) {
      if (v == null) return null;
      if (v is double) return v;
      if (v is num) return v.toDouble();
      if (v is String) return double.tryParse(v.trim());
      return null;
    }

    int toInt(dynamic v) {
      if (v is int) return v;
      if (v is num) return v.toInt();
      if (v is String) return int.tryParse(v.trim()) ?? 0;
      return 0;
    }

    // Parse expected items from the 'items' array
    final rawItems = json['items'];
    final List<ExpectedPickupItem> items = [];
    if (rawItems is List) {
      for (final item in rawItems) {
        if (item is Map<String, dynamic>) {
          items.add(ExpectedPickupItem.fromJson(item));
        }
      }
    }

    return PickupAssignment(
      id: toInt(json['pickup_id'] ?? json['id']),
      orderCode: json['order_code']?.toString() ?? json['pickup_code']?.toString() ?? '#${json['id']}',
      customerName: json['customer_name']?.toString() ?? '',
      customerPhone: json['customer_phone']?.toString() ?? '',
      address: json['address']?.toString() ?? '',
      latitude: toDouble(json['latitude']),
      longitude: toDouble(json['longitude']),
      scheduledAt: json['scheduled_at']?.toString() ?? '',
      status: json['status']?.toString() ?? 'assigned',
      itemsSummary: json['items_summary']?.toString(),
      estimatedWeightKg: toDouble(json['estimated_weight_kg']),
      expectedItems: items,
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
