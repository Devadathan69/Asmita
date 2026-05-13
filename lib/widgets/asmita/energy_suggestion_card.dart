import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../l10n/strings.dart';
import '../../theme/app_colors.dart';
import '../common/asmita_card.dart';

class EnergySuggestionCard extends StatelessWidget {
  const EnergySuggestionCard({
    super.key,
    required this.energyLevel,
    required this.isPregnant,
    required this.language,
    this.painLevel = 0,
    this.selectedSymptoms = const [],
  });

  final int? energyLevel;
  final bool isPregnant;
  final AppLanguage language;
  final int painLevel;
  final Iterable<String> selectedSymptoms;

  static const _pregnancyWarningSymptoms = {
    'Bleeding',
    'Severe pain',
    'Fainting',
    'Severe headache',
    'Blurred vision',
    'Fever',
    'Reduced baby movement',
  };

  @override
  Widget build(BuildContext context) {
    final energy = energyLevel;
    if (energy == null || energy > 2) return const SizedBox.shrink();

    final hasWarningSymptom = isPregnant &&
        selectedSymptoms.any((symptom) => _pregnancyWarningSymptoms.contains(
              symptom,
            ));
    final highPain = painLevel >= 7;
    final message = hasWarningSymptom
        ? Strings.t('pregnancy_danger_advice', language)
        : highPain
            ? Strings.t('low_energy_pain_rest', language)
            : isPregnant
                ? Strings.t('low_energy_pregnancy', language)
                : Strings.t('low_energy_normal', language);
    final safety = isPregnant && !hasWarningSymptom
        ? Strings.t('pregnancy_energy_safety', language)
        : null;
    final color = hasWarningSymptom ? AppColors.danger : AppColors.success;

    return AsmitaCard(
      accent: color,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            backgroundColor: color.withOpacity(.12),
            child: Icon(
              hasWarningSymptom
                  ? Icons.support_agent_rounded
                  : Icons.self_improvement_rounded,
              color: color,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  Strings.t('energy', language),
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 6),
                Text(message),
                if (safety != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    safety,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 240.ms).slideY(begin: .04);
  }
}
