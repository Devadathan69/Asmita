import '../theme/app_colors.dart';

class CycleDayInfo {
  const CycleDayInfo({
    required this.phase,
    required this.day,
    required this.daysUntilPeriod,
  });
  final CyclePhase phase;
  final int day;
  final int daysUntilPeriod;
}

class CycleCalculator {
  static CycleDayInfo infoFor(
    DateTime date,
    DateTime lastPeriodStart, {
    int cycleLength = 28,
    int periodDuration = 5,
  }) {
    final days = date
        .difference(
          DateTime(
            lastPeriodStart.year,
            lastPeriodStart.month,
            lastPeriodStart.day,
          ),
        )
        .inDays;
    final day = ((days % cycleLength) + cycleLength) % cycleLength + 1;
    final phase = phaseForDay(
      day,
      cycleLength: cycleLength,
      periodDuration: periodDuration,
    );
    return CycleDayInfo(
      phase: phase,
      day: day,
      daysUntilPeriod: cycleLength - day + 1,
    );
  }

  static CyclePhase phaseForDay(
    int day, {
    int cycleLength = 28,
    int periodDuration = 5,
  }) {
    final ovulationDay = cycleLength - 14;
    if (day <= periodDuration) return CyclePhase.menstruation;
    if (day >= ovulationDay - 1 && day <= ovulationDay + 1)
      return CyclePhase.ovulation;
    if (day < ovulationDay) return CyclePhase.follicular;
    return CyclePhase.luteal;
  }

  static int movingAverage(List<int> lengths, {int fallback = 28}) {
    if (lengths.isEmpty) return fallback;
    final recent =
        lengths.length > 6 ? lengths.sublist(lengths.length - 6) : lengths;
    return (recent.reduce((a, b) => a + b) / recent.length).round().clamp(
          21,
          45,
        );
  }

  static List<String> nutritionTips(CyclePhase phase) => switch (phase) {
        CyclePhase.menstruation => const [
            'Warm kanji with moong dal can feel gentle on period days.',
            'Try iron-rich spinach thoran, dates, sesame, or ragi.',
            'Ginger tea may help you feel warmer and settled.',
            'Keep water nearby, especially in humid weather.',
            'Choose simple meals if your appetite feels low.',
          ],
        CyclePhase.follicular => const [
            'Sprouts, dosa with sambar, and curd rice support steady energy.',
            'Fresh coconut water and seasonal fruit can feel refreshing.',
            'Add protein like chana, egg, fish, paneer, or dal.',
            'A little movement may feel easier in this phase.',
            'Use this phase for meal prep if your body feels ready.',
          ],
        CyclePhase.ovulation => const [
            'Colorful vegetables, lemon rice, and chickpea salad fit this phase.',
            'Add zinc-rich pumpkin seeds or groundnuts.',
            'Hydrate well before travel or outdoor work.',
            'Choose balanced snacks when cravings rise.',
            'Listen to your body if energy feels high or sensitive.',
          ],
        CyclePhase.luteal => const [
            'Magnesium-rich banana, peanuts, ragi, and greens may support comfort.',
            'Try warm rasam, khichdi, or kanji when bloated.',
            'Reduce long gaps between meals to steady mood.',
            'A small jaggery-sesame snack can satisfy sweet cravings.',
            'Gentle walks and early sleep can help pre-period heaviness.',
          ],
      };
}
