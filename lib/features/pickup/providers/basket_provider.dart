import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/storage/app_preferences.dart';
import '../domain/models/basket_item.dart';
import '../domain/models/category.dart';

class BasketNotifier extends Notifier<List<BasketItem>> {
  @override
  List<BasketItem> build() {
    Future.microtask(_restoreBasket);
    return [];
  }

  void addItem(BasketItem item) {
    final index = state.indexWhere(
      (existing) => existing.category.id == item.category.id,
    );
    if (index == -1) {
      state = [...state, item];
      _persistBasket();
      return;
    }

    state = [
      for (int i = 0; i < state.length; i++)
        if (i == index)
          state[i].copyWith(quantity: state[i].quantity + item.quantity)
        else
          state[i],
    ];
    _persistBasket();
  }

  void setItem(BasketItem item) {
    final index = state.indexWhere(
      (existing) => existing.category.id == item.category.id,
    );

    if (item.quantity <= 0) {
      if (index == -1) {
        return;
      }
      removeItem(index);
      return;
    }

    if (index == -1) {
      state = [...state, item];
      _persistBasket();
      return;
    }

    state = [
      for (int i = 0; i < state.length; i++)
        if (i == index) item else state[i],
    ];
    _persistBasket();
  }

  void removeItem(int index) {
    state = [
      for (int i = 0; i < state.length; i++)
        if (i != index) state[i],
    ];
    _persistBasket();
  }

  void updateQuantity(int index, double newQuantity) {
    state = [
      for (int i = 0; i < state.length; i++)
        if (i == index) state[i].copyWith(quantity: newQuantity) else state[i],
    ];
    _persistBasket();
  }

  void clearBasket() {
    state = [];
    _persistBasket();
  }

  double get totalEstimate =>
      state.fold(0, (sum, item) => sum + item.totalEstimate);

  int get itemCount => state.length;

  Future<void> _restoreBasket() async {
    final savedItems = await ref.read(appPreferencesProvider).getBasketItems();
    if (!ref.mounted || savedItems.isEmpty) {
      return;
    }

    state = savedItems.map(_basketItemFromJson).toList();
  }

  Future<void> _persistBasket() async {
    final preferences = ref.read(appPreferencesProvider);
    if (state.isEmpty) {
      await preferences.clearBasketItems();
      return;
    }

    await preferences.saveBasketItems(state.map(_basketItemToJson).toList());
  }

  Map<String, dynamic> _basketItemToJson(BasketItem item) {
    return {
      'category': {
        'id': item.category.id,
        'name': item.category.name.toJson(),
        'slug': item.category.slug,
        'category_type_id': item.category.categoryTypeId,
        'parent_id': item.category.parentId,
        'pricing_type': item.category.pricingType,
        'base_price': item.category.basePrice,
        'image_url': item.category.imageUrl,
        'attributes': const [],
        'children': const [],
      },
      'sub_category_name': item.subCategoryName,
      'quantity': item.quantity,
      'unit': item.unit,
      'price_per_unit': item.pricePerUnit,
      'selected_attributes': item.selectedAttributes
          .map(
            (attribute) => {
              'id': attribute.id,
              'name': attribute.name,
              'value': attribute.value,
            },
          )
          .toList(),
    };
  }

  BasketItem _basketItemFromJson(Map<String, dynamic> json) {
    final selectedAttributes =
        (json['selected_attributes'] as List<dynamic>? ?? [])
            .map(
              (attribute) => SelectedAttribute(
                id: (attribute as Map<String, dynamic>)['id'] as int? ?? 0,
                name: attribute['name']?.toString() ?? '',
                value: attribute['value']?.toString() ?? '',
              ),
            )
            .toList();

    return BasketItem(
      category: Category.fromJson(
        Map<String, dynamic>.from(json['category'] as Map),
      ),
      subCategoryName: json['sub_category_name']?.toString(),
      quantity: (json['quantity'] as num?)?.toDouble() ?? 0,
      unit: json['unit']?.toString() ?? '',
      pricePerUnit: (json['price_per_unit'] as num?)?.toDouble() ?? 0,
      selectedAttributes: selectedAttributes,
    );
  }
}

final basketProvider = NotifierProvider<BasketNotifier, List<BasketItem>>(() {
  return BasketNotifier();
});
