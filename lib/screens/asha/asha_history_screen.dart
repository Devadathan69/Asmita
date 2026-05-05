import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../services/screening_storage_service.dart';
import '../../widgets/common/asmita_button.dart';
import '../../widgets/common/gradient_background.dart';
import 'widgets/history_entry_card.dart';

class AshaHistoryScreen extends ConsumerWidget {
  const AshaHistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: GradientBackground(
        child: SafeArea(
          child: FutureBuilder(
            future: ScreeningStorageService().getHistory(),
            builder: (context, snapshot) {
              final records = snapshot.data ?? const [];
              final high = records
                  .where(
                      (r) => r.riskTier == 'Hormonal' || r.riskTier == 'Urgent')
                  .length;
              final month = records
                  .where((r) =>
                      r.screenedAt.month == DateTime.now().month &&
                      r.screenedAt.year == DateTime.now().year)
                  .length;
              return ListView(
                padding: const EdgeInsets.all(18),
                children: [
                  Row(
                    children: [
                      IconButton(
                        onPressed: () => context.go('/asha/home'),
                        icon: const Icon(Icons.arrow_back),
                      ),
                      Expanded(
                        child: Text('Screening History',
                            style: Theme.of(context).textTheme.headlineSmall),
                      ),
                      IconButton(
                        onPressed: records.isEmpty
                            ? null
                            : () async {
                                final ok = await showDialog<bool>(
                                  context: context,
                                  builder: (_) => AlertDialog(
                                    title: const Text('Delete records?'),
                                    content: const Text(
                                      'This clears anonymized screening history.',
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () =>
                                            Navigator.pop(context, false),
                                        child: const Text('Cancel'),
                                      ),
                                      TextButton(
                                        onPressed: () =>
                                            Navigator.pop(context, true),
                                        child: const Text('Delete'),
                                      ),
                                    ],
                                  ),
                                );
                                if (ok == true) {
                                  await ScreeningStorageService().deleteAll();
                                  if (context.mounted)
                                    context.go('/asha/history');
                                }
                              },
                        icon: const Icon(Icons.delete_outline),
                      ),
                    ],
                  ),
                  if (snapshot.connectionState == ConnectionState.waiting)
                    const Center(child: CircularProgressIndicator())
                  else if (records.isEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 80),
                      child: Column(
                        children: [
                          const Icon(Icons.fact_check_outlined, size: 72),
                          const SizedBox(height: 12),
                          const Text('No screenings yet'),
                          const SizedBox(height: 18),
                          AsmitaButton(
                            label: 'Start First Screening',
                            onPressed: () => context.go('/asha/instructions'),
                          ),
                        ],
                      ),
                    )
                  else ...[
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(14),
                        child: Text(
                          'Total: ${records.length} | High Risk: $high | This Month: $month',
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    for (final record in records)
                      HistoryEntryCard(record: record),
                    const SizedBox(height: 12),
                    AsmitaButton(
                      label: 'Export Records',
                      icon: Icons.lock_outline,
                      onPressed: () => _export(context),
                    ),
                  ],
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Future<void> _export(BuildContext context) async {
    final controller = TextEditingController();
    final password = await showDialog<String>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Export password'),
        content: TextField(
          controller: controller,
          obscureText: true,
          decoration: const InputDecoration(labelText: 'Password'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, controller.text),
            child: const Text('Export'),
          ),
        ],
      ),
    );
    if (password == null || password.isEmpty) return;
    final path = await ScreeningStorageService().exportEncryptedCsv(password);
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Encrypted export saved: $path')),
      );
    }
  }
}
