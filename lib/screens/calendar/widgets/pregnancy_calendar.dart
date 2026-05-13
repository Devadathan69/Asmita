import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../db/models/daily_log.dart';
import '../../../db/models/user_profile.dart';
import '../../../l10n/strings.dart';
import '../../../theme/app_colors.dart';
import '../../../widgets/common/asmita_card.dart';
import '../../../widgets/common/asmita_screen_header.dart';

class PregnancyCalendar extends StatelessWidget {
  const PregnancyCalendar({
    super.key,
    required this.profile,
    required this.logs,
    required this.language,
  });

  final UserProfile profile;
  final List<DailyLog> logs;
  final AppLanguage language;

  @override
  Widget build(BuildContext context) {
    String t(String key) => Strings.t(key, language);
    final week = profile.pregnancyWeek;
    final trimester = profile.trimester;
    final due = profile.dueDate;
    final today = DateTime.now();
    final daysRemaining = due?.difference(today).inDays;

    return ListView(
      padding: const EdgeInsets.fromLTRB(18, 12, 18, 112),
      children: [
        AsmitaScreenHeader(
          title: t('pregnancy_calendar'),
          subtitle: week == null
              ? t('pregnancy_date_needed')
              : '${t('week')} $week · ${t('trimester')} $trimester',
        ),
        const SizedBox(height: 16),
        if (week == null && due == null)
          AsmitaCard(
            accent: AppColors.coral,
            onTap: () => context.go('/profile'),
            child: Row(
              children: [
                const Icon(Icons.event_note_rounded, color: AppColors.coral),
                const SizedBox(width: 12),
                Expanded(child: Text(t('pregnancy_date_needed'))),
              ],
            ),
          )
        else
          AsmitaCard(
            accent: AppColors.coral,
            child: Row(
              children: [
                CircleAvatar(
                  radius: 32,
                  backgroundColor: AppColors.coral.withOpacity(.14),
                  child: Text(
                    week == null ? '?' : '$week',
                    style: const TextStyle(
                      color: AppColors.coral,
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        week == null
                            ? t('pregnancy_support')
                            : '${t('week')} $week',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      if (trimester != null)
                        Text('${t('trimester')} $trimester'),
                      if (due != null) Text('${t('due_date')}: ${_date(due)}'),
                      if (daysRemaining != null && daysRemaining >= 0)
                        Text('$daysRemaining ${t('days_remaining')}'),
                    ],
                  ),
                ),
              ],
            ),
          ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: FilledButton.icon(
                onPressed: () => context.go('/profile'),
                icon: const Icon(Icons.event_available_rounded),
                label: Text(t('add_appointment')),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: FilledButton.tonalIcon(
                onPressed: () => context.go('/log'),
                icon: const Icon(Icons.edit_note_rounded),
                label: Text(t('log_today')),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        FilledButton.tonalIcon(
          onPressed: () => context.go('/log'),
          icon: const Icon(Icons.note_add_rounded),
          label: Text(t('add_note')),
        ),
        const SizedBox(height: 16),
        _MonthGrid(logs: logs, language: language),
        const SizedBox(height: 14),
        AsmitaCard(
          accent: AppColors.success,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                t('hydration_rest_reminder'),
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              Text(t('pregnancy_guidance_1')),
              const SizedBox(height: 6),
              Text(t('pregnancy_nutrition_2')),
            ],
          ),
        ),
      ],
    );
  }

  String _date(DateTime value) => '${value.day}/${value.month}/${value.year}';
}

class _MonthGrid extends StatelessWidget {
  const _MonthGrid({required this.logs, required this.language});

  final List<DailyLog> logs;
  final AppLanguage language;

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final first = DateTime(now.year, now.month);
    final days = DateTime(now.year, now.month + 1, 0).day;
    final leadingBlanks = first.weekday % 7;
    final totalCells = leadingBlanks + days;
    return AsmitaCard(
      accent: AppColors.coral,
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${_monthName(now.month)} ${now.year}',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              for (final day in ['S', 'M', 'T', 'W', 'T', 'F', 'S'])
                Expanded(
                  child: Center(
                    child: Text(
                      day,
                      style: const TextStyle(fontWeight: FontWeight.w900),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 10),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
            ),
            itemCount: totalCells,
            itemBuilder: (context, index) {
              if (index < leadingBlanks) return const SizedBox.shrink();
              final day = index - leadingBlanks + 1;
              final date = DateTime(first.year, first.month, day);
              final log =
                  logs.where((entry) => _sameDay(entry.date, date)).firstOrNull;
              final isToday = _sameDay(date, now);
              return _PregnancyDayTile(day: day, log: log, isToday: isToday);
            },
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 10,
            runSpacing: 8,
            children: [
              _Legend(
                  color: AppColors.success,
                  label: Strings.t('symptom_logged', language)),
              _Legend(
                  color: AppColors.accent,
                  label: Strings.t('energy_low', language)),
              _Legend(
                  color: AppColors.danger,
                  label: Strings.t('warning_sign_noted', language)),
            ],
          ),
        ],
      ),
    );
  }

  String _monthName(int month) => const [
        'January',
        'February',
        'March',
        'April',
        'May',
        'June',
        'July',
        'August',
        'September',
        'October',
        'November',
        'December',
      ][month - 1];

  bool _sameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;
}

class _PregnancyDayTile extends StatelessWidget {
  const _PregnancyDayTile({
    required this.day,
    required this.log,
    required this.isToday,
  });

  final int day;
  final DailyLog? log;
  final bool isToday;

  @override
  Widget build(BuildContext context) {
    final hasSymptoms = log?.symptoms.isNotEmpty == true;
    final lowEnergy = (log?.energyLevel ?? 5) <= 2;
    final warning =
        log?.symptoms.any(_isWarning) == true || (log?.painIntensity ?? 0) >= 8;
    return Container(
      decoration: BoxDecoration(
        color: isToday
            ? AppColors.coral.withOpacity(.16)
            : Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isToday ? AppColors.coral : AppColors.coral.withOpacity(.08),
          width: isToday ? 2 : 1,
        ),
      ),
      child: Stack(
        children: [
          Center(
            child: Text(
              '$day',
              style: TextStyle(
                fontWeight: FontWeight.w900,
                color: isToday ? AppColors.coral : null,
              ),
            ),
          ),
          Positioned(
            left: 6,
            right: 6,
            bottom: 6,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (hasSymptoms) _Dot(AppColors.success),
                if (lowEnergy) _Dot(AppColors.accent),
                if (warning) _Dot(AppColors.danger),
              ],
            ),
          ),
        ],
      ),
    );
  }

  bool _isWarning(String value) => const {
        'Bleeding',
        'Fever',
        'Severe pain',
        'Fainting',
        'Severe headache',
        'Blurred vision',
        'Reduced baby movement',
        'Severe breathlessness',
      }.contains(value);
}

class _Dot extends StatelessWidget {
  const _Dot(this.color);
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 6,
      height: 6,
      margin: const EdgeInsets.symmetric(horizontal: 1.5),
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }
}

class _Legend extends StatelessWidget {
  const _Legend({required this.color, required this.label});
  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _Dot(color),
        const SizedBox(width: 4),
        Text(label, style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }
}

extension _FirstOrNull<T> on Iterable<T> {
  T? get firstOrNull => isEmpty ? null : first;
}
