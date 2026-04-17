import 'package:image_picker/image_picker.dart';
import 'category.dart';

class BasketItem {
  final Category category;
  final String? subCategoryName;
  final double quantity;
  final String unit; // 'kg', 'pcs', etc.
  final double pricePerUnit;
  final List<SelectedAttribute> selectedAttributes;
  final XFile? image;

  BasketItem({
    required this.category,
    this.subCategoryName,
    required this.quantity,
    required this.unit,
    required this.pricePerUnit,
    this.selectedAttributes = const [],
    this.image,
  });

  double get totalEstimate => quantity * pricePerUnit;

  BasketItem copyWith({
    Category? category,
    String? subCategoryName,
    double? quantity,
    String? unit,
    double? pricePerUnit,
    List<SelectedAttribute>? selectedAttributes,
    XFile? image,
  }) {
    return BasketItem(
      category: category ?? this.category,
      subCategoryName: subCategoryName ?? this.subCategoryName,
      quantity: quantity ?? this.quantity,
      unit: unit ?? this.unit,
      pricePerUnit: pricePerUnit ?? this.pricePerUnit,
      selectedAttributes: selectedAttributes ?? this.selectedAttributes,
      image: image ?? this.image,
    );
  }
}

class SelectedAttribute {
  final int id;
  final String name;
  final String value;

  SelectedAttribute({
    required this.id,
    required this.name,
    required this.value,
  });
}
