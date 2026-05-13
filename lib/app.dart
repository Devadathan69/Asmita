import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'l10n/strings.dart';
import 'providers/language_provider.dart';
import 'router/app_router.dart';
import 'theme/app_theme.dart';

class AsmitaApp extends ConsumerWidget {
  const AsmitaApp({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final language = ref.watch(languageProvider).value ?? AppLanguage.english;
    return MaterialApp.router(
      key: ValueKey(language.name),
      title: 'Asmita',
      debugShowCheckedModeBanner: false,
      locale: _localeFor(language),
      supportedLocales: const [
        Locale('en'),
        Locale('ml'),
        Locale('hi'),
      ],
      localizationsDelegates: GlobalMaterialLocalizations.delegates,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      routerConfig: appRouter,
    );
  }

  Locale _localeFor(AppLanguage language) => switch (language) {
        AppLanguage.malayalam => const Locale('ml'),
        AppLanguage.hindi => const Locale('hi'),
        AppLanguage.english || AppLanguage.manglish => const Locale('en'),
      };
}
