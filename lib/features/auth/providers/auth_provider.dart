import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../../../../core/network/dio_client.dart';
import '../../../core/session/session_controller.dart';
import '../../../core/storage/app_preferences.dart';
import '../domain/models/user.dart';
import '../domain/repositories/auth_repository.dart';

/// 1. Provide the main Dio Client
final dioClientProvider = Provider<DioClient>((ref) {
  return DioClient();
});

/// 2. Provide the Authentication Repository
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final dioClient = ref.watch(dioClientProvider);
  final preferences = ref.watch(appPreferencesProvider);
  return AuthRepository(dioClient, preferences);
});

/// 3. Provide the global AuthState (User Session)
class AuthNotifier extends StateNotifier<User?> {
  final AuthRepository _authRepository;
  int _lastLogoutVersion = SessionController.instance.logoutVersion;

  AuthNotifier(this._authRepository) : super(null) {
    SessionController.instance.addListener(_handleForcedLogout);
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

  /// Explicitly fetch profile and update session
  Future<void> fetchProfile() async {
    final response = await _authRepository.fetchProfile();
    if (response.isSuccess) {
      state = response.data;
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

  void _handleForcedLogout() {
    final logoutVersion = SessionController.instance.logoutVersion;
    if (logoutVersion == _lastLogoutVersion) {
      return;
    }

    _lastLogoutVersion = logoutVersion;
    state = null;
  }

  @override
  void dispose() {
    SessionController.instance.removeListener(_handleForcedLogout);
    super.dispose();
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, User?>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return AuthNotifier(repository);
});
