import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../db/models/daily_log.dart';
import '../../l10n/strings.dart';
import '../../providers/language_provider.dart';
import '../../providers/log_provider.dart';
import '../../providers/personal_tracking_mode_provider.dart';
import '../../providers/user_profile_provider.dart';
import '../../theme/app_colors.dart';
import '../../widgets/asmita/energy_suggestion_card.dart';
import '../../widgets/asmita/pain_map_card.dart';
import '../../widgets/common/animated_icon_badge.dart';
import '../../widgets/common/asmita_button.dart';
import '../../widgets/common/asmita_card.dart';
import '../../widgets/common/asmita_screen_header.dart';
import '../../widgets/common/gradient_background.dart';
import 'widgets/energy_selector.dart';
import 'widgets/flow_selector.dart';
import 'widgets/mood_selector.dart';
import 'widgets/symptom_chips.dart';

class DailyLogScreen extends ConsumerStatefulWidget {
  const DailyLogScreen({super.key});
  @override
  ConsumerState<DailyLogScreen> createState() => _DailyLogScreenState();
}

class _DailyLogScreenState extends ConsumerState<DailyLogScreen> {
  int flow = 0;
  String? mood;
  int energy = 3;
  int pain = 0;
  final symptoms = <String>{};
  final zones = <String>{};
  final notes = TextEditingController();
  final painNote = TextEditingController();
  final temp = TextEditingController();
  static const pregnancySymptoms = [
    'Nausea',
    'Vomiting',
    'Back pain',
    'Headache',
    'Heartburn',
    'Constipation',
    'Swelling',
    'Cramps',
    'Sleep trouble',
    'Dizziness',
    'Bleeding',
    'Fever',
    'Severe pain',
    'Fainting',
    'Severe headache',
    'Blurred vision',
    'Severe breathlessness',
    'Reduced baby movement',
    'Other',
    'Medicine/vitamin taken',
    'Appointment attended',
  ];
  static const pregnancyWarningSymptoms = {
    'Bleeding',
    'Fever',
    'Severe pain',
    'Fainting',
    'Severe headache',
    'Blurred vision',
    'Reduced baby movement',
    'Severe breathlessness',
  };

  bool get _hasPregnancyWarning =>
      symptoms.any(pregnancyWarningSymptoms.contains) || pain >= 8;
  int get _painSegmentValue {
    if (pain <= 0) return 0;
    if (pain <= 3) return 3;
    if (pain <= 6) return 6;
    return 9;
  }

  bool babyMovementFelt = false;
  bool appointmentAttended = false;
  bool medicineTaken = false;
  double waterCups = 6;
  String restQuality = 'Okay';
  static const pregnancyMoods = [
    ('Calm', Icons.spa_rounded, AppColors.success),
    ('Happy', Icons.sentiment_very_satisfied_rounded, AppColors.accent),
    ('Anxious', Icons.air_rounded, AppColors.primary),
    ('Tired', Icons.bedtime_rounded, AppColors.luteal),
    ('Emotional', Icons.favorite_rounded, AppColors.secondary),
    ('Low', Icons.sentiment_dissatisfied_rounded, AppColors.textSecondary),
  ];

