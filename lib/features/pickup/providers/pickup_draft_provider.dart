import 'dart:io';
import 'package:flutter_riverpod/legacy.dart';

/// Accumulates state across the multi-step pickup creation flow:
/// CategorySelection → QuestionForm → UploadPhoto → SelectDateTime → createPickup

class PickupDraft {
  final int? categoryId;
  final String categoryName;
  final String estimatedWeight; // 'small' | 'medium' | 'large'
  final List<File> images;
  final String address;
  final int cityId;

  const PickupDraft({
    this.categoryId,
    this.categoryName = '',
    this.estimatedWeight = 'medium',
    this.images = const [],
    this.address = '',
    this.cityId = 1,
  });

  PickupDraft copyWith({
    int? categoryId,
    String? categoryName,
    String? estimatedWeight,
    List<File>? images,
    String? address,
    int? cityId,
  }) {
    return PickupDraft(
      categoryId: categoryId ?? this.categoryId,
      categoryName: categoryName ?? this.categoryName,
      estimatedWeight: estimatedWeight ?? this.estimatedWeight,
      images: images ?? this.images,
      address: address ?? this.address,
      cityId: cityId ?? this.cityId,
    );
  }

  /// Convert weight to estimated kg for API items[]
  double get estimatedKg {
    switch (estimatedWeight) {
      case 'small':
        return 5.0;
      case 'large':
        return 50.0;
      default:
        return 20.0;
    }
  }

  /// Build items[] payload for createPickup
  List<Map<String, dynamic>> get itemsPayload {
    if (categoryId == null) return [];
    return [
      {
        'category_id': categoryId,
        'item_name': categoryName.isNotEmpty ? categoryName : 'Scrap',
        'expected_weight': estimatedKg,
        'quantity': 1,
      }
    ];
  }
}

class PickupDraftNotifier extends StateNotifier<PickupDraft> {
  PickupDraftNotifier() : super(const PickupDraft());

  void setCategory(int id, String name) {
    state = state.copyWith(categoryId: id, categoryName: name);
  }

  void setWeight(String weight) {
    state = state.copyWith(estimatedWeight: weight);
  }

  void setImages(List<File> images) {
    state = state.copyWith(images: images);
  }

  void setAddress(String address, {int? cityId}) {
    state = state.copyWith(address: address, cityId: cityId);
  }

  void reset() {
    state = const PickupDraft();
  }
}

final pickupDraftProvider =
    StateNotifierProvider<PickupDraftNotifier, PickupDraft>(
  (ref) => PickupDraftNotifier(),
);
