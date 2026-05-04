import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../db/models/cycle_entry.dart';
import '../../db/models/user_profile.dart';
import '../../providers/cycle_provider.dart';
import '../../providers/user_profile_provider.dart';
import '../../widgets/common/asmita_button.dart';

class SetupScreen extends ConsumerStatefulWidget {
  const SetupScreen({super.key});
  @override
  ConsumerState<SetupScreen> createState() => _SetupScreenState();
}

class _SetupScreenState extends ConsumerState<SetupScreen> {
  final name = TextEditingController();
  DateTime lastPeriod = DateTime.now().subtract(const Duration(days: 4));
  double cycle = 28;
  double duration = 5;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Private setup')),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          TextField(
            controller: name,
            decoration: const InputDecoration(labelText: 'Name (optional)'),
          ),
          const SizedBox(height: 16),
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Last period start'),
            subtitle: Text(
              '${lastPeriod.day}/${lastPeriod.month}/${lastPeriod.year}',
            ),
            trailing: const Icon(Icons.calendar_month),
            onTap: _pickDate,
          ),
          Text('Average cycle length: ${cycle.round()} days'),
          Slider(
            value: cycle,
            min: 21,
            max: 45,
            divisions: 24,
            onChanged: (v) => setState(() => cycle = v),
          ),
          Text('Period duration: ${duration.round()} days'),
          Slider(
            value: duration,
            min: 2,
            max: 9,
            divisions: 7,
            onChanged: (v) => setState(() => duration = v),
          ),
          const SizedBox(height: 24),
          AsmitaButton(label: 'Start using Asmita', onPressed: _save),
        ],
      ),
    );
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now(),
      initialDate: lastPeriod,
    );
    if (picked != null) setState(() => lastPeriod = picked);
  }

  Future<void> _save() async {
    await ref.read(userProfileProvider.notifier).save(
          UserProfile(
            name: name.text.trim().isEmpty ? null : name.text.trim(),
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
}
