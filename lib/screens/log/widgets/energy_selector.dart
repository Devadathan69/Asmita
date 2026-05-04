import 'package:flutter/material.dart';
import '../../../theme/app_colors.dart';

class EnergySelector extends StatelessWidget {
  const EnergySelector({
    super.key,
    required this.value,
    required this.onChanged,
  });
  final int value;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text('Energy', style: Theme.of(context).textTheme.titleMedium),
              const Spacer(),
              Text(
                '$value/5',
                style: const TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: List.generate(
              5,
              (i) => Expanded(
                child: Padding(
                  padding: EdgeInsets.only(right: i == 4 ? 0 : 8),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(18),
                    onTap: () => onChanged(i + 1),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 220),
                      height: 56,
                      decoration: BoxDecoration(
                        color: i < value
                            ? AppColors.primary.withOpacity(.14)
                            : AppColors.lilacMist,
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: Icon(
                        i < value
                            ? Icons.battery_full_rounded
                            : Icons.battery_0_bar_rounded,
                        color: i < value
                            ? AppColors.primary
                            : AppColors.textSecondary,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      );
}
