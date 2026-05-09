import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../providers/asha_screening_provider.dart';
import '../../widgets/common/asmita_button.dart';
import '../../widgets/common/asmita_card.dart';
import '../../widgets/common/gradient_background.dart';
import 'widgets/breakdown_tile.dart';
import 'widgets/referral_letter_widget.dart';
import 'widgets/risk_score_card.dart';

class AshaResultScreen extends ConsumerWidget {
  const AshaResultScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(ashaScreeningProvider);
    final result = state.result;
    if (result == null) {
      return Scaffold(
        body: Center(
          child: AsmitaButton(
            label: 'Start Screening',
            onPressed: () => context.go('/asha/home'),
          ),
        ),
      );
    }
    final markers = [
      if (state.anNeckScore > .5) 'Neck metabolic marker',
      if (state.anKnuckle) 'Knuckle metabolic marker',
      if (state.periorbital) 'Periorbital marker',
      if (state.hirsutism) 'Hair-growth pattern',
      if (state.acneJawline) 'Jawline acne pattern',
      if (state.menstrualScore > 0) 'Cycle pattern',
    ];
    return Scaffold(
      body: GradientBackground(
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.all(18),
            children: [
              Text('Screening Result',
                  style: Theme.of(context).textTheme.headlineSmall),
              if (state.girlName != null || state.ageYears != null) ...[
                const SizedBox(height: 8),
                _ScreeningIdentityCard(
                  name: state.girlName,
                  ageYears: state.ageYears,
                ),
              ],
              const SizedBox(height: 16),
              RiskScoreCard(result: result),
              const SizedBox(height: 16),
              AsmitaCard(
                child: ExpansionTile(
                  tilePadding: EdgeInsets.zero,
                  title: const Text('See how score was calculated'),
                  children: [
                    BreakdownTile(
                      label: 'AN Neck',
                      value: result.breakdown['AN Neck'] ?? 0,
                      max: 15,
                    ),
                    BreakdownTile(
                      label: 'AN Knuckle',
                      value: result.breakdown['AN Knuckle'] ?? 0,
                      max: 15,
                    ),
                    BreakdownTile(
                      label: 'Periorbital',
                      value: result.breakdown['Periorbital'] ?? 0,
                      max: 10,
                    ),
                    BreakdownTile(
                      label: 'Hirsutism',
                      value: result.breakdown['Hirsutism'] ?? 0,
                      max: 5,
                    ),
                    BreakdownTile(
                      label: 'Menstrual',
                      value: result.breakdown['Menstrual'] ?? 0,
                      max: 25,
                    ),
                    BreakdownTile(
                      label: 'Acne Pattern',
                      value: result.breakdown['Acne Pattern'] ?? 0,
                      max: 10,
                    ),
                    BreakdownTile(
                      label: 'Sudden Onset',
                      value: result.breakdown['Sudden Onset'] ?? 0,
                      max: 5,
                    ),
                    const Divider(),
                    ListTile(
                      title: const Text('Total'),
                      trailing: Text('${result.score}/85'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              AsmitaButton(
                label: 'Generate Referral Letter',
                icon: Icons.description_outlined,
                onPressed: () => showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  builder: (_) => ReferralLetterWidget(
                    result: result,
                    positiveMarkers: markers,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              OutlinedButton(
                onPressed: () => showDialog<void>(
                  context: context,
                  builder: (_) => AlertDialog(
                    title: const Text('Follow-up enrolled'),
                    content: const Text(
                      'Configure WhatsApp follow-up in Settings to enable live messages.',
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('OK'),
                      ),
                    ],
                  ),
                ),
                child: const Text('Enroll in Follow-up'),
              ),
              TextButton(
                onPressed: () {
                  ref.read(ashaScreeningProvider.notifier).reset();
                  context.go('/asha/home');
                },
                child: const Text('New Screening'),
              ),
              TextButton(
                onPressed: () => context.go('/asha/history'),
                child: const Text('View History'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ScreeningIdentityCard extends StatelessWidget {
  const _ScreeningIdentityCard({this.name, this.ageYears});

  final String? name;
  final int? ageYears;

  @override
  Widget build(BuildContext context) {
    final parts = [
      if ((name ?? '').trim().isNotEmpty) name!.trim(),
      if (ageYears != null) '$ageYears years',
    ];
    return AsmitaCard(
      child: Row(
        children: [
          const CircleAvatar(child: Icon(Icons.person_outline_rounded)),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              parts.join(' • '),
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
        ],
      ),
    );
  }
}
