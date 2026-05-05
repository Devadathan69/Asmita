import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';

import '../../../services/risk_engine.dart';
import '../../../widgets/common/asmita_button.dart';

class ReferralLetterWidget extends StatelessWidget {
  const ReferralLetterWidget({
    super.key,
    required this.result,
    required this.positiveMarkers,
  });

  final RiskResult result;
  final List<String> positiveMarkers;

  @override
  Widget build(BuildContext context) {
    final text = letterText();
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Referral Letter',
                style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 12),
            Container(
              constraints: const BoxConstraints(maxHeight: 360),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(18),
                color: Theme.of(context)
                    .colorScheme
                    .surfaceVariant
                    .withOpacity(.5),
              ),
              child: SingleChildScrollView(child: Text(text)),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: AsmitaButton(
                    label: 'Copy Text',
                    icon: Icons.copy,
                    onPressed: () =>
                        Clipboard.setData(ClipboardData(text: text)),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: AsmitaButton(
                    label: 'Share',
                    icon: Icons.share,
                    onPressed: () => Share.share(text),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String letterText() {
    final date = DateFormat('dd MMM yyyy').format(result.screenedAt);
    final markers = positiveMarkers.isEmpty
        ? 'No major markers noted'
        : positiveMarkers.map((m) => '- $m').join('\n');
    return '''
ASMITA SCREENING REFERRAL
Date: $date

Dear Doctor,

An adolescent girl has been screened using the Asmita AI screening tool by an ASHA worker.

Risk Score: ${result.score}/85 — ${result.tier}
Recommended Action: ${result.action}

Screening markers:
$markers

Please conduct metabolic/hormonal screening. This is a referral, not a clinical conclusion.

Asmita | Team Naayattu | MACE Kothamangalam
''';
  }
}
