import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../l10n/strings.dart';
import '../../providers/cycle_provider.dart';
import '../../providers/language_provider.dart';
import '../../providers/log_provider.dart';
import '../../providers/personal_tracking_mode_provider.dart';
import '../../providers/user_profile_provider.dart';
import '../../theme/app_colors.dart';
import '../../utils/irregularity_detector.dart';
import '../../widgets/common/animated_icon_badge.dart';
import '../../widgets/common/asmita_card.dart';
import '../../widgets/common/asmita_screen_header.dart';
import '../../widgets/common/gradient_background.dart';

class InsightsScreen extends ConsumerWidget {
  const InsightsScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mode = ref.watch(personalTrackingModeProvider);
    final language = ref.watch(languageProvider).value ?? AppLanguage.english;
    if (mode == PersonalTrackingMode.pregnancy) {
      return _PregnancyInsights(language: language);
    }
    final lengths = (ref.watch(cycleProvider).value ?? const [])
        .map((e) => e.cycleLength)
        .whereType<int>()
        .toList();
    final result = IrregularityDetector.analyze(lengths);
    final chartSpots = lengths.isEmpty
        ? const [
            FlSpot(0, 28),
            FlSpot(1, 27),
            FlSpot(2, 29),
            FlSpot(3, 28),
            FlSpot(4, 30),
            FlSpot(5, 28),
          ]
        : [
            for (var i = 0; i < lengths.length; i++)
              FlSpot(i.toDouble(), lengths[i].toDouble()),
          ];
    return Scaffold(
      body: GradientBackground(
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(18, 12, 18, 112),
            children: [
              const AsmitaScreenHeader(
                title: 'Insights',
                subtitle: 'Personal analysis & trends',
              ),
              const SizedBox(height: 20),
              AsmitaCard(
                accent: result.isWorthDiscussing
                    ? AppColors.accent
                    : AppColors.primary,
                child: Row(
                  children: [
                    AnimatedIconBadge(
                      icon: Icons.trending_up_rounded,
                      color: result.isWorthDiscussing
                          ? AppColors.accent
                          : AppColors.primary,
                      size: 64,
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            result.isWorthDiscussing
                                ? 'Cycle pattern worth discussing'
                                : 'Your cycle pattern looks steady',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Based on locally stored cycle data',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              AsmitaCard(
                accent: AppColors.primary,
                child: ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Regularity score'),
                  subtitle: Text(
                    result.isWorthDiscussing
                        ? 'Worth discussing with a doctor or ASHA worker'
                        : 'Looking steady with available data',
                  ),
                  trailing: Text(
                    '${result.score}',
                    style: Theme.of(context).textTheme.displaySmall,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 270,
                child: AsmitaCard(
                  accent: AppColors.primary,
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            'Cycle length variation',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const Spacer(),
                          const _TinyPill('Last 6 cycles'),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Expanded(
                        child: LineChart(
                          LineChartData(
                            gridData: FlGridData(
                              drawVerticalLine: false,
                              getDrawingHorizontalLine: (value) => FlLine(
                                color: AppColors.primary.withOpacity(.08),
                                strokeWidth: 1,
                              ),
                            ),
                            borderData: FlBorderData(show: false),
                            titlesData: const FlTitlesData(
                              topTitles: AxisTitles(
                                sideTitles: SideTitles(showTitles: false),
                              ),
                              rightTitles: AxisTitles(
                                sideTitles: SideTitles(showTitles: false),
                              ),
                            ),
                            lineBarsData: [
                              LineChartBarData(
                                spots: chartSpots,
                                isCurved: true,
                                color: AppColors.primary,
                                barWidth: 5,
                                belowBarData: BarAreaData(
                                  show: true,
                                  color: AppColors.primary.withOpacity(.08),
                                ),
                                dotData: const FlDotData(show: true),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              AsmitaCard(
                accent: AppColors.secondary,
                child: Row(
                  children: const [
                    CircleAvatar(
                      backgroundColor: AppColors.coralPale,
                      child: Icon(
                        Icons.favorite_rounded,
                        color: AppColors.secondary,
                      ),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text('Most pain: lower back during menstruation'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              FilledButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.lock_outline_rounded),
                label: const Text('Export encrypted data'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PregnancyInsights extends ConsumerWidget {
  const _PregnancyInsights({required this.language});

  final AppLanguage language;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    String t(String key) => Strings.t(key, language);
    final profile = ref.watch(userProfileProvider).value;
    final logs = ref.watch(logProvider).value ?? const [];
    final recentLogs = logs.take(7).toList();
    final symptoms = <String, int>{};
    var lowEnergyDays = 0;
    for (final log in recentLogs) {
      if ((log.energyLevel ?? 5) <= 2) lowEnergyDays++;
      for (final symptom in log.symptoms) {
        symptoms[symptom] = (symptoms[symptom] ?? 0) + 1;
      }
    }
    final topSymptoms = symptoms.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final week = profile?.pregnancyWeek;

    return Scaffold(
      body: GradientBackground(
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(18, 12, 18, 112),
            children: [
              AsmitaScreenHeader(
                title: t('pregnancy_insights'),
                subtitle: week == null
                    ? t('cycle_predictions_paused')
                    : '${t('week')} $week · ${t('pregnancy_support')}',
              ),
              const SizedBox(height: 16),
              AsmitaCard(
                accent: AppColors.coral,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const AnimatedIconBadge(
                      icon: Icons.favorite_rounded,
                      color: AppColors.coral,
                      size: 62,
                    ),
                    const SizedBox(width: 14),
                    Expanded(child: Text(t('cycle_predictions_paused'))),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              _CareTile(
                color: AppColors.success,
                icon: Icons.healing_rounded,
                title: t('recent_symptoms'),
                value: topSymptoms.isEmpty
                    ? t('notes')
                    : topSymptoms.take(3).map((entry) => entry.key).join(', '),
              ),
              const SizedBox(height: 12),
              _CareTile(
                color: AppColors.accent,
                icon: Icons.battery_charging_full_rounded,
                title: t('energy_trend'),
                value: lowEnergyDays == 0
                    ? t('pregnancy_guidance_1')
                    : '$lowEnergyDays ${t('energy_low')}',
              ),
              const SizedBox(height: 12),
              _CareTile(
                color: AppColors.primary,
                icon: Icons.event_available_rounded,
                title: t('appointments'),
                value: t('pregnancy_guidance_2'),
              ),
              const SizedBox(height: 12),
              _CareTile(
                color: AppColors.follicular,
                icon: Icons.water_drop_rounded,
                title: t('hydration_rest_reminder'),
                value: t('pregnancy_nutrition_1'),
              ),
              const SizedBox(height: 12),
              FilledButton.icon(
                onPressed: () => context.go('/companion'),
                icon: const Icon(Icons.auto_awesome_rounded),
                label: const Text('Sakhi'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CareTile extends StatelessWidget {
  const _CareTile({
    required this.color,
    required this.icon,
    required this.title,
    required this.value,
  });

  final Color color;
  final IconData icon;
  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    return AsmitaCard(
      accent: color,
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: color.withOpacity(.12),
            child: Icon(icon, color: color),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 4),
                Text(value),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TinyPill extends StatelessWidget {
  const _TinyPill(this.label);
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: AppColors.lilacMist,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: AppColors.primary,
          fontSize: 12,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}
