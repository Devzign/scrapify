import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../../auth/providers/auth_provider.dart';
import '../domain/models/payment_method_model.dart';
import '../domain/repositories/payment_repository.dart';

final paymentRepositoryProvider = Provider<PaymentRepository>((ref) {
  final dioClient = ref.watch(dioClientProvider);
  return PaymentRepository(dioClient);
});

final paymentProvider = StateNotifierProvider<PaymentNotifier, AsyncValue<List<PaymentMethodModel>>>((ref) {
  final repository = ref.watch(paymentRepositoryProvider);
  return PaymentNotifier(repository);
});

class PaymentNotifier extends StateNotifier<AsyncValue<List<PaymentMethodModel>>> {
  final PaymentRepository _repository;

  PaymentNotifier(this._repository) : super(const AsyncValue.loading()) {
    getPaymentDetails();
  }

  Future<void> getPaymentDetails() async {
    state = const AsyncValue.loading();
    final response = await _repository.getPaymentDetails();
    if (response.isSuccess) {
      state = AsyncValue.data(response.data!);
    } else {
      state = AsyncValue.error(response.errorMessage ?? 'Failed to fetch payment methods', StackTrace.current);
    }
  }

  Future<bool> addPaymentDetail(PaymentMethodModel payment) async {
    final response = await _repository.addPaymentDetail(payment);
    if (response.isSuccess) {
      await getPaymentDetails(); // Refresh list
      return true;
    }
    return false;
  }

  Future<bool> updatePaymentDetail(int id, PaymentMethodModel payment) async {
    final response = await _repository.updatePaymentDetail(id, payment);
    if (response.isSuccess) {
      await getPaymentDetails(); // Refresh list
      return true;
    }
    return false;
  }

  Future<bool> deletePaymentDetail(int id) async {
    final response = await _repository.deletePaymentDetail(id);
    if (response.isSuccess) {
      await getPaymentDetails(); // Refresh list
      return true;
    }
    return false;
  }
}
