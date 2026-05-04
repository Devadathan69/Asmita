import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../l10n/strings.dart';

final languageProvider =
    AsyncNotifierProvider<LanguageNotifier, AppLanguage>(LanguageNotifier.new);

class LanguageNotifier extends AsyncNotifier<AppLanguage> {
  static const _key = 'asmita_language';

  @override
  Future<AppLanguage> build() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString(_key);
    return AppLanguage.values.firstWhere(
      (language) => language.name == saved,
      orElse: () => AppLanguage.english,
    );
  }

  Future<void> setLanguage(AppLanguage language) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, language.name);
    state = AsyncData(language);
  }
}
