import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'core/theme/app_theme.dart';
import 'core/utils/app_routes.dart';
import 'core/storage/app_preferences.dart';
import 'core/utils/role_route_resolver.dart';
import 'core/config/app_config.dart';
import 'core/services/fcm_service.dart';
import 'core/utils/app_logger.dart';
import 'firebase_options.dart';
import 'package:easy_localization/easy_localization.dart';

/// Called directly only in development/fallback scenarios.
/// Flavor-specific entry points (main_dev, main_staging, main_production)
/// call [runMain] after setting up [AppConfig].
void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // must be first
  // Fallback: if run without a flavor entry point, default to dev.
  if (!AppConfig.isInitialized) {
    AppConfig.initialize(AppFlavor.dev);
  }
  await EasyLocalization.ensureInitialized();
  await initializeAppServices();
  final initialLocation = await resolveInitialLocation();
  runMain(initialLocation: initialLocation);
}

Future<void> initializeAppServices() async {
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    await FcmService.instance.initializeMessaging();
    AppLogger.info('Firebase initialized successfully');
  } catch (e) {
    // Keep app running even when Firebase is not configured yet.
    AppLogger.error('Firebase initialization skipped/failed', error: e);
  }
}

/// Shared bootstrap called by each flavor's entry point.
Future<String> resolveInitialLocation() async {
  final preferences = AppPreferences();
  final token = await preferences.getAuthToken();
  final hasSeenOnboarding = await preferences.getHasSeenOnboarding();

  if (token != null && token.isNotEmpty) {
    final primaryRole = await preferences.getPrimaryUserRole();
    return RoleRouteResolver.resolve(primaryRole);
  }

  return hasSeenOnboarding ? AppRoutes.language : AppRoutes.onboarding;
}

/// Shared bootstrap called by each flavor's entry point.
void runMain({required String initialLocation}) {
  AppRoutes.initializeRouter(initialLocation: initialLocation);

  runApp(
    ProviderScope(
      child: EasyLocalization(
        supportedLocales: const [Locale('en'), Locale('hi')],
        path: 'assets/translations',
        fallbackLocale: const Locale('en'),
        child: const ScrapifyApp(),
      ),
    ),
  );
}

class ScrapifyApp extends StatelessWidget {
  const ScrapifyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final config = AppConfig.instance;
    return ScreenUtilInit(
      designSize: const Size(375, 812),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return MaterialApp.router(
          title: config.appName,
          debugShowCheckedModeBanner: config.isDev,
          theme: AppTheme.lightTheme,
          routerConfig: AppRoutes.router,
          localizationsDelegates: context.localizationDelegates,
          supportedLocales: context.supportedLocales,
          locale: context.locale,
          builder: (context, child) {
            final appSurface = DecoratedBox(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFFEFF6F1),
                    Color(0xFFF7FBF8),
                    Color(0xFFEAF3ED),
                  ],
                ),
              ),
              child: child ?? const SizedBox.shrink(),
            );
            if (kIsWeb && MediaQuery.of(context).size.width > 800) {
              final double padding = MediaQuery.of(context).size.width * 0.20;
              return Container(
                color: Colors.grey.shade100,
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: padding),
                  child: ClipRect(child: appSurface),
                ),
              );
            }
            return appSurface;
          },
        );
      },
    );
  }
}
