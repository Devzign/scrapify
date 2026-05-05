import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../../profile/domain/models/address_model.dart';
import '../../profile/domain/models/payment_method_model.dart';
import '../domain/models/pickup_request_model.dart';
import '../domain/repositories/pickup_repository.dart';
import '../../../core/utils/app_logger.dart';
import '../../referral/data/models/validate_coupon_response_model.dart';
import 'donation_provider.dart';

class BookingState {
  final String requestType;
  final String? donationCategory;
  final AddressModel? selectedAddress;
  final DateTime? selectedDate;
  final String? selectedTimeSlot;
  final String? payoutMethod;
  final PaymentMethodModel? selectedPaymentDetail;
  final String? appliedCouponCode;
  final ValidateCouponResponseModel? appliedCoupon;
  // categoryImages: categoryId → list of photos for that category
  final Map<int, List<XFile>> categoryImages;
  final bool isSubmitting;
  final String? error;

  BookingState({
    this.requestType = 'scrap',
    this.donationCategory,
    this.selectedAddress,
    this.selectedDate,
    this.selectedTimeSlot,
    this.payoutMethod,
    this.selectedPaymentDetail,
    this.appliedCouponCode,
    this.appliedCoupon,
    this.categoryImages = const {},
    this.isSubmitting = false,
    this.error,
  });

  /// Flat list of all images across all categories (used in submission)
  List<XFile> get images =>
      categoryImages.values.expand((list) => list).toList();

  BookingState copyWith({
    String? requestType,
    String? donationCategory,
    AddressModel? selectedAddress,
    DateTime? selectedDate,
    String? selectedTimeSlot,
    String? payoutMethod,
    PaymentMethodModel? selectedPaymentDetail,
    String? appliedCouponCode,
    ValidateCouponResponseModel? appliedCoupon,
    Map<int, List<XFile>>? categoryImages,
    bool? isSubmitting,
    String? error,
    bool clearCoupon = false,
  }) {
    return BookingState(
      requestType: requestType ?? this.requestType,
      donationCategory: donationCategory ?? this.donationCategory,
      selectedAddress: selectedAddress ?? this.selectedAddress,
      selectedDate: selectedDate ?? this.selectedDate,
      selectedTimeSlot: selectedTimeSlot ?? this.selectedTimeSlot,
      payoutMethod: payoutMethod ?? this.payoutMethod,
      selectedPaymentDetail:
          selectedPaymentDetail ?? this.selectedPaymentDetail,
      appliedCouponCode: clearCoupon
          ? null
          : (appliedCouponCode ?? this.appliedCouponCode),
      appliedCoupon: clearCoupon ? null : (appliedCoupon ?? this.appliedCoupon),
      categoryImages: categoryImages ?? this.categoryImages,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      error: error,
    );
  }

  bool get isDonationFlow => requestType == 'donation';
}

class BookingNotifier extends Notifier<BookingState> {
  @override
  BookingState build() {
    return BookingState();
  }

  void setSelectedAddress(AddressModel address) {
    state = state.copyWith(selectedAddress: address);
  }

  void startScrapFlow() {
    state = BookingState(
      requestType: 'scrap',
      selectedAddress: state.selectedAddress,
      appliedCouponCode: null,
      appliedCoupon: null,
      categoryImages: const {},
    );
  }

  void startDonationFlow({required String donationCategory}) {
    state = BookingState(
      requestType: 'donation',
      donationCategory: donationCategory,
      selectedAddress: state.selectedAddress,
      appliedCouponCode: null,
      appliedCoupon: null,
      categoryImages: const {},
    );
  }

  void setSelectedDate(DateTime date) {
    state = state.copyWith(selectedDate: date);
  }

  void setSelectedTimeSlot(String timeSlot) {
    state = state.copyWith(selectedTimeSlot: timeSlot);
  }

  void clearSelectedTimeSlot() {
    state = BookingState(
      requestType: state.requestType,
      donationCategory: state.donationCategory,
      selectedAddress: state.selectedAddress,
      selectedDate: state.selectedDate,
      payoutMethod: state.payoutMethod,
      selectedPaymentDetail: state.selectedPaymentDetail,
      appliedCouponCode: state.appliedCouponCode,
      appliedCoupon: state.appliedCoupon,
      isSubmitting: state.isSubmitting,
      error: state.error,
    );
  }

  void setPayoutMethod(String method) {
    state = state.copyWith(payoutMethod: method, selectedPaymentDetail: null);
  }

