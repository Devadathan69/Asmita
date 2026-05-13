import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/cycle_provider.dart';
import '../../providers/language_provider.dart';
import '../../providers/log_provider.dart';
import '../../providers/personal_tracking_mode_provider.dart';
import '../../providers/user_profile_provider.dart';
import '../../l10n/strings.dart';
import '../../theme/app_colors.dart';
import '../../utils/cycle_calculator.dart';
import '../../widgets/asmita/energy_suggestion_card.dart';
import '../../widgets/asmita/home_music_player_card.dart';
import '../../widgets/common/asmita_card.dart';
import '../../widgets/common/asmita_screen_header.dart';
import '../../widgets/common/gradient_background.dart';
import '../../widgets/common/privacy_badge.dart';
import 'widgets/cycle_alert_banner.dart';
import 'widgets/cycle_ring_widget.dart';
import 'widgets/myth_fact_card.dart';
import 'widgets/phase_tip_card.dart';
import 'widgets/pregnancy_home_view.dart';
import 'widgets/quick_log_card.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(userProfileProvider).value;
    final mode = ref.watch(personalTrackingModeProvider);
    final language = ref.watch(languageProvider).value ?? AppLanguage.english;
    final logs = ref.watch(logProvider).value ?? const [];
    final todayLog =
        logs.where((log) => _sameDay(log.date, DateTime.now())).firstOrNull;
    String t(String key) => Strings.t(key, language);
    final cycles = ref.watch(cycleProvider).value ?? const [];
    final lastStart = cycles.isEmpty ? DateTime.now() : cycles.last.startDate;
    final info = CycleCalculator.infoFor(
      DateTime.now(),
      lastStart,
      cycleLength: profile?.avgCycleLength ?? 28,
      periodDuration: profile?.periodDuration ?? 5,
    );
    return Scaffold(
      body: GradientBackground(
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 132),
            children: [
              if (mode == PersonalTrackingMode.pregnancy &&
                  profile != null) ...[
                PregnancyHomeView(profile: profile, language: language),
                const SizedBox(height: 22),
                const HomeMusicPlayerCard(),
                if (todayLog?.energyLevel != null) ...[
                  const SizedBox(height: 22),
                  EnergySuggestionCard(
                    energyLevel: todayLog?.energyLevel,
                    isPregnant: true,
                    language: language,
                    painLevel: todayLog?.painIntensity ?? 0,
                    selectedSymptoms: todayLog?.symptoms ?? const [],
                  ),
                ],
                const SizedBox(height: 24),
                const MythFactCard(),
              ] else ...[
                AsmitaScreenHeader(
                  title: 'Asmita',
                  subtitle: 'Your private cycle companion',
                  trailing: IconButton.filledTonal(
                    onPressed: () => context.push('/insights'),
                    icon: const Icon(Icons.notifications_none_rounded),
                  ),
                ),
                const SizedBox(height: 22),
                const PrivacyBadge(label: 'Works offline'),
                const SizedBox(height: 24),
                if (profile?.needsProfileCompletion == true) ...[
                  AsmitaCard(
                    accent: AppColors.success,
                    onTap: () => context.go('/profile'),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.health_and_safety_rounded,
                          color: AppColors.success,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                t('complete_health_profile'),
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                              Text(t('complete_health_profile_body')),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 22),
                ],
                AsmitaCard(
                  accent: info.phase.color,
                  padding: const EdgeInsets.fromLTRB(18, 22, 18, 22),
                  child: Column(
                    children: [
                      CycleRingWidget(info: info),
                      const SizedBox(height: 18),
                      Row(
                        children: [
                          _StatusBadge(
                            icon: Icons.water_drop_rounded,
                            title: 'Period expected',
                            value: 'in ${info.daysUntilPeriod} days',
                            color: AppColors.secondary,
                          ),
                          const SizedBox(width: 10),
                          _StatusBadge(
                            icon: Icons.auto_awesome_rounded,
                            title: 'Current phase',
                            value: info.phase.label,
                            color: info.phase.color,
                          ),
                        ],
                      ),
                    ],
                  ),
                ).animate().fadeIn(duration: 420.ms).slideY(begin: .05),
                const SizedBox(height: 24),
                const HomeMusicPlayerCard(),
                const SizedBox(height: 22),
                EnergySuggestionCard(
                  energyLevel: todayLog?.energyLevel,
                  isPregnant: false,
                  language: language,
                  painLevel: todayLog?.painIntensity ?? 0,
                  selectedSymptoms: todayLog?.symptoms ?? const [],
                ),
                if ((todayLog?.energyLevel ?? 5) <= 2)
                  const SizedBox(height: 22),
                CycleAlertBanner(
                  cycleLengths: cycles
                      .map((e) => e.cycleLength)
                      .whereType<int>()
                      .toList(),
                ),
                const SizedBox(height: 20),
                QuickLogCard(onTap: () => context.go('/log')),
                const SizedBox(height: 20),
                PhaseTipCard(phase: info.phase),
                const SizedBox(height: 24),
                Text(
                  "Explore",
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: AsmitaCard(
                        accent: info.phase.color,
                        onTap: () => context.push('/music'),
                        child: _HomeAction(
                          icon: Icons.music_note_rounded,
                          label: 'Cycle Music',
                          color: info.phase.color,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: AsmitaCard(
                        accent: AppColors.accent,
                        onTap: () => context.push('/napkin'),
                        child: const _HomeAction(
                          icon: Icons.storefront_rounded,
                          label: 'Napkin Finder',
                          color: AppColors.accent,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                const MythFactCard(),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

bool _sameDay(DateTime a, DateTime b) =>
    a.year == b.year && a.month == b.month && a.day == b.day;

extension _FirstOrNull<T> on Iterable<T> {
  T? get firstOrNull => isEmpty ? null : first;
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({
    required this.icon,
    required this.title,
    required this.value,
    required this.color,
  });

  final IconData icon;
  final String title;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: color.withOpacity(.1),
          borderRadius: BorderRadius.circular(22),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color),
            const SizedBox(height: 8),
            Text(title, style: Theme.of(context).textTheme.bodySmall),
            Text(
              value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontWeight: FontWeight.w800),
            ),
          ],
        ),
      ),
    );
  }
}

class _HomeAction extends StatelessWidget {
  const _HomeAction({
    required this.icon,
    required this.label,
    required this.color,
  });
  final IconData icon;
  final String label;
  final Color color;
  @override
  Widget build(BuildContext context) {
    final reduceMotion = MediaQuery.of(context).accessibleNavigation;
    final badge = Container(
      width: 54,
      height: 54,
      decoration: BoxDecoration(
        color: color.withOpacity(.13),
        shape: BoxShape.circle,
      ),
      child: Icon(icon, color: color),
    );
    return Column(
      children: [
        reduceMotion
            ? badge
            : badge
                .animate(
                    onPlay: (controller) => controller.repeat(reverse: true))
                .moveY(begin: 0, end: -3, duration: 1600.ms),
        const SizedBox(height: 8),
        Text(
          label,
          textAlign: TextAlign.center,
          style: const TextStyle(fontWeight: FontWeight.w800),
        ),
      ],
    );
  }
}
