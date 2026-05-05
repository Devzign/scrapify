class PickupItem {
  final int? id;       // pickup_item_id (null for new items)
  final int? itemId;
  final String itemName;
  final double? weight;
  final int? quantity;
  final String? condition;
  final String action; // 'updated' | 'added' | 'removed'

  const PickupItem({
    this.id,
    this.itemId,
    required this.itemName,
    this.weight,
    this.quantity,
    this.condition,
    required this.action,
  });

  factory PickupItem.fromJson(Map<String, dynamic> json) {
    double? toDouble(dynamic v) {
      if (v == null) return null;
      if (v is double) return v;
      if (v is num) return v.toDouble();
      if (v is String) return double.tryParse(v.trim());
      return null;
    }

    // category_name can be a Map {"en": "...", "hi": "..."} or a String
    String itemName;
    final rawCat = json['category_name'];
    if (rawCat is Map) {
      itemName = rawCat['en']?.toString() ?? rawCat.values.first?.toString() ?? '';
    } else if (rawCat is String) {
      itemName = rawCat;
    } else {
      itemName = json['item_name']?.toString() ?? json['name']?.toString() ?? '';
    }

    return PickupItem(
      id: json['id'] ?? json['pickup_item_id'],
      itemId: json['item_id'],
      itemName: itemName,
      weight: toDouble(json['weight']) ?? toDouble(json['weight_kg']),
      quantity: json['quantity'],
      condition: json['condition']?.toString(),
      action: json['action']?.toString() ?? 'updated',
    );
  }

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{
      'item_name': itemName,
      'action': action,
    };
    if (id != null) map['pickup_item_id'] = id;
    if (itemId != null) map['item_id'] = itemId;
    if (weight != null) map['weight_kg'] = weight;
    if (quantity != null) map['quantity'] = quantity;
    if (condition != null) map['condition'] = condition;
    return map;
  }

  PickupItem copyWith({
    int? id,
    int? itemId,
    String? itemName,
    double? weight,
    int? quantity,
    String? condition,
    String? action,
  }) {
    return PickupItem(
      id: id ?? this.id,
      itemId: itemId ?? this.itemId,
      itemName: itemName ?? this.itemName,
      weight: weight ?? this.weight,
      quantity: quantity ?? this.quantity,
      condition: condition ?? this.condition,
      action: action ?? this.action,
    );
  }
}
