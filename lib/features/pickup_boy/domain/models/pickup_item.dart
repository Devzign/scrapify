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
    return PickupItem(
      id: json['id'] ?? json['pickup_item_id'],
      itemId: json['item_id'],
      itemName: json['item_name']?.toString() ?? json['name']?.toString() ?? '',
      weight: (json['weight'] as num?)?.toDouble() ??
          (json['weight_kg'] as num?)?.toDouble(),
      quantity: json['quantity'],
      condition: json['condition']?.toString(),
      action: json['action']?.toString() ?? 'updated',
    );
  }

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{
      'item_id': itemId,
      'item_name': itemName,
      'action': action,
    };
    if (id != null) map['id'] = id;
    if (weight != null) map['weight'] = weight;
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
