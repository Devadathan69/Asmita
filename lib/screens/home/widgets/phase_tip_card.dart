import 'package:flutter/material.dart';
import '../../../theme/app_colors.dart';
import '../../../utils/cycle_calculator.dart';
import '../../../widgets/common/asmita_card.dart';

class PhaseTipCard extends StatelessWidget {
  const PhaseTipCard({super.key, required this.phase});
  final CyclePhase phase;

  @override
  Widget build(BuildContext context) => AsmitaCard(
        accent: phase.color,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: phase.color.withOpacity(.13),
                  child: Icon(Icons.restaurant_rounded, color: phase.color),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Nutrition for ${phase.label}',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(CycleCalculator.nutritionTips(phase).first),
          ],
        ),
      );
}
