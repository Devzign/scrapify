class PickupBoyMini {
  final int id;
  final String name;
  final String mobile;
  final String status; // available | busy

  const PickupBoyMini({
    required this.id,
    required this.name,
    required this.mobile,
    required this.status,
  });

  bool get isAvailable => status == 'available';

  factory PickupBoyMini.fromJson(Map<String, dynamic> json) {
    return PickupBoyMini(
      id: _parseInt(json['id']) ?? 0,
      name: json['name']?.toString() ?? '',
      mobile: json['mobile']?.toString() ?? json['phone']?.toString() ?? '',
      status: json['status']?.toString() ?? 'busy',
    );
  }

  static int? _parseInt(dynamic v) {
    if (v is int) return v;
    return v == null ? null : int.tryParse(v.toString());
  }
}

class WarehouseProfile {
  final int id;
  final String name;
  final String? code;
  final String? city;
  final String? state;
  final String? zone;
  final String? area;
  final String? address;
  final double? latitude;
  final double? longitude;
  final double? serviceRadiusKm;
  final List<PickupBoyMini> pickupBoys;

  const WarehouseProfile({
    required this.id,
    required this.name,
    this.code,
    this.city,
    this.state,
    this.zone,
    this.area,
    this.address,
    this.latitude,
    this.longitude,
    this.serviceRadiusKm,
    this.pickupBoys = const [],
  });

  factory WarehouseProfile.fromJson(Map<String, dynamic> json) {
    final boysJson = json['pickup_boys'] as List<dynamic>? ?? [];
    return WarehouseProfile(
      id: _parseInt(json['id']) ?? 0,
      name: json['name']?.toString() ?? '',
      code: json['code']?.toString(),
      city: json['city']?.toString(),
      state: json['state']?.toString(),
      zone: json['zone']?.toString(),
      area: json['area']?.toString(),
      address: json['address']?.toString(),
      latitude: _parseDouble(json['latitude']),
      longitude: _parseDouble(json['longitude']),
      serviceRadiusKm: _parseDouble(json['service_radius_km']),
      pickupBoys: boysJson
          .whereType<Map<String, dynamic>>()
          .map(PickupBoyMini.fromJson)
          .toList(),
    );
  }

  static int? _parseInt(dynamic v) {
    if (v is int) return v;
    return v == null ? null : int.tryParse(v.toString());
  }

  static double? _parseDouble(dynamic v) {
    if (v is num) return v.toDouble();
    return v == null ? null : double.tryParse(v.toString());
  }
}

/// Top-level response for `/api/warehouse/app/profile`.
class WarehouseAppProfileResponse {
  final Map<String, dynamic>? user;
  final List<WarehouseProfile> warehouses;

  const WarehouseAppProfileResponse({
    this.user,
    this.warehouses = const [],
  });

  factory WarehouseAppProfileResponse.fromJson(Map<String, dynamic> json) {
    final data = (json['data'] as Map<String, dynamic>?) ?? json;
    final whJson = data['warehouses'] as List<dynamic>? ?? [];
    return WarehouseAppProfileResponse(
      user: data['user'] as Map<String, dynamic>?,
      warehouses: whJson
          .whereType<Map<String, dynamic>>()
          .map(WarehouseProfile.fromJson)
          .toList(),
    );
  }
}
