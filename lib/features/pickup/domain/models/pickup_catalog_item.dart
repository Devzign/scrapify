class PickupCatalogItem {
  final int id;
  final String name;
  final double price;
  final String unit;
  final String materialType;
  final String pickupSize;
  final String priceType;
  final String condition;
  final String imageUrl;

  const PickupCatalogItem({
    required this.id,
    required this.name,
    required this.price,
    required this.unit,
    required this.materialType,
    required this.pickupSize,
    required this.priceType,
    required this.condition,
    required this.imageUrl,
  });

  factory PickupCatalogItem.fromJson(Map<String, dynamic> json) {
    final resolvedPrice =
        _parseDouble(json['price']) ?? _parseDouble(json['base_price']) ?? 0;
    final resolvedPriceType =
        json['price_type']?.toString() ??
        json['pricing_type']?.toString() ??
        '';

    return PickupCatalogItem(
      id: _parseInt(json['id']) ?? 0,
      name: json['name']?.toString() ?? '',
      price: resolvedPrice,
      unit: json['unit']?.toString() ?? resolvedPriceType,
      materialType: json['material_type']?.toString() ?? '',
      pickupSize: json['pickup_size']?.toString() ?? '',
      priceType: resolvedPriceType,
      condition: json['condition']?.toString() ?? '',
      imageUrl:
          json['image_url']?.toString() ?? json['image']?.toString() ?? '',
    );
  }
}

int? _parseInt(dynamic value) {
  if (value is int) {
    return value;
  }
  if (value == null) {
    return null;
  }
  return int.tryParse(value.toString());
}

double? _parseDouble(dynamic value) {
  if (value is double) {
    return value;
  }
  if (value is int) {
    return value.toDouble();
  }
  if (value == null) {
    return null;
  }
  return double.tryParse(value.toString());
}
