import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/cycle_provider.dart';
import '../../providers/user_profile_provider.dart';
import '../../theme/app_colors.dart';
import '../../utils/cycle_calculator.dart';
import '../../widgets/common/asmita_card.dart';
import '../../widgets/common/asmita_screen_header.dart';
import '../../widgets/common/gradient_background.dart';
import '../../widgets/common/privacy_badge.dart';
import 'widgets/cycle_alert_banner.dart';
import 'widgets/cycle_ring_widget.dart';
import 'widgets/music_mini_player.dart';
import 'widgets/myth_fact_card.dart';
import 'widgets/phase_tip_card.dart';
import 'widgets/quick_log_card.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(userProfileProvider).value;
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
            padding: const EdgeInsets.fromLTRB(18, 12, 18, 112),
            children: [
              AsmitaScreenHeader(
                title: 'Asmita',
                subtitle: 'Your private cycle companion',
                trailing: IconButton.filledTonal(
                  onPressed: () => context.push('/insights'),
                  icon: const Icon(Icons.notifications_none_rounded),
                ),
              ),
              const SizedBox(height: 18),
              const PrivacyBadge(label: 'Works offline'),
              const SizedBox(height: 18),
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
              const SizedBox(height: 16),
              CycleAlertBanner(
                cycleLengths:
                    cycles.map((e) => e.cycleLength).whereType<int>().toList(),
              ),
              QuickLogCard(onTap: () => context.go('/log')),
              PhaseTipCard(phase: info.phase),
              const MusicMiniPlayer(),
              const SizedBox(height: 6),
              Text(
                "Explore",
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 12),
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
              const SizedBox(height: 12),
              const MythFactCard(),
            ],
          ),
        ),
      ),
    );
  }
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
  Widget build(BuildContext context) => Column(
        children: [
          Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              color: color.withOpacity(.13),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color),
          )
              .animate(onPlay: (controller) => controller.repeat(reverse: true))
              .moveY(begin: 0, end: -3, duration: 1400.ms),
          const SizedBox(height: 8),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(fontWeight: FontWeight.w800),
          ),
        ],
      );
}
