class LanguageSelectionViewState {
  final String selectedLanguage;

  const LanguageSelectionViewState({this.selectedLanguage = 'en'});

  LanguageSelectionViewState copyWith({String? selectedLanguage}) {
    return LanguageSelectionViewState(
      selectedLanguage: selectedLanguage ?? this.selectedLanguage,
    );
  }
}
