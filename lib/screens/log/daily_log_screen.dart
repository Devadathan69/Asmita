import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../db/models/daily_log.dart';
import '../../providers/log_provider.dart';
import '../../theme/app_colors.dart';
import '../../widgets/common/animated_icon_badge.dart';
import '../../widgets/common/asmita_button.dart';
import '../../widgets/common/asmita_card.dart';
import '../../widgets/common/asmita_screen_header.dart';
import '../../widgets/common/gradient_background.dart';
import 'widgets/energy_selector.dart';
import 'widgets/flow_selector.dart';
import 'widgets/mood_selector.dart';
import 'widgets/pain_body_map.dart';
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
  final temp = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GradientBackground(
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(18, 12, 18, 112),
            children: [
              const AsmitaScreenHeader(
                title: 'Daily log',
                subtitle: 'Capture what your body is saying today',
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
                          Text(
                            'Today',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          Text(
                            'Saved privately and encrypted on this device',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ).animate().fadeIn().slideY(begin: .04),
              const SizedBox(height: 14),
              AsmitaCard(
                accent: AppColors.secondary,
                child: FlowSelector(
                  value: flow,
                  onChanged: (v) => setState(() => flow = v),
                ),
              ),
              const SizedBox(height: 14),
              AsmitaCard(
                accent: AppColors.accent,
                child: MoodSelector(
                  value: mood,
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
              AsmitaCard(
                accent: AppColors.follicular,
                child: SymptomChips(
                  selected: symptoms,
                  onChanged: () => setState(() {}),
                ),
              ),
              const SizedBox(height: 14),
              AsmitaCard(
                accent: AppColors.secondary,
                child: PainBodyMap(
                  selectedZones: zones,
                  onChanged: () => setState(() {}),
                ),
              ),
              const SizedBox(height: 14),
              AsmitaCard(
                accent: AppColors.danger,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const CircleAvatar(
                          backgroundColor: AppColors.coralPale,
                          child: Icon(
                            Icons.healing_rounded,
                            color: AppColors.secondary,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Pain intensity',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const Spacer(),
                        Text(
                          '$pain/10',
                          style: const TextStyle(
                            color: AppColors.secondary,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ],
                    ),
                    Slider(
                      value: pain.toDouble(),
                      min: 0,
                      max: 10,
                      divisions: 10,
                      activeColor: AppColors.secondary,
                      onChanged: (v) => setState(() => pain = v.round()),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              TextField(
                controller: notes,
                minLines: 2,
                maxLines: 4,
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.lock_outline_rounded),
                  labelText: 'Notes (optional, encrypted)',
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
              AsmitaButton(label: 'Save log privately', onPressed: _save),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _save() async {
    await ref.read(logProvider.notifier).save(
          DailyLog(
            date: DateTime.now(),
            flowLevel: flow,
            mood: mood,
            energyLevel: energy,
            painLocations: zones.toList(),
            painIntensity: pain,
            symptoms: symptoms.toList(),
            notes: notes.text,
            temperature: double.tryParse(temp.text),
            createdAt: DateTime.now(),
          ),
        );
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Saved privately on this device')),
      );
    }
  }
}
