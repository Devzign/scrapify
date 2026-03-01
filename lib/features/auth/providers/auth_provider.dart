import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../../../../core/network/dio_client.dart';
import '../domain/models/user.dart';
import '../domain/repositories/auth_repository.dart';

/// 1. Provide the main Dio Client
final dioClientProvider = Provider<DioClient>((ref) {
  return DioClient();
});

/// 2. Provide the Authentication Repository
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final dioClient = ref.watch(dioClientProvider);
  return AuthRepository(dioClient);
});

/// 3. Provide the global AuthState (User Session)
class AuthNotifier extends StateNotifier<User?> {
  final AuthRepository _authRepository;

  AuthNotifier(this._authRepository) : super(null) {
    _checkInitialAuth();
  }

  /// Load session on startup
  Future<void> _checkInitialAuth() async {
    final token = await _authRepository.getToken();
    if (token != null) {
      // Token exists, let's fetch profile to ensure it's still valid
      final response = await _authRepository.fetchProfile();
      if (response.isSuccess) {
        state = response.data;
      } else {
        // Token might be expired or invalid
        await _authRepository.logout();
        state = null;
      }
    }
  }

  /// Verify OTP and update user state
  Future<bool> login(String phone, String otp) async {
    final response = await _authRepository.verifyOtp(phone: phone, otp: otp);
    if (response.isSuccess) {
      state = response.data;
      return true;
    }
    return false;
  }

  /// Wipe session completely
  Future<void> logout() async {
    await _authRepository.logout();
    state = null;
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, User?>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return AuthNotifier(repository);
});
