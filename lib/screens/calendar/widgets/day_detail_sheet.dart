import 'package:flutter/material.dart';
import '../../../theme/app_colors.dart';
import '../../../utils/cycle_calculator.dart';

class DayDetailSheet extends StatelessWidget {
  const DayDetailSheet({
    super.key,
    required this.date,
    required this.info,
    this.embedded = false,
  });

  final DateTime date;
  final CycleDayInfo info;
  final bool embedded;

  @override
  Widget build(BuildContext context) {
    final content = Padding(
      padding: EdgeInsets.fromLTRB(24, embedded ? 8 : 4, 24, 24),
      child: Column(
        mainAxisSize: embedded ? MainAxisSize.max : MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 28,
                backgroundColor: info.phase.color.withOpacity(.14),
                child: Icon(Icons.event_available_rounded,
                    color: info.phase.color),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${date.day}/${date.month}/${date.year}',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    Text(
                      'Day ${info.day} • ${info.phase.label}',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _DetailPill(
            icon: Icons.water_drop_rounded,
            title: 'Flow',
            value: 'No flow logged',
            color: AppColors.secondary,
          ),
          _DetailPill(
            icon: Icons.mood_rounded,
            title: 'Mood',
            value: 'No mood logged',
            color: AppColors.accent,
          ),
          _DetailPill(
            icon: Icons.spa_rounded,
            title: 'Tip',
            value: CycleCalculator.nutritionTips(info.phase).first,
            color: info.phase.color,
          ),
        ],
      ),
    );

    return embedded ? content : SafeArea(child: content);
  }
}

class _DetailPill extends StatelessWidget {
  const _DetailPill({
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
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withOpacity(.09),
        borderRadius: BorderRadius.circular(22),
      ),
      child: Row(
        children: [
          Icon(icon, color: color),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(fontWeight: FontWeight.w800)),
                Text(value, style: Theme.of(context).textTheme.bodySmall),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
