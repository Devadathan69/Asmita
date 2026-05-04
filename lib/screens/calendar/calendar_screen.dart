import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/cycle_provider.dart';
import '../../providers/user_profile_provider.dart';
import '../../theme/app_colors.dart';
import '../../utils/cycle_calculator.dart';
import '../../widgets/common/asmita_card.dart';
import '../../widgets/common/asmita_screen_header.dart';
import '../../widgets/common/gradient_background.dart';
import 'widgets/cycle_calendar.dart';
import 'widgets/day_detail_sheet.dart';

class CalendarScreen extends ConsumerWidget {
  const CalendarScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(userProfileProvider).value;
    final cycles = ref.watch(cycleProvider).value ?? const [];
    final lastStart = cycles.isEmpty ? DateTime.now() : cycles.last.startDate;
    final todayInfo = CycleCalculator.infoFor(
      DateTime.now(),
      lastStart,
      cycleLength: profile?.avgCycleLength ?? 28,
      periodDuration: profile?.periodDuration ?? 5,
    );
    final calendar = CycleCalendar(
      lastPeriodStart: lastStart,
      avgCycleLength: profile?.avgCycleLength ?? 28,
      periodDuration: profile?.periodDuration ?? 5,
    );

    return Scaffold(
      body: GradientBackground(
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final header = Column(
                children: [
                  const AsmitaScreenHeader(
                    title: 'Calendar',
                    subtitle: 'Cycle phases at a glance',
                  ),
                  const SizedBox(height: 16),
                  AsmitaCard(
                    accent: todayInfo.phase.color,
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 30,
                          backgroundColor:
                              todayInfo.phase.color.withOpacity(.14),
                          child: Icon(
                            Icons.auto_awesome_rounded,
                            color: todayInfo.phase.color,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                todayInfo.phase.label,
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                              Text(
                                'Day ${todayInfo.day} • ${todayInfo.daysUntilPeriod} days to period',
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              );

              if (constraints.maxWidth > 700) {
                return Padding(
                  padding: const EdgeInsets.fromLTRB(18, 12, 18, 100),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                          child: ListView(children: [
                        header,
                        const SizedBox(height: 16),
                        calendar
                      ])),
                      const SizedBox(width: 16),
                      Expanded(
                        child: AsmitaCard(
                          accent: AppColors.primary,
                          child: DayDetailSheet(
                            date: DateTime.now(),
                            info: todayInfo,
                            embedded: true,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }

              return ListView(
                padding: const EdgeInsets.fromLTRB(18, 12, 18, 112),
                children: [
                  header,
                  const SizedBox(height: 16),
                  calendar,
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
