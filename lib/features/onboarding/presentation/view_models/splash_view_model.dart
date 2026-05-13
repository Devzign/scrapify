import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../../../../core/services/location_service.dart';
import '../../../../core/storage/app_preferences.dart';
import '../../../../core/utils/app_routes.dart';
import '../../../../core/utils/role_route_resolver.dart';
import 'package:scrapify/features/settings/providers/settings_provider.dart';
import 'splash_view_state.dart';

final splashViewModelProvider =
    StateNotifierProvider<SplashViewModel, SplashViewState>((ref) {
      return SplashViewModel(ref);
    });

class SplashViewModel extends StateNotifier<SplashViewState> {
  final Ref _ref;
  bool _isLoading = false;

  SplashViewModel(this._ref) : super(const SplashViewState());

  Future<void> initialize() async {
    if (_isLoading || state.hasResolvedRoute) {
      return;
    }

    _isLoading = true;

    // Prompt location permission early and cache it for login/app-settings payloads.
    await LocationService().getBestAvailableLocation();

    // 1. Get Settings
    final appSettings = _ref.read(settingsProvider);

    // 2. Routing logic
    final preferences = _ref.read(appPreferencesProvider);
    final token = await preferences.getAuthToken();
    final hasSeenOnboarding = await preferences.getHasSeenOnboarding();

    final nextRoute = token != null && token.isNotEmpty
        ? RoleRouteResolver.resolve(await preferences.getPrimaryUserRole())
        : hasSeenOnboarding
        ? AppRoutes.language
        : AppRoutes.onboarding;

    state = state.copyWith(
      hasResolvedRoute: true,
      nextRoute: nextRoute,
      targetLanguage: appSettings.language,
    );
  }

  void clearNavigation() {
    state = state.copyWith(clearNextRoute: true);
  }
}
