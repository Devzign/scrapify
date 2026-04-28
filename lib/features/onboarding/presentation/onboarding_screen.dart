import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/theme/app_color.dart';
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

      if (nextRoute == null) {
        return;
      }

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
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: EdgeInsets.fromLTRB(24.w, 12.h, 16.w, 0),
                child: Row(
                  children: [
                    Container(
                      height: 40.r,
                      width: 40.r,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14.r),
                        boxShadow: [
                          BoxShadow(
                            color: AppColor.deepNavy.withValues(alpha: 0.06),
                            blurRadius: 14,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: Image.asset(
                        'assets/images/Scrapify-app-icon.png',
                        fit: BoxFit.cover,
                      ),
                    ),
                    const Spacer(),
                    TextButton(
                      onPressed: viewModel.skip,
                      child: const Text(
                        'Skip',
                        style: TextStyle(
                          color: Color(0xFF64748B),
                          fontWeight: FontWeight.w800,
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
                    return OnboardingPageCard(page: viewModel.pages[index]);
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 32,
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
                    SizedBox(height: 24.h),
                    SizedBox(
                      width: double.infinity,
                      child: CustomButton(
                        text: isLastPage
                            ? 'Get Started  |  शुरू करें  →'
                            : 'Next  →',
                        onPressed: viewModel.handlePrimaryAction,
                        backgroundColor: AppColor.emeraldMoss,
                        textColor: Colors.white,
                        borderRadius: 16,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