  void setSelectedPaymentDetail(PaymentMethodModel? payment) {
    state = state.copyWith(selectedPaymentDetail: payment);
  }

  void setAppliedCoupon(ValidateCouponResponseModel coupon) {
    state = state.copyWith(
      appliedCouponCode: coupon.couponCode,
      appliedCoupon: coupon,
    );
  }

  void clearAppliedCoupon() {
    state = state.copyWith(clearCoupon: true);
  }

  void addCategoryImage(int categoryId, XFile image) {
    final updated = Map<int, List<XFile>>.from(state.categoryImages);
    updated[categoryId] = [...(updated[categoryId] ?? []), image];
    state = state.copyWith(categoryImages: updated);
  }

  void removeCategoryImage(int categoryId, int imageIndex) {
    final updated = Map<int, List<XFile>>.from(state.categoryImages);
    final list = List<XFile>.from(updated[categoryId] ?? []);
    list.removeAt(imageIndex);
    updated[categoryId] = list;
    state = state.copyWith(categoryImages: updated);
  }

  // Legacy helpers kept for non-category flows
  void addImages(List<XFile> newImages) {
    // Add to a generic key (0) for backward compatibility
    final updated = Map<int, List<XFile>>.from(state.categoryImages);
    updated[0] = [...(updated[0] ?? []), ...newImages];
    state = state.copyWith(categoryImages: updated);
  }

  void removeImage(int index) {
    final updated = Map<int, List<XFile>>.from(state.categoryImages);
    final list = List<XFile>.from(updated[0] ?? []);
    if (index < list.length) list.removeAt(index);
    updated[0] = list;
    state = state.copyWith(categoryImages: updated);
  }

  Future<PickupRequestModel?> submitBooking(List<dynamic> basketItems) async {
    if (state.selectedAddress == null) {
      state = state.copyWith(error: 'Please select an address');
      return null;
    }
    if (state.selectedDate == null || state.selectedTimeSlot == null) {
      state = state.copyWith(error: 'Please select pickup date and time');
      return null;
    }
    if (state.payoutMethod == null || state.payoutMethod!.trim().isEmpty) {
      state = state.copyWith(error: 'Please select a payout method');
      return null;
    }

    state = state.copyWith(isSubmitting: true, error: null);

    try {
      final repository = ref.read(pickupRepositoryProvider);
      final selectedDate = state.selectedDate!;
      final scheduledAt = _buildScheduledAt(
        selectedDate,
        state.selectedTimeSlot!,
      );

      final itemsList = basketItems
          .map(
            (item) => {
              'category_id': item.category.id,
              'weight': item.quantity,
              'quantity': 1,
              'attributes': item.selectedAttributes
                  .map((attr) => {'attribute_id': attr.id, 'value': attr.value})
                  .toList(),
            },
          )
          .toList();

      final data = {
        'address':
            '${state.selectedAddress!.addressLine1}, ${state.selectedAddress!.pincode}',
        'address_id': state.selectedAddress!.id,
        'city_id': state.selectedAddress!.cityId,
        'pincode': state.selectedAddress!.pincode,
        'latitude': state.selectedAddress!.latitude ?? 28.6139,
        'longitude': state.selectedAddress!.longitude ?? 77.2090,
        'scheduled_at': scheduledAt,
        'payout_method': state.payoutMethod,
        'payment_detail_id': state.selectedPaymentDetail?.id,
        'coupon_code': state.appliedCouponCode,
        'items': itemsList,
        'images': state.images,
      };

      AppLogger.info('Booking Submission Data: $data');

      final response = await repository.createPickup(data);

      if (response.isSuccess) {
        state = state.copyWith(isSubmitting: false, error: null);
        return response.data;
      }

      final errorMessage =
          response.errorMessage ?? 'Failed to create pickup request';
      AppLogger.error('Pickup request failed: $errorMessage');
      state = state.copyWith(isSubmitting: false, error: errorMessage);
      return null;
    } catch (e) {
      AppLogger.error('Pickup request crashed before completion', error: e);
      state = state.copyWith(isSubmitting: false, error: e.toString());
      return null;
    }
  }

