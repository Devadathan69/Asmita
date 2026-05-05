import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../providers/asha_screening_provider.dart';
import '../../providers/language_provider.dart';
import '../../services/risk_engine.dart';
import '../../services/sarvam_service.dart';
import '../../widgets/common/asmita_button.dart';
import '../../widgets/common/asmita_card.dart';
import '../../widgets/common/gradient_background.dart';

class AshaMenstrualScreen extends ConsumerStatefulWidget {
  const AshaMenstrualScreen({super.key});

  @override
  ConsumerState<AshaMenstrualScreen> createState() =>
      _AshaMenstrualScreenState();
}

class _AshaMenstrualScreenState extends ConsumerState<AshaMenstrualScreen> {
  final answers = List.generate(3, (_) => TextEditingController());
  MenstrualScore? score;
  bool voiceAvailable = false;

  @override
  void initState() {
    super.initState();
    _checkVoice();
  }

  Future<void> _checkVoice() async {
    final connected = await Connectivity().checkConnectivity();
    final configured = await SarvamService().isConfigured;
    if (mounted) {
      setState(() => voiceAvailable =
          configured && !connected.contains(ConnectivityResult.none));
    }
  }

  @override
  Widget build(BuildContext context) {
    final lang = ref.watch(languageProvider).value?.name ?? 'english';
    final questions = _questions(lang);
    return Scaffold(
      body: GradientBackground(
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.all(18),
            children: [
              AppBar(title: const Text('Cycle Questions')),
              const Text('Ask the girl these questions in her language'),
              const SizedBox(height: 14),
              for (var i = 0; i < questions.length; i++) ...[
                Text(questions[i],
                    style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 8),
                TextFormField(
                  controller: answers[i],
                  minLines: 2,
                  maxLines: 4,
                  decoration: InputDecoration(
                    hintText: 'Type answer here',
                    suffixIcon: voiceAvailable
                        ? IconButton(
                            icon: const Icon(Icons.mic),
                            onPressed: () => ScaffoldMessenger.of(context)
                                .showSnackBar(const SnackBar(
                              content:
                                  Text('Voice input unavailable, please type'),
                            )),
                          )
                        : null,
                  ),
                  onChanged: (_) => _analyze(),
                ),
                if (voiceAvailable)
                  const Padding(
                    padding: EdgeInsets.only(top: 4, bottom: 12),
                    child: Text('Voice input (optional)'),
                  )
                else
                  const SizedBox(height: 12),
              ],
              if (score != null)
                AsmitaCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Pattern: ${score!.detected}',
                          style: Theme.of(context).textTheme.titleMedium),
                      Text('Score preview: ${score!.score}/25'),
                      const Text('Looks wrong? Edit above.'),
                    ],
                  ),
                ),
              const SizedBox(height: 18),
              AsmitaButton(
                label: 'Calculate Risk',
                icon: Icons.calculate,
                onPressed: _combined.trim().isEmpty
                    ? null
                    : () {
                        ref.read(ashaScreeningProvider.notifier).setMenstrual(
                              _combined,
                            );
                        context.go('/asha/processing');
                      },
              ),
            ],
          ),
        ),
      ),
    );
  }

  String get _combined => answers.map((c) => c.text).join('\n');

  void _analyze() {
    setState(() => score = MenstrualScorer().analyze(_combined));
  }

  List<String> _questions(String language) => switch (language) {
        'malayalam' => [
            'ആർത്തവം എത്ര ദിവസം കൂടുമ്പോൾ വരും?',
            'എല്ലാ മാസവും ക്രമമായി വരുന്നുണ്ടോ?',
            'ആർത്തവം എത്ര ദിവസം ഉണ്ടാകും?',
          ],
        'hindi' => [
            'मासिक धर्म कितने दिनों में आता है?',
            'क्या हर महीने नियमित आता है?',
            'मासिक धर्म कितने दिन रहता है?',
          ],
        'manglish' => [
            'Periods enthu divasam koodi varum?',
            'Ellaa maasavum regular aano?',
            'Periods enthu divasam kaanum?',
          ],
        _ => [
            'How many days between periods? (e.g. every 28 days)',
            'Is the cycle regular every month?',
            'How many days does the period last?',
          ],
      };
}
