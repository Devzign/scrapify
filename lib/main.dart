import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/theme/app_theme.dart';
import 'core/utils/app_routes.dart';
import 'core/config/app_config.dart';
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
  runMain();
}

/// Shared bootstrap called by each flavor's entry point.
void runMain() {
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
          theme: AppTheme.lightTheme.copyWith(
            textTheme: GoogleFonts.interTextTheme(
              AppTheme.lightTheme.textTheme,
            ),
          ),
          routerConfig: AppRoutes.router,
          localizationsDelegates: context.localizationDelegates,
          supportedLocales: context.supportedLocales,
          locale: context.locale,
          builder: (context, child) {
            if (kIsWeb && MediaQuery.of(context).size.width > 800) {
              final double padding = MediaQuery.of(context).size.width * 0.20;
              return Container(
                color: Colors.grey.shade100,
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: padding),
                  child: ClipRect(child: child ?? const SizedBox.shrink()),
                ),
              );
            }
            return child ?? const SizedBox.shrink();
          },
        );
      },
    );
  }
}
