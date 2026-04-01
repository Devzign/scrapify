import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/models/basket_item.dart';

class BasketNotifier extends Notifier<List<BasketItem>> {
  @override
  List<BasketItem> build() {
    return [];
  }

  void addItem(BasketItem item) {
    final index = state.indexWhere(
      (existing) => existing.category.id == item.category.id,
    );
    if (index == -1) {
      state = [...state, item];
      return;
    }

    state = [
      for (int i = 0; i < state.length; i++)
        if (i == index)
          state[i].copyWith(quantity: state[i].quantity + item.quantity)
        else
          state[i],
    ];
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
      return;
    }

    state = [
      for (int i = 0; i < state.length; i++)
        if (i == index) item else state[i],
    ];
  }

  void removeItem(int index) {
    state = [
      for (int i = 0; i < state.length; i++)
        if (i != index) state[i],
    ];
  }

  void updateQuantity(int index, double newQuantity) {
    state = [
      for (int i = 0; i < state.length; i++)
        if (i == index) state[i].copyWith(quantity: newQuantity) else state[i],
    ];
  }

  void clearBasket() {
    state = [];
  }

  double get totalEstimate =>
      state.fold(0, (sum, item) => sum + item.totalEstimate);

  int get itemCount => state.length;
}

final basketProvider = NotifierProvider<BasketNotifier, List<BasketItem>>(() {
  return BasketNotifier();
});
