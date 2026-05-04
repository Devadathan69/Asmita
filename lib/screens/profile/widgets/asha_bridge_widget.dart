import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../../widgets/common/asmita_card.dart';

class AshaBridgeWidget extends StatelessWidget {
  const AshaBridgeWidget({super.key});
  @override
  Widget build(BuildContext context) {
    final payload = jsonEncode({
      'avg_cycle_length': 28,
      'variability': 0,
      'frequent_symptoms': [],
      'regularity_score': 80,
      'expires_at':
          DateTime.now().add(const Duration(minutes: 10)).toIso8601String(),
    });
    return AsmitaCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('ASHA Bridge', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 12),
          Center(child: QrImageView(data: payload, size: 160)),
          const Text(
            'Anonymous QR. No personal details. Expires in 10 minutes.',
          ),
        ],
      ),
    );
  }
}
