class User {
  final int id;
  final String name;
  final String phone;
  final String? email;
  final int? cityId;
  final String? profilePhoto;
  final String? walletBalance;
  final int? status;
  final List<String> roles;

  User({
    required this.id,
    required this.name,
    required this.phone,
    this.email,
    this.cityId,
    this.profilePhoto,
    this.walletBalance,
    this.status,
    required this.roles,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] is int ? json['id'] : int.parse(json['id'].toString()),
      name: json['name'] ?? '',
      phone: json['phone'] ?? '',
      email: json['email'],
      cityId: json['city_id'] is int
          ? json['city_id']
          : (json['city_id'] != null
                ? int.tryParse(json['city_id'].toString())
                : null),
      profilePhoto:
          json['profile_photo_path']?.toString() ??
          json['profile_photo']?.toString(),
      walletBalance: json['wallet_balance']?.toString(),
      status: json['status'] is int
          ? json['status']
          : int.tryParse(json['status']?.toString() ?? ''),
      roles: _parseRoles(json['roles']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'phone': phone,
      'email': email,
      'city_id': cityId,
      'profile_photo_path': profilePhoto,
      'wallet_balance': walletBalance,
      'status': status,
      'roles': roles,
    };
  }

  static List<String> _parseRoles(dynamic rawRoles) {
    if (rawRoles is! List) {
      return [];
    }

    return rawRoles
        .map((role) {
          if (role is String) {
            return role;
          }
          if (role is Map<String, dynamic>) {
            return role['name']?.toString() ?? '';
          }
          if (role is Map) {
            return role['name']?.toString() ?? '';
          }
          return role.toString();
        })
        .where((role) => role.isNotEmpty)
        .toList();
  }
}
