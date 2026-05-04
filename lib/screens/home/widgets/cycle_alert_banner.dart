import 'package:flutter/material.dart';
import '../../../utils/irregularity_detector.dart';

class CycleAlertBanner extends StatelessWidget {
  const CycleAlertBanner({super.key, required this.cycleLengths});
  final List<int> cycleLengths;
  @override
  Widget build(BuildContext context) {
    final result = IrregularityDetector.analyze(cycleLengths);
    if (!result.isWorthDiscussing) return const SizedBox.shrink();
    return Card(
      child: ListTile(
        leading: const Icon(Icons.info_outline),
        title: const Text('Cycle pattern note'),
        subtitle: const Text(
          'Your recent cycle patterns are worth discussing with a doctor or ASHA worker.',
        ),
      ),
    );
  }
}
