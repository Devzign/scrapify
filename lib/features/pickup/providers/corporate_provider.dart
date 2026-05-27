import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../../profile/domain/models/address_model.dart';
import '../domain/models/category.dart';

class CorporateCategoryEntry {
  final int? categoryId;
  final String category;
  final String parentCategory;
  final double quantity;
  final String unit; // 'kg' or 'qns'

  CorporateCategoryEntry({
    this.categoryId,
    required this.category,
    required this.parentCategory,
    required this.quantity,
    required this.unit,
  });
}

class CorporateItem {
  final Category category;
  final double quantity;
  final String unit; // 'kg' or 'qns'

  CorporateItem({
    required this.category,
    required this.quantity,
    required this.unit,
  });

  CorporateItem copyWith({double? quantity, String? unit}) {
    return CorporateItem(
      category: category,
      quantity: quantity ?? this.quantity,
      unit: unit ?? this.unit,
    );
  }
}

class CorporateBookingState {
  final List<CorporateItem> items;
  final List<CorporateCategoryEntry> corporateEntries;
  final AddressModel? selectedAddress;
  final DateTime? selectedDate;
  final String? selectedTimeSlot;
  final String companyName;
  final String contactName;
  final String contactMobile;
  final String contactEmail;
  final String corporateCategory;
  final String meetingType;
  final String? gstNumber;
  final String? notes;
  final List<XFile> images;
  final bool isSubmitting;
  final String? error;

  CorporateBookingState({
    this.items = const [],
    this.corporateEntries = const [],
    this.selectedAddress,
    this.selectedDate,
    this.selectedTimeSlot,
    this.companyName = '',
    this.contactName = '',
    this.contactMobile = '',
    this.contactEmail = '',
    this.corporateCategory = '',
    this.meetingType = '',
    this.gstNumber,
    this.notes,
    this.images = const [],
    this.isSubmitting = false,
    this.error,
  });

  CorporateBookingState copyWith({
    List<CorporateItem>? items,
    List<CorporateCategoryEntry>? corporateEntries,
    AddressModel? selectedAddress,
    DateTime? selectedDate,
    String? selectedTimeSlot,
    String? companyName,
    String? contactName,
    String? contactMobile,
    String? contactEmail,
    String? corporateCategory,
    String? meetingType,
    String? gstNumber,
    String? notes,
    List<XFile>? images,
    bool? isSubmitting,
    String? error,
    bool clearError = false,
  }) {
    return CorporateBookingState(
      items: items ?? this.items,
      corporateEntries: corporateEntries ?? this.corporateEntries,
      selectedAddress: selectedAddress ?? this.selectedAddress,
      selectedDate: selectedDate ?? this.selectedDate,
      selectedTimeSlot: selectedTimeSlot ?? this.selectedTimeSlot,
      companyName: companyName ?? this.companyName,
      contactName: contactName ?? this.contactName,
      contactMobile: contactMobile ?? this.contactMobile,
      contactEmail: contactEmail ?? this.contactEmail,
      corporateCategory: corporateCategory ?? this.corporateCategory,
      meetingType: meetingType ?? this.meetingType,
      gstNumber: gstNumber ?? this.gstNumber,
      notes: notes ?? this.notes,
      images: images ?? this.images,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      error: clearError ? null : (error ?? this.error),
    );
  }

  bool get isReadyForSchedule =>
      corporateEntries.isNotEmpty || items.isNotEmpty;
  bool get isReadyToSubmit =>
      (corporateEntries.isNotEmpty || items.isNotEmpty) &&
      selectedAddress != null &&
      selectedDate != null &&
      selectedTimeSlot != null &&
      contactName.trim().isNotEmpty &&
      contactMobile.trim().isNotEmpty &&
      contactEmail.trim().isNotEmpty &&
      meetingType.trim().isNotEmpty;
}

class CorporateBookingNotifier extends Notifier<CorporateBookingState> {
  @override
  CorporateBookingState build() => CorporateBookingState();

