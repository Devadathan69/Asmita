import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../theme/app_colors.dart';
import '../../../utils/cycle_calculator.dart';

class CycleRingWidget extends StatelessWidget {
  const CycleRingWidget({super.key, required this.info});
  final CycleDayInfo info;

  @override
  Widget build(BuildContext context) {
    final progress = info.day / (info.day + info.daysUntilPeriod);
    return SizedBox(
      width: 214,
      height: 214,
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox(
            width: 206,
            height: 206,
            child: CircularProgressIndicator(
              value: progress,
              strokeWidth: 18,
              strokeCap: StrokeCap.round,
              color: info.phase.color,
              backgroundColor: AppColors.primaryPale,
            ),
          ).animate().rotate(
                begin: -.035,
                end: 0,
                duration: 700.ms,
                curve: Curves.easeOutCubic,
              ),
          SizedBox(
            width: 160,
            height: 160,
            child: CircularProgressIndicator(
              value: .68,
              strokeWidth: 13,
              strokeCap: StrokeCap.round,
              color: AppColors.secondary.withOpacity(.72),
              backgroundColor: AppColors.coralPale,
            ),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '${info.day}',
                style: Theme.of(context).textTheme.displaySmall?.copyWith(
                      color: AppColors.primary,
                      fontSize: 48,
                    ),
              ),
              const Text(
                'DAY',
                style: TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.4,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
                decoration: BoxDecoration(
                  color: AppColors.primaryPale,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  info.phase.label,
                  style: const TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
