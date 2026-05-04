import 'package:flutter/material.dart';
import '../../../theme/app_colors.dart';

class FlowSelector extends StatelessWidget {
  const FlowSelector({super.key, required this.value, required this.onChanged});
  final int value;
  final ValueChanged<int> onChanged;

  static const labels = ['None', 'Spotting', 'Light', 'Medium', 'Heavy'];

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Flow', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 12),
          Row(
            children: [
              for (var i = 0; i < labels.length; i++)
                Expanded(
                  child: Padding(
                    padding:
                        EdgeInsets.only(right: i == labels.length - 1 ? 0 : 8),
                    child: _FlowDrop(
                      label: labels[i],
                      level: i,
                      selected: value == i,
                      onTap: () => onChanged(i),
                    ),
                  ),
                ),
            ],
          ),
        ],
      );
}

class _FlowDrop extends StatelessWidget {
  const _FlowDrop({
    required this.label,
    required this.level,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final int level;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = level == 0 ? AppColors.textSecondary : AppColors.secondary;
    return InkWell(
      borderRadius: BorderRadius.circular(22),
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: selected ? color.withOpacity(.14) : AppColors.lilacMist,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: selected ? color : Colors.transparent),
        ),
        child: Column(
          children: [
            Icon(
              level == 0 ? Icons.water_drop_outlined : Icons.water_drop_rounded,
              color: color,
              size: 20 + level.toDouble() * 2,
            ),
            const SizedBox(height: 6),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 11,
                fontWeight: selected ? FontWeight.w900 : FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
