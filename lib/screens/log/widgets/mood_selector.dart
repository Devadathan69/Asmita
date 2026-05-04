import 'package:flutter/material.dart';
import '../../../theme/app_colors.dart';

class MoodSelector extends StatelessWidget {
  const MoodSelector({super.key, required this.value, required this.onChanged});
  final String? value;
  final ValueChanged<String> onChanged;

  static const moods = [
    ('Calm', Icons.spa_rounded, AppColors.success),
    ('Happy', Icons.sentiment_very_satisfied_rounded, AppColors.accent),
    ('Low', Icons.sentiment_dissatisfied_rounded, AppColors.textSecondary),
    ('Tired', Icons.bedtime_rounded, AppColors.luteal),
    ('Anxious', Icons.air_rounded, AppColors.primary),
    ('Irritated', Icons.flash_on_rounded, AppColors.secondary),
    ('Tender', Icons.favorite_rounded, AppColors.secondaryLight),
    ('Focused', Icons.psychology_rounded, AppColors.follicular),
  ];

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Mood', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final mood in moods)
                ChoiceChip(
                  avatar: Icon(mood.$2, color: mood.$3, size: 18),
                  label: Text(mood.$1),
                  selected: value == mood.$1,
                  showCheckmark: false,
                  onSelected: (_) => onChanged(mood.$1),
                ),
            ],
          ),
        ],
      );
}
