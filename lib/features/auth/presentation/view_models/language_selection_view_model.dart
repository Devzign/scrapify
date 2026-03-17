import 'package:flutter_riverpod/legacy.dart';

import 'language_selection_view_state.dart';

final languageSelectionViewModelProvider =
    StateNotifierProvider.autoDispose<
      LanguageSelectionViewModel,
      LanguageSelectionViewState
    >((ref) {
      return LanguageSelectionViewModel();
    });

class LanguageSelectionViewModel
    extends StateNotifier<LanguageSelectionViewState> {
  LanguageSelectionViewModel() : super(const LanguageSelectionViewState());

  void selectLanguage(String languageCode) {
    state = state.copyWith(selectedLanguage: languageCode);
  }
}
