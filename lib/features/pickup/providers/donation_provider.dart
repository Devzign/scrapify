import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../settings/providers/settings_provider.dart';
import '../domain/models/basket_item.dart';
import '../domain/models/category.dart';

class DonationState {
  final List<BasketItem> items;
  final String notes;

  DonationState({this.items = const [], this.notes = ''});

  DonationState copyWith({List<BasketItem>? items, String? notes}) {
    return DonationState(
      items: items ?? this.items,
      notes: notes ?? this.notes,
    );
  }
}

class DonationNotifier extends Notifier<DonationState> {
  @override
  DonationState build() => DonationState();

  void setQuantity(Category category, int quantity) {
    final index = state.items.indexWhere(
      (item) => item.category.id == category.id,
    );

    if (quantity <= 0) {
      if (index == -1) {
        return;
      }
      state = state.copyWith(
        items: [
          for (int i = 0; i < state.items.length; i++)
            if (i != index) state.items[i],
        ],
      );
      return;
    }

    final item = BasketItem(
      category: category,
      quantity: quantity.toDouble(),
      unit: 'pcs',
      pricePerUnit: 0,
    );

    if (index == -1) {
      state = state.copyWith(items: [...state.items, item]);
      return;
    }

    state = state.copyWith(
      items: [
        for (int i = 0; i < state.items.length; i++)
          if (i == index)
            item.copyWith(image: state.items[i].image)
          else
            state.items[i],
      ],
    );
  }

  void updateItemImage(int categoryId, XFile? image) {
    state = state.copyWith(
      items: [
        for (final item in state.items)
          if (item.category.id == categoryId)
            item.copyWith(image: image)
          else
            item,
      ],
    );
  }

  void updateNotes(String notes) {
    state = state.copyWith(notes: notes);
  }

  int quantityFor(int categoryId) {
    final match = state.items.where((item) => item.category.id == categoryId);
    if (match.isEmpty) {
      return 0;
    }
    return match.first.quantity.round();
  }

  String get donationCategoryKey {
    if (state.items.isEmpty) {
      return 'mixed';
    }
    if (state.items.length == 1) {
      return state.items.first.category.slug;
    }
    return 'mixed';
  }

  void clear() {
    state = DonationState();
  }
}

final donationProvider = NotifierProvider<DonationNotifier, DonationState>(
  DonationNotifier.new,
);

final donationCategoriesProvider = Provider<List<Category>>((ref) {
  final settings = ref.watch(settingsProvider).settings;
  final dynamicProducts = (settings['donation_products'] as List<dynamic>?)
      ?.map((e) => e.toString().trim())
      .where((e) => e.isNotEmpty)
      .toList();

  final names = (dynamicProducts == null || dynamicProducts.isEmpty)
      ? const ['Cloth', 'Shoes', 'Toys', 'Books']
      : dynamicProducts;

  return List.generate(names.length, (index) {
    final name = names[index];
    final slug = name.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]+'), '_');
    return Category(
      id: 21000 + index + 1,
      name: LocalizedName(en: name, hi: name),
      slug: slug,
      imageUrl: '',
      attributes: const [],
      children: const [],
    );
  });
});