  Future<PickupRequestModel?> submitDonation(
    List<dynamic> donationItems,
  ) async {
    if (state.selectedAddress == null) {
      state = state.copyWith(error: 'Please select an address');
      return null;
    }
    if (state.selectedDate == null || state.selectedTimeSlot == null) {
      state = state.copyWith(error: 'Please select pickup date and time');
      return null;
    }

    state = state.copyWith(isSubmitting: true, error: null);

    try {
      final repository = ref.read(pickupRepositoryProvider);
      final selectedDate = state.selectedDate!;
      final scheduledAt = _buildScheduledAt(
        selectedDate,
        state.selectedTimeSlot!,
      );

      final itemsList = donationItems
          .map(
            (item) => {
              'category_id': item.category.id,
              'weight': item.quantity,
              'quantity': item.quantity.round(),
              'attributes': item.selectedAttributes
                  .map((attr) => {'attribute_id': attr.id, 'value': attr.value})
                  .toList(),
            },
          )
          .toList();

      final donationData = ref.read(donationProvider);
      final itemImages = donationData.items
          .where((item) => item.image != null)
          .map((item) => item.image!)
          .toList();
      final donationCategoryPayload = _buildDonationCategoryPayload(
        donationItems,
        fallback: state.donationCategory,
      );

      final data = {
        'address':
            '${state.selectedAddress!.addressLine1}, ${state.selectedAddress!.pincode}',
        'address_id': state.selectedAddress!.id,
        'city_id': state.selectedAddress!.cityId,
        'pincode': state.selectedAddress!.pincode,
        'latitude': state.selectedAddress!.latitude ?? 28.6139,
        'longitude': state.selectedAddress!.longitude ?? 77.2090,
        'scheduled_at': scheduledAt,
        'donation_category': donationCategoryPayload,
        'notes': donationData.notes.isNotEmpty
            ? donationData.notes
            : 'Donation pickup request from mobile app',
        'items': itemsList,
        'images': [...state.images, ...itemImages],
      };

      AppLogger.info('Donation Submission Data: $data');

      final response = await repository.createDonationPickup(data);

      if (response.isSuccess) {
        state = state.copyWith(isSubmitting: false, error: null);
        return response.data;
      }

      final errorMessage =
          response.errorMessage ?? 'Failed to create donation request';
      AppLogger.error('Donation request failed: $errorMessage');
      state = state.copyWith(isSubmitting: false, error: errorMessage);
      return null;
    } catch (e) {
      AppLogger.error('Donation request crashed before completion', error: e);
      state = state.copyWith(isSubmitting: false, error: e.toString());
      return null;
    }
  }

  void reset() {
    state = BookingState();
  }
}

final bookingProvider = NotifierProvider<BookingNotifier, BookingState>(() {
  return BookingNotifier();
});

String _buildDonationCategoryPayload(
  List<dynamic> donationItems, {
  String? fallback,
}) {
  final categories = <String>{};

  for (final item in donationItems) {
    final rawSlug = item.category.slug.toString().trim().toLowerCase();
    if (rawSlug.isEmpty) {
      continue;
    }
    categories.add(_normalizeDonationSlug(rawSlug));
  }

  if (categories.isNotEmpty) {
    return categories.join(',');
  }

  final normalizedFallback = (fallback ?? '').trim().toLowerCase();
  if (normalizedFallback.isNotEmpty) {
    return _normalizeDonationSlug(normalizedFallback);
  }

  return 'mixed';
}

String _normalizeDonationSlug(String slug) {
  switch (slug) {
    case 'furniture':
      return 'old_furniture';
    case 'old-clothes':
      return 'clothes';
    case 'reusable-goods':
      return 'reusable_goods';
    default:
      return slug;
  }
}

String _formatDate(DateTime date) {
  final month = date.month.toString().padLeft(2, '0');
  final day = date.day.toString().padLeft(2, '0');
  return '${date.year}-$month-$day';
}

String _buildScheduledAt(DateTime date, String timeSlot) {
  final startTime = timeSlot.split(' - ').first.trim();
  final timeParts = startTime.split(' ');
  final hourMinute = timeParts.first.split(':');
  var hour = int.parse(hourMinute.first);
  final minute = int.parse(hourMinute.last);
  final meridian = timeParts.length > 1 ? timeParts.last.toUpperCase() : 'AM';

  if (meridian == 'PM' && hour != 12) {
    hour += 12;
  } else if (meridian == 'AM' && hour == 12) {
    hour = 0;
  }

  final hourText = hour.toString().padLeft(2, '0');
  final minuteText = minute.toString().padLeft(2, '0');
  return '${_formatDate(date)} $hourText:$minuteText:00';
}
