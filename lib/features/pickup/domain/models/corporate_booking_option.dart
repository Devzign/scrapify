import 'category.dart';

class CorporateBookingOption {
  final List<String> categories;
  final List<String> meetingTypes;
  final List<CorporateCategoryGroup> groups;

  const CorporateBookingOption({
    this.categories = const [],
    this.meetingTypes = const [],
    this.groups = const [],
  });

  factory CorporateBookingOption.fromJson(Map<String, dynamic> json) {
    final data = (json['data'] as Map<String, dynamic>?) ?? json;
    return CorporateBookingOption(
      categories:
          (data['categories'] as List<dynamic>?)
              ?.map((e) => e.toString().trim())
              .where((e) => e.isNotEmpty)
              .toList() ??
          const [],
      meetingTypes:
          (data['meeting_types'] as List<dynamic>?)
              ?.map((e) => e.toString().trim().toLowerCase())
              .where((e) => e.isNotEmpty)
              .toList() ??
          const [],
      groups:
          (data['scrap_categories'] as List<dynamic>?)
              ?.map(
                (e) => CorporateCategoryGroup.fromJson(
                  Map<String, dynamic>.from(e as Map),
                ),
              )
              .toList() ??
          const [],
    );
  }
}

class CorporateCategoryGroup {
  final int id;
  final String name;
  final String imageUrl;
  final List<Category> subcategories;

  const CorporateCategoryGroup({
    required this.id,
    required this.name,
    required this.imageUrl,
    this.subcategories = const [],
  });

  factory CorporateCategoryGroup.fromJson(Map<String, dynamic> json) {
    return CorporateCategoryGroup(
      id: _parseInt(json['id']) ?? 0,
      name: json['name']?.toString() ?? '',
      imageUrl:
          json['image_url']?.toString() ?? json['image']?.toString() ?? '',
      subcategories:
          (json['subcategories'] as List<dynamic>?)
              ?.map(
                (e) => Category.fromJson(Map<String, dynamic>.from(e as Map)),
              )
              .toList() ??
          const [],
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
