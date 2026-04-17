import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:scrapify/features/settings/providers/settings_provider.dart';
import 'language_selection_view_state.dart';

final languageSelectionViewModelProvider =
    StateNotifierProvider.autoDispose<LanguageSelectionViewModel, LanguageSelectionViewState>(
  (ref) {
    return LanguageSelectionViewModel(ref);
  },
);

class LanguageSelectionViewModel extends StateNotifier<LanguageSelectionViewState> {
  final Ref _ref;
  
  LanguageSelectionViewModel(this._ref) : super(const LanguageSelectionViewState());

  void selectLanguage(String languageCode) {
    state = state.copyWith(selectedLanguage: languageCode);
  }

  Future<void> confirmLanguage() async {
    final languageCode = state.selectedLanguage;
    await _ref.read(settingsProvider.notifier).updateLanguage(languageCode);
  }
}
