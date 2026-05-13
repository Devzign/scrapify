class PickupRequestModel {
  final int id;
  final String pickupCode;
  final String address;
  final int cityId;
  final double latitude;
  final double longitude;
  final DateTime scheduledAt;
  final String status;
  final String requestType;
  final String payoutMethod;
  final double? estimatedAmount;
  final double? finalAmount;
  final DateTime? priceLockedAt;
  final String? couponCode;
  final double? couponDiscountValue;
  final String? customerName;
  final String? customerPhone;
  final List<PickupItemModel> items;
  final List<PickupImageModel> images;
  final DateTime? createdAt;

  PickupRequestModel({
    required this.id,
    required this.pickupCode,
    required this.address,
    required this.cityId,
    required this.latitude,
    required this.longitude,
    required this.scheduledAt,
    required this.status,
    required this.requestType,
    required this.payoutMethod,
    this.estimatedAmount,
    this.finalAmount,
    this.priceLockedAt,
    this.couponCode,
    this.couponDiscountValue,
    this.customerName,
    this.customerPhone,
    required this.items,
    required this.images,
    this.createdAt,
  });

  bool get isPriceLocked => priceLockedAt != null;
  bool get hasCoupon => couponCode != null && couponCode!.isNotEmpty;
  bool get isDonation => requestType == 'donation';
  bool get isCorporate => requestType == 'corporate';

  factory PickupRequestModel.fromJson(Map<String, dynamic> json) {
    final inferredRequestType = _resolveRequestType(
      explicit: json['request_type']?.toString() ?? json['type']?.toString(),
      pickupCode:
          json['pickup_code']?.toString() ??
          json['booking_code']?.toString() ??
          json['code']?.toString(),
    );

    return PickupRequestModel(
      id: _parseInt(json['id']) ?? 0,
      pickupCode:
          json['pickup_code']?.toString() ??
          json['booking_code']?.toString() ??
          json['code']?.toString() ??
          '',
      address:
          json['address']?.toString() ??
          json['pickup_address']?.toString() ??
          json['company_address']?.toString() ??
          '',
      cityId:
          _parseInt(json['city_id']) ?? _parseInt(json['service_city_id']) ?? 0,
      latitude: _parseDouble(json['latitude']) ?? 0,
      longitude: _parseDouble(json['longitude']) ?? 0,
      scheduledAt:
          _parseDateTime(json['scheduled_at']) ??
          _parseDateTime(json['pickup_at']) ??
          _parseDateTime(json['preferred_date']) ??
          DateTime.now(),
      status: json['status']?.toString() ?? 'pending',
      requestType: inferredRequestType,
      payoutMethod: json['payout_method']?.toString() ?? '',
      estimatedAmount:
          _parseDouble(json['estimated_amount']) ??
          _parseDouble(json['quote_amount']) ??
          _parseDouble(json['amount']),
      finalAmount: _parseDouble(json['final_amount']),
      priceLockedAt: _parseDateTime(json['price_locked_at']),
      couponCode: json['coupon_code']?.toString(),
      couponDiscountValue: _parseDouble(json['coupon_discount_value']),
      customerName: json['customer_name']?.toString(),
      customerPhone: json['customer_phone']?.toString(),
      items:
          (json['items'] as List<dynamic>?)
              ?.map(
                (item) =>
                    PickupItemModel.fromJson(item as Map<String, dynamic>),
              )
              .toList() ??
          [],
      images:
          (json['images'] as List<dynamic>?)
              ?.map(
                (image) =>
                    PickupImageModel.fromJson(image as Map<String, dynamic>),
              )
              .toList() ??
          [],
      createdAt: _parseDateTime(json['created_at']),
    );
  }

  static int? _parseInt(dynamic value) {
    if (value is int) return value;
    if (value == null) return null;
    return int.tryParse(value.toString());
  }

  static double? _parseDouble(dynamic value) {
    if (value is num) return value.toDouble();
    if (value == null) return null;
    return double.tryParse(value.toString());
  }

  static DateTime? _parseDateTime(dynamic value) {
    if (value == null) return null;
    try {
      return DateTime.parse(value.toString());
    } catch (_) {
      return null;
    }
  }

  static String _resolveRequestType({String? explicit, String? pickupCode}) {
    final normalized = explicit?.toLowerCase().trim();
    if (normalized != null && normalized.isNotEmpty) {
      if (normalized == 'donation' ||
          normalized == 'corporate' ||
          normalized == 'scrap') {
        return normalized;
      }
    }

    final code = pickupCode?.toUpperCase() ?? '';
    if (code.startsWith('DON-')) return 'donation';
    if (code.startsWith('CORP-')) return 'corporate';
    return 'scrap';
  }
}

class PickupItemModel {
  final int? categoryId;
  final int? itemId;
  final double weight;
  final int quantity;
  final String? name; // For display

  PickupItemModel({
    this.categoryId,
    this.itemId,
    required this.weight,
    required this.quantity,
    this.name,
  });

  factory PickupItemModel.fromJson(Map<String, dynamic> json) {
    return PickupItemModel(
      categoryId: _parseInt(json['category_id']),
      itemId: _parseInt(json['item_id']),
      weight: _parseDouble(json['weight']) ?? 0,
      quantity: _parseInt(json['quantity']) ?? 1,
      name: json['name']?.toString(),
    );
  }

  static int? _parseInt(dynamic value) {
    if (value is int) return value;
    if (value == null) return null;
    return int.tryParse(value.toString());
  }

  static double? _parseDouble(dynamic value) {
    if (value is num) return value.toDouble();
    if (value == null) return null;
    return double.tryParse(value.toString());
  }
}

class PickupImageModel {
  final int id;
  final String imagePath;
  final String? url;
  final double? latitude;
  final double? longitude;

  PickupImageModel({
    required this.id,
    required this.imagePath,
    this.url,
    this.latitude,
    this.longitude,
  });

  factory PickupImageModel.fromJson(Map<String, dynamic> json) {
    return PickupImageModel(
      id: PickupRequestModel._parseInt(json['id']) ?? 0,
      imagePath: json['image_path']?.toString() ?? '',
      url: json['url']?.toString(),
      latitude: PickupRequestModel._parseDouble(json['latitude']),
      longitude: PickupRequestModel._parseDouble(json['longitude']),
    );
  }
}
