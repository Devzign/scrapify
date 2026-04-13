import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'view_models/splash_view_model.dart';
import 'view_models/splash_view_state.dart';
import 'widgets/splash_content.dart';

class SplashScreen extends ConsumerWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen<SplashViewState>(splashViewModelProvider, (previous, next) {
      final nextRoute = next.nextRoute;
      final targetLanguage = next.targetLanguage;

      if (targetLanguage != null &&
          targetLanguage != context.locale.languageCode) {
        context.setLocale(Locale(targetLanguage));
      }

      if (nextRoute == null) {
        return;
      }

      ref.read(splashViewModelProvider.notifier).clearNavigation();
      context.go(nextRoute);
    });

    final state = ref.watch(splashViewModelProvider);

    if (!state.hasResolvedRoute) {
      Future<void>.microtask(
        ref.read(splashViewModelProvider.notifier).initialize,
      );
    }

    return const SplashContent();
  }
}
