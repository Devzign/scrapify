import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../profile/domain/models/address_model.dart';

class BookingState {
  final AddressModel? selectedAddress;
  final DateTime? selectedDate;
  final String? selectedTimeSlot;
  final String? payoutMethod;

  BookingState({
    this.selectedAddress,
    this.selectedDate,
    this.selectedTimeSlot,
    this.payoutMethod,
  });

  BookingState copyWith({
    AddressModel? selectedAddress,
    DateTime? selectedDate,
    String? selectedTimeSlot,
    String? payoutMethod,
  }) {
    return BookingState(
      selectedAddress: selectedAddress ?? this.selectedAddress,
      selectedDate: selectedDate ?? this.selectedDate,
      selectedTimeSlot: selectedTimeSlot ?? this.selectedTimeSlot,
      payoutMethod: payoutMethod ?? this.payoutMethod,
    );
  }
}

class BookingNotifier extends Notifier<BookingState> {
  @override
  BookingState build() {
    return BookingState();
  }

  void setSelectedAddress(AddressModel address) {
    state = state.copyWith(selectedAddress: address);
  }

  void setSelectedDate(DateTime date) {
    state = state.copyWith(selectedDate: date);
  }

  void setSelectedTimeSlot(String timeSlot) {
    state = state.copyWith(selectedTimeSlot: timeSlot);
  }

  void setPayoutMethod(String method) {
    state = state.copyWith(payoutMethod: method);
  }

  void reset() {
    state = BookingState();
  }
}

final bookingProvider = NotifierProvider<BookingNotifier, BookingState>(() {
  return BookingNotifier();
});
