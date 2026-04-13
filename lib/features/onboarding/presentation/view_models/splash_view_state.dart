class SplashViewState {
  final bool hasResolvedRoute;
  final String? nextRoute;
  final String? targetLanguage;

  const SplashViewState({
    this.hasResolvedRoute = false,
    this.nextRoute,
    this.targetLanguage,
  });

  SplashViewState copyWith({
    bool? hasResolvedRoute,
    String? nextRoute,
    String? targetLanguage,
    bool clearNextRoute = false,
  }) {
    return SplashViewState(
      hasResolvedRoute: hasResolvedRoute ?? this.hasResolvedRoute,
      nextRoute: clearNextRoute ? null : nextRoute ?? this.nextRoute,
      targetLanguage: targetLanguage ?? this.targetLanguage,
    );
  }
}
