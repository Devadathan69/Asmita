import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../config/build_config.dart';
import '../../l10n/strings.dart';
import '../../providers/language_provider.dart';
import '../../theme/app_colors.dart';
import '../../widgets/common/animated_icon_badge.dart';
import '../../widgets/common/asmita_card.dart';
import '../../widgets/common/asmita_logo_mark.dart';
import '../../widgets/common/gradient_background.dart';
import '../../widgets/common/privacy_badge.dart';

class ModeSelectionScreen extends ConsumerWidget {
  const ModeSelectionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final language = ref.watch(languageProvider).value ?? AppLanguage.english;
    String t(String key) => Strings.t(key, language);

    return Scaffold(
      body: GradientBackground(
        child: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 520),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: ListView(
                  padding: EdgeInsets.zero,
                  children: [
                    const SizedBox(height: 22),
                    const Center(
                      child: AsmitaLogoMark(size: 112, heroTag: 'asmita-logo'),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      t('app_name'),
                      style: Theme.of(context)
                          .textTheme
                          .displaySmall
                          ?.copyWith(color: AppColors.primary),
                      textAlign: TextAlign.center,
                    ),
                    Text(
                      t('wellness_companion'),
                      style: Theme.of(context).textTheme.bodyLarge,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    Center(child: PrivacyBadge(label: t('works_offline'))),
                    const SizedBox(height: 28),
                    _ModeCard(
                      icon: Icons.calendar_month_rounded,
                      title: t('personal_tracking'),
                      subtitle: t('personal_tracking_subtitle'),
                      color: AppColors.secondary,
                      onTap: () => context.go('/onboarding'),
                    ),
                    if (BuildConfig.showAshaMode) ...[
                      const SizedBox(height: 16),
                      _ModeCard(
                        icon: Icons.health_and_safety_rounded,
                        title: t('asha_mode'),
                        subtitle: t('asha_worker_subtitle'),
                        color: AppColors.primary,
                        onTap: () => context.go('/asha-coming-soon'),
                      ),
                    ],
                    const SizedBox(height: 30),
                    Text(
                      t('select_language'),
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            letterSpacing: 2,
                            fontWeight: FontWeight.w800,
                          ),
                    ),
                    const SizedBox(height: 14),
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      alignment: WrapAlignment.center,
                      children: [
                        _LanguagePill(
                          'English',
                          selected: language == AppLanguage.english,
                          onTap: () => ref
                              .read(languageProvider.notifier)
                              .setLanguage(AppLanguage.english),
                        ),
                        _LanguagePill(
                          'മലയാളം',
                          selected: language == AppLanguage.malayalam,
                          onTap: () => ref
                              .read(languageProvider.notifier)
                              .setLanguage(AppLanguage.malayalam),
                        ),
                        _LanguagePill(
                          'हिंदी',
                          selected: language == AppLanguage.hindi,
                          onTap: () => ref
                              .read(languageProvider.notifier)
                              .setLanguage(AppLanguage.hindi),
                        ),
                        _LanguagePill(
                          'Manglish',
                          selected: language == AppLanguage.manglish,
                          onTap: () => ref
                              .read(languageProvider.notifier)
                              .setLanguage(AppLanguage.manglish),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                  ],
                ).animate().fadeIn(duration: 500.ms).slideY(begin: .04),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ModeCard extends StatelessWidget {
  const _ModeCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return AsmitaCard(
      onTap: onTap,
      accent: color,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
      child: Column(
        children: [
          AnimatedIconBadge(icon: icon, color: color, size: 82),
          const SizedBox(height: 18),
          Text(
            title,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: color,
                  fontWeight: FontWeight.w800,
                ),
          ),
          const SizedBox(height: 8),
          Text(subtitle, textAlign: TextAlign.center),
        ],
      ),
    );
  }
}

class _LanguagePill extends StatelessWidget {
  const _LanguagePill(this.label, {required this.onTap, this.selected = false});
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(999),
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary : Colors.white,
          borderRadius: BorderRadius.circular(999),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withOpacity(selected ? .18 : .06),
              blurRadius: 18,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? Colors.white : AppColors.textPrimary,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}
