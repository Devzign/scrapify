import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/theme/app_color.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/custom_button.dart';
import 'view_models/onboarding_view_model.dart';
import 'view_models/onboarding_view_state.dart';
import 'widgets/onboarding_page_card.dart';
import 'widgets/onboarding_page_indicator.dart';

class OnboardingScreen extends ConsumerWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen<OnboardingViewState>(onboardingViewModelProvider, (_, next) {
      final nextRoute = next.nextRoute;
      if (nextRoute == null) return;
      ref.read(onboardingViewModelProvider.notifier).clearNavigation();
      context.go(nextRoute);
    });

    final state = ref.watch(onboardingViewModelProvider);
    final viewModel = ref.read(onboardingViewModelProvider.notifier);
    final isLastPage = state.currentPage == viewModel.pages.length - 1;

    return Scaffold(
      backgroundColor: AppColor.onboardingBackground,
      body: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.dark,
        child: Stack(
          children: [
            // Subtle sage glow at top — eco "breath" behind the illustration.
            Positioned(
              top: -120,
              left: -60,
              right: -60,
              child: IgnorePointer(
                child: Container(
                  height: 380,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        AppColor.primary.withValues(alpha: 0.18),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),
            ),
            SafeArea(
              child: Column(
                children: [
                  Padding(
                    padding: EdgeInsets.fromLTRB(24.w, 12.h, 16.w, 0),
                    child: Row(
                      children: [
                        Container(
                          height: 44.r,
                          width: 44.r,
                          decoration: BoxDecoration(
                            color: AppColor.surface,
                            borderRadius: BorderRadius.circular(14.r),
                            border:
                                Border.all(color: AppColor.cardBorder),
                            boxShadow: AppTheme.e1,
                          ),
                          clipBehavior: Clip.antiAlias,
                          child: Padding(
                            padding: EdgeInsets.all(6.r),
                            child: Image.asset(
                              'assets/images/Scrapify-app-icon.png',
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),
                        const Spacer(),
                        TextButton(
                          onPressed: viewModel.skip,
                          style: TextButton.styleFrom(
                            foregroundColor: AppColor.textSecondary,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 10,
                            ),
                          ),
                          child: const Text(
                            'Skip',
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 15,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: PageView.builder(
                      controller: viewModel.pageController,
                      itemCount: viewModel.pages.length,
                      onPageChanged: viewModel.onPageChanged,
                      itemBuilder: (context, index) {
                        return OnboardingPageCard(
                          page: viewModel.pages[index],
                        );
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 28,
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(
                            viewModel.pages.length,
                            (index) => OnboardingPageIndicator(
                              isSelected: state.currentPage == index,
                            ),
                          ),
                        ),
                        SizedBox(height: 22.h),
                        CustomButton(
                          text: isLastPage
                              ? 'Get Started  |  शुरू करें  →'
                              : 'Next  →',
                          onPressed: viewModel.handlePrimaryAction,
                          variant: AppButtonVariant.primary,
                          fontWeight: FontWeight.w700,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
