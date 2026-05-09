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
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: color.withOpacity(.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color, width: 2),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 104,
            height: 104,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color.withOpacity(.12),
              border: Border.all(color: color, width: 3),
            ),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '${result.score}',
                    style: TextStyle(
                      fontSize: 38,
                      height: .95,
                      fontWeight: FontWeight.w900,
                      color: color,
                    ),
                  ),
                  Text('of 85', style: Theme.of(context).textTheme.labelLarge),
                ],
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
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
                const SizedBox(height: 10),
                Text(
                  result.action,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 6),
                Text(
                  result.displayMessage,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
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
