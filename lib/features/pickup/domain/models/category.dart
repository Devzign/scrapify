import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

class Category {
  final int id;
  final LocalizedName name;
  final String slug;
  final int? categoryTypeId;
  final int? parentId;
  final String? pricingType;
  final double? basePrice;
  final bool requiresDetails;
  final String imageUrl;
  final List<CategoryAttribute> attributes;
  final List<Category> children;

  Category({
    required this.id,
    required this.name,
    required this.slug,
    this.categoryTypeId,
    this.parentId,
    this.pricingType,
    this.basePrice,
    this.requiresDetails = false,
    required this.imageUrl,
    required this.attributes,
    required this.children,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: _parseInt(json['id']) ?? 0,
      name: LocalizedName.fromJson(json['name']),
      slug: json['slug']?.toString() ?? '',
      categoryTypeId: _parseInt(json['category_type_id']),
      parentId: _parseInt(json['parent_id']),
      pricingType: json['pricing_type'] as String?,
      basePrice: (json['base_price'] as num?)?.toDouble(),
      requiresDetails:
          json['requires_details'] == true || json['requires_details'] == 1,
      imageUrl:
          json['image_url']?.toString() ?? json['image']?.toString() ?? '',
      attributes:
          (json['attributes'] as List<dynamic>?)
              ?.map(
                (e) => CategoryAttribute.fromJson(
                  Map<String, dynamic>.from(e as Map),
                ),
              )
              .toList() ??
          [],
      children:
          (json['children'] as List<dynamic>?)
              ?.map(
                (e) => Category.fromJson(Map<String, dynamic>.from(e as Map)),
              )
              .toList() ??
          [],
    );
  }

  String getName(BuildContext context) {
    return context.locale.languageCode == 'hi' ? name.hi : name.en;
  }

  bool get hasAttributes => attributes.isNotEmpty || requiresDetails;
}

class LocalizedName {
  final String en;
  final String hi;

  LocalizedName({required this.en, required this.hi});

  factory LocalizedName.fromJson(dynamic json) {
    if (json is String) {
      return LocalizedName(en: json, hi: json);
    }
    if (json is Map) {
      final en = json['en']?.toString() ?? json['name']?.toString() ?? '';
      final hi = json['hi']?.toString() ?? en;
      return LocalizedName(en: en, hi: hi);
    }
    final fallback = json?.toString() ?? '';
    return LocalizedName(en: fallback, hi: fallback);
  }

  Map<String, dynamic> toJson() {
    return {'en': en, 'hi': hi};
  }

  String localized(String languageCode) {
    return languageCode == 'hi' ? hi : en;
  }
}

class CategoryType {
  final int id;
  final String name;
  final String slug;
  final String imageUrl;
  final bool status;

  CategoryType({
    required this.id,
    required this.name,
    required this.slug,
    required this.imageUrl,
    required this.status,
  });

  factory CategoryType.fromJson(Map<String, dynamic> json) {
    return CategoryType(
      id: _parseInt(json['id']) ?? 0,
      name: json['name']?.toString() ?? '',
      slug: json['slug']?.toString() ?? '',
      imageUrl:
          json['image_url']?.toString() ?? json['image']?.toString() ?? '',
      status: json['status'] == true || json['status'] == 1,
    );
  }
}

class CategoryAttribute {
  final int id;
  final LocalizedName name;
  final String type;
  final bool isRequired;
  final List<CategoryAttributeOption> options;

  CategoryAttribute({
    required this.id,
    required this.name,
    required this.type,
    required this.isRequired,
    required this.options,
  });

  factory CategoryAttribute.fromJson(Map<String, dynamic> json) {
    final rawIsRequired = json['is_required'] ?? json['pivot']?['is_required'];
    final isRequiredBool = rawIsRequired == true || rawIsRequired == 1;

    return CategoryAttribute(
      id: _parseInt(json['id']) ?? 0,
      name: LocalizedName.fromJson(json['name']),
      type: json['type']?.toString() ?? 'text',
      isRequired: isRequiredBool,
      options:
          (json['options'] as List<dynamic>?)
              ?.map(
                (e) => CategoryAttributeOption.fromJson(
                  Map<String, dynamic>.from(e as Map),
                ),
              )
              .toList() ??
          [],
    );
  }
}

class CategoryAttributeOption {
  final int id;
  final LocalizedName value;

  CategoryAttributeOption({required this.id, required this.value});

  factory CategoryAttributeOption.fromJson(Map<String, dynamic> json) {
    return CategoryAttributeOption(
      id: _parseInt(json['id']) ?? 0,
      value: LocalizedName.fromJson(json['value']),
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
