class UserTypeOption {
  final String code;
  final String name;
  final String description;
  final bool visible;
  final int sortOrder;

  const UserTypeOption({
    required this.code,
    required this.name,
    required this.description,
    required this.visible,
    required this.sortOrder,
  });

  factory UserTypeOption.fromJson(Map<String, dynamic> json) {
    final code =
        json['code']?.toString() ??
        json['role']?.toString() ??
        json['name']?.toString() ??
        'customer';

    return UserTypeOption(
      code: code,
      name:
          json['display_name']?.toString() ?? json['name']?.toString() ?? code,
      description: json['description']?.toString() ?? '',
      visible: _parseBool(
        json['visible'] ?? json['app_visible'] ?? json['login_enabled'] ?? true,
      ),
      sortOrder: _parseInt(json['sort_order']) ?? 0,
    );
  }

  static bool _parseBool(dynamic value) {
    if (value is bool) return value;
    if (value is num) return value != 0;
    final text = value?.toString().toLowerCase().trim();
    return text == '1' || text == 'true';
  }

  static int? _parseInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '');
  }
}
