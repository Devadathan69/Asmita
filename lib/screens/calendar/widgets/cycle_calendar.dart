import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../theme/app_colors.dart';
import '../../../utils/cycle_calculator.dart';
import '../../../widgets/common/asmita_card.dart';
import 'day_detail_sheet.dart';

class CycleCalendar extends StatelessWidget {
  const CycleCalendar({
    super.key,
    required this.lastPeriodStart,
    required this.avgCycleLength,
    required this.periodDuration,
  });

  final DateTime lastPeriodStart;
  final int avgCycleLength;
  final int periodDuration;

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final first = DateTime(now.year, now.month);
    final days = DateTime(now.year, now.month + 1, 0).day;
    final leadingBlanks = first.weekday % 7;
    final totalCells = leadingBlanks + days;
    final monthName = _monthName(now.month);

    return AsmitaCard(
      accent: AppColors.primary,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                '$monthName ${now.year}',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const Spacer(),
              _Legend(color: AppColors.menstruation, label: 'Period'),
              const SizedBox(width: 8),
              _Legend(color: AppColors.ovulation, label: 'Ovulation'),
            ],
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              for (final day in ['S', 'M', 'T', 'W', 'T', 'F', 'S'])
                Expanded(
                  child: Center(
                    child: Text(
                      day,
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 10),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              mainAxisSpacing: 9,
              crossAxisSpacing: 9,
            ),
            itemCount: totalCells,
            itemBuilder: (context, i) {
              if (i < leadingBlanks) return const SizedBox.shrink();
              final day = i - leadingBlanks + 1;
              final date = DateTime(first.year, first.month, day);
              final info = CycleCalculator.infoFor(
                date,
                lastPeriodStart,
                cycleLength: avgCycleLength,
                periodDuration: periodDuration,
              );
              final isToday = date.year == now.year &&
                  date.month == now.month &&
                  date.day == now.day;
              return _DayTile(
                day: day,
                info: info,
                isToday: isToday,
                onTap: () => showModalBottomSheet(
                  context: context,
                  showDragHandle: true,
                  isScrollControlled: true,
                  backgroundColor: Theme.of(context).colorScheme.surface,
                  builder: (_) => DayDetailSheet(date: date, info: info),
                ),
              ).animate(delay: (day * 16).ms).fadeIn().scale(
                    begin: const Offset(.92, .92),
                    duration: 260.ms,
                    curve: Curves.easeOutBack,
                  );
            },
          ),
        ],
      ),
    );
  }

  String _monthName(int month) => const [
        'January',
        'February',
        'March',
        'April',
        'May',
        'June',
        'July',
        'August',
        'September',
        'October',
        'November',
        'December',
      ][month - 1];
}

class _DayTile extends StatelessWidget {
  const _DayTile({
    required this.day,
    required this.info,
    required this.isToday,
    required this.onTap,
  });

  final int day;
  final CycleDayInfo info;
  final bool isToday;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        decoration: BoxDecoration(
          color: info.phase.color.withOpacity(isToday ? .2 : .1),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isToday ? info.phase.color : Colors.transparent,
            width: 2,
          ),
        ),
        child: Stack(
          children: [
            Center(
              child: Text(
                '$day',
                style: TextStyle(
                  color: isToday ? info.phase.color : AppColors.textPrimary,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            Positioned(
              right: 7,
              bottom: 7,
              child: Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  color: info.phase.color,
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Legend extends StatelessWidget {
  const _Legend({required this.color, required this.label});
  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 4),
        Text(label, style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }
}
