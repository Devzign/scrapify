import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../../auth/providers/auth_provider.dart';
import '../domain/models/address_model.dart';
import '../domain/repositories/address_repository.dart';

final addressRepositoryProvider = Provider<AddressRepository>((ref) {
  final dioClient = ref.watch(dioClientProvider);
  return AddressRepository(dioClient);
});

final addressProvider = StateNotifierProvider<AddressNotifier, AsyncValue<List<AddressModel>>>((ref) {
  final repository = ref.watch(addressRepositoryProvider);
  return AddressNotifier(repository);
});

class AddressNotifier extends StateNotifier<AsyncValue<List<AddressModel>>> {
  final AddressRepository _repository;

  AddressNotifier(this._repository) : super(const AsyncValue.loading()) {
    getAddresses();
  }

  Future<void> getAddresses() async {
    state = const AsyncValue.loading();
    final response = await _repository.getAddresses();
    if (response.isSuccess) {
      state = AsyncValue.data(response.data!);
    } else {
      state = AsyncValue.error(response.errorMessage ?? 'Failed to fetch addresses', StackTrace.current);
    }
  }

  Future<bool> addAddress(AddressModel address) async {
    final response = await _repository.addAddress(address);
    if (response.isSuccess) {
      await getAddresses(); // Refresh list
      return true;
    }
    return false;
  }

  Future<bool> updateAddress(int id, AddressModel address) async {
    final response = await _repository.updateAddress(id, address);
    if (response.isSuccess) {
      await getAddresses(); // Refresh list
      return true;
    }
    return false;
  }

  Future<bool> deleteAddress(int id) async {
    final response = await _repository.deleteAddress(id);
    if (response.isSuccess) {
      await getAddresses(); // Refresh list
      return true;
    }
    return false;
  }
}
