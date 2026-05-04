import 'package:flutter/material.dart';
import '../../../theme/app_colors.dart';
import '../../../widgets/common/asmita_card.dart';

class MythFactCard extends StatelessWidget {
  const MythFactCard({super.key});

  @override
  Widget build(BuildContext context) => AsmitaCard(
        accent: AppColors.primary,
        child: Row(
          children: [
            const CircleAvatar(
              backgroundColor: AppColors.primaryPale,
              child: Icon(Icons.lightbulb_rounded, color: AppColors.primary),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    'Myth vs Fact',
                    style: TextStyle(fontWeight: FontWeight.w800),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Gentle movement is okay during periods if it feels comfortable.',
                  ),
                ],
              ),
            ),
          ],
        ),
      );
}
