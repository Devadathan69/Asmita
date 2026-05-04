class CycleEntry {
  CycleEntry({
    this.id,
    required this.startDate,
    this.endDate,
    this.cycleLength,
    this.periodLength,
    this.notes,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
  final int? id;
  final DateTime startDate;
  final DateTime? endDate;
  final int? cycleLength;
  final int? periodLength;
  final String? notes;
  final DateTime createdAt;
}
