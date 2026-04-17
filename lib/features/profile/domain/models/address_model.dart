class AddressModel {
  final int id;
  final int? userId;
  final String title;
  final String addressLine1;
  final String? addressLine2;
  final String pincode;
  final int cityId;
  final String? state;
  final bool isDefault;
  final double? latitude;
  final double? longitude;
  final String? cityName;
  final String? cityCode;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  AddressModel({
    required this.id,
    this.userId,
    required this.title,
    required this.addressLine1,
    this.addressLine2,
    required this.pincode,
    required this.cityId,
    this.state,
    required this.isDefault,
    this.latitude,
    this.longitude,
    this.cityName,
    this.cityCode,
    this.createdAt,
    this.updatedAt,
  });

  factory AddressModel.fromJson(Map<String, dynamic> json) {
    final city = json['city'];
    return AddressModel(
      id: json['id'] is int ? json['id'] : int.parse(json['id'].toString()),
      userId: _parseInt(json['user_id']),
      title: json['title'] ?? '',
      addressLine1: json['address_line_1'] ?? '',
      addressLine2: json['address_line_2'],
      pincode: json['pincode'] ?? '',
      cityId: _parseInt(json['city_id']) ?? _parseInt(city?['id']) ?? 0,
      state: json['state'],
      isDefault: json['is_default'] == true || json['is_default'] == 1,
      latitude: _parseDouble(json['latitude']),
      longitude: _parseDouble(json['longitude']),
      cityName: city is Map ? city['name']?.toString() : null,
      cityCode: city is Map ? city['code']?.toString() : null,
      createdAt: _parseDateTime(json['created_at']),
      updatedAt: _parseDateTime(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'address_line_1': addressLine1,
      'address_line_2': addressLine2,
      'pincode': pincode,
      'city_id': cityId,
      'state': state,
      'is_default': isDefault,
      'latitude': latitude,
      'longitude': longitude,
    };
  }

  static int? _parseInt(dynamic value) {
    if (value is int) {
      return value;
    }
    if (value == null) {
      return null;
    }
    return int.tryParse(value.toString());
  }

  static double? _parseDouble(dynamic value) {
    if (value is num) {
      return value.toDouble();
    }
    if (value == null) {
      return null;
    }
    return double.tryParse(value.toString());
  }

  static DateTime? _parseDateTime(dynamic value) {
    if (value == null) {
      return null;
    }
    return DateTime.tryParse(value.toString());
  }
}
