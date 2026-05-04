class Symptom {
  const Symptom({
    this.id,
    required this.name,
    required this.category,
    required this.icon,
  });
  final int? id;
  final String name;
  final String category;
  final String icon;
}
