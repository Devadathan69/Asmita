class DailyLog {
  DailyLog({
    this.id,
    required this.date,
    this.flowLevel = 0,
    this.mood,
    this.energyLevel,
    this.painLocations = const [],
    this.painIntensity = 0,
    this.symptoms = const [],
    this.notes,
    this.temperature,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);

  final int? id;
  final DateTime date;
  final int flowLevel;
  final String? mood;
  final int? energyLevel;
  final List<String> painLocations;
  final int painIntensity;
  final List<String> symptoms;
  final String? notes;
  final double? temperature;
  final DateTime createdAt;
}