  @override
  void dispose() {
    notes.dispose();
    painNote.dispose();
    temp.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final profile = ref.watch(userProfileProvider).value;
    final isPregnant = ref.watch(personalTrackingModeProvider) ==
        PersonalTrackingMode.pregnancy;
    final pregnancyWeek = profile?.pregnancyWeek;
    final language = ref.watch(languageProvider).value ?? AppLanguage.english;
    String t(String key) => Strings.t(key, language);
    return Scaffold(
      body: GradientBackground(
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(18, 12, 18, 112),
            children: [
              AsmitaScreenHeader(
                title: t('log_today'),
                subtitle: isPregnant
                    ? t('pregnancy_support')
                    : 'Capture what your body is saying today',
              ),
              const SizedBox(height: 18),
              AsmitaCard(
                accent: AppColors.secondary,
                child: Row(
                  children: [
                    const AnimatedIconBadge(
                      icon: Icons.edit_note_rounded,
                      color: AppColors.secondary,
                      size: 66,
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(t('log_today'),
                              style: Theme.of(context).textTheme.titleMedium),
                          Text(
                            isPregnant
                                ? t('pregnancy_support')
                                : t('saved_private'),
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ).animate().fadeIn().slideY(begin: .04),
              const SizedBox(height: 14),
              if (!isPregnant) ...[
                AsmitaCard(
                  accent: AppColors.secondary,
                  child: FlowSelector(
                    value: flow,
                    onChanged: (v) => setState(() => flow = v),
                  ),
                ),
                const SizedBox(height: 14),
              ],
              if (isPregnant) ...[
                AsmitaCard(
                  accent: AppColors.success,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        t('pregnancy_daily_log'),
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 10),
                      if ((pregnancyWeek ?? 0) >= 20)
                        CheckboxListTile(
                          contentPadding: EdgeInsets.zero,
                          value: babyMovementFelt,
                          onChanged: (value) => setState(
                            () => babyMovementFelt = value ?? false,
                          ),
                          title: Text(t('baby_movement')),
                        ),
                      CheckboxListTile(
                        contentPadding: EdgeInsets.zero,
                        value: appointmentAttended,
                        onChanged: (value) => setState(
                          () => appointmentAttended = value ?? false,
                        ),
                        title: Text(t('appointment_attended')),
                      ),
                      CheckboxListTile(
                        contentPadding: EdgeInsets.zero,
                        value: medicineTaken,
                        onChanged: (value) => setState(
                          () => medicineTaken = value ?? false,
                        ),
                        title: Text(t('medicine_if_prescribed')),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Text(
                            '${t('water_intake')}: ${waterCups.round()}',
                            style: Theme.of(context).textTheme.titleSmall,
                          ),
                          const Spacer(),
                          const Icon(Icons.water_drop_rounded),
                        ],
                      ),
                      Slider(
                        value: waterCups,
                        min: 0,
                        max: 12,
                        divisions: 12,
                        activeColor: AppColors.success,
                        onChanged: (value) => setState(() => waterCups = value),
                      ),
                      DropdownButtonFormField<String>(
                        value: restQuality,
                        decoration:
                            InputDecoration(labelText: t('rest_quality')),
                        items: const ['Low', 'Okay', 'Good']
                            .map(
                              (quality) => DropdownMenuItem(
                                value: quality,
                                child: Text(quality),
                              ),
                            )
                            .toList(),
                        onChanged: (value) => setState(
                          () => restQuality = value ?? restQuality,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
              ],
              AsmitaCard(
                accent: AppColors.accent,
                child: MoodSelector(
                  value: mood,
                  options: isPregnant ? pregnancyMoods : MoodSelector.moods,
                  onChanged: (v) => setState(() => mood = v),
                ),
              ),
              const SizedBox(height: 14),
              AsmitaCard(
                accent: AppColors.primary,
                child: EnergySelector(
                  value: energy,
                  onChanged: (v) => setState(() => energy = v),
                ),
              ),
              const SizedBox(height: 14),
              EnergySuggestionCard(
                energyLevel: energy,
                isPregnant: isPregnant,
                language: language,
                painLevel: pain,
                selectedSymptoms: symptoms,
              ),
              if (energy <= 2) const SizedBox(height: 14),
              AsmitaCard(
                accent: AppColors.follicular,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      t('symptoms'),
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 12),
                    SymptomChips(
                      selected: symptoms,
                      options: isPregnant
                          ? pregnancySymptoms
                              .where((symptom) =>
                                  symptom != 'Reduced baby movement' ||
                                  (pregnancyWeek ?? 0) >= 20)
                              .toList()
                          : SymptomChips.symptoms,
                      onChanged: () => setState(() {}),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              PainMapCard(
                selectedRegions: zones,
                intensity: _painSegmentValue,
                onRegionsChanged: (next) => setState(() {
                  zones
                    ..clear()
                    ..addAll(next);
                }),
                onIntensityChanged: (value) => setState(() => pain = value),
                noteController: painNote,
                language: language,
                isPregnant: isPregnant,
              ),
              const SizedBox(height: 14),
              if (isPregnant && _hasPregnancyWarning) ...[
                AsmitaCard(
                  accent: AppColors.danger,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(
                        Icons.medical_services_rounded,
                        color: AppColors.danger,
                      ),
                      const SizedBox(width: 12),
                      Expanded(child: Text(t('pregnancy_danger_advice'))),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
              ],
              TextField(
                controller: notes,
                minLines: 2,
                maxLines: 4,
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.lock_outline_rounded),
                  labelText:
                      isPregnant ? t('questions_notes_doctor') : t('notes'),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: temp,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.thermostat_rounded),
                  labelText: 'Temperature (optional)',
                ),
              ),
              const SizedBox(height: 20),
              AsmitaButton(label: t('save'), onPressed: _save),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _save() async {
    final language = ref.read(languageProvider).value ?? AppLanguage.english;
    final isPregnant = ref.read(personalTrackingModeProvider) ==
        PersonalTrackingMode.pregnancy;
    final savedSymptoms = {...symptoms};
    if (isPregnant) {
      if (babyMovementFelt) savedSymptoms.add('Baby movement felt');
      if (appointmentAttended) savedSymptoms.add('Appointment attended');
      if (medicineTaken) savedSymptoms.add('Medicine/vitamin taken');
    }
    final noteText = isPregnant
        ? [
            notes.text,
            if (painNote.text.trim().isNotEmpty)
              '${Strings.t('pain_map', language)}: ${painNote.text.trim()}',
            '${Strings.t('water_intake', language)}: ${waterCups.round()}',
            '${Strings.t('rest_quality', language)}: $restQuality',
          ].where((line) => line.trim().isNotEmpty).join('\n')
        : [
            notes.text,
            if (painNote.text.trim().isNotEmpty)
              '${Strings.t('pain_map', language)}: ${painNote.text.trim()}',
          ].where((line) => line.trim().isNotEmpty).join('\n');
    await ref.read(logProvider.notifier).save(
          DailyLog(
            date: DateTime.now(),
            flowLevel: isPregnant ? 0 : flow,
            mood: mood,
            energyLevel: energy,
            painLocations: isPregnant ? const [] : zones.toList(),
            painIntensity: pain,
            symptoms: savedSymptoms.toList(),
            notes: noteText,
            temperature: double.tryParse(temp.text),
            createdAt: DateTime.now(),
          ),
        );
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(Strings.t('saved_private', language))),
      );
    }
  }
}