  void reset() => state = CorporateBookingState();

  void setItem(Category category, double quantity, String unit) {
    final existing = state.items.indexWhere(
      (i) => i.category.id == category.id,
    );
    if (quantity <= 0) {
      if (existing != -1) {
        final updated = List<CorporateItem>.from(state.items)
          ..removeAt(existing);
        state = state.copyWith(items: updated);
      }
      return;
    }
    final item = CorporateItem(
      category: category,
      quantity: quantity,
      unit: unit,
    );
    if (existing == -1) {
      state = state.copyWith(items: [...state.items, item]);
    } else {
      final updated = List<CorporateItem>.from(state.items);
      updated[existing] = item;
      state = state.copyWith(items: updated);
    }
  }

  void removeItem(int categoryId) {
    state = state.copyWith(
      items: state.items.where((i) => i.category.id != categoryId).toList(),
    );
  }

  void addCorporateEntry(
    String category,
    String parentCategory,
    double quantity,
    String unit, {
    int? categoryId,
  }) {
    final normalized = category.trim();
    final normalizedParent = parentCategory.trim();
    if (normalized.isEmpty || normalizedParent.isEmpty || quantity <= 0) return;
    final existing = state.corporateEntries.indexWhere(
      (e) =>
          (categoryId != null
              ? e.categoryId == categoryId
              : e.category == normalized) &&
          e.unit == unit,
    );
    final entry = CorporateCategoryEntry(
      categoryId: categoryId,
      category: normalized,
      parentCategory: normalizedParent,
      quantity: quantity,
      unit: unit,
    );
    if (existing == -1) {
      state = state.copyWith(
        corporateEntries: [...state.corporateEntries, entry],
        corporateCategory: state.corporateCategory.trim().isEmpty
            ? normalizedParent
            : state.corporateCategory,
      );
      return;
    }
    final updated = List<CorporateCategoryEntry>.from(state.corporateEntries);
    updated[existing] = entry;
    state = state.copyWith(
      corporateEntries: updated,
      corporateCategory: state.corporateCategory.trim().isEmpty
          ? normalizedParent
          : state.corporateCategory,
    );
  }

  void removeCorporateEntryAt(int index) {
    final updated = List<CorporateCategoryEntry>.from(state.corporateEntries)
      ..removeAt(index);
    state = state.copyWith(corporateEntries: updated);
  }

  void setAddress(AddressModel address) =>
      state = state.copyWith(selectedAddress: address);

  void setDate(DateTime date) => state = state.copyWith(selectedDate: date);

  void setTimeSlot(String slot) =>
      state = state.copyWith(selectedTimeSlot: slot);

  void setCompanyName(String value) =>
      state = state.copyWith(companyName: value);

  void setContactName(String value) =>
      state = state.copyWith(contactName: value);

  void setContactMobile(String value) =>
      state = state.copyWith(contactMobile: value);

  void setContactEmail(String value) =>
      state = state.copyWith(contactEmail: value);

  void setCorporateCategory(String value) =>
      state = state.copyWith(corporateCategory: value);

  void setMeetingType(String value) =>
      state = state.copyWith(meetingType: value);

  void setGstNumber(String value) => state = state.copyWith(gstNumber: value);

  void setNotes(String notes) => state = state.copyWith(notes: notes);

  void addImage(XFile image) =>
      state = state.copyWith(images: [...state.images, image]);

  void removeImage(int index) {
    final updated = List<XFile>.from(state.images)..removeAt(index);
    state = state.copyWith(images: updated);
  }

  CorporateItem? itemFor(int categoryId) {
    try {
      return state.items.firstWhere((i) => i.category.id == categoryId);
    } catch (_) {
      return null;
    }
  }
}

final corporateBookingProvider =
    NotifierProvider<CorporateBookingNotifier, CorporateBookingState>(
      CorporateBookingNotifier.new,
    );
