class OnboardingViewState {
  final int currentPage;
  final String? nextRoute;

  const OnboardingViewState({this.currentPage = 0, this.nextRoute});

  OnboardingViewState copyWith({
    int? currentPage,
    String? nextRoute,
    bool clearNextRoute = false,
  }) {
    return OnboardingViewState(
      currentPage: currentPage ?? this.currentPage,
      nextRoute: clearNextRoute ? null : nextRoute ?? this.nextRoute,
    );
  }
}
