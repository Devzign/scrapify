class HomeApplianceDetails {
  final int id;
  final String name;
  final double estimatedPrice;
  final String pricingType;
  final List<HomeApplianceSection> sections;

  const HomeApplianceDetails({
    required this.id,
    required this.name,
    required this.estimatedPrice,
    required this.pricingType,
    required this.sections,
  });

  factory HomeApplianceDetails.fromJson(Map<String, dynamic> json) {
    return HomeApplianceDetails(
      id: (json['id'] as num?)?.toInt() ?? 0,
      name: json['name'] as String? ?? '',
      estimatedPrice: (json['estimated_price'] as num?)?.toDouble() ?? 0,
      pricingType: json['pricing_type']?.toString() ?? 'per_piece',
      sections: (json['sections'] as List<dynamic>? ?? const <dynamic>[])
          .whereType<Map<String, dynamic>>()
          .map(HomeApplianceSection.fromJson)
          .toList(),
    );
  }
}

class HomeApplianceSection {
  final int id;
  final String title;
  final String slug;
  final List<HomeApplianceOption> options;

  const HomeApplianceSection({
    required this.id,
    required this.title,
    required this.slug,
    required this.options,
  });

  factory HomeApplianceSection.fromJson(Map<String, dynamic> json) {
    return HomeApplianceSection(
      id: (json['id'] as num?)?.toInt() ?? 0,
      title: json['title'] as String? ?? '',
      slug: json['slug'] as String? ?? '',
      options: (json['options'] as List<dynamic>? ?? const <dynamic>[])
          .whereType<Map<String, dynamic>>()
          .map(HomeApplianceOption.fromJson)
          .toList(),
    );
  }
}

class HomeApplianceOption {
  final int id;
  final String value;

  const HomeApplianceOption({required this.id, required this.value});

  factory HomeApplianceOption.fromJson(Map<String, dynamic> json) {
    return HomeApplianceOption(
      id: (json['id'] as num?)?.toInt() ?? 0,
      value: json['value'] as String? ?? '',
    );
  }
}
