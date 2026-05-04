import 'package:flutter/material.dart';
import '../../../theme/app_colors.dart';
import '../../../widgets/common/asmita_card.dart';

class QuickLogCard extends StatelessWidget {
  const QuickLogCard({super.key, required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => AsmitaCard(
        onTap: onTap,
        accent: AppColors.secondary,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Today's Log",
                style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 14),
            Row(
              children: const [
                _QuickItem(
                    Icons.water_drop_rounded, 'Flow', AppColors.secondary),
                _QuickItem(Icons.mood_rounded, 'Mood', AppColors.accent),
                _QuickItem(Icons.bolt_rounded, 'Energy', AppColors.primary),
                _QuickItem(Icons.add_rounded, 'More', AppColors.textSecondary),
              ],
            ),
          ],
        ),
      );
}

class _QuickItem extends StatelessWidget {
  const _QuickItem(this.icon, this.label, this.color);
  final IconData icon;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: color.withOpacity(.12),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }
}
