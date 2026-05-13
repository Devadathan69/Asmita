class UserProfile {
  UserProfile({
    this.id,
    this.name,
    this.dateOfBirth,
    this.heightCm,
    this.weightKg,
    this.avgCycleLength = 28,
    this.periodDuration = 5,
    this.isIrregular = false,
    this.lifeStage = 'menstruating',
    this.suspectsCyclePatternConcerns = 'not_sure',
    this.language = 'english',
    this.discreetMode = false,
    this.isPregnant = false,
    this.lastMenstrualPeriodForPregnancy,
    this.estimatedDueDate,
    this.highRiskPregnancy = false,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);

  final int? id;
  final String? name;
  final String? dateOfBirth;
  final double? heightCm;
  final double? weightKg;
  final int avgCycleLength;
  final int periodDuration;
  final bool isIrregular;
  final String lifeStage;
  final String suspectsCyclePatternConcerns;
  final String language;
  final bool discreetMode;
  final bool isPregnant;
  final String? lastMenstrualPeriodForPregnancy;
  final String? estimatedDueDate;
  final bool highRiskPregnancy;
  final DateTime createdAt;

  DateTime? get birthDate =>
      dateOfBirth == null ? null : DateTime.tryParse(dateOfBirth!);

  int? get age {
    final dob = birthDate;
    if (dob == null) return null;
    final today = DateTime.now();
    var years = today.year - dob.year;
    final birthdayThisYear = DateTime(today.year, dob.month, dob.day);
    if (today.isBefore(birthdayThisYear)) years--;
    return years;
  }

  double? get bmi {
    final height = heightCm;
    final weight = weightKg;
    if (height == null || weight == null || height <= 0 || weight <= 0) {
      return null;
    }
    final meters = height / 100;
    return weight / (meters * meters);
  }

  DateTime? get pregnancyLmp => lastMenstrualPeriodForPregnancy == null
      ? null
      : DateTime.tryParse(lastMenstrualPeriodForPregnancy!);

  DateTime? get dueDate =>
      estimatedDueDate == null ? null : DateTime.tryParse(estimatedDueDate!);

  int? get pregnancyWeek {
    if (!isPregnant) return null;
    final today = DateTime.now();
    int? week;
    final lmp = pregnancyLmp;
    final due = dueDate;
    if (lmp != null) {
      week = today.difference(lmp).inDays ~/ 7 + 1;
    } else if (due != null) {
      final weeksUntilDue = due.difference(today).inDays ~/ 7;
      week = 40 - weeksUntilDue;
    }
    if (week == null) return null;
    return week.clamp(1, 42);
  }

  int? get trimester {
    final week = pregnancyWeek;
    if (week == null) return null;
    if (week <= 13) return 1;
    if (week <= 27) return 2;
    return 3;
  }

  bool get canUsePregnancyMode => (age ?? 0) >= 18;

  bool get needsProfileCompletion =>
      dateOfBirth == null || heightCm == null || weightKg == null;

  UserProfile copyWith({
    int? id,
    String? name,
    String? dateOfBirth,
    double? heightCm,
    double? weightKg,
    int? avgCycleLength,
    int? periodDuration,
    bool? isIrregular,
    String? lifeStage,
    String? suspectsCyclePatternConcerns,
    String? language,
    bool? discreetMode,
    bool? isPregnant,
    String? lastMenstrualPeriodForPregnancy,
    String? estimatedDueDate,
    bool? highRiskPregnancy,
    DateTime? createdAt,
  }) {
    return UserProfile(
      id: id ?? this.id,
      name: name ?? this.name,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      heightCm: heightCm ?? this.heightCm,
      weightKg: weightKg ?? this.weightKg,
      avgCycleLength: avgCycleLength ?? this.avgCycleLength,
      periodDuration: periodDuration ?? this.periodDuration,
      isIrregular: isIrregular ?? this.isIrregular,
      lifeStage: lifeStage ?? this.lifeStage,
      suspectsCyclePatternConcerns:
          suspectsCyclePatternConcerns ?? this.suspectsCyclePatternConcerns,
      language: language ?? this.language,
      discreetMode: discreetMode ?? this.discreetMode,
      isPregnant: isPregnant ?? this.isPregnant,
      lastMenstrualPeriodForPregnancy: lastMenstrualPeriodForPregnancy ??
          this.lastMenstrualPeriodForPregnancy,
      estimatedDueDate: estimatedDueDate ?? this.estimatedDueDate,
      highRiskPregnancy: highRiskPregnancy ?? this.highRiskPregnancy,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
