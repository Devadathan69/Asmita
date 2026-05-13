import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../config/build_config.dart';
import '../../db/database_helper.dart';
import '../../db/models/user_profile.dart';
import '../../l10n/strings.dart';
import '../../providers/language_provider.dart';
import '../../providers/user_profile_provider.dart';
import '../../services/security_service.dart';
import '../../theme/app_colors.dart';
import '../../widgets/common/asmita_button.dart';
import '../../widgets/common/asmita_card.dart';
import '../../widgets/common/asmita_screen_header.dart';
import '../../widgets/common/gradient_background.dart';
import 'widgets/asha_bridge_widget.dart';
import 'widgets/data_export_widget.dart';
import 'widgets/discreet_mode_widget.dart';
import 'widgets/security_settings_widget.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  final name = TextEditingController();
  final height = TextEditingController();
  final weight = TextEditingController();
  DateTime? dob;
  DateTime? lastPeriod;
  double cycle = 28;
  double duration = 5;
  String _loadedSignature = '';

  @override
  void dispose() {
    name.dispose();
    height.dispose();
    weight.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final profile = ref.watch(userProfileProvider).value;
    final language = ref.watch(languageProvider).value ?? AppLanguage.english;
    String t(String key) => Strings.t(key, language);
    if (profile != null) _syncControllers(profile);

    return Scaffold(
      body: GradientBackground(
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(18, 12, 18, 112),
            children: [
              AsmitaScreenHeader(
                title: t('more'),
                subtitle: t('settings_privacy_local'),
              ),
              const SizedBox(height: 18),
              if (profile != null) _profileEditor(profile, language, t),
              const SizedBox(height: 12),
              _languageCard(profile, language, t),
              const SizedBox(height: 12),
              if (profile != null) _pregnancyCard(profile, language, t),
              const SizedBox(height: 12),
              const DiscreetModeWidget(),
              const SizedBox(height: 12),
              const SecuritySettingsWidget(),
              if (BuildConfig.showAshaMode) ...[
                const SizedBox(height: 12),
                const AshaBridgeWidget(),
              ],
              const SizedBox(height: 12),
              const DataExportWidget(),
              const SizedBox(height: 12),
              FilledButton.tonalIcon(
                onPressed: () async => SecurityService.instance.wipeAllData(
                  await DatabaseHelper.instance.database,
                ),
                icon: const Icon(Icons.delete_forever),
                label: Text(t('delete_all_data')),
              ),
              const SizedBox(height: 24),
              const Center(
                child: Text(
                  'Made with love for Indian women | Team Naayattu, MACE',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _profileEditor(
    UserProfile profile,
    AppLanguage language,
    String Function(String) t,
  ) {
    final age = _age(dob);
    final bmi = _bmi;
    return AsmitaCard(
      accent: AppColors.primary,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            t('profile_health_details'),
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 14),
          TextField(
            controller: name,
            decoration: InputDecoration(labelText: t('name_optional')),
          ),
          const SizedBox(height: 12),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.cake_rounded),
            title: Text(t('date_of_birth')),
            subtitle: Text(dob == null ? t('add_date') : _date(dob!)),
            trailing: const Icon(Icons.calendar_month_rounded),
            onTap: _pickDob,
          ),
          if (age != null) _InfoLine('${t('age')}: $age ${t('years_suffix')}'),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _NumberField(
                  controller: height,
                  label: t('height_cm'),
                  onChanged: () => setState(() {}),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _NumberField(
                  controller: weight,
                  label: t('weight_kg'),
                  onChanged: () => setState(() {}),
                ),
              ),
            ],
          ),
          if (bmi != null) ...[
            const SizedBox(height: 12),
            _InfoLine('${t('bmi_context')}: ${bmi.toStringAsFixed(1)}'),
          ],
          const SizedBox(height: 12),
          Text('${t('average_cycle_length')}: ${cycle.round()} days'),
          Slider(
            value: cycle,
            min: 21,
            max: 45,
            divisions: 24,
            onChanged: profile.isPregnant
                ? null
                : (value) => setState(() => cycle = value),
          ),
          Text('${t('period_duration')}: ${duration.round()} days'),
          Slider(
            value: duration,
            min: 2,
            max: 9,
            divisions: 7,
            onChanged: profile.isPregnant
                ? null
                : (value) => setState(() => duration = value),
          ),
          const SizedBox(height: 12),
          AsmitaButton(
            label: t('save_details'),
            icon: Icons.save_rounded,
            onPressed: () => _saveProfile(profile, language),
          ),
        ],
      ),
    );
  }

  Widget _languageCard(
    UserProfile? profile,
    AppLanguage language,
    String Function(String) t,
  ) {
    return AsmitaCard(
      accent: AppColors.follicular,
      child: Row(
        children: [
          const CircleAvatar(
            backgroundColor: AppColors.primaryPale,
            child: Icon(Icons.language_rounded, color: AppColors.primary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: DropdownButtonFormField<AppLanguage>(
              value: language,
              decoration: InputDecoration(labelText: t('language')),
              items: [
                DropdownMenuItem(
                  value: AppLanguage.english,
                  child: Text(t('english')),
                ),
                DropdownMenuItem(
                  value: AppLanguage.malayalam,
                  child: Text(t('malayalam')),
                ),
                DropdownMenuItem(
                  value: AppLanguage.hindi,
                  child: Text(t('hindi')),
                ),
                DropdownMenuItem(
                  value: AppLanguage.manglish,
                  child: Text(t('manglish')),
                ),
              ],
              onChanged: (value) async {
                if (value == null) return;
                await ref.read(languageProvider.notifier).setLanguage(value);
                if (profile != null) {
                  await ref
                      .read(userProfileProvider.notifier)
                      .save(profile.copyWith(language: value.name));
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _pregnancyCard(
    UserProfile profile,
    AppLanguage language,
    String Function(String) t,
  ) {
    final adult = profile.canUsePregnancyMode;
    return AsmitaCard(
      accent: AppColors.coral,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const CircleAvatar(
                backgroundColor: AppColors.coralPale,
                child: Icon(Icons.favorite_rounded, color: AppColors.coral),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      t('pregnancy_mode'),
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    Text(
                      adult
                          ? (profile.isPregnant
                              ? t('pregnant')
                              : t('not_pregnant'))
                          : t('pregnancy_adult_only'),
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              if (adult)
                Switch(
                  value: profile.isPregnant,
                  onChanged: (value) => value
                      ? _showPregnancySetup(profile, language)
                      : _turnPregnancyOff(profile, language),
                ),
            ],
          ),
          if (profile.isPregnant) ...[
            const SizedBox(height: 12),
            _InfoLine(
              profile.pregnancyWeek == null
                  ? t('pregnancy_date_needed')
                  : '${t('week')} ${profile.pregnancyWeek} · ${t('trimester')} ${profile.trimester}',
            ),
          ],
        ],
      ),
    );
  }

  void _syncControllers(UserProfile profile) {
    final signature = [
      profile.id,
      profile.name,
      profile.dateOfBirth,
      profile.heightCm,
      profile.weightKg,
      profile.avgCycleLength,
      profile.periodDuration,
      profile.language,
      profile.isPregnant,
    ].join('|');
    if (_loadedSignature == signature) return;
    _loadedSignature = signature;
    name.text = profile.name ?? '';
    dob = profile.birthDate;
    height.text = profile.heightCm?.toStringAsFixed(1) ?? '';
    weight.text = profile.weightKg?.toStringAsFixed(1) ?? '';
    cycle = profile.avgCycleLength.toDouble();
    duration = profile.periodDuration.toDouble();
    lastPeriod = profile.pregnancyLmp;
  }

  Future<void> _pickDob() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      firstDate: DateTime(now.year - 60),
      lastDate: DateTime(now.year - 9, now.month, now.day),
      initialDate: dob ?? DateTime(now.year - 18),
    );
    if (picked != null) setState(() => dob = picked);
  }

  Future<void> _saveProfile(UserProfile profile, AppLanguage language) async {
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
    final adult = age >= 18;
    await ref.read(userProfileProvider.notifier).save(
          profile.copyWith(
            name: name.text.trim().isEmpty ? null : name.text.trim(),
            dateOfBirth: dob!.toIso8601String(),
            heightCm: h,
            weightKg: w,
            avgCycleLength: cycle.round(),
            periodDuration: duration.round(),
            language: language.name,
            isPregnant: adult ? profile.isPregnant : false,
          ),
        );
    if (!adult) _show(Strings.t('pregnancy_adult_only', language));
    _show(Strings.t('saved_private', language));
  }

  Future<void> _showPregnancySetup(
    UserProfile profile,
    AppLanguage language,
  ) async {
    DateTime? lmp = profile.pregnancyLmp;
    DateTime? due = profile.dueDate;
    var highRisk = profile.highRiskPregnancy;
    String t(String key) => Strings.t(key, language);
    final saved = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (context) {
        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: .72,
          minChildSize: .45,
          maxChildSize: .95,
          builder: (context, scrollController) {
            return StatefulBuilder(
              builder: (context, setSheetState) {
                final media = MediaQuery.of(context);
                return SafeArea(
                  child: ListView(
                    controller: scrollController,
                    padding: EdgeInsets.fromLTRB(
                      20,
                      20,
                      20,
                      media.viewInsets.bottom + media.padding.bottom + 32,
                    ),
                    children: [
                      Container(
                        width: 42,
                        height: 5,
                        margin: const EdgeInsets.only(bottom: 18),
                        decoration: BoxDecoration(
                          color: AppColors.textSecondary.withOpacity(.35),
                          borderRadius: BorderRadius.circular(100),
                        ),
                      ),
                      Text(
                        t('switch_to_pregnancy_mode'),
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 12),
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text(t('last_menstrual_period')),
                        subtitle:
                            Text(lmp == null ? t('optional') : _date(lmp!)),
                        trailing: const Icon(Icons.calendar_month_rounded),
                        onTap: () async {
                          final picked = await showDatePicker(
                            context: context,
                            firstDate: DateTime.now()
                                .subtract(const Duration(days: 42 * 7)),
                            lastDate: DateTime.now(),
                            initialDate: lmp ??
                                DateTime.now().subtract(
                                  const Duration(days: 8 * 7),
                                ),
                          );
                          if (picked != null) {
                            setSheetState(() => lmp = picked);
                          }
                        },
                      ),
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text(t('expected_due_date')),
                        subtitle:
                            Text(due == null ? t('optional') : _date(due!)),
                        trailing: const Icon(Icons.event_available_rounded),
                        onTap: () async {
                          final picked = await showDatePicker(
                            context: context,
                            firstDate: DateTime.now(),
                            lastDate: DateTime.now()
                                .add(const Duration(days: 42 * 7)),
                            initialDate: due ??
                                DateTime.now()
                                    .add(const Duration(days: 32 * 7)),
                          );
                          if (picked != null) {
                            setSheetState(() => due = picked);
                          }
                        },
                      ),
                      SwitchListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text(t('high_risk_pregnancy')),
                        value: highRisk,
                        onChanged: (value) =>
                            setSheetState(() => highRisk = value),
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: FilledButton.icon(
                          onPressed: () => Navigator.of(context).pop(true),
                          icon: const Icon(Icons.check_rounded),
                          label: Text(t('save')),
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          },
        );
      },
    );
    if (saved != true) return;
    await ref.read(userProfileProvider.notifier).save(
          profile.copyWith(
            isPregnant: true,
            lastMenstrualPeriodForPregnancy: lmp?.toIso8601String(),
            estimatedDueDate: due?.toIso8601String(),
            highRiskPregnancy: highRisk,
          ),
        );
  }

  Future<void> _turnPregnancyOff(
    UserProfile profile,
    AppLanguage language,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(Strings.t('switch_to_period_tracking', language)),
        content: Text(Strings.t('pregnancy_history_private', language)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(Strings.t('cancel', language)),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(Strings.t('switch', language)),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    await ref
        .read(userProfileProvider.notifier)
        .save(profile.copyWith(isPregnant: false));
  }

  double? get _bmi {
    final h = double.tryParse(height.text);
    final w = double.tryParse(weight.text);
    if (h == null || w == null || h <= 0 || w <= 0) return null;
    final meters = h / 100;
    return w / (meters * meters);
  }

  int? _age(DateTime? date) {
    if (date == null) return null;
    final today = DateTime.now();
    var years = today.year - date.year;
    if (today.isBefore(DateTime(today.year, date.month, date.day))) years--;
    return years;
  }

  String _date(DateTime value) => '${value.day}/${value.month}/${value.year}';

  void _show(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
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

class _InfoLine extends StatelessWidget {
  const _InfoLine(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(.08),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(text, style: const TextStyle(fontWeight: FontWeight.w800)),
    );
  }
}
