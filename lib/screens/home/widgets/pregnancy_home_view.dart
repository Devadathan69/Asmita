import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';

import '../../../db/models/user_profile.dart';
import '../../../l10n/strings.dart';
import '../../../theme/app_colors.dart';
import '../../../widgets/common/asmita_card.dart';
import '../../../widgets/common/asmita_screen_header.dart';
import '../../../widgets/common/privacy_badge.dart';

class PregnancyHomeView extends StatelessWidget {
  const PregnancyHomeView({
    super.key,
    required this.profile,
    required this.language,
  });

  final UserProfile profile;
  final AppLanguage language;

  @override
  Widget build(BuildContext context) {
    String t(String key) => Strings.t(key, language);
    final week = profile.pregnancyWeek;
    final trimester = profile.trimester;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AsmitaScreenHeader(
          title: t('pregnancy_support'),
          subtitle: week == null
              ? t('pregnancy_date_needed')
              : '${t('week')} $week · ${t('trimester')} $trimester',
          trailing: IconButton.filledTonal(
            onPressed: () => context.go('/profile'),
            icon: const Icon(Icons.edit_rounded),
          ),
        ),
        const SizedBox(height: 18),
        PrivacyBadge(label: t('private_offline')),
        const SizedBox(height: 18),
        AsmitaCard(
          accent: AppColors.coral,
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Container(
                width: 86,
                height: 86,
                decoration: BoxDecoration(
                  color: AppColors.coral.withOpacity(.12),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.favorite_rounded,
                  color: AppColors.coral,
                  size: 42,
                ),
              )
                  .animate(
                      onPlay: (controller) => controller.repeat(reverse: true))
                  .scale(
                    begin: const Offset(.98, .98),
                    end: const Offset(1.04, 1.04),
                    duration: 1400.ms,
                  ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      week == null
                          ? t('pregnancy_support')
                          : '${t('week')} $week',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      trimester == null
                          ? t('pregnancy_on')
                          : '${t('trimester')} $trimester',
                      style: const TextStyle(fontWeight: FontWeight.w800),
                    ),
                    if (profile.dueDate != null)
                      Text('${t('due_date')}: ${_date(profile.dueDate!)}'),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        GridView.count(
          crossAxisCount: MediaQuery.of(context).size.width > 520 ? 3 : 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 1.45,
          children: [
            _ActionTile(
              icon: Icons.edit_note_rounded,
              label: t('log_today'),
              color: AppColors.primary,
              onTap: () => context.go('/log'),
            ),
            _ActionTile(
              icon: Icons.healing_rounded,
              label: t('symptoms'),
              color: AppColors.secondary,
              onTap: () => context.go('/log'),
            ),
            _ActionTile(
              icon: Icons.battery_charging_full_rounded,
              label: t('energy'),
              color: AppColors.success,
              onTap: () => context.go('/log'),
            ),
            _ActionTile(
              icon: Icons.event_available_rounded,
              label: t('appointments'),
              color: AppColors.accent,
              onTap: () {},
            ),
            _ActionTile(
              icon: Icons.quiz_rounded,
              label: t('questions_for_doctor'),
              color: AppColors.follicular,
              onTap: () {},
            ),
            _ActionTile(
              icon: Icons.auto_awesome_rounded,
              label: 'Sakhi',
              color: AppColors.luteal,
              onTap: () => context.go('/companion'),
            ),
          ],
        ),
        const SizedBox(height: 14),
        _GuidanceCard(
          icon: Icons.spa_rounded,
          color: AppColors.success,
          title: t('weekly_guidance'),
          lines: [
            t('pregnancy_guidance_1'),
            t('pregnancy_guidance_2'),
            t('pregnancy_guidance_3'),
          ],
        ),
        const SizedBox(height: 14),
        _GuidanceCard(
          icon: Icons.restaurant_rounded,
          color: AppColors.accent,
          title: t('nutrition_wellbeing'),
          lines: [
            t('pregnancy_nutrition_1'),
            t('pregnancy_nutrition_2'),
            t('pregnancy_nutrition_3'),
          ],
        ),
        const SizedBox(height: 14),
        _GuidanceCard(
          icon: Icons.medical_services_rounded,
          color: AppColors.danger,
          title: t('get_medical_help_urgently_if'),
          lines: [
            t('warning_heavy_bleeding'),
            t('warning_severe_pain'),
            t('warning_fainting_fever'),
            t('warning_headache_swelling'),
            t('warning_baby_movement'),
            t('warning_water_leaking'),
          ],
        ),
      ],
    );
  }

  String _date(DateTime value) => '${value.day}/${value.month}/${value.year}';
}

class _ActionTile extends StatelessWidget {
  const _ActionTile({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return AsmitaCard(
      accent: color,
      onTap: onTap,
      padding: const EdgeInsets.all(12),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 8),
          Text(
            label,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontWeight: FontWeight.w800),
          ),
        ],
      ),
    );
  }
}

class _GuidanceCard extends StatelessWidget {
  const _GuidanceCard({
    required this.icon,
    required this.color,
    required this.title,
    required this.lines,
  });

  final IconData icon;
  final Color color;
  final String title;
  final List<String> lines;

  @override
  Widget build(BuildContext context) {
    return AsmitaCard(
      accent: color,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          for (final line in lines)
            Padding(
              padding: const EdgeInsets.only(bottom: 7),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 6,
                    height: 6,
                    margin: const EdgeInsets.only(top: 8, right: 8),
                    decoration:
                        BoxDecoration(color: color, shape: BoxShape.circle),
                  ),
                  Expanded(child: Text(line)),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
