class UserProfile {
  UserProfile({
    this.id,
    this.name,
    this.dateOfBirth,
    this.avgCycleLength = 28,
    this.periodDuration = 5,
    this.isIrregular = false,
    this.lifeStage = 'menstruating',
    this.suspectsCyclePatternConcerns = 'not_sure',
    this.language = 'english',
    this.discreetMode = false,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);

  final int? id;
  final String? name;
  final String? dateOfBirth;
  final int avgCycleLength;
  final int periodDuration;
  final bool isIrregular;
  final String lifeStage;
  final String suspectsCyclePatternConcerns;
  final String language;
  final bool discreetMode;
  final DateTime createdAt;

  UserProfile copyWith({
    int? id,
    String? name,
    String? dateOfBirth,
    int? avgCycleLength,
    int? periodDuration,
    bool? isIrregular,
    String? lifeStage,
    String? suspectsCyclePatternConcerns,
    String? language,
    bool? discreetMode,
    DateTime? createdAt,
  }) {
    return UserProfile(
      id: id ?? this.id,
      name: name ?? this.name,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      avgCycleLength: avgCycleLength ?? this.avgCycleLength,
      periodDuration: periodDuration ?? this.periodDuration,
      isIrregular: isIrregular ?? this.isIrregular,
      lifeStage: lifeStage ?? this.lifeStage,
      suspectsCyclePatternConcerns:
          suspectsCyclePatternConcerns ?? this.suspectsCyclePatternConcerns,
      language: language ?? this.language,
      discreetMode: discreetMode ?? this.discreetMode,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
