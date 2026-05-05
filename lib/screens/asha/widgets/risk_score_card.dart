import 'package:flutter/material.dart';

import '../../../services/risk_engine.dart';
import '../../../theme/app_colors.dart';

class RiskScoreCard extends StatelessWidget {
  const RiskScoreCard({super.key, required this.result});

  final RiskResult result;

  @override
  Widget build(BuildContext context) {
    final color = tierColor(result.color);
    return Container(
      width: double.infinity,
      height: 190,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: color.withOpacity(.15),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: color, width: 2),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            '${result.score}',
            style: TextStyle(
              fontSize: 48,
              fontWeight: FontWeight.w900,
              color: color,
            ),
          ),
          Text('/85', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              result.tier,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(result.action, textAlign: TextAlign.center),
        ],
      ),
    );
  }

  static Color tierColor(String color) => switch (color) {
        'green' => AppColors.success,
        'yellow' => AppColors.warning,
        'orange' => const Color(0xFFF97316),
        _ => AppColors.danger,
      };
}
