import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../../../core/storage/app_preferences.dart';
import '../../../../core/utils/app_routes.dart';
import 'onboarding_view_state.dart';

typedef OnboardingPageContent = ({
  String titleEn,
  String titleHi,
  String description,
  IconData icon,
});

const List<OnboardingPageContent> onboardingPages = [
  (
    titleEn: 'Sell from Home',
    titleHi: 'घर बैठे सामान बेचें',
    description:
        'Sell your scrap and e-waste easily without going anywhere. Schedule a pickup in just a few clicks.',
    icon: FontAwesomeIcons.boxOpen,
  ),
  (
    titleEn: 'Best Prices',
    titleHi: 'सही दाम पाएँ',
    description:
        'Get transparent and fair market prices for your metal and electronic waste.',
    icon: FontAwesomeIcons.moneyBillTrendUp,
  ),
  (
    titleEn: 'Instant Payment',
    titleHi: 'तुरंत पैसे पाएँ',
    description:
        'Receive money directly in your bank account after the pickup.',
    icon: FontAwesomeIcons.buildingColumns,
  ),
];

final onboardingViewModelProvider =
    StateNotifierProvider.autoDispose<OnboardingViewModel, OnboardingViewState>(
      (ref) {
        return OnboardingViewModel(ref);
      },
    );

class OnboardingViewModel extends StateNotifier<OnboardingViewState> {
  final Ref _ref;
  late final PageController pageController;

  OnboardingViewModel(this._ref) : super(const OnboardingViewState()) {
    pageController = PageController();
    _ref.onDispose(pageController.dispose);
  }

  List<OnboardingPageContent> get pages {
    return onboardingPages;
  }

  void onPageChanged(int index) {
    state = state.copyWith(currentPage: index);
  }

  Future<void> handlePrimaryAction() async {
    if (state.currentPage == pages.length - 1) {
      await _completeOnboarding();
      return;
    }

    await pageController.nextPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  Future<void> skip() async {
    await _completeOnboarding();
  }

  Future<void> _completeOnboarding() async {
    await _ref.read(appPreferencesProvider).setHasSeenOnboarding(true);
    state = state.copyWith(nextRoute: AppRoutes.language);
  }

  void clearNavigation() {
    state = state.copyWith(clearNextRoute: true);
  }
}
