import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/theme/app_theme.dart';
import 'core/utils/app_routes.dart';

import 'package:easy_localization/easy_localization.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();
  
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
    // Set up ScreenUtil for responsive metrics
    // using a generalized base mobile design size (e.g. 375x812 iPhone 11 Pro)
    return ScreenUtilInit(
      designSize: const Size(375, 812),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return MaterialApp.router(
          title: 'Scrapify',
          debugShowCheckedModeBanner: false,
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
            // Apply 20% horizontal padding on desktop web browsers
            if (kIsWeb && MediaQuery.of(context).size.width > 800) {
              final double padding = MediaQuery.of(context).size.width * 0.20;
              return Container(
                color: Colors.grey.shade100, // Background color for the empty space
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: padding),
                  child: ClipRect(
                    child: child ?? const SizedBox.shrink(),
                  ),
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
