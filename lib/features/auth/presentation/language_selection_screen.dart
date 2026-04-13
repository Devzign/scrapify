import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';

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
      backgroundColor: AppTheme.backgroundLight,
      body: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.dark,
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(height: 20.h),
                Container(
                  height: 120.w,
                  width: 120.w,
                  decoration: const BoxDecoration(
                    color: AppTheme.primaryLight,
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: FaIcon(
                    FontAwesomeIcons.recycle,
                    color: AppTheme.primaryColor,
                    size: 48.sp,
                  ),
                ),
                SizedBox(height: 16.h),
                Text(
                  'Scrapify',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                SizedBox(height: 32.h),
                Text(
                  'language.title'.tr(),
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontSize: 22),
                ),
                Text(
                  'भाषा चुनें',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontSize: 20,
                    color: AppTheme.textSecondary,
                    fontWeight: FontWeight.normal,
                  ),
                ),
                SizedBox(height: 16.h),
                Text(
                  'language.subtitle'.tr(),
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(color: AppTheme.textSecondary),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 32.h),
                LanguageOptionCard(
                  iconLabel: 'A',
                  title: 'English',
                  subtitle: 'English',
                  isSelected: state.selectedLanguage == 'en',
                  onTap: () => viewModel.selectLanguage('en'),
                ),
                SizedBox(height: 16.h),
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
                    await viewModel.confirmLanguage();
                    if (context.mounted) {
                      await context.setLocale(Locale(state.selectedLanguage));
                      context.push(AppRoutes.role);
                    }
                  },
                  text: "${'common.continue'.tr(gender: 'en')}  /  आगे बढ़ें",
                  trailing: const FaIcon(FontAwesomeIcons.arrowRight, size: 20),
                ),
                SizedBox(height: 24.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const FaIcon(
                      FontAwesomeIcons.circleQuestion,
                      color: AppTheme.primaryColor,
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${'common.needHelp'.tr()} / मदद चाहिए?',
                      style: const TextStyle(
                        color: AppTheme.primaryColor,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
