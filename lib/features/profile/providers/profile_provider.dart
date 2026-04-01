import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../../auth/providers/auth_provider.dart';
import '../domain/repositories/profile_repository.dart';

final profileRepositoryProvider = Provider<ProfileRepository>((ref) {
  final dioClient = ref.watch(dioClientProvider);
  return ProfileRepository(dioClient);
});

final profileProvider = StateNotifierProvider<ProfileNotifier, AsyncValue<void>>((ref) {
  final repository = ref.watch(profileRepositoryProvider);
  return ProfileNotifier(repository, ref);
});

class ProfileNotifier extends StateNotifier<AsyncValue<void>> {
  final ProfileRepository _repository;
  final Ref _ref;

  ProfileNotifier(this._repository, this._ref) : super(const AsyncValue.data(null));

  Future<void> updateProfile({
    String? name,
    String? email,
    int? cityId,
    File? profilePhoto,
  }) async {
    state = const AsyncValue.loading();
    final response = await _repository.updateProfile(
      name: name,
      email: email,
      cityId: cityId,
      profilePhoto: profilePhoto,
    );
    
    if (response.isSuccess) {
      if (response.data != null) {
        // Here we could update the auth provider's user instance if needed.
        // For now, trigger a refresh of the profile in the auth provider.
        await _ref.read(authProvider.notifier).fetchProfile();
      }
      state = const AsyncValue.data(null);
    } else {
      state = AsyncValue.error(response.errorMessage ?? 'Failed to update profile', StackTrace.current);
    }
  }
}
