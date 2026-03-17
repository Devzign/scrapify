class SplashViewState {
  final bool hasResolvedRoute;
  final String? nextRoute;

  const SplashViewState({this.hasResolvedRoute = false, this.nextRoute});

  SplashViewState copyWith({
    bool? hasResolvedRoute,
    String? nextRoute,
    bool clearNextRoute = false,
  }) {
    return SplashViewState(
      hasResolvedRoute: hasResolvedRoute ?? this.hasResolvedRoute,
      nextRoute: clearNextRoute ? null : nextRoute ?? this.nextRoute,
    );
  }
}
