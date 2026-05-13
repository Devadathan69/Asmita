import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../db/models/cycle_entry.dart';
import '../../db/models/user_profile.dart';
import '../../l10n/strings.dart';
import '../../providers/cycle_provider.dart';
import '../../providers/language_provider.dart';
import '../../providers/user_profile_provider.dart';
import '../../theme/app_colors.dart';
import '../../widgets/common/asmita_button.dart';
import '../../widgets/common/asmita_card.dart';
import '../../widgets/common/gradient_background.dart';

class SetupScreen extends ConsumerStatefulWidget {
  const SetupScreen({super.key});
  @override
  ConsumerState<SetupScreen> createState() => _SetupScreenState();
}

class _SetupScreenState extends ConsumerState<SetupScreen> {
  final name = TextEditingController();
  final height = TextEditingController();
  final weight = TextEditingController();
  DateTime? dob;
  DateTime lastPeriod = DateTime.now().subtract(const Duration(days: 4));
  double cycle = 28;
  double duration = 5;

  @override
  void dispose() {
    name.dispose();
    height.dispose();
    weight.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final language = ref.watch(languageProvider).value ?? AppLanguage.english;
    String t(String key) => Strings.t(key, language);
    final age = _age(dob);
    final bmi = _bmi;
    return Scaffold(
      body: GradientBackground(
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
            children: [
              Text(t('private_setup'),
                  style: Theme.of(context).textTheme.headlineMedium),
              const SizedBox(height: 8),
              Text(t('details_stay_phone')),
              const SizedBox(height: 18),
              _StepCard(
                number: 1,
                title: t('name_optional'),
                child: TextField(
                  controller: name,
                  decoration: InputDecoration(labelText: t('name_optional')),
                ),
              ),
              _StepCard(
                number: 2,
                title: t('date_of_birth'),
                child: Column(
                  children: [
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(Icons.cake_rounded),
                      title: Text(t('date_of_birth')),
                      subtitle: Text(dob == null ? t('add_date') : _date(dob!)),
                      trailing: const Icon(Icons.calendar_month_rounded),
                      onTap: _pickDob,
                    ),
                    if (age != null)
                      _InfoPill(
                        label: '${t('age')}: $age ${t('years_suffix')}',
                      ),
                  ],
                ),
              ),
              _StepCard(
                number: 3,
                title: '${t('height_cm')} / ${t('weight_kg')}',
                child: Column(
                  children: [
                    _NumberField(
                      controller: height,
                      label: t('height_cm'),
                      onChanged: () => setState(() {}),
                    ),
                    const SizedBox(height: 12),
                    _NumberField(
                      controller: weight,
                      label: t('weight_kg'),
                      onChanged: () => setState(() {}),
                    ),
                    if (bmi != null) ...[
                      const SizedBox(height: 12),
                      _InfoPill(
                        label: '${t('bmi_context')}: ${bmi.toStringAsFixed(1)}',
                      ),
                    ],
                  ],
                ),
              ),
              _StepCard(
                number: 4,
                title: t('last_period_start'),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(Icons.water_drop_rounded),
                      title: Text(t('last_period_start')),
                      subtitle: Text(_date(lastPeriod)),
                      trailing: const Icon(Icons.calendar_month_rounded),
                      onTap: _pickLastPeriod,
                    ),
                    Text('${t('average_cycle_length')}: ${cycle.round()} days'),
                    Slider(
                      value: cycle,
                      min: 21,
                      max: 45,
                      divisions: 24,
                      onChanged: (v) => setState(() => cycle = v),
                    ),
                    Text('${t('period_duration')}: ${duration.round()} days'),
                    Slider(
                      value: duration,
                      min: 2,
                      max: 9,
                      divisions: 7,
                      onChanged: (v) => setState(() => duration = v),
                    ),
                  ],
                ),
              ),
              AsmitaCard(
                accent: AppColors.success,
                child: Row(
                  children: [
                    const Icon(Icons.lock_rounded, color: AppColors.success),
                    const SizedBox(width: 12),
                    Expanded(child: Text(t('details_stay_phone'))),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              AsmitaButton(
                label: t('start_using_asmita'),
                icon: Icons.arrow_forward_rounded,
                onPressed: _save,
              ),
            ],
          ),
        ),
      ),
    );
  }

  double? get _bmi {
    final h = double.tryParse(height.text);
    final w = double.tryParse(weight.text);
    if (h == null || w == null || h <= 0 || w <= 0) return null;
    final meters = h / 100;
    return w / (meters * meters);
  }

  Future<void> _pickDob() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      firstDate: DateTime(now.year - 60),
      lastDate: DateTime(now.year - 9, now.month, now.day),
      initialDate: dob ?? DateTime(now.year - 16),
    );
    if (picked != null) setState(() => dob = picked);
  }

  Future<void> _pickLastPeriod() async {
    final picked = await showDatePicker(
      context: context,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now(),
      initialDate: lastPeriod,
    );
    if (picked != null) setState(() => lastPeriod = picked);
  }

  Future<void> _save() async {
    final h = double.tryParse(height.text);
    final w = double.tryParse(weight.text);
    final age = _age(dob);
    if (dob == null || age == null || age < 9 || age > 60) {
      _show('Please add a valid date of birth.');
      return;
    }
    if (h == null || h < 100 || h > 220) {
      _show('Please enter height between 100 and 220 cm.');
      return;
    }
    if (w == null || w < 20 || w > 180) {
      _show('Please enter weight between 20 and 180 kg.');
      return;
    }

    await ref.read(userProfileProvider.notifier).save(
          UserProfile(
            name: name.text.trim().isEmpty ? null : name.text.trim(),
            dateOfBirth: dob!.toIso8601String(),
            heightCm: h,
            weightKg: w,
            avgCycleLength: cycle.round(),
            periodDuration: duration.round(),
            createdAt: DateTime.now(),
          ),
        );
    await ref
        .read(cycleProvider.notifier)
        .add(CycleEntry(startDate: lastPeriod, createdAt: DateTime.now()));
    if (mounted) context.go('/home');
  }

  void _show(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  int? _age(DateTime? date) {
    if (date == null) return null;
    final today = DateTime.now();
    var years = today.year - date.year;
    if (today.isBefore(DateTime(today.year, date.month, date.day))) years--;
    return years;
  }

  String _date(DateTime value) => '${value.day}/${value.month}/${value.year}';
}

class _StepCard extends StatelessWidget {
  const _StepCard({
    required this.number,
    required this.title,
    required this.child,
  });

  final int number;
  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: AsmitaCard(
        accent: AppColors.primary,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 16,
                  backgroundColor: AppColors.primaryPale,
                  child: Text(
                    '$number',
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            child,
          ],
        ),
      ),
    );
  }
}

class _NumberField extends StatelessWidget {
  const _NumberField({
    required this.controller,
    required this.label,
    required this.onChanged,
  });

  final TextEditingController controller;
  final String label;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9.]'))],
      decoration: InputDecoration(labelText: label),
      onChanged: (_) => onChanged(),
    );
  }
}

class _InfoPill extends StatelessWidget {
  const _InfoPill({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.success.withOpacity(.1),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Text(
        label,
        style: const TextStyle(fontWeight: FontWeight.w800),
      ),
    );
  }
}
