import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_color.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/app_routes.dart';
import '../../../core/widgets/custom_button.dart';
import 'view_models/language_selection_view_model.dart';
import 'widgets/language_option_card.dart';

class LanguageSelectionScreen extends ConsumerWidget {
  const LanguageSelectionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(languageSelectionViewModelProvider);
    final viewModel = ref.read(languageSelectionViewModelProvider.notifier);

    return Scaffold(
      backgroundColor: AppColor.backgroundLight,
      body: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.dark,
        child: Stack(
          children: [
            Positioned(
              top: -120,
              left: -80,
              right: -80,
              child: IgnorePointer(
                child: Container(
                  height: 360,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        AppColor.primary.withValues(alpha: 0.16),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),
            ),
            SafeArea(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(height: 16.h),
                    Image.asset(
                      'assets/images/Scrapify-logo-main.png',
                      width: 240.w,
                      fit: BoxFit.contain,
                    ),
                    SizedBox(height: 28.h),
                    Text(
                      'language.title'.tr(),
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        color: AppColor.deepNavy,
                        height: 1.15,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'भाषा चुनें',
                      style: TextStyle(
                        fontSize: 20,
                        color: AppColor.primary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    SizedBox(height: 12.h),
                    Text(
                      'language.subtitle'.tr(),
                      style: const TextStyle(
                        color: AppColor.textSecondary,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        height: 1.45,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 28.h),
                    LanguageOptionCard(
                      iconLabel: 'A',
                      title: 'English',
                      subtitle: 'English',
                      isSelected: state.selectedLanguage == 'en',
                      onTap: () => viewModel.selectLanguage('en'),
                    ),
                    SizedBox(height: 14.h),
                    LanguageOptionCard(
                      iconLabel: 'अ',
                      title: 'हिंदी',
                      subtitle: 'Hindi',
                      isSelected: state.selectedLanguage == 'hi',
                      onTap: () => viewModel.selectLanguage('hi'),
                    ),
                    const Spacer(),
                    CustomButton(
                      onPressed: () async {
                        final selectedLanguage = ref
                            .read(languageSelectionViewModelProvider)
                            .selectedLanguage;
                        await context.setLocale(Locale(selectedLanguage));
                        if (!context.mounted) return;
                        viewModel.confirmLanguage();
                        context.go(AppRoutes.role);
                      },
                      text:
                          "${'common.continue'.tr(gender: 'en')}  /  आगे बढ़ें",
                      trailing: const FaIcon(
                        FontAwesomeIcons.arrowRight,
                        size: 18,
                      ),
                    ),
                    SizedBox(height: 18.h),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: AppColor.primarySurface,
                        borderRadius:
                            BorderRadius.circular(AppTheme.radiusPill),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const FaIcon(
                            FontAwesomeIcons.circleQuestion,
                            color: AppColor.primary,
                            size: 16,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '${'common.needHelp'.tr()} / मदद चाहिए?',
                            style: const TextStyle(
                              color: AppColor.primaryDark,
                              fontWeight: FontWeight.w700,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
